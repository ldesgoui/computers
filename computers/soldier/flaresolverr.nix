{ pkgs, inputs, ... }: {
  services.flaresolverr = {
    enable = true;
    # TODO: when flaresolverr is fixed (xdd)
    package = inputs.nur-xddxdd.packages.${pkgs.stdenv.hostPlatform.system}.flaresolverr-21hsmw;
  };
}
