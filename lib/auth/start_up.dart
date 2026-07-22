import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Slivepage/streampage.dart';
import '../choixinscription/choix_inscription_page.dart';
import 'login.dart';



class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.repeat(reverse: true);

    verifierConnexion();
  }

  Future<void> verifierConnexion() async {

    await Future.delayed(
        const Duration(seconds: 2)
    );


    final supabase =
        Supabase.instance.client;


    final user =
        supabase.auth.currentUser;



    if (!mounted) return;



    // ============================
    // PAS CONNECTE
    // ============================

    if(user == null){


      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) =>
          const LoginPage(),

        ),

      );


      return;

    }




    try{


      // ============================
      // VERIFICATION PROFIL JOUEUR
      // ============================


      final joueur =

      await supabase

          .from("player")

          .select("id")

          .eq(
          "user_id",
          user.id
      )

          .maybeSingle();





      // ============================
      // VERIFICATION PROFIL RECRUTEUR
      // ============================


      final recruteur =

      await supabase

          .from("profils_recruteurs")

          .select("id")

          .eq(
          "user_id",
          user.id
      )

          .maybeSingle();





      // ============================
      // AUCUN PROFIL
      // ============================


      if(joueur == null &&
          recruteur == null){


        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>
            const ChoixInscriptionPage(),

          ),

        );


        return;

      }





      // ============================
      // PROFIL EXISTANT
      // ============================


      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) =>
          const StreamPage(),

        ),

      );




    }

    catch(e){


      print(
          "ERREUR STARTUP : $e"
      );


      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) =>
          const ChoixInscriptionPage(),

        ),

      );


    }


  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent.shade700,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.95,
                    end: 1.05,
                  ).animate(_animation),
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      size: 65,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "TalentBook",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "La plateforme des talents sportifs",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 70),
                const SizedBox(
                  width: 35,
                  height: 35,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Chargement...",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.9),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}