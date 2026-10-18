abstract final class AppConfig {
  static const simulateMovement = bool.fromEnvironment(
    'SIMULATE_MOVEMENT',
    defaultValue: false,
  );
}