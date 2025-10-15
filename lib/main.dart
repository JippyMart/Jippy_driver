import 'dart:async';
import 'dart:convert';

import 'package:android_pip/android_pip.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:driver/app/splash_screen.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/controllers/global_setting_controller.dart';
import 'package:driver/controllers/play_integrity_controller.dart';
import 'package:driver/firebase_options.dart';
import 'package:driver/models/language_model.dart';
import 'package:driver/services/audio_player_service.dart';
import 'package:driver/services/localization_service.dart';
import 'package:driver/services/play_integrity_service.dart';
import 'package:driver/themes/styles.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized(); //<= the key is here
    FlutterError.onError = (FlutterErrorDetails errorDetails) {};
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize Play Integrity Service
    print('🚀 [Main] Initializing Play Integrity Service...');
    await PlayIntegrityService.initialize();
    print('🚀 [Main] ✅ Play Integrity Service initialized');
    // Initialize Play Integrity Controller
    print('🚀 [Main] Initializing Play Integrity Controller...');
    Get.put(PlayIntegrityController(),);
    print('🚀 [Main] ✅ Play Integrity Controller initialized');
    await Preferences.initPref();
    runApp(const MyApp());
  }, (error, stackTrace) {});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    getCurrentAppTheme();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Preferences.getString(Preferences.languageCodeKey)
          .toString()
          .isNotEmpty) {
        LanguageModel languageModel = Constant.getLanguage();
        LocalizationService().changeLocale(languageModel.slug.toString());
      } else {
        LanguageModel languageModel =
            LanguageModel(slug: "en", isRtl: false, title: "English");
        Preferences.setString(
            Preferences.languageCodeKey, jsonEncode(languageModel.toJson()));
      }
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.paused) {
      AudioPlayerService.initAudio();
    }
    if (state == AppLifecycleState.inactive||state == AppLifecycleState.paused  ) {
         floatingButton();
      }
    getCurrentAppTheme();
  }
  Future<void>  floatingButton()async{
    AndroidPIP().enterPipMode(aspectRatio: [7, 9],);
  }
  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return GetMaterialApp(
            title: 'Driver'.tr,
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(
                themeChangeProvider.darkTheme == 0
                    ? true
                    : themeChangeProvider.darkTheme == 1
                        ? false
                        : false,
                context),
            localizationsDelegates: const [
              CountryLocalizations.delegate,
            ],
            locale: LocalizationService.locale,
            fallbackLocale: LocalizationService.locale,
            translations: LocalizationService(),
            builder: EasyLoading.init(),
            home: GetBuilder<GlobalSettingController>(
              init: GlobalSettingController(),
              builder: (context) {
                return const SplashScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
