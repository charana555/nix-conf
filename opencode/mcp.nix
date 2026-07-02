{ lib, pkgs }:
let
  inherit (lib) getExe getExe';
in
{
  git = {
    type = "local";
    command = [ (getExe pkgs.mcp-server-git) ];
    enabled = true;
  };

  fetch = {
    type = "local";
    command = [ (getExe pkgs.mcp-server-fetch) ];
    enabled = true;
  };

  sequential-thinking = {
    type = "local";
    command = [ (getExe' pkgs.mcp-server-sequential-thinking "mcp-server-sequential-thinking") ];
    enabled = true;
  };

  github = {
    type = "local";
    command = [
      (getExe pkgs.github-mcp-server)
      "stdio"
    ];
    enabled = true;
    environment.GITHUB_PERSONAL_ACCESS_TOKEN = "{env:GITHUB_TOKEN}";
  };

  deepwiki = {
    type = "remote";
    url = "https://mcp.deepwiki.com/mcp";
    enabled = true;
  };

  nixos = {
    type = "local";
    command = [
      (getExe pkgs.nix)
      "run"
      "github:utensils/mcp-nixos"
      "--"
    ];
    enabled = true;
  };
}
