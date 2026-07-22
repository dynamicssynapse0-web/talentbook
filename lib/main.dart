
import 'package:LESWAYS/recrutuer/creer_annonce_page.dart';
import 'package:LESWAYS/recrutuer/profil_recruteur_page.dart';
import 'package:LESWAYS/recrutuer/r%20annonces_page.dart';
import 'package:LESWAYS/searchplayer/RechercheJoueursPage.dart';
import 'package:flutter/material.dart';


import 'package:intl/date_symbol_data_local.dart' as date_local;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Slivepage/streampage.dart';
import 'auth/creationcompte.dart';
import 'auth/login.dart';
import 'auth/start_up.dart';
import 'joeur/InformationProfessionnellePage.dart';
import 'joeur/ProfilJoueurPage.dart';
import 'joeur/infoprofess.dart';
import 'joeur/joueurprofil.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⏱️ Mesure du temps d'initialisation
  final stopwatch = Stopwatch()..start();

  // Initialise les données de formatage pour la locale 'fr_FR'
  await date_local.initializeDateFormatting('fr_FR', null);

  // Initialisation de Supabase
  await Supabase.initialize(
    url: 'https://xgqsbvvcaiypkycovmhd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhncXNidnZjYWl5cGt5Y292bWhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQxNTg5MzQsImV4cCI6MjA5OTczNDkzNH0.XPOHKRtC43DKbmnNaHWcK2UbFk8xnsxEz8lAjxb8io0',
  );

  stopwatch.stop();
  debugPrint('✅ Supabase init took ${stopwatch.elapsedMilliseconds}ms');

  // On lance directement l'application sans le MultiProvider qui faisait planter
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 👈 Désactive le bandeau "DEBUG"
      routes:{

        "/profil_joueur":
            (context)=>ProfilJoueurPage(
          playerId:
          ModalRoute.of(context)!
              .settings
              .arguments
          as String,
        ),

      },

      title: 'Application Bonjour',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StartupPage(), // 👈 Ouvre directement ton écran avec le texte centré
    );
  }
}