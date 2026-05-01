import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/professional_block.dart';

abstract interface class ProfessionalBlockRepository {
  Future<Result<Failure, List<ProfessionalBlock>>> listBlocks({
    required String tenantId,
    required String professionalId,
    DateTime? from,
    DateTime? to,
  });

  Future<Result<Failure, ProfessionalBlock>> createBlock({
    required String tenantId,
    required String professionalId,
    required DateTime dataInicio,
    required DateTime dataFim,
    String? motivo,
    bool recorrente = false,
  });

  Future<Result<Failure, void>> deleteBlock({
    required String tenantId,
    required String professionalId,
    required String blockId,
  });
}
