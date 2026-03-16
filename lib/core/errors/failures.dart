/// Jerarquía de fallos del dominio.
/// Las capas superiores reciben Failure, no excepciones crudas.
sealed class Failure {
  final String message;
  const Failure(this.message);
}

/// Error de comunicación con el servidor (red, timeout, 5xx)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

/// Credenciales inválidas o sesión expirada (401)
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'No autorizado']);
}

/// Recurso no encontrado (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}

/// Error de parsing / JSON malformado
class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Error al procesar la respuesta']);
}

/// Error genérico / inesperado
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Error desconocido']);
}
