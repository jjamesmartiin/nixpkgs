{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-events";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "angusmcleod";
    repo = "discourse-events";
    rev = "7e77af58ee2191c19e1f99f9a833596eafbe22cc";
    sha256 = "sha256-1QOXJRpEXMMpsS2LLNNdPe+aJ8Tu8Q9hnSKW4yP9Phk=";
  };
  meta = {
    homepage = "https://github.com/angusmcleod/discourse-events";
    maintainers = [ lib.maintainers.leona ];
    license = lib.licenses.gpl2Plus;
    description = "Discourse plugin to manage events";
  };
}
