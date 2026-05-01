import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/beleze_bottom_nav.dart';
import '../../../domain/entities/salon.dart';
import '../../../domain/repositories/salon_repository.dart';
import '../widgets/salon_card.dart';

class ClientFavoritesPage extends StatefulWidget {
  const ClientFavoritesPage({super.key});

  @override
  State<ClientFavoritesPage> createState() => _ClientFavoritesPageState();
}

class _ClientFavoritesPageState extends State<ClientFavoritesPage> {
  List<Salon>? _favorites;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await context.read<SalonRepository>().getFavoriteSalons();
    if (!mounted) return;

    result.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (list) => setState(() {
        _favorites = list;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Favoritos',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _favorites!.isEmpty
                  ? const _EmptyState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _favorites!.length,
                        itemBuilder: (_, i) => SalonCard(
                          salon: _favorites![i],
                          onTap: () => context.go('/client/salon/${_favorites![i].slug}'),
                        ),
                      ),
                    ),
      bottomNavigationBar: BelezeBottomNav(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) context.go('/client/home');
          if (i == 1) context.go('/client/appointments');
          if (i == 2) {} // Already on favorites
          if (i == 3) context.go('/client/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Agendamentos'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_outline, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Você não tem salões favoritos.',
            style: GoogleFonts.manrope(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/client/home'),
            icon: const Icon(Icons.search),
            label: const Text('Buscar salões'),
          ),
        ],
      ),
    );
  }
}
