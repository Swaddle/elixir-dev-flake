{
  description = "Elixir dev flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
      erlang = pkgs.beam.interpreters.erlangR24;
      elixir = pkgs.beam.packages.erlangR26.elixir_1_15;
      hex = pkgs.beam.packages.erlang.hex;
      MIX_PATH = "${hex}/archives/hex-${hex.version}/hex-${hex.version}/ebin";
      rebar3 = pkgs.beam.packages.erlang.rebar3;
      MIX_REBAR3 = "${rebar3}/bin/rebar3";

      postgres_setup = import ./extra-pkgs/postgres_setup.nix { };
    in
    {
      devShell.aarch64-darwin = pkgs.mkShell {
        inherit MIX_PATH MIX_REBAR3;
        # use local HOME to avoid global things
        MIX_HOME = ".cache/mix";
        HEX_HOME = ".cache/hex";
        # enable IEx shell history
        ERL_AFLAGS = "-kernel shell_history enabled";
        packages = [
          elixir
          pkgs.postgresql_14
          pkgs.nixpkgs-fmt
        ];
        shellHook = postgresql_setup;
      };
    };
}
