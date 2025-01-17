{ lib, inputs, pkgs, ... }:
let
  install-knot-zones = pkgs.writeShellApplication {
    name = "install-knot-zones";
    text = builtins.readFile ./install-knot-zones.sh;

    runtimeEnv = {
      KEEP_RECORDS_AWK = ./keep-records.awk;
      ZONES = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.dns-zones;
    };
  };
in
{
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  services.knot = {
    enable = true;
    settings = {
      log = [{ target = "syslog"; any = "info"; }];

      server = {
        listen = [ "0.0.0.0@53" "::0@53" ];
      };

      acl = [{
        id = "update-txt-only";
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
        id = "sign-ed25519";
        algorithm = "ed25519";
        ksk-shared = "on";
      }];

      template = [{
        id = "default";
        acl = "update-txt-only";
        dnssec-signing = "on";
        dnssec-policy = "sign-ed25519";
        semantic-checks = "on";
        serial-policy = "dateserial";
        zonefile-load = "difference-no-serial";
      }];

      zone = [
        {
          domain = "lde.sg";
          dnssec-signing = "off"; # XXX: netim please
        }
        { domain = "ldesgoui.xyz"; }
        { domain = "piss-your.se"; }
      ];
    };
  };

  system.activationScripts."install-knot-zones".text = ''
    ${lib.getExe install-knot-zones}
  '';

  zfs.datasets.main = {
    _.enc._.services._.knot = {
      mountPoint = "/var/lib/knot"; # StateDirectory
    };
  };
}
