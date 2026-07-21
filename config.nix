{
  users = rec {
    me = {
      username = "charana";
      fullname = "Charana555";
      email = "charanchandrashekar555@gmail.com";
      sshPublicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILoFTzP1jCYcGX7KwJu0QrnKlWhOUCTbhftEPadNyQBB"
      ];
    };
    # Existing Pop!_OS user (keep username for backward compat)
    personal = me // {
      username = "itachi";
    };
    work = {
      username = "charana.c";
      fullname = "charana.c";
      email = "charana.c@juspay.in";
    };
  };
}
