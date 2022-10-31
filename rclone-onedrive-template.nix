# Systemd service template for mounting OneDrive for users using rclone
# (remote must be configured as the user before this can work)

{ pkgs, user, uid, ... }:
let
  rcloneConfig = "/home/${user}/.config/rclone/rclone.conf";
  mountpoint = "/home/${user}/OneDrive";
  uidStr = toString uid;
  rcPort = toString (uid + 5520);  # add arbitrary (>= 1024) num, for port that won't collide w/ other users
in {
  enable = true;
  description = "OneDrive mount for user ${user}";
  after = [ "network-online.target" ];
  wantedBy = [ "default.target" ];
  serviceConfig = {
    Type = "notify";
    ConditionPathExists = "${rcloneConfig}";
    ExecStart = ''
      ${pkgs.rclone}/bin/rclone mount \
      --config=${rcloneConfig} \
      --vfs-cache-mode full \
      --umask 077 \
      --allow-other \
      --uid ${uidStr} \
      --rc \
      --rc-addr localhost:${rcPort} \
      --attr-timeout 8700h \
      --dir-cache-time 8760h \
      --poll-interval 30s \
      OneDrive:/ ${mountpoint}
      '';
    ExecStartPost = ''
      ${pkgs.rclone}/bin/rclone rc vfs/refresh recursive=true _async=true \
      --config=${rcloneConfig} \
      --rc-addr localhost:${rcPort}
      '';
    ExecStop = "${pkgs.fuse}/bin/fusermount -u ${mountpoint}";
  };
}

