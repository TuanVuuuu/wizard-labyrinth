/// Version deploy web — inject qua `--dart-define=WL_DEPLOY_VERSION=...`.
class WLDeployConfig {
  WLDeployConfig._();

  static const String version = String.fromEnvironment(
    'WL_DEPLOY_VERSION',
    defaultValue: 'dev',
  );

  static const String webGameUrl = 'https://wizardlabyrinth-9b1c2.web.app';
}
