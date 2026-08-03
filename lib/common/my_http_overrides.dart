import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // Sirve para que la aplicación que ignore las reglas estándar de validación
    // para el cliente HTTP. Solo debe ser usado para desarrollo nunca prod
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
