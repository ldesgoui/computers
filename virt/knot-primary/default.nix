{ self, inputs, ... }: {
  flake.nixosConfigurations.knot-primary = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.agenix.nixosModules.default
      inputs.agenix-rekey.nixosModules.default
      self.nixosModules.age-rekey-settings
      inputs.microvm.nixosModules.microvm
      self.nixosModules.microvm-nix-store-ro
      self.nixosModules.microvm-ssh
      self.nixosModules.microvm-users
      self.nixosModules.microvm-vlan100 # TODO: force ipv6 ::53
      self.nixosModules.microvm-vsock-cid
      self.nixosModules.microvm-zfs-shares-guest

      ({ config, lib, pkgs, ... }:
        let
          zones = self.packages.${pkgs.stdenv.hostPlatform.system}.dns-zones;

          acmeTsigs = [
            "mumble-server"
            "tf2-spot"
          ];
        in
        {
          networking.hostName = "knot-primary";
          system.stateVersion = "26.05";

          microvm = {
            machineId = "00000053-835e-4676-b95c-27cfc86b9d77";
            registerWithMachined = true;
            systemSymlink = true;

            zfs = {
              root.encryption-passphrase-age-rekeyFile = ./zfs-encryption-passphrase.age;

              datasets = {
                var = { mountPoint = "/var"; }; # Just in case
                nixos = { mountPoint = "/var/lib/nixos"; };
                systemd = { mountPoint = "/var/lib/systemd"; };

                knot = { mountPoint = "/var/lib/knot"; };
                "knot/keys" = { mountPoint = "/var/lib/knot/keys"; };
              };
            };
          };

          age.rekey = {
            hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDRF9Rs6Sc0PzD2LR4k7umxbDTQNPUKjRak5GNnfLDhW";
          };

          age.secrets.tsig-keys = {
            rekeyFile = ./tsig-keys.age;
            generator = {
              dependencies = [
                self.nixosConfigurations.knot-secondary.config.age.secrets.xfr-tsig
              ]
              ++ map
                (hostName: self.nixosConfigurations.${hostName}.config.age.secrets.acme-tsig)
                acmeTsigs;

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
              server = {
                listen = [
                  "0.0.0.0"
                  "::"
                ];

                automatic-acl = "on"; # This gives remotes that we notify the permission to XFR
              };

              log = [{ target = "syslog"; any = "info"; }];

              remote = [{
                id = "knot-secondary";
                address = [ "2001:41d0:fc14:cafe::2:53" ];
                via = [ "2001:41d0:fc14:cafe::53" ];
                key = "knot-secondary.xfr";
              }];

              acl = [
                {
                  id = "axfr-local"; # This is nice for debugging
                  address = [ "127.0.0.1" "::1" ];
                  action = "transfer";
                }

                {
                  id = "acme-update-txt";
                  action = "update";
                  key = map (hostName: "${hostName}.acme") acmeTsigs;
                  address = [
                    "2001:41d0:fc14:cafe::/64"
                    "2001:41d0:fc14:ca00::/64" # TMP: soldier lives here
                    # TODO: sniper can't do that
                  ];
                  update-type = [ "TXT" ];
                  update-owner = "name";
                  update-owner-match = "pattern";
                  # My domains + up to 4 subdomains deep
                  update-owner-name = (builtins.foldl'
                    (acc: _: rec {
                      last = acc.last + ".*";
                      out = acc.out ++ [ last ];
                    })
                    { last = "_acme-challenge.*"; out = [ ]; }
                    (builtins.genList (n: n) 5)
                  ).out;
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

                  acl = [
                    "axfr-local"
                    "acme-update-txt"
                  ];
                  notify = [
                    "knot-secondary"
                    # "hurricane-electric"
                  ];

                  semantic-checks = "on";
                  zonefile-load = "difference-no-serial";
                  journal-content = "all";
                  dnssec-signing = "on";
                  dnssec-policy = "sign-ed25519";
                  serial-policy = "dateserial";

                  global-module = [
                    "mod-cookies"
                    "mod-rrl"
                    "mod-stats/default"
                  ];
                }

                {
                  id = "unsigned";
                  file = "${zones}/%s.zone";

                  acl = [
                    "axfr-local"
                    "acme-update-txt"
                  ];
                  notify = [
                    "knot-secondary"
                    # "hurricane-electric"
                  ];

                  semantic-checks = "on";
                  zonefile-load = "difference-no-serial";
                  journal-content = "all";
                  serial-policy = "dateserial";

                  global-module = [
                    "mod-cookies"
                    "mod-rrl"
                    "mod-stats/default"
                  ];
                }

                {
                  id = "catalog";
                  acl = [
                    "axfr-local"
                  ];
                  notify = [
                    "knot-secondary"
                  ];
                  catalog-role = "generate";
                }
              ];

              zone = [
                { domain = "catalog."; template = "catalog"; }
                { domain = "lde.sg."; template = "unsigned"; }
                { domain = "ldesgoui.xyz."; }
                { domain = "piss-your.se."; }
                { domain = "tf2.spot."; }
              ];

              mod-stats = [{
                id = "default";
                query-size = "on";
                reply-size = "on";
              }];
            };
          };
        })
    ];
  };
}
