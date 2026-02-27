_:
{
  services.postgrest = {
    enable = true;

    settings = {
      db-uri = {
        user = "postgrest";
        dbname = "postgres";
      };

      db-schema = "fantasy_v0";
      db-anon-role = "fantasy_visitor";

      server-port = 3000;
      server-unix-socket = null;
    };

    jwtSecretFile = "/tmp/fantasy-jwt";
  };
}
