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
            sha256 = "sha256-iJai8KN4i8Rr/hGnWxqaRKggww7tBDCI6WNBQQjS0jQ=";
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
              version = "v2.0.0";
              src = casper_client;
              doCheck = false;
              cargoHash = pkgs.lib.fakeHash;
              buildInputs = with pkgs; [ openssl ];
              nativeBuildInputs = with pkgs; [ pkg-config ];
              PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
            };
            cargo_casper = buildRustPackage rec {
              pname = "cargo-casper";
              version = "v2.0.0";
              src = cargo_casper;
              # cargoHash = pkgs.lib.fakeHash;
              doCheck = false;
              cargoLock = { lockFile = src + /Cargo.lock; };
              buildInputs = with pkgs; [ openssl ];
              nativeBuildInputs = with pkgs; [ pkg-config ];
              PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
            };
          };
        };
    };
}
