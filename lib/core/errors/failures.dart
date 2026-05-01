abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Sessão expirada. Faça login novamente.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso não encontrado.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erro ao acessar dados locais.']);
}
