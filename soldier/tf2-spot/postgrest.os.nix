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
    };

    jwtSecretFile = "/tmp/fantasy-jwt";
  };
}
