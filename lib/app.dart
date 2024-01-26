import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:fast_menu/common/index.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: Obx(
        () {
          return GetMaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English, no country code
            ],
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,
            theme: ThemeData(useMaterial3: ConfigService.ins.useMaterial3),
            darkTheme:
                ThemeData.dark(useMaterial3: ConfigService.ins.useMaterial3),
            themeMode: ThemeMode.system,
            initialRoute: RouteNames.chat,
            getPages: RoutePages.list,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
