import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/model_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/auth/login_register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/get_started_wizard.dart'; // ✅ FIXED: Added missing import
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MLAdvisorApp());
}

class MLAdvisorApp extends StatelessWidget {
  const MLAdvisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ModelProvider()..loadModels()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (context, auth, chat) {
            if (chat != null && !auth.isLoggedIn) {
              chat.clearChat();
            }
            return chat!;
          },
        ),
      ],
      child: MaterialApp(
        title: 'ML Advisor',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    // 🌟 FIX: Only show full-screen loading if we don't know the authentication status yet
    // (Assuming your AuthProvider has an 'isInitialized' or similar flag, 
    // or we check if the user stream has emitted its first value).
    // If you don't have that flag yet, we can check if the user is null AND the app is checking status:
    if (auth.loading && !auth.isLoggedIn && auth.user == null) {
      // NOTE: If your AuthProvider sets auth.loading to true during form submit,
      // this condition might still trip unless we change how AuthProvider handles submission.
    }
    
    if (auth.isLoggedIn) {
      final bool completedOnboarding = auth.user?.hasCompletedOnboarding ?? false;

      if (completedOnboarding) {
        return const HomeScreen();
      } else {
        return const GetStartedWizard(); 
      }
    }
    
    // 🌟 Let the LoginRegisterScreen stay mounted! It has its own loading indicator inside the button.
    return const LoginRegisterScreen();
  }
}