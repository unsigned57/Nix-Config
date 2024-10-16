{ ... }:

{
  imports = [
    ./Proxy.nix
    ./Shell.nix
    ./Virtualisation.nix
    ./Editor.nix
    ./Packages.nix
    ./Git.nix
    ./InputMethod.nix
    ./Flatpak.nix
    ./Backup.nix
  ];
}
