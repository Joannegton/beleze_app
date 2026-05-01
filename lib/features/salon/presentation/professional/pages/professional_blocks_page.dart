import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/professional_block.dart';
import '../../../domain/repositories/professional_block_repository.dart';

class ProfessionalBlocksPage extends StatefulWidget {
  final String tenantId;
  final String professionalId;

  const ProfessionalBlocksPage({
    super.key,
    required this.tenantId,
    required this.professionalId,
  });

  @override
  State<ProfessionalBlocksPage> createState() => _ProfessionalBlocksPageState();
}

class _ProfessionalBlocksPageState extends State<ProfessionalBlocksPage> {
  List<ProfessionalBlock> _blocks = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  Future<void> _loadBlocks() async {
    setState(() => _loading = true);
    final result = await context.read<ProfessionalBlockRepository>().listBlocks(
          tenantId: widget.tenantId,
          professionalId: widget.professionalId,
          from: DateTime.now(),
          to: DateTime.now().add(const Duration(days: 90)),
        );
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loading = false),
      (list) => setState(() {
        _blocks = list;
        _loading = false;
      }),
    );
  }

  Future<void> _showCreateDialog() async {
    DateTime? dataInicio;
    DateTime? dataFim;
    final motivoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Novo Bloqueio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DateTimePickerTile(
                  label: 'Início',
                  value: dataInicio,
                  onChanged: (dt) => setDialogState(() => dataInicio = dt),
                ),
                const SizedBox(height: 12),
                _DateTimePickerTile(
                  label: 'Fim',
                  value: dataFim,
                  onChanged: (dt) => setDialogState(() => dataFim = dt),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: motivoController,
                  decoration: const InputDecoration(
                    labelText: 'Motivo (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 255,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: (dataInicio != null && dataFim != null)
                  ? () async {
                      Navigator.of(ctx).pop();
                      await _createBlock(
                        dataInicio: dataInicio!,
                        dataFim: dataFim!,
                        motivo: motivoController.text.trim().isEmpty
                            ? null
                            : motivoController.text.trim(),
                      );
                    }
                  : null,
              child: const Text('Bloquear'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBlock({
    required DateTime dataInicio,
    required DateTime dataFim,
    String? motivo,
  }) async {
    final result = await context.read<ProfessionalBlockRepository>().createBlock(
          tenantId: widget.tenantId,
          professionalId: widget.professionalId,
          dataInicio: dataInicio,
          dataFim: dataFim,
          motivo: motivo,
        );
    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: ${f.message}'))),
      (_) => _loadBlocks(),
    );
  }

  Future<void> _deleteBlock(String blockId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover bloqueio?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result =
        await context.read<ProfessionalBlockRepository>().deleteBlock(
              tenantId: widget.tenantId,
              professionalId: widget.professionalId,
              blockId: blockId,
            );
    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: ${f.message}'))),
      (_) => _loadBlocks(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bloqueios de Agenda')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.block),
        label: const Text('Novo Bloqueio'),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _blocks.isEmpty
              ? const _EmptyBlocks()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _blocks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _BlockTile(
                    block: _blocks[i],
                    onDelete: () => _deleteBlock(_blocks[i].id),
                  ),
                ),
    );
  }
}

class _BlockTile extends StatelessWidget {
  final ProfessionalBlock block;
  final VoidCallback onDelete;

  const _BlockTile({required this.block, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      child: ListTile(
        leading: const Icon(Icons.block, color: AppColors.error),
        title: Text(
          '${fmt.format(block.dataInicio)} → ${fmt.format(block.dataFim)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: block.motivo != null
            ? Text(block.motivo!, style: const TextStyle(color: AppColors.textSecondary))
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _DateTimePickerTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  const _DateTimePickerTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date == null || !context.mounted) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value ?? DateTime.now()),
        );
        if (time == null) return;
        onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              value != null ? '$label: ${fmt.format(value!)}' : 'Selecionar $label',
              style: TextStyle(
                color: value != null ? Colors.black87 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBlocks extends StatelessWidget {
  const _EmptyBlocks();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available, size: 64, color: AppColors.grey400),
          SizedBox(height: 16),
          Text(
            'Nenhum bloqueio cadastrado.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 8),
          Text(
            'Adicione bloqueios para folgas ou compromissos.',
            style: TextStyle(color: AppColors.grey400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
