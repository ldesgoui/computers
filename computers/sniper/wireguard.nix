{ config, ... }: {
  age.secrets.wireguard-private = {
    rekeyFile = ./wireguard-private.age;
    generator.script = { lib, pkgs, file, ... }: ''
      priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
      ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
      echo "$priv"
    '';
  };

  networking.nat = {
    enable = true;
    externalInterface = "ens2";
    internalInterfaces = [ "wg0" ];
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.77.67.1/24" ];
    listenPort = 51820;
    privateKeyFile = config.age.secrets.wireguard-private.path;
    peers = [
      # UDM-SE
      {
        publicKey = "dM0OQbDFIIKpFyhZSfUank7+h5vZWIcgGUgK18Zj0Cg=";
        allowedIPs = [ "10.77.67.100/32" ];
      }
    ];
  };
}
