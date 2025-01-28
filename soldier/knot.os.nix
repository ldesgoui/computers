{ self, ... }:
{ lib, pkgs, ... }:
let
  install-knot-zones = pkgs.writeShellApplication {
    name = "install-knot-zones";
    text = builtins.readFile ./install-knot-zones.sh;

    runtimeInputs = [ pkgs.gawk pkgs.knot-dns ];
    runtimeEnv = {
      KEEP_RECORDS_AWK = ./keep-records.awk;
      ZONES = self.packages.${pkgs.stdenv.hostPlatform.system}.dns-zones;
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
        listen = [
          # enp2s0
          "192.168.1.2@53"
          "2001:41d0:fc14:ca00:aaa1:59ff:fe44:7806@53"

          #tailscale0
          "100.101.0.130@53"
          "fd7a:115c:a1e0::678b@53"
        ];
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
        journal-content = "all";
        zonefile-load = "difference-no-serial";
        global-module = [ "mod-cookies" "mod-rrl" "mod-stats/default" ];
      }];

      mod-stats = [{
        id = "default";
        query-size = "on";
        reply-size = "on";
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
