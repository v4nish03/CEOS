class AppConstants {
  /// Permite configurar URL sin tocar código:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000/api/v1
  ///
  /// Para pruebas por USB sin depender de WiFi (adb reverse):
  /// 1) adb reverse tcp:8000 tcp:8000
  /// 2) flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  static const tokenKey = 'ceos_jwt_token';
}
