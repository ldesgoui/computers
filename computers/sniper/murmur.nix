{
  services.murmur = {
    enable = true;
    password = "jurassicpark";
    registerName = "SERVER HAS MOVED";
    welcometext = builtins.replaceStrings [ "\n" ] [ "<br />" ] ''
      Hello, the server has moved hosts.
      You were connecting to the server directly by IP, which means I had no opportunity to offer you a smooth transition.
      Thankfully I still own this IP and I can give you instructions here!
      To connect to the new server, please click Server -> Connect -> Add New... and fill in:
      - Address: cool-zone.lde.sg
      - Port: 64738
      - Password: jurassicpark
      Thank you
    '';
  };
}
