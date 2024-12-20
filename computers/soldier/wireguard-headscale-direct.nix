{ config, ... }: {
  age.secrets.wireguard-privkey = {
    rekeyFile = ./wireguard-privkey.age;
  };

  networking.firewall.trustedInterfaces = [ "wg-headscale-direct" ];

  networking.wireguard.interfaces.wg-headscale-direct = {
    # unCcOBXewoh78MG3E7o3cfaDgEE2A/2y1P684ppD4Ug=
    ips = [ "fc00:7767::2/128" ];

    privateKeyFile = config.age.secrets.wireguard-privkey.path;

    peers = [{
      publicKey = "QDEuEy768a+sQ2w+jvAzx2OJmHHgcaPpKQlifVFgzF0=";

      allowedIPs = [ "fc00:7767::/24" ];

      endpoint = "ldesgoui.xyz:51820";
      persistentKeepalive = 25;
    }];
  };
}
