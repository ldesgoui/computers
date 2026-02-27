_:
{
  services.postgrest = {
    enable = true;

    settings = {
      db-uri = {
        host = "localhost";
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
