{ config, pkgs, lib, ... }:
{
  age.secrets.borgkey.file = ./secrets/borgkey.age;
  age.secrets.borgpassphrase.file = ./secrets/borgpassphrase.age;
}
