import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/professional_block.dart';
import '../../domain/repositories/professional_block_repository.dart';
import '../datasources/salon_remote_datasource.dart';

class ProfessionalBlockRepositoryImpl implements ProfessionalBlockRepository {
  final SalonRemoteDatasource _datasource;

  ProfessionalBlockRepositoryImpl(this._datasource);

  @override
  Future<Result<Failure, List<ProfessionalBlock>>> listBlocks({
    required String tenantId,
    required String professionalId,
    DateTime? from,
    DateTime? to,
  }) =>
      _execute(() => _datasource.listBlocks(
            tenantId: tenantId,
            professionalId: professionalId,
            from: from,
            to: to,
          ));

  @override
  Future<Result<Failure, ProfessionalBlock>> createBlock({
    required String tenantId,
    required String professionalId,
    required DateTime dataInicio,
    required DateTime dataFim,
    String? motivo,
    bool recorrente = false,
  }) =>
      _execute(() => _datasource.createBlock(
            tenantId: tenantId,
            professionalId: professionalId,
            dataInicio: dataInicio,
            dataFim: dataFim,
            motivo: motivo,
            recorrente: recorrente,
          ));

  @override
  Future<Result<Failure, void>> deleteBlock({
    required String tenantId,
    required String professionalId,
    required String blockId,
  }) =>
      _execute(() => _datasource.deleteBlock(
            tenantId: tenantId,
            professionalId: professionalId,
            blockId: blockId,
          ));

  Future<Result<Failure, T>> _execute<T>(Future<T> Function() action) async {
    try {
      return ok(await action());
    } on DioException catch (e) {
      return err(_mapError(e));
    }
  }

  Failure _mapError(DioException e) => switch (e.response?.statusCode) {
        401 => const UnauthorizedFailure(),
        403 => const UnauthorizedFailure(),
        404 => NotFoundFailure(e.message ?? 'Não encontrado'),
        _ when e.type == DioExceptionType.connectionError =>
          const NetworkFailure(),
        _ => ServerFailure(e.message ?? 'Erro inesperado',
            statusCode: e.response?.statusCode),
      };
}
