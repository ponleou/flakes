{ config, constants, ... }:
let
  var = constants.alcyone.drive;
in
{
  fileSystems = {
    "/${var.root}/${var.main}" = {
      device = "/dev/disk/by-label/${var.main}";
      fsType = "ext4";
      options = [
        "nofail"
        "x-systemd.automount"
        "x-systemd.device-timeout=5s"
      ];
    };

    "/${var.root}/${var.storage}" = {
      device = "/dev/disk/by-label/${var.storage}";
      fsType = "ntfs";
      options = [
        "nofail"
        "x-systemd.automount"
        "x-systemd.device-timeout=5s"
        "x-systemd.idle-timeout=60s"
        "uid=${toString config.users.users.star.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "umask=022"
      ];
    };
  };
}
