{
  boot.zfs.datasets = {
    main = {
      properties = {
        acltype = "posix";
        atime = "off";
        compression = "on";
        dnodesize = "auto";
        normalization = "formD";
        relatime = "on";
        xattr = "sa";
      };
    };

    # Cleartext
    main._.clr = { };

    # Encrypted
    main._.enc = {
      properties = {
        encryption = "on";
        keylocation = "prompt";
        keyformat = "passphrase";
      };
    };

    main._.enc._.sys._.root = {
      mountPoint = "/";
    };

    main._.clr._.sys._.nix = {
      mountPoint = "/nix";

      properties = {
        exec = "on";
      };
    };
  };
}
