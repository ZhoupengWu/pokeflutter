import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'l10n/l10n_extensions.dart';
import 'app_services.dart';
import 'theme/responsive.dart';
import 'theme/theme.dart';
import 'views/shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Draw behind the system bars; their colours come from the page overlay style.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final services = AppServices.production();
  await services.init();

  runApp(MyApp(services: services));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      services: services,
      child: ScreenUtilInit(
        designSize: designSizeFor(MediaQuery.sizeOf(context)),
        minTextAdapt: true,
        builder: (context, child) {
          return ListenableBuilder(
            listenable: services.settings,
            builder: (context, _) => MaterialApp(
              onGenerateTitle: (context) => context.l10n.appTitle,
              debugShowCheckedModeBanner: false,
              locale: services.settings.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: services.settings.themeMode,
              builder: (context, child) =>
                  AnnotatedRegion<SystemUiOverlayStyle>(
                    value: pageOverlayStyle(Theme.of(context).brightness),
                    child: child!,
                  ),
              home: const ShellPage(),
            ),
          );
        },
      ),
    );
  }
}
