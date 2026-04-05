{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-yearly-review";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-yearly-review";
    rev = "2da65378ed39daf555e0622dd650791195beea20";
    sha256 = "sha256-GmuB+vcRrY4X2K4EH17wSmP7ywmebcgYLqaLL80Dqis=";
  };
  meta = {
    homepage = "https://github.com/discourse/discourse-yearly-review";
    maintainers = with lib.maintainers; [ talyz ];
    license = lib.licenses.mit;
    description = "Publishes an automated Year in Review topic";
  };
}
