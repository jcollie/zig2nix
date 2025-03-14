# generated by zon2nix (https://github.com/jcollie/zon2nix)
{
  lib,
  linkFarm,
  fetchurl,
  fetchgit,
  runCommandLocal,
  zig_0_14,
  name ? "zig-packages",
}:
let
  unpackZigArtifact =
    {
      name,
      artifact,
    }:
    runCommandLocal name
      {
        nativeBuildInputs = [ zig_0_14 ];
      }
      ''
        hash="$(zig fetch --global-cache-dir "$TMPDIR" ${artifact})"
        mv "$TMPDIR/p/$hash" "$out"
        chmod 755 "$out"
      '';

  fetchZig =
    {
      name,
      url,
      hash,
    }:
    let
      artifact = fetchurl { inherit url hash; };
    in
    unpackZigArtifact { inherit name artifact; };

  fetchGitZig =
    {
      name,
      url,
      hash,
    }:
    let
      parts = lib.splitString "#" url;
      url_base = builtins.elemAt parts 0;
      url_without_query = builtins.elemAt (lib.splitString "?" url_base) 0;
      rev_base = builtins.elemAt parts 1;
      rev =
        if builtins.match "^[a-fA-F0-9]{40}$" rev_base != null then
          rev_base
        else
          "refs/heads/${rev_base}";
    in
    fetchgit {
      inherit name rev hash;
      url = url_without_query;
      deepClone = false;
    };

  fetchZigArtifact =
    {
      name,
      url,
      hash,
    }:
    let
      parts = lib.splitString "://" url;
      proto = builtins.elemAt parts 0;
      path = builtins.elemAt parts 1;
      fetcher = {
        "git+http" = fetchGitZig {
          inherit name hash;
          url = "http://${path}";
        };
        "git+https" = fetchGitZig {
          inherit name hash;
          url = "https://${path}";
        };
        http = fetchZig {
          inherit name hash;
          url = "http://${path}";
        };
        https = fetchZig {
          inherit name hash;
          url = "https://${path}";
        };
      };
    in
    fetcher.${proto};
in
linkFarm name [
