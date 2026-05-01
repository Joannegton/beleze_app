class Professional {
  final String id;
  final String tenantId;
  final String name;
  final List<String> serviceIds;
  final bool active;
  final String? avatarUrl;
  final String specialties;
  final double commission;

  const Professional({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.serviceIds,
    required this.active,
    this.avatarUrl,
    this.specialties = '',
    this.commission = 0.0,
  });
}
