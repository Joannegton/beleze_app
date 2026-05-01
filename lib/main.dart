import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config/app_config.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/salon/domain/repositories/appointment_repository.dart';
import 'features/salon/domain/repositories/professional_block_repository.dart';
import 'features/salon/domain/repositories/salon_repository.dart';
import 'features/salon/presentation/client/bloc/booking_bloc.dart';
import 'features/salon/presentation/client/bloc/salon_list_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  AppConfig.logConfiguration();
  await initDependencies();
  runApp(const BelezeApp());
}

class BelezeApp extends StatefulWidget {
  const BelezeApp({super.key});

  @override
  State<BelezeApp> createState() => _BelezeAppState();
}

class _BelezeAppState extends State<BelezeApp> {
  late final AuthBloc _authBloc;
  late final _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _router = AppRouter.create(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(create: (_) => sl<SalonListBloc>()),
        BlocProvider(create: (_) => sl<BookingBloc>()),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SalonRepository>(create: (_) => sl()),
          RepositoryProvider<AppointmentRepository>(create: (_) => sl()),
          RepositoryProvider<ProfessionalBlockRepository>(create: (_) => sl()),
          RepositoryProvider<AuthRepository>(create: (_) => sl()),
        ],
        child: MaterialApp.router(
          title: 'Beleze',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          routerConfig: _router,
        ),
      ),
    );
  }
}
