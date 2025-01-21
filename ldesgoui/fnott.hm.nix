_:
{
  services.fnott = {
    enable = true;
    settings = {
      main = {
        title-font = "FiraMono Nerd Font:size=7";
        summary-font = "Work Sans:size=18:weight=Light";
        body-font = "PT Serif:size=9";
      };

      default = {
        default-timeout = 30;
        idle-timeout = 60;
      };
    };
  };
}
