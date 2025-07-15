import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'add_visita_screen.dart';
import 'registro_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCqnUpRvlD1xbVGTqWn5cMX0HwM26WRZwI",
      authDomain: "proyectofirebase-2f71c.firebaseapp.com",
      projectId: "proyectofirebase-2f71c",
      storageBucket: "proyectofirebase-2f71c.firebasestorage.app",
      messagingSenderId: "399104877567",
      appId: "1:399104877567:web:8ca869d72c1ec365e17dca"
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // 👈 agregado el key aquí

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Visitas',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => LoginScreen(),
        '/home': (_) =>  HomeScreen(),
        '/add': (_) => AddVisitaScreen(),
        '/registro': (_) => RegistroScreen(),
      },
    );
  }
}

