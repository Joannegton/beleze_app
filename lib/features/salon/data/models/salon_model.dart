import '../../domain/entities/salon.dart';

class SalonModel extends Salon {
  const SalonModel({
    required super.id,
    required super.slug,
    required super.name,
    required super.address,
    super.logoUrl,
    super.distanceKm,
  });

  factory SalonModel.fromJson(Map<String, dynamic> json) {
    final addr = json['endereco'] as Map<String, dynamic>? ?? {};
    return SalonModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['nome_fantasia'] as String,
      logoUrl: json['logo_url'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      address: SalonAddress(
        street: addr['logradouro'] as String? ?? '',
        city: addr['cidade'] as String? ?? '',
        state: addr['estado'] as String? ?? '',
        lat: double.tryParse(addr['lat']?.toString() ?? ''),
        lng: double.tryParse(addr['lng']?.toString() ?? ''),
      ),
    );
  }
}
