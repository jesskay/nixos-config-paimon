{ config, pkgs, lib, ... }:
{
  services.borgbackup.jobs."paimon-data" = {
    paths = [ "/home/jess" ];
    exclude = [
      # exclude downloads as stuff only temporarily goes there
      "/home/jess/Downloads"
      # exclude onedrive as it's already synced
      "/home/jess/OneDrive"
      # exclude cache as anything there rapidly changes
      "/home/jess/.cache"
      # exclude steam and ffxiv data because those can be redownloaded from their servers instead
      "/home/jess/.local/share/Steam/steamapps"
      "/home/jess/.xlcore/ffxiv/game"
    ];
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
