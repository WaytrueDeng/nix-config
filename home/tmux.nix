{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 100000;
    prefix = "C-s"; # 将前缀键改为 Ctrl+s
    mouse = true;
    keyMode = "vi";
    escapeTime = 10;
    shell = "${pkgs.fish}/bin/fish"; # 如果你使用 zsh

    extraConfig = ''
              # 基础设置
              set -g default-terminal "screen-256color"
      	    set -g default-shell "${pkgs.fish}/bin/fish"
          set -g default-command "${pkgs.fish}/bin/fish"
              set -as terminal-features ",xterm-256color:RGB"
              set -g status-position top
              set -sg escape-time 10
              set -g allow-passthrough on
            set -ga update-environment TERM
            set -ga update-environment TERM_PROGRA
      
              # 快捷键绑定
              bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
      
              # 窗格导航 (vim 风格)
              bind-key h select-pane -L
              bind-key j select-pane -D
              bind-key k select-pane -U
              bind-key l select-pane -R
      
              # 窗格分割
              bind v split-window -h -c "#{pane_current_path}"
              bind - split-window -v -c "#{pane_current_path}"
      
              # 窗格调整大小
              bind -r H resize-pane -L 5
              bind -r J resize-pane -D 5
              bind -r K resize-pane -U 5
              bind -r L resize-pane -R 5
      
              # 窗口管理
              bind c new-window -c "#{pane_current_path}"
              bind n next-window
              bind p previous-window
      
              # 复制模式
              bind Enter copy-mode
              bind -T copy-mode-vi v send-keys -X begin-selection
              bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -selection clipboard"
              bind -T copy-mode-vi Escape send-keys -X cancel
      
              # Catppuccin 主题配置
              set -g @catppuccin_flavour 'mocha'  # latte, frappe, macchiato, mocha
      
              # 窗口配置
              set -g @catppuccin_window_left_separator ""
              set -g @catppuccin_window_right_separator " "
              set -g @catppuccin_window_middle_separator " █"
              set -g @catppuccin_window_number_position "right"
              set -g @catppuccin_window_default_fill "number"
              set -g @catppuccin_window_default_text "#W"
              set -g @catppuccin_window_current_fill "number"
              set -g @catppuccin_window_current_text "#W"
      
              # 状态栏配置
              set -g @catppuccin_status_modules_right "directory session date_time"
              set -g @catppuccin_status_left_separator " "
              set -g @catppuccin_status_right_separator ""
              set -g @catppuccin_status_right_separator_inverse "no"
              set -g @catppuccin_status_fill "icon"
              set -g @catppuccin_status_connect_separator "no"
      
              # 目录显示
              set -g @catppuccin_directory_text "#{pane_current_path}"
      
              # 日期时间格式
              set -g @catppuccin_date_time "%Y-%m-%d %H:%M"
    '';

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
        '';
      }
      sensible
      vim-tmux-navigator
      yank
      resurrect
      continuum
    ];
  };
}
