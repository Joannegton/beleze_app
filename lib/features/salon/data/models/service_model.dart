import '../../domain/entities/service.dart';

class ServiceModel extends SalonService {
  const ServiceModel({
    required super.id,
    required super.tenantId,
    required super.name,
    required super.category,
    required super.price,
    required super.durationMinutes,
    required super.active,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String,
        name: json['nome'] as String,
        category: json['categoria'] as String,
        price: (json['preco'] as num).toDouble(),
        durationMinutes: json['duracao_minutos'] as int,
        active: json['ativo'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'nome': name,
        'categoria': category,
        'preco': price,
        'duracao_minutos': durationMinutes,
        'ativo': active,
      };
}
