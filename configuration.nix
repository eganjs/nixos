/* vim: set ai et sw=2 sts=2 : */
{ config, pkgs, ... }:
let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "8def3835111f0b16850736aa210ca542fcd02af6";
    ref = "release-19.03";
  };
  polybar-custom = pkgs.polybar.override {
    i3GapsSupport = true;
    pulseSupport = true;
  };
in
{
  imports =
    [
      ./hardware-configuration.nix
      "${home-manager}/nixos"
    ];

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };


  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "overture";
  networking.wireless.enable = true;

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "uk";
    defaultLocale = "en_GB.UTF-8";
  };

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [
    wget
    vim
    git
  ];

  networking.firewall.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  environment.pathsToLink = [ "/libexec" ];

  services = {
    xserver = {
      enable = true;
      layout = "gb";
      libinput.enable = true;

      displayManager.lightdm.enable = true;

      desktopManager = {
        default = "xfce";
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [
          dmenu
          i3status
          i3lock
        ];
      };
    };

    redshift = {
      enable = true;
      latitude = "51.5";
      longitude = "0.13";
    };
  };

  systemd.services.redshift.enable = true;

  nixpkgs.config.pulseaudio = true;

  users.users.eganjs = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager.users.eganjs = {
    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      dejavu_fonts
      firejail
      polybar-custom
      urxvt_perls
      xclip
    ];

    xdg = {
      enable = true;

      configFile.userDirs = {
        target = "user-dirs.dirs";
        text = ''
          XDG_DESKTOP_DIR="\$HOME/bar"
          XDG_DOCUMENTS_DIR="\$HOME/rec"
          XDG_DOWNLOAD_DIR="\$HOME/net"
          XDG_MUSIC_DIR="\$HOME/mus"
          XDG_PICTURES_DIR="\$HOME/img"
          XDG_PUBLICSHARE_DIR="\$HOME/pub"
          XDG_TEMPLATES_DIR="\$HOME/tmp"
          XDG_VIDEOS_DIR="\$HOME/vid"
          XDG_DEVELOPMENT_DIR="\$HOME/dev"
        '';
      };

      dataFile.background = {
        target = "~/.background-image";
        source = pkgs.fetchFromGitHub {
          owner = "LaniJW";
          repo = "linux-pictures";
          rev = "6c05ed677c31fa1fb97087008e65123678e66fc9";
          sha256 = "1paq9ngj46lgv2a6ig0mkarijkqx3a1r7gs2fax3yyxpq08n2hd5";
        } + "/walls/solarized-dark/solarized-wallpaper-java.png";
      };

      configFile.i3 = {
        target = "i3/config";
        text = ''
          ### i3 config

          font pango:monospace 8

          set $mod Mod4
          set $terminal i3-sensible-terminal;
          set $browser firejail firefox

          set $left h
          set $down j
          set $up k
          set $right l

          set $display1 Virtual1
          set $display2 Virtual2
          set $display3 Virtual3

          bindsym $mod+Shift+c reload
          bindsym $mod+Shift+r restart

          # Use Mouse+$mod to drag floating windows to their wanted position
          floating_modifier $mod

          ### styling

          gaps outer 2
          for_window [class="^.*"] border pixel 2

          new_window 1pixel
          new_float 1pixel
          hide_edge_borders both
          popup_during_fullscreen smart
          exec border none

          client.focused          #002b36 #586e75 #fdf6e3 #268bd2
          client.focused_inactive #002b36 #073642 #839496 #073642
          client.unfocused        #002b36 #073642 #839496 #073642
          client.urgent           #002b36 #dc322f #fdf6e3 #002b36

          ### Always run

          exec_always --no-startup-id ~/.config/polybar/launch.sh
          exec_always --no-startup-id xrdb -merge ~/.Xresources

          ### Bindings

          bindsym Control+q exec echo "Masking firefox's ctrl+q binding"

          # kill focused window
          bindsym $mod+Shift+q kill

          # start dmenu (a program launcher)
          bindsym $mod+d exec --no-startup-id i3-dmenu-desktop

          ### Applications

          bindsym $mod+Return exec $terminal
          bindsym $mod+w exec $browser

          ### Container/Window control

          # focus
          bindsym $mod+$left focus left
          bindsym $mod+$down focus down
          bindsym $mod+$up focus up
          bindsym $mod+$right focus right

          bindsym $mod+Left focus left
          bindsym $mod+Down focus down
          bindsym $mod+Up focus up
          bindsym $mod+Right focus right

          # move
          bindsym $mod+Shift+$left move left
          bindsym $mod+Shift+$down move down
          bindsym $mod+Shift+$up move up
          bindsym $mod+Shift+$right move right

          bindsym $mod+Shift+Left move left
          bindsym $mod+Shift+Down move down
          bindsym $mod+Shift+Up move up
          bindsym $mod+Shift+Right move right

          # size
          bindsym $mod+Mod1+Up    resize shrink height 10 px or 1 ppt
          bindsym $mod+Mod1+Down  resize grow   height 10 px or 1 ppt
          bindsym $mod+Mod1+Left  resize shrink width  10 px or 1 ppt
          bindsym $mod+Mod1+Right resize grow   width  10 px or 1 ppt

          # split
          bindsym $mod+x split toggle

          # fullscreen
          bindsym $mod+Shift+f fullscreen toggle

          # layout toggle
          bindsym $mod+e layout toggle
          bindsym $mod+q layout toggle split

          # tiling/floating
          bindsym $mod+Shift+space floating toggle
          bindsym $mod+space focus mode_toggle

          # parent/child group selection
          bindsym $mod+a focus parent
          bindsym $mod+Shift+a focus child

          ### Workspace Bindings

          set $ws01  "1"
          set $wsb01 "1"
          set $ws02  "2"
          set $wsb02 "2"
          set $ws03  "3"
          set $wsb03 "3"
          set $ws04  "4"
          set $wsb04 "4"
          set $ws05  "5"
          set $wsb05 "5"
          set $ws06  "6"
          set $wsb06 "6"
          set $ws07  "7"
          set $wsb07 "7"
          set $ws08  "8"
          set $wsb08 "8"

          exec --no-startup-id i3-msg "workspace $ws01"

          workspace $ws01 output $display1
          workspace $ws02 output $display1
          workspace $ws03 output $display1
          workspace $ws04 output $display1
          workspace $ws05 output $display2
          workspace $ws06 output $display2
          workspace $ws07 output $display2
          workspace $ws08 output $display2

          bindsym $mod+$wsb01 workspace $ws01
          bindsym $mod+$wsb02 workspace $ws02
          bindsym $mod+$wsb03 workspace $ws03
          bindsym $mod+$wsb04 workspace $ws04
          bindsym $mod+$wsb05 workspace $ws05
          bindsym $mod+$wsb06 workspace $ws06
          bindsym $mod+$wsb07 workspace $ws07
          bindsym $mod+$wsb08 workspace $ws08

          bindsym $mod+Shift+$wsb01 move container to workspace $ws01; workspace $ws01
          bindsym $mod+Shift+$wsb02 move container to workspace $ws02; workspace $ws02
          bindsym $mod+Shift+$wsb03 move container to workspace $ws03; workspace $ws03
          bindsym $mod+Shift+$wsb04 move container to workspace $ws04; workspace $ws04
          bindsym $mod+Shift+$wsb05 move container to workspace $ws05; workspace $ws05
          bindsym $mod+Shift+$wsb06 move container to workspace $ws06; workspace $ws06
          bindsym $mod+Shift+$wsb07 move container to workspace $ws07; workspace $ws07
          bindsym $mod+Shift+$wsb08 move container to workspace $ws08; workspace $ws08

          bindsym $mod+Tab workspace next
          bindsym $mod+Shift+Tab workspace prev

          ### Mode: System

          set $system "system: (l) lock, (shift+e) logout, (shift+r) reboot, (shift+s) shutdown"
          mode $system {
                  bindsym l exec i3lock-fancy, mode "default"
                  bindsym Shift+e exec i3-msg exit, mode "default"
                  bindsym Shift+r exec systemctl reboot, mode "default"
                  bindsym Shift+s exec systemctl -i poweroff, mode "default"

                  bindsym Return mode "default"
                  bindsym Escape mode "default"
          }

          bindsym Control+$mod+Delete mode $system

          ### Mode: Resize

          mode "resize" {
                  bindsym $left resize shrink width 10 px or 1 ppt
                  bindsym $down resize grow height 10 px or 1 ppt
                  bindsym $up resize shrink height 10 px or 1 ppt
                  bindsym $right resize grow width 10 px or 1 ppt

                  bindsym Left resize shrink width 10 px or 1 ppt
                  bindsym Down resize grow height 10 px or 1 ppt
                  bindsym Up resize shrink height 10 px or 1 ppt
                  bindsym Right resize grow width 10 px or 1 ppt

                  bindsym Return mode "default"
                  bindsym Escape mode "default"
          }

          bindsym $mod+r mode "resize"
        '';
      };

      configFile.polybarLaunchScript = {
        target = "polybar/launch.sh";
        executable = true;
        text = ''
          #!/usr/bin/env bash

          # Terminate already running bar instances
          pkill polybar

          # Wait until the processes have been shut down
          while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

          # Launch Polybar, using default config location ~/.config/polybar/config
          polybar union &

          echo "Polybar launched..."
        '';
      };

      configFile.polybar = {
        target = "polybar/config";
        text = ''
          [bar/union]
          monitor = eDP-1

          width = 100%
          height = 18

          background = #002b36
          foreground = #839496

          line-color = #fff
          line-size = 1

          module-margin = 1

          font-0 = Monospace:size=10;1

          modules-left = i3
          modules-center = date
          modules-right = wireless-network volume backlight cpu memory battery

          [module/i3]
          type = internal/i3
          pin-workspaces = true
          strip-wsnumbers = false
          index-sort = true
          enable-click = true
          fuzzy-match = true

          ws-icon-default = 
          format = <label-state><label-mode>
          label-mode = %mode%
          label-mode-padding = 2
          label-focused = %name%
          label-focused-padding = 2
          label-unfocused = %name%
          label-unfocused-padding = 2
          label-visible = %name%
          label-visible-padding = 2
          label-urgent = %name%
          label-urgent-padding = 2
          label-mode-underline = #bf616a
          label-focused-underline = #839496
          label-visible-underline = #b48ead
          label-urgent-underline = #bf616a

          [module/date]
          type = internal/date
          date = %A, %d %B %Y %H:%M:%S

          [module/wireless-network]
          type = internal/network
          interface = wlp1s0
          interval = 10
          ping-interval = 10

          format-connected = <label-connected> <ramp-signal>
          format-disconnected = <label-disconnected>
          format-packetloss = <label-packetloss>

          label-connected = %essid%
          label-disconnected = NO NETWORK
          label-packetloss = %essid% !

          ramp-signal-0 = ▁
          ramp-signal-1 = ▂
          ramp-signal-2 = ▃
          ramp-signal-3 = ▄
          ramp-signal-4 = ▅
          ramp-signal-5 = ▆
          ramp-signal-6 = ▇
          ramp-signal-7 = █

          ramp-signal-foreground = #2aa198

          [module/volume]
          type = internal/pulseaudio
          interval = 3
          use-ui-max = true

          format-volume = <label-volume> <ramp-volume>
          label-volume = VOL

          format-muted = <label-muted> <ramp-volume>
          label-muted = MUT
          label-muted-foreground = #666

          ramp-volume-0 = ▁
          ramp-volume-1 = ▂
          ramp-volume-2 = ▃
          ramp-volume-3 = ▄
          ramp-volume-4 = ▅
          ramp-volume-5 = ▆
          ramp-volume-6 = ▇
          ramp-volume-7 = █

          ramp-volume-foreground = #2aa198

          [module/backlight]
          type = internal/xbacklight
          format = <label>
          label = BCK

          [module/cpu]
          type = internal/cpu
          interval = 0.5
          format = <label> <ramp-coreload>
          label = CPU

          ramp-coreload-spacing = 0

          ramp-coreload-0 = ▁
          ramp-coreload-1 = ▂
          ramp-coreload-2 = ▃
          ramp-coreload-3 = ▄
          ramp-coreload-4 = ▅
          ramp-coreload-5 = ▆
          ramp-coreload-6 = ▇
          ramp-coreload-7 = █

          ramp-coreload-foreground = #2aa198

          [module/memory]
          type = internal/memory
          format = <label> <ramp-used><ramp-swap-used>
          label = RAM

          ramp-used-0 = ▁
          ramp-used-1 = ▂
          ramp-used-2 = ▃
          ramp-used-3 = ▄
          ramp-used-4 = ▅
          ramp-used-5 = ▆
          ramp-used-6 = ▇
          ramp-used-7 = █

          ramp-used-foreground = #2aa198

          ramp-swap-used-0 = ▁
          ramp-swap-used-1 = ▂
          ramp-swap-used-2 = ▃
          ramp-swap-used-3 = ▄
          ramp-swap-used-4 = ▅
          ramp-swap-used-5 = ▆
          ramp-swap-used-6 = ▇
          ramp-swap-used-7 = █

          ramp-swap-used-foreground = #2aa198

          [module/battery]
          type = internal/battery
          full-at = 98

          format-charging = <label-charging>
          format-discharging = <label-discharging>
          format-full = <label-full>

          label-charging = CHR %time%
          label-discharging = BAT %time%
          label-full = FUL 00:00:00
        '';
      };
    };

    xresources.extraConfig = builtins.readFile(
      pkgs.fetchFromGitHub {
        owner = "solarized";
        repo = "xresources";
        rev = "025ceddbddf55f2eb4ab40b05889148aab9699fc";
        sha256 = "0lxv37gmh38y9d3l8nbnsm1mskcv10g3i83j0kac0a2qmypv1k9f";
      } + "/Xresources.dark"
    );

    programs.vim = {
      enable = true;
      settings = {
        number = true;
        relativenumber = true;
      };
      extraConfig = ''
        set virtualedit=all

        "" vim-better-whitespace
        let g:strip_whitespace_on_save=1
        let g:strip_whitespace_confirm=0

        "" solarized
        let g:solarized_termcolors=16
        syntax enable
        set background=dark
        colorscheme solarized
      '';
      plugins = [
        "fugitive"
        "sensible"
        "vim-airline"
        "vim-better-whitespace"
        "vim-colors-solarized"
        "vim-gitgutter"
        "vim-nix"
      ];
    };

    programs.urxvt = {
      enable = true;
      fonts = [ "xft:DejaVu Sans Mono:size=12" ];
      scroll.bar.enable = false;
      extraConfig = {
        "iso14755" = false;
        "perl-ext-common" = "default,clipboard,resize-font";
        "keysym.M-c" = "perl:clipboard:copy";
        "keysym.M-v" = "perl:clipboard:paste";
        "clipboard.autocopy" = true;
        "clipboard.copycmd" = "xclip -i -selection clipboard";
        "clipboard.pastecmd" = "xclip -o -selection clipboard";
      };
    };

    programs.zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "copyfile"
          "docker"
          "git"
          "git-extras"
          "gradle"
          "sudo"
          "systemd"
          "tig"
          "yarn"
          "z"
        ];
      };
    };

    programs.git = {
      enable = true;
      userName = "Joseph Egan";
      userEmail = "joseph.s.egan@gmail.com";
      aliases = {
        ap = "add --patch";
        ca = "commit --amend";
        cne = "commit --amend --no-edit";
        fa = "fetch --all --prune";
        ff = "merge --ff-only";
        gl = "log --graph --decorate --format=oneline --all";
        rh = "reset --hard";
        st = "status";
        un = "rm --cache --force";
      };
      ignores = [ "*.swp" ];
      extraConfig = {
        core.editor = "vim";
        color.ui = "auto";
      };
    };

    programs.taskwarrior.enable = true;

    programs.firefox = {
      enable = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        decentraleyes
        https-everywhere
        link-cleaner
        octotree
        refined-github
        save-page-we
        stylus
        ublock-origin
        umatrix
        vim-vixen
        zoom-page-we
      ];
    };
  };

  system.stateVersion = "19.03";
}
