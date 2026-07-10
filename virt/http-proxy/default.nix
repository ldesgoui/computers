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

          zfs = {
            root.encryption-passphrase-age-rekeyFile = ./zfs-encryption-passphrase.age;

            datasets = {
              var = { mountPoint = "/var"; }; # Just in case
              nixos = { mountPoint = "/var/lib/nixos"; };
              systemd = { mountPoint = "/var/lib/systemd"; };
            };
          };
        };

        age.rekey = {
          # hostPubkey = "";
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
                http-request deny deny_status 400 if !allowed_host

                http-request do-resolve(txn.dst,dns,ipv6) hdr(host),field(1,:)
                use_backend be_http if { var(txn.dst) -m found }
                http-request deny deny_status 400

            backend be_http
                mode http
                tcp-request content set-dst var(txn.dst)
                server dynamic 0.0.0.0:80 send-proxy-v2

            frontend https
                bind *:443
                mode tcp
                tcp-request inspect-delay 5s
                tcp-request content accept if { req.ssl_hello_type 1 }

                acl allowed_sni req.ssl_sni -i -m dom -f /etc/haproxy/allowed-domains
                tcp-request content reject if !allowed_sni

                tcp-request content do-resolve(txn.dst,dns,ipv6) req.ssl_sni
                use_backend be_https if { var(txn.dst) -m found }
                tcp-request content reject

            backend be_https
                mode tcp
                tcp-request content set-dst var(txn.dst)
                server dynamic 0.0.0.0:443 send-proxy-v2
          '';
        };
      })
    ];
  };
}
