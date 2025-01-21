_:
{ config, ... }: {
  programs.htop = {
    enable = true;
    settings = {
      delay = 2;
      fields = with config.lib.htop.fields; [ PID USER PERCENT_CPU PERCENT_MEM TIME COMM ];
      hide_kernel_threads = true;
      hide_userland_threads = true;
      highlight_base_name = true;
      shadow_other_users = true;
      show_cpu_frequency = true;
      show_program_path = false;
      tree_view = true;
    };
  };
}
