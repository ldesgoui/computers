{ self, ... }:
let
  pubkey = computer: self.nixosConfigurations.${computer}.config.age.rekey.hostPubkey;
in
{
  users.users.nix-remote-builder = {
    isSystemUser = true;
    useDefaultShell = true;
    group = "nogroup";

    openssh.authorizedKeys.keys =
      map (computer: ''restrict,command="nix-daemon --stdio" ${pubkey computer}'') [
        "scout"
        "soldier"
      ];
  };

  nix.settings.trusted-users = [ "nix-remote-builder" ];
}
