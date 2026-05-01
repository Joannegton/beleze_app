import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../bloc/salon_list_bloc.dart';
import '../widgets/salon_card.dart';
import '../../widgets/banner_carousel.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _currentIndex = 0;
  String _selectedCategory = '';

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Cabelo', 'icon': Icons.content_cut},
    {'label': 'Barba', 'icon': Icons.face},
    {'label': 'Unhas', 'icon': Icons.brush},
    {'label': 'Estética', 'icon': Icons.spa},
    {'label': 'Sobrancelha', 'icon': Icons.remove_red_eye},
    {'label': 'Cílios', 'icon': Icons.visibility},
    {'label': 'Massagem', 'icon': Icons.self_improvement},
    {'label': 'Maquiagem', 'icon': Icons.face_retouching_natural},
    {
      'label': 'Depilação',
      'icon': Icons.clean_hands,
    }, // Ou Icons.architecture para precisão
    {'label': 'Podologia', 'icon': Icons.airline_seat_legroom_extra},
    {'label': 'Tattoo', 'icon': Icons.draw},
    {'label': 'Pet Shop', 'icon': Icons.pets},
  ];

  @override
  void initState() {
    super.initState();
    context.read<SalonListBloc>().add(const SalonListLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'BELEZE',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryContainer,
              letterSpacing: 0.2,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () => context.go('/client/profile'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryContainer),
                    color: AppColors.surfaceContainerHigh,
                  ),
                  child: Icon(Icons.person, color: AppColors.primaryContainer),
                ),
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<SalonListBloc, SalonListState>(
        builder: (context, state) {
          return switch (state) {
            SalonListLoading() => const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryContainer,
              ),
            ),
            SalonListError(message: final msg) => _ErrorView(
              message: msg,
              onRetry: () => context.read<SalonListBloc>().add(
                const SalonListLoadRequested(),
              ),
            ),
            SalonListLoaded(salons: final salons) =>
              salons.isEmpty
                  ? const _EmptyView()
                  : RefreshIndicator(
                      onRefresh: () async => context.read<SalonListBloc>().add(
                        const SalonListLoadRequested(),
                      ),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 24,
                              ),
                              child: BannerCarousel(
                                banners: [
                                  'assets/banners/Generated Image May 01, 2026 - 2_39AM.jpg',
                                  'assets/banners/Generated Image May 01, 2026 - 2_41AM.jpg',
                                  'assets/banners/Generated Image May 01, 2026 - 2_46AM.jpg',
                                  'assets/banners/ChatGPT Image 1 de mai. de 2026, 02_46_26.png',
                                  'assets/banners/ChatGPT Image 1 de mai. de 2026, 02_48_10.png',
                                ],
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'O que você quer fazer hoje?',
                                    style: GoogleFonts.manrope(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    style: TextStyle(
                                      color: AppColors.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Buscar serviços ou salões...',
                                      hintStyle: TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: AppColors.primaryContainer,
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.outlineVariant,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.outlineVariant,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primaryContainer,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Categorias',
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.onSurfaceVariant,
                                      letterSpacing: 0.05,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: _categories.map((cat) {
                                        final isSelected =
                                            _selectedCategory == cat['label'];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: GestureDetector(
                                            onTap: () => setState(
                                              () =>
                                                  _selectedCategory = isSelected
                                                  ? ''
                                                  : cat['label'],
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? AppColors
                                                                .primaryContainer
                                                          : AppColors
                                                                .outlineVariant,
                                                      width: isSelected ? 2 : 1,
                                                    ),
                                                    color: isSelected
                                                        ? AppColors
                                                              .surfaceContainerHigh
                                                        : Colors.transparent,
                                                  ),
                                                  child: Icon(
                                                    cat['icon'],
                                                    color: isSelected
                                                        ? AppColors
                                                              .primaryContainer
                                                        : AppColors
                                                              .onSurfaceVariant,
                                                    size: 28,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  cat['label'],
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: isSelected
                                                        ? AppColors
                                                              .primaryContainer
                                                        : AppColors
                                                              .onSurfaceVariant,
                                                    letterSpacing: 0.05,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Próximos a você',
                                        style: GoogleFonts.manrope(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          'Ver todos',
                                          style: GoogleFonts.manrope(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryContainer,
                                            letterSpacing: 0.05,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    childAspectRatio: 1,
                                    mainAxisSpacing: 16,
                                  ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => SalonCard(
                                  salon: salons[index],
                                  onTap: () => context.go(
                                    '/client/salon/${salons[index].slug}',
                                  ),
                                ),
                                childCount: salons.length,
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 80)),
                        ],
                      ),
                    ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: AppColors.surfaceContainerLowest,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Agendamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (i) {
          setState(() => _currentIndex = i);
          switch (i) {
            case 1:
              context.go('/client/appointments');
            case 2:
              context.go('/client/favorites');
            case 3:
              context.go('/client/profile');
          }
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.store_outlined,
            size: 48,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum salão encontrado na sua região.',
            style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
