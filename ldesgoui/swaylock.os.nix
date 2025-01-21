_:
{
  security.pam.services.swaylock = { };

  home-manager.users.ldesgoui = {
    programs.swaylock = {
      enable = true;
      settings = {
        color = "123456";
        show-failed-attempts = true;
      };
    };
  };
}
