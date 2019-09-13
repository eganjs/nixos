/* vim: set ai et sw=2 sts=2 : */
{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

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
  };

  system.stateVersion = "19.03";
}
