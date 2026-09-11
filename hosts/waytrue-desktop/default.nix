{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  gpuSwitch = pkgs.writeShellScriptBin "gpu-switch" ''
    set -euo pipefail

    PATH=${lib.makeBinPath [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.gnused
      pkgs.kmod
      pkgs.libvirt
      pkgs.pciutils
      pkgs.procps
      pkgs.psmisc
      pkgs.systemd
    ]}:$PATH

    VM="win10"
    GPU="0000:01:00.0"
    AUDIO="0000:01:00.1"
    DEFAULT_HUGEPAGES_2M="8192"

    die() {
      echo "gpu-switch: $*" >&2
      exit 1
    }

    need_root() {
      [ "$(id -u)" -eq 0 ] || die "please run as root, for example: sudo gpu-switch $*"
    }

    driver_of() {
      local dev="$1"
      if [ -L "/sys/bus/pci/devices/$dev/driver" ]; then
        basename "$(readlink "/sys/bus/pci/devices/$dev/driver")"
      else
        echo "none"
      fi
    }

    override_of() {
      local dev="$1"
      if [ -f "/sys/bus/pci/devices/$dev/driver_override" ]; then
        local value
        value="$(cat "/sys/bus/pci/devices/$dev/driver_override")"
        case "$value" in
          ""|"(null)") echo "none" ;;
          *) echo "$value" ;;
        esac
      else
        echo "unsupported"
      fi
    }

    vm_state() {
      virsh -c qemu:///system domstate "$VM" 2>/dev/null || echo "not found"
    }

    wait_vm_stopped() {
      local timeout="''${1:-60}"
      local state

      state="$(vm_state)"
      case "$state" in
        "shut off"|"not found")
          return 0
          ;;
      esac

      echo "Shutting down $VM ..."
      virsh -c qemu:///system shutdown "$VM" >/dev/null || true

      while [ "$timeout" -gt 0 ]; do
        state="$(vm_state)"
        case "$state" in
          "shut off"|"not found")
            return 0
            ;;
        esac
        sleep 1
        timeout=$((timeout - 1))
      done

      die "$VM is still running. Shut it down from Windows or run: sudo virsh -c qemu:///system destroy $VM"
    }

    show_users() {
      local shown=0
      for path in /dev/nvidia* /dev/dri/by-path/pci-$GPU-*; do
        [ -e "$path" ] || continue
        shown=1
        fuser -v "$path" 2>/dev/null || true
      done
      [ "$shown" -eq 1 ] || true
    }

    has_users() {
      local path
      for path in /dev/nvidia* /dev/dri/by-path/pci-$GPU-*; do
        [ -e "$path" ] || continue
        if fuser "$path" >/dev/null 2>&1; then
          return 0
        fi
      done
      return 1
    }

    kill_users() {
      for path in /dev/nvidia* /dev/dri/by-path/pci-$GPU-*; do
        [ -e "$path" ] || continue
        fuser -k -9 "$path" 2>/dev/null || true
      done
    }

    unbind_current_driver() {
      local dev="$1"
      local driver
      driver="$(driver_of "$dev")"

      [ "$driver" != "none" ] || return 0
      echo "$dev" > "/sys/bus/pci/devices/$dev/driver/unbind"
    }

    bind_with_override() {
      local dev="$1"
      local driver="$2"

      echo "$driver" > "/sys/bus/pci/devices/$dev/driver_override"
      echo "$dev" > /sys/bus/pci/drivers_probe
    }

    clear_override() {
      local dev="$1"
      echo "" > "/sys/bus/pci/devices/$dev/driver_override"
    }

    unload_nvidia_modules() {
      modprobe -r nvidia_drm nvidia_uvm nvidia_modeset nvidia
    }

    load_nvidia_compute_modules() {
      modprobe nvidia
      modprobe nvidia_uvm
    }

    compact_memory() {
      sync
      echo 3 > /proc/sys/vm/drop_caches
      echo 1 > /proc/sys/vm/compact_memory
    }

    hugepages_on() {
      local pages="''${1:-$DEFAULT_HUGEPAGES_2M}"
      compact_memory
      sysctl -w "vm.nr_hugepages=$pages" >/dev/null
      echo "2M hugepages: $(cat /proc/sys/vm/nr_hugepages)"
    }

    hugepages_off() {
      sysctl -w vm.nr_hugepages=0 >/dev/null
      if [ -e /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages ]; then
        echo 0 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages || true
      fi
      echo "2M hugepages: $(cat /proc/sys/vm/nr_hugepages)"
    }

    to_vm() {
      local kill=0
      local start=1

      while [ "$#" -gt 0 ]; do
        case "$1" in
          --kill-users) kill=1 ;;
          --no-start) start=0 ;;
          *) die "unknown to-vm option: $1" ;;
        esac
        shift
      done

      need_root to-vm

      if [ "$kill" -eq 1 ]; then
        kill_users
      else
        echo "Checking NVIDIA users ..."
        show_users
        if has_users; then
          die "NVIDIA is still in use. Close those processes or rerun with: sudo gpu-switch to-vm --kill-users"
        fi
      fi

      unload_nvidia_modules || die "failed to unload NVIDIA modules. Check users with: sudo gpu-switch status"
      modprobe vfio-pci

      for dev in $GPU $AUDIO; do
        unbind_current_driver "$dev"
        bind_with_override "$dev" vfio-pci
      done

      if [ "$start" -eq 1 ]; then
        virsh -c qemu:///system start "$VM" || true
      fi

      status
    }

    to_host() {
      need_root to-host
      wait_vm_stopped 60

      clear_override "$GPU"
      unbind_current_driver "$GPU"

      load_nvidia_compute_modules

      echo "$GPU" > /sys/bus/pci/drivers_probe

      bind_with_override "$AUDIO" vfio-pci

      hugepages_off || true
      status
    }

    status() {
      echo "VM $VM: $(vm_state)"
      for dev in $GPU $AUDIO; do
        printf '%s driver=%s override=%s\n' "$dev" "$(driver_of "$dev")" "$(override_of "$dev")"
      done
      echo "2M hugepages: $(cat /proc/sys/vm/nr_hugepages)"
      if command -v nvidia-smi >/dev/null 2>&1; then
        nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null || true
      fi
    }

    usage() {
      cat <<'EOF'
    Usage:
      gpu-switch status
      sudo gpu-switch to-vm [--kill-users] [--no-start]
      sudo gpu-switch to-host
      sudo gpu-switch hugepages-on [pages]
      sudo gpu-switch hugepages-off

    Devices:
      GPU   0000:01:00.0
      Audio 0000:01:00.1
    EOF
    }

    case "''${1:-}" in
      status) status ;;
      to-vm) shift; to_vm "$@" ;;
      to-host) to_host ;;
      hugepages-on) need_root hugepages-on; hugepages_on "''${2:-}" ;;
      hugepages-off) need_root hugepages-off; hugepages_off ;;
      *) usage; exit 1 ;;
    esac
  '';
