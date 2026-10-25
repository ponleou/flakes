{ ... }:
{
  # these are defined by nixos-raspberry's sd image, i have no idea how to modify it
  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
      ];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 2 * 1024; # 2 gb
    }
  ];
  zramSwap.enable = true;
}
