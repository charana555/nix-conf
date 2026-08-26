{
  config,
  ...
}:
{
  services.k3s = {
    enable = true;
    role = "agent";
    serverAddr = "https://100.126.165.111:6443";
    tokenFile = config.sops.secrets."k3s/token".path;
    extraFlags = [
      "--node-name=dell"
      "--node-external-ip=100.71.68.23"
      "--node-ip=100.71.68.23"
      "--flannel-iface=tailscale0"
    ];
  };

  sops.secrets."k3s/token" = {
    sopsFile = config.sops.defaultSopsFile;
    owner = "root";
    mode = "0400";
  };
}
