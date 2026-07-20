{ self, ... }:
{
  imports = [ self.nixosModules.profiles-nginx ];

  networking.firewall = {
    allowedTCPPorts = [ 9080 9443 ];
  };

  services.nginx = {
    enable = true;
    defaultListenAddresses = [
      "100.101.0.5"
      "[fd7a:115c:a1e0::ced8]"
    ];
  };
}
