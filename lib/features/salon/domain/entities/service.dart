class SalonService {
  final String id;
  final String tenantId;
  final String name;
  final String category;
  final double price;
  final int durationMinutes;
  final bool active;

  const SalonService({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.category,
    required this.price,
    required this.durationMinutes,
    required this.active,
  });

  String get formattedPrice =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  String get formattedDuration {
    if (durationMinutes < 60) return '${durationMinutes}min';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h${m}min';
  }
}
