/// Version deploy web — inject qua `--dart-define=WL_DEPLOY_VERSION=...`.
class WLDeployConfig {
  WLDeployConfig._();

  static const String version = String.fromEnvironment(
    'WL_DEPLOY_VERSION',
    defaultValue: 'dev',
  );
}
