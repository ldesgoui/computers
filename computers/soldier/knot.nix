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

      policy = [{
        id = "sign_ed25519";
        algorithm = "ed25519";
      }];

      template = [{
        id = "default";
        acl = "update_txt_only";
        dnssec-signing = "on";
        dnssec-policy = "sign_ed25519";
        semantic-checks = "on";
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
      cp -f ${zones}/*.zone /var/lib/knot/
    '';
  };

  zfs.datasets.main = {
    _.enc._.services._.knot = {
      mountPoint = "/var/lib/knot"; # StateDirectory
    };
  };
}
