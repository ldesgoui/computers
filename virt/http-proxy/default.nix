{ self, inputs, ... }:
{
  flake.nixosConfigurations.http-proxy = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.agenix.nixosModules.default
      inputs.agenix-rekey.nixosModules.default
      self.nixosModules.age-rekey-settings
      inputs.microvm.nixosModules.microvm
      self.nixosModules.microvm-nix-store-ro
      self.nixosModules.microvm-ssh
      self.nixosModules.microvm-users
      self.nixosModules.microvm-vlan100
      self.nixosModules.microvm-vsock-cid
      self.nixosModules.microvm-zfs-shares-guest

      ({ config, ... }: {
        networking.hostName = "http-proxy";
        system.stateVersion = "26.05";

        microvm = {
          machineId = "8104a050-5039-4f0e-8475-9bbbef0cd563";
          registerWithMachined = true;
          systemSymlink = true;

          interfaces = [{
            type = "bridge";
            id = "vm-mgmt-http-pr";
            mac = "02:00:00:33:69:7a";
            bridge = "br-mgmt";
          }];

          zfs = {
            root.encryption-passphrase-age-rekeyFile = ./zfs-encryption-passphrase.age;

            root.options = {
              recordsize = "1M";

              compression = "zstd-3"; # lil harder than lz4

              acltype = "posix";
              atime = "off"; # don't care about access times
              dnodesize = "auto"; # more efficient than legacy
              xattr = "sa"; # enhances perf for acltype=posix and dnodesize=auto

              utf8only = "on";
              normalization = "formD";
            };

            datasets = {
              var = { mountPoint = "/var"; }; # Just in case
              nixos = { mountPoint = "/var/lib/nixos"; };
              systemd = { mountPoint = "/var/lib/systemd"; };
            };
          };
        };

        age.rekey = {
          hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVvCA6Jcxb4Q3Vo+DD7tD1/s8jYrnUvrti7n8FhxII0";
        };

        environment.etc."haproxy/allowed-domains".text = ''
          lde.sg.
          ldesgoui.xyz.
          piss-your.se.
          tf2.spot.
        '';

        services.haproxy = {
          enable = true;
          config = ''
            global
              log /dev/log local0
              daemon
              maxconn 2048

            defaults
                timeout connect 5s
                timeout client 30s
                timeout server 30s
                timeout tunnel 4h

            resolvers dns
                parse-resolv-conf
                resolve_retries 3
                timeout resolve 1s
                timeout retry 1s
                hold valid 10s

            frontend http
                bind *:80
                mode http

                acl allowed_host hdr(host),field(1,:) -i -m dom -f /etc/haproxy/allowed-domains
                http-request deny deny_status 400 unless allowed_host

                http-request do-resolve(txn.dst,dns,ipv6) hdr(host),field(1,:)
                http-request deny deny_status 400 unless { var(txn.dst) -m found }

                use_backend be_http

            backend be_http
                mode http
                http-request content set-dst var(txn.dst)
                server dynamic 0.0.0.0:80 send-proxy-v2

            frontend https
                bind *:443
                mode tcp

                tcp-request inspect-delay 5s
                tcp-request content accept if { req.ssl_hello_type 1 }

                acl allowed_sni req.ssl_sni -i -m dom -f /etc/haproxy/allowed-domains
                tcp-request content reject unless allowed_sni

                tcp-request content do-resolve(txn.dst,dns,ipv6) req.ssl_sni
                tcp-request content reject unless { var(txn.dst) -m found }

                use_backend be_https

            backend be_https
                mode tcp
                tcp-request content set-dst var(txn.dst)
                server dynamic 0.0.0.0:443 send-proxy-v2
          '';
        };

        time.timeZone = "Europe/Paris";
      })
    ];
  };
}
