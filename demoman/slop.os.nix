_:
{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.claude-code
  ];

  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    rocmOverrideGfx = "10.3.0";
  };
}
