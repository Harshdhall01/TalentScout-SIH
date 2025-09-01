import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/test_selection_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocalizationService(),
      child: const TalentScoutApp(),
    ),
  );
}

class TalentScoutApp extends StatelessWidget {
  const TalentScoutApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return MaterialApp(
          title: 'TalentScout',
          debugShowCheckedModeBanner: false,
          locale: localizationService.currentLocale,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: const Color(0xFF1976D2),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1976D2),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            cardTheme: CardThemeData(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load saved language
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    await localizationService.loadSavedLanguage();
    
    // Wait for splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if user is registered
    final isRegistered = await _checkUserRegistration();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => isRegistered 
              ? TestSelectionScreen()
              : LoginScreen(),
        ),
      );
    }
  }

  Future<bool> _checkUserRegistration() async {
    try {
      return await StorageService.isUserRegistered();
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF1565C0),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_tennis,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'TalentScout',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'AI-Powered Sports Assessment',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocalizationService extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  
  Locale get currentLocale => _currentLocale;
  
  void changeLanguage(String languageCode) {
    _currentLocale = Locale(languageCode);
    notifyListeners();
    StorageService.saveSettings(language: languageCode);
  }
  
  Future<void> loadSavedLanguage() async {
    try {
      final settings = await StorageService.getSettings();
      if (settings != null && settings['language'] != null) {
        _currentLocale = Locale(settings['language']);
        notifyListeners();
      }
    } catch (e) {
      // Use default language
      _currentLocale = const Locale('en');
    }
  }
  
  String translate(String key) {
    final translations = _getTranslations();
    return translations[_currentLocale.languageCode]?[key] ?? key;
  }
  
  Map<String, Map<String, String>> _getTranslations() {
    return {
      'en': {
        'app_name': 'TalentScout',
        'welcome': 'Welcome to TalentScout',
        'login': 'Login',
        'register': 'Register',
        'email': 'Email',
        'password': 'Password',
        'name': 'Full Name',
        'age': 'Age',
        'gender': 'Gender',
        'male': 'Male',
        'female': 'Female',
        'height': 'Height (cm)',
        'weight': 'Weight (kg)',
        'submit': 'Submit',
        'select_test': 'Select Fitness Test',
        'situps': 'Sit-ups Test',
        'vertical_jump': 'Vertical Jump Test',
        'shuttle_run': 'Shuttle Run Test',
        'start_test': 'Start Test',
        'results': 'Test Results',
        'history': 'Test History',
        'camera_permission': 'Camera Permission Required',
        'storage_permission': 'Storage Permission Required',
        'recording': 'Recording...',
        'stop_recording': 'Stop Recording',
        'play_video': 'Play Video',
        'retake_video': 'Retake Video',
        'save_result': 'Save Result',
      },
      'hi': {
        'app_name': 'टैलेंटस्काउट',
        'welcome': 'टैलेंटस्काउट में आपका स्वागत है',
        'login': 'लॉगिन',
        'register': 'रजिस्टर',
        'email': 'ईमेल',
        'password': 'पासवर्ड',
        'name': 'पूरा नाम',
        'age': 'उम्र',
        'gender': 'लिंग',
        'male': 'पुरुष',
        'female': 'महिला',
        'height': 'कद (सेमी)',
        'weight': 'वजन (किग्रा)',
        'submit': 'जमा करें',
        'select_test': 'फिटनेस टेस्ट चुनें',
        'situps': 'सिट-अप्स टेस्ट',
        'vertical_jump': 'वर्टिकल जंप टेस्ट',
        'shuttle_run': 'शटल रन टेस्ट',
        'start_test': 'टेस्ट शुरू करें',
        'results': 'टेस्ट परिणाम',
        'history': 'टेस्ट इतिहास',
        'camera_permission': 'कैमरा अनुमति आवश्यक',
        'storage_permission': 'स्टोरेज अनुमति आवश्यक',
        'recording': 'रिकॉर्डिंग...',
        'stop_recording': 'रिकॉर्डिंग बंद करें',
        'play_video': 'वीडियो चलाएं',
        'retake_video': 'दोबारा रिकॉर्ड करें',
        'save_result': 'परिणाम सेव करें',
      },
    };
  }
}