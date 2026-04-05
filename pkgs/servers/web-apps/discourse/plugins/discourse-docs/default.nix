{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-docs";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-docs";
    rev = "ddbddac2fed43f7e4e62e504239ed63cb9cd1551";
    sha256 = "sha256-Q16YbK01azr0VGRhL3CiILUCAmWK7mpNeqtX1tXMZE4=";
  };
  meta = {
    homepage = "https://github.com/discourse/discourse-docs";
    license = lib.licenses.mit;
    description = "Find and filter knowledge base topics";
  };
}
