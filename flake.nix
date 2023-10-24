{
  description = "Project starter";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = { flake-parts, nixpkgs, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem = { config, system, ... }:
        let
          pkgs = import nixpkgs { inherit system; };

          buildRustPackage = pkgs.rustPlatform.buildRustPackage;

          cargo_casper = pkgs.fetchFromGitHub {
            owner = "casper-ecosystem";
            repo = "cargo-casper";
            rev = "abc9cf9a9e7394a3f36d330cb8ca53bbce99ffce";
            sha256 = pkgs.lib.fakeSha256;
          };

          casper_client = pkgs.fetchFromGitHub {
            owner = "casper-ecosystem";
            repo = "casper-client-rs";
            rev = "22f9df358864954e96fb82d9a873eb8595565565";
            sha256 = "sha256-tKKensnUEryX57zJvwT+/zywd1dDVdc6BGmzqf4lxIg=";
          };

        in {
          packages = {
            client = buildRustPackage rec {
              pname = "casper-client";
              version = "0.0.1";
              src = casper_client;
              cargoLock = { lockFile = src + ./Cargo.lock; };

            };
          };
        };
    };
}
