{ self, ... }:
{ config, lib, pkgs, ... }:
let
  zones = self.packages.${pkgs.stdenv.hostPlatform.system}.dns-zones;
in
{
  age.secrets.tsig-keys = {
    rekeyFile = ./tsig-keys.age;

    owner = "knot";

    generator = {
      dependencies = [
        self.nixosConfigurations.sniper.config.age.secrets.mx-tsig
        self.nixosConfigurations.sniper.config.age.secrets.xfr-tsig
      ];

      script = { decrypt, deps, lib, pkgs, ... }:
        let
          args = lib.concatMapStringsSep " " (s: "<(${decrypt} ${lib.escapeShellArg s.file})") deps;
        in
        ''
          ${pkgs.yq-go}/bin/yq eval-all '[.key[0]] | { "key": . }' ${args}
        '';
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  services.knot = {
    enable = true;

    keyFiles = [ config.age.secrets.tsig-keys.path ];

    settings = {
      log = [{ target = "syslog"; any = "info"; }];

      server = {
        listen = [
          # enp2s0
          "192.168.1.2@53"
          "2001:41d0:fc14:ca00:3e7c:3fff:fe22:bb0d"

          # tailscale0
          "100.101.0.5@53"
          "fd7a:115c:a1e0::ced8@53"
        ];
      };

      remote = [{
        id = "sniper";
        address = [ "2001:bc8:710:7dfc::8" ];
        key = "sniper.xfr.";
      }];

      acl = [
        {
          id = "axfr-local";
          address = [
            "127.0.0.1"
            "::1"
            "100.101.0.0/24"
            "fd7a:115c:a1e0::/112"
          ];
          action = "transfer";
        }
        {
          id = "axfr-secondary";
          key = [ "sniper.xfr." ];
          action = "transfer";
        }
        {
          id = "update-mx";
          key = [ "sniper.mx." ];
          action = "update";
        }
        {
          id = "update-txt-only";
          address = [
            "127.0.0.1"
            "::1"
            "100.101.0.0/24"
            "fd7a:115c:a1e0::/112"
          ];
          action = "update";
          update-type = [ "TXT" ];
        }
      ];

      policy = [{
        id = "sign-ed25519";
        algorithm = "ed25519";
        ksk-shared = "on";
      }];

      template = [
        {
          id = "default";
          file = "${zones}/%s.zone";
          acl = [ "axfr-local" "axfr-secondary" "update-txt-only" ];
          notify = [ "sniper" ];
          dnssec-signing = "on";
          dnssec-policy = "sign-ed25519";
          semantic-checks = "on";
          serial-policy = "dateserial";
          journal-content = "all";
          zonefile-load = "difference-no-serial";
          catalog-role = "member";
          catalog-zone = "catalog.";
          global-module = [
            "mod-cookies"
            "mod-rrl/default"
            "mod-stats/default"
          ];
        }

        {
          id = "catalog";
          acl = [ "axfr-local" "axfr-secondary" ];
          notify = [ "sniper" ];
          catalog-role = "generate";
        }
      ];

      mod-rrl = [{
        id = "default";
        rate-limit = 200;
      }];

      mod-stats = [{
        id = "default";
        query-size = "on";
        reply-size = "on";
      }];

      zone = [
        { domain = "catalog."; template = "catalog"; }
        {
          domain = "lde.sg";
          dnssec-signing = "off"; # XXX: netim please
        }
        { domain = "ldesgoui.xyz"; }
        { domain = "piss-your.se"; }
        { domain = "tf2.spot"; }
      ];
    };
  };

  zfs.datasets.main = {
    enc.services.knot = {
      mountPoint = "/var/lib/knot"; # StateDirectory
    };
  };
}