in {
  imports = [
    ../../modules/nixos/common.nix
    ../../os/hardware-configuration-desktop.nix
  ];

  xdg.portal = {
    enable = lib.mkDefault true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.niri = {
      "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
    };
  };

  services.displayManager.ly.enable = true;
  users.groups.waytrue = {};
  users.users.waytrue = {
    group = "waytrue";
    extraGroups = ["libvirtd"];
  };

  environment.etc."gitconfig".text = ''
    [safe]
      directory = /home/waytrue/Documents/nix-config
  '';

  environment.systemPackages = [
    pkgs.clash-verge-rev
    pkgs.looking-glass-client
    gpuSwitch
    config.boot.kernelPackages.nvidiaPackages.stable
    inputs.logseq-nightly.packages.${pkgs.system}.logseq
  ];

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu.vhostUserPackages = with pkgs; [virtiofsd];
  };
  boot.extraModulePackages = [
    config.boot.kernelPackages.nvidiaPackages.stable
  ];
  hardware.nvidia = {
    modesetting.enable = false;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaSettings = false;
  };
  programs.virt-manager.enable = true;
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 waytrue libvirtd -"
  ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ENV{ID_PART_TABLE_UUID}=="fb5cb324-d5d3-4464-b2ad-ea6e949ed4db", TAG+="systemd", ENV{SYSTEMD_WANTS}+="usb-redirect-win10@%k.service"
  '';

  systemd.services."usb-redirect-win10@" = {
    description = "Redirect USB disk %I to Win10 VM";
    after = ["libvirtd.service"];
    requires = ["libvirtd.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "usb-redirect-win10" ''
        set -eu

        vm="win10"
        dev="/dev/$1"

        ${pkgs.udisks2}/bin/udisksctl unmount -b "$dev" >/dev/null 2>&1 || true
        for partition in /sys/class/block/"$1"/"$1"*; do
          [ -e "$partition" ] || continue
          ${pkgs.udisks2}/bin/udisksctl unmount -b "/dev/$(basename "$partition")" >/dev/null 2>&1 || true
        done

        path="$(${pkgs.systemd}/bin/udevadm info -q path -n "$dev")"
        sys="/sys$path"

        while [ "$sys" != "/sys" ]; do
          if [ -f "$sys/busnum" ] && [ -f "$sys/devnum" ]; then
            bus="$(cat "$sys/busnum")"
            usbdev="$(cat "$sys/devnum")"
            break
          fi
          sys="$(dirname "$sys")"
        done

        if [ -z "''${bus:-}" ] || [ -z "''${usbdev:-}" ]; then
          echo "Could not find parent USB device for $dev" >&2
          exit 1
        fi

        xml="$(mktemp)"
        trap 'rm -f "$xml"' EXIT
        cat > "$xml" <<EOF
        <hostdev mode='subsystem' type='usb' managed='yes'>
          <source>
            <address bus='$bus' device='$usbdev'/>
          </source>
        </hostdev>
        EOF

        ${pkgs.libvirt}/bin/virsh -c qemu:///system attach-device "$vm" "$xml" --live
      ''} %I";
    };
  };

}
