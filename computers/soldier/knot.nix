{ inputs, pkgs, ... }:
let
  zones = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.dns-zones;
in
{
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  services.knot = {
    enable = true;
    settings = {
      server.listen = [ "0.0.0.0@53" "::0@53" ];
      log = [{ target = "syslog"; any = "info"; }];

      acl = [{
        id = "update_txt_only";
        address = [
          "127.0.0.1"
          "::1"
          "100.101.0.0/24"
          "fd7a:115c:a1e0::/112"
        ];
        action = "update";
        update-type = [ "TXT" ];
      }];

      template = [{
        id = "default";
        semantic-checks = "on";
        acl = "update_txt_only";
      }];

      zone = [
        { domain = "piss-your.se"; }
        { domain = "lde.sg"; }
        { domain = "ldesgoui.xyz"; }
      ];
    };
  };

  systemd.services.knot = {
    preStart = ''
      cp -f "${zones}/*.zones" /var/lib/knot/
    '';
  };
}
