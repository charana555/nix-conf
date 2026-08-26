{
  config,
  lib,
  ...
}:
{
  services.k3s = {
    enable = true;
    role = "agent";
    # TODO: set actual server URL before first install
    # Extract from ~/install-k3s.sh or /etc/rancher/k3s/k3s.yaml
    serverAddr = "https://CHANGE_ME:6443";
    tokenFile = config.sops.secrets."k3s/token".path;
  };

  sops.secrets."k3s/token" = {
    sopsFile = config.sops.defaultSopsFile;
    owner = "root";
    mode = "0400";
  };
}
