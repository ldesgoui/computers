_:
{
  services.kanshi = {
    enable = true;

    settings = [
      {
        profile.name = "roaming";
        profile.outputs = [{
          criteria = "eDP-1";
          status = "enable";
          scale = 1.5;
        }];
      }

      {
        profile.name = "docked-office";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "LG Electronics 34GN850 007NTRL7G022";
            status = "enable";
            mode = "3440x1440@160Hz";
          }
        ];
      }

      {
        profile.name = "docked-living-room";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "LG Electronics LG ULTRAGEAR 103NTXREH162";
            status = "enable";
            mode = "3440x1440@99.99Hz";
          }
        ];
      }
    ];
  };

  systemd.user.services.kanshi = {
    Service = {
      RestartMaxDelaySec = "2s";
      RestartSteps = 3;
    };
  };
}
  
