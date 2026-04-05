{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  bundlerEnvArgs.gemdir = ./.;
  name = "discourse-prometheus";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-prometheus";
    rev = "64ba51751ee3dfb06f9044df48c34aae65fd2676";
    sha256 = "sha256-QbHS396odqlVfaqV1n0y8a8ityA7b6HbUeHBnAnffdw=";
  };

  patches = [
    # The metrics collector tries to run git to get the commit id but fails
    # because we don't run Discourse from a Git repository.
    ./no-git-version.patch
    ./spec-import-fix-abi-version.patch
  ];

  meta = {
    homepage = "https://github.com/discourse/discourse-prometheus";
    license = lib.licenses.mit;
    description = "Official Discourse Plugin for Prometheus Monitoring";
  };
}
