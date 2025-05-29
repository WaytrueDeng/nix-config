# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  pkgs-stable,
  self,
  ...
}: {
     environment.systemPackages =
        [ pkgs.vim
        ];
   
      # Necessary for using flakes on this system.                                                       
      nix.settings.experimental-features = "nix-command flakes";                                         
                                                                                                         
      # Enable alternative shell support in nix-darwin.                                                  
      # programs.fish.enable = true;                                                                     
  
      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;                                  
    
      # Used for backwards compatibility, please read the changelog before changing.                     
      # $ darwin-rebuild changelog                                                                       
      system.stateVersion = 6;                                                                           
                                                                                                         
      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
}
