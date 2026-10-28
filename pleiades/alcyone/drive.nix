{ config, constants, ... }:
let
  drive = constants.alcyone.drive;
in
{
  fileSystems = {
    "/${drive.root}/${drive.main}" = {
      device = "/dev/disk/by-label/${drive.main}";
      fsType = "ext4";
      options = [
        "nofail"
        "x-systemd.automount"
        "x-systemd.device-timeout=5s"
      ];
    };

    "/${drive.root}/${drive.storage}" = {
      device = "/dev/disk/by-label/${drive.storage}";
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
