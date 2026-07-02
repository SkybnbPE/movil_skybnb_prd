import '../errors/failures.dart';
import '../../data/datasources/remote/api_remote_datasource.dart';

/// Convierte excepciones de la capa data a Failures del dominio.
class ExceptionMapper {
  ExceptionMapper._();

  static Failure mapToFailure(Exception e) {
    if (e is HttpException) {
      return _mapHttpException(e);
    }
    if (e is FormatException) {
      return const ParseFailure();
    }
    return UnknownFailure(e.toString());
  }

  static Failure _mapHttpException(HttpException e) {
    switch (e.statusCode) {
      case 401:
        return const AuthFailure();
      case 404:
        return const NotFoundFailure();
      default:
        if (e.statusCode >= 500) {
          return ServerFailure('Error del servidor (${e.statusCode})');
        }
        return ServerFailure('Error HTTP ${e.statusCode}');
    }
  }
}
