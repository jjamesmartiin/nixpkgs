{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-saved-searches";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-saved-searches";
    rev = "4a40ba0501b7b3b79eae442f1331dee2135ec940";
    sha256 = "sha256-y0Ym2rf6UKIvtWS0NBUAwYAQoAeGSCy61/jW63BEgGc=";
  };
  meta = {
    homepage = "https://github.com/discourse/discourse-saved-searches";
    license = lib.licenses.mit;
    description = "Allow users to save searches and be notified of new results";
  };
}
