import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/state/storybook_state.dart';
import 'core/state/sound_state.dart';
import 'core/widgets/bottom_nav_bar.dart';
import 'core/state/processed_image.dart';
import 'core/services/animation_cache_manager.dart';
import 'core/services/sound_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/supabase_client.dart';

void main() async {
  // Ensure that the app waits for dotenv to load the environment variables
  await dotenv.load();
  
  // Initialize Supabase
  await SupabaseManager.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StorybookState()),
        ChangeNotifierProvider(create: (context) => SoundState()),
        ChangeNotifierProvider(create: (context) => ProcessedImageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _preloadSounds();
  }

  // Preload all sounds for immediate playback
  Future<void> _preloadSounds() async {
    final List<String> soundPaths = [
      'assets/audio/bell_button.mp3',
      'assets/audio/future_button.mp3',
      'assets/audio/game_button.mp3',
      'assets/audio/lively_button.mp3',
      'assets/audio/pop_button.mp3',
      'assets/audio/typewriter_button.mp3',
    ];

    await SoundService().preloadSounds(soundPaths);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clearTempCacheOnExit();
    super.dispose();
  }

  Future<void> _clearTempCacheOnExit() async {
    await AnimationCacheManager.clearTemporaryCache();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ISADRA App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const BottomNavBar(),
    );
  }
}
