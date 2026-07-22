import 'package:flutter/material.dart';

class NoInternetPage extends StatelessWidget {

  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(

        child: Padding(

          padding: const EdgeInsets.all(30),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.wifi_off,
                size: 90,
                color: Colors.red,
              ),

              const SizedBox(height: 20),

              const Text(

                "Aucune connexion Internet",

                style: TextStyle(

                  fontSize: 24,

                  fontWeight: FontWeight.bold,

                ),

                textAlign: TextAlign.center,

              ),

              const SizedBox(height: 15),

              const Text(

                "Veuillez vérifier votre connexion puis réessayer.",

                textAlign: TextAlign.center,

              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(

                onPressed: () {

                  Navigator.pushReplacementNamed(context, "/");

                },

                icon: const Icon(Icons.refresh),

                label: const Text("Réessayer"),

              )

            ],

          ),

        ),

      ),

    );

  }

}