{
  boot.initrd = {
    # network = {
    #   enable = true;

    #   ssh = {
    #     enable = true;
    #     port = 2222;
    #     hostKeys = [ "/etc/ssh/host-keys/initrd_ed25519" ];
    #     authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
    #   };
    # };

    systemd.enable = true;

    systemd.emergencyAccess = true;

    systemd.services.symlink-machine-id = {
      after = [ "var-lib-systemd.mount" ];
      before = [ "initrd-switch-root.target" ];

      serviceConfig.Type = "oneshot";

      script = ''
        mkdir -p /sysroot/etc
        ln -sf /var/lib/systemd/machine-id /sysroot/etc/machine-id
      '';
    };
  };
}
