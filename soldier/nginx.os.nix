{ self, ... }:
{
  imports = [ self.nixosModules.profiles-nginx ];

  services.nginx = {
    enable = true;
    defaultListenAddresses = [
      "100.101.0.130"
      "[fd7a:115c:a1e0::678b]"
    ];
  };
}
