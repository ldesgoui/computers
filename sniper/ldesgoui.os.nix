{ self, inputs, ... }:
{ lib, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    self.nixosModules.ldesgoui-user
  ];

  home-manager.users.ldesgoui = {
    imports = [
      self.modules.homeManager.ldesgoui-htop
      self.modules.homeManager.ldesgoui-shell
      self.modules.homeManager.ldesgoui-xdg
    ];
  };
}
