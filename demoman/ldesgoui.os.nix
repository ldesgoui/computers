{ self, inputs, ... }:
{ lib, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ]
  ++ lib.mapAttrsToList
    (name: module: if lib.hasPrefix "ldesgoui-" name then module else { })
    self.nixosModules;

  home-manager.users.ldesgoui = {
    imports = lib.mapAttrsToList
      (name: module: if lib.hasPrefix "ldesgoui-" name || lib.hasPrefix "demoman-" name then module else { })
      self.modules.homeManager;
  };
}
