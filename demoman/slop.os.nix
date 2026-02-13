_:
{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.claude-code
  ];

  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    rocmOverridegfx = "10.3.0";
  };
}
