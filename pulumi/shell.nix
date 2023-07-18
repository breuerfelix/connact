{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs; [
      pulumi-bin
      nodejs
      nodePackages.npm
    ];

    shellHook = ''
      #export PULUMI_CONFIG_PASSPHRASE=""
      #export PULUMI_K8S_SUPPRESS_HELM_HOOK_WARNINGS="true"
    '';
}
