{ config, pkgs, lib, ... }:
{
  services.borgbackup.jobs."paimon-data" = {
    paths = [ "/home" "/media/win-e" ];
    exclude = [ "/home/jess/Downloads" ];
    repo = "u360976@u360976.your-storagebox.de:paimon-data";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.age.secrets.borgpassphrase.path}";
    };
    environment.BORG_RSH = "ssh -i ${config.age.secrets.borgkey.path} -p 23";
    compression = "auto,lzma";
    startAt = "daily";
  };
}
