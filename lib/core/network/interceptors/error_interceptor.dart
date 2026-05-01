import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '[ErrorInterceptor] Erro interceptado',
      error: err,
      stackTrace: err.stackTrace,
    );
    developer.log('[ErrorInterceptor] Tipo: ${err.type}, Status: ${err.response?.statusCode}');

    final message = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Tempo de conexão esgotado.',
      DioExceptionType.connectionError => 'Sem conexão com a internet.',
      _ => _extractServerMessage(err) ?? 'Erro inesperado.',
    };

    developer.log('[ErrorInterceptor] Mensagem: $message');

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: message,
        message: message,
      ),
    );
  }

  String? _extractServerMessage(DioException err) {
    try {
      return err.response?.data['error']?['message'] as String? ??
          err.response?.data['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}
