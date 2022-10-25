# Systemd service template for mounting OneDrive for users using rclone
# (remote must be configured as the user before this can work)

{ pkgs, user, uid, ... }:
let
  rcloneConfig = "/home/${user}/.config/rclone/rclone.conf";
  mountpoint = "/home/${user}/OneDrive";
  uidStr = toString uid;
in {
  enable = true;
  description = "OneDrive mount for user ${user}";
  after = [ "network-online.target" ];
  wantedBy = [ "default.target" ];
  serviceConfig = {
    Type = "notify";
    ConditionPathExists = "${rcloneConfig}";
    ExecStart = "${pkgs.rclone}/bin/rclone mount --config=${rcloneConfig} --vfs-cache-mode full --umask 022 --allow-other --uid ${uidStr} OneDrive:/ ${mountpoint}";
    ExecStop = "${pkgs.fuse}/bin/fusermount -u ${mountpoint}";
  };
}

