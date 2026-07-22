import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'InformationProfessionnellePage.dart';
import 'infoprofess.dart';
import 'infospersonnelle.dart';

class ProfilJoueurPage extends StatefulWidget {
  final String playerId;
  const ProfilJoueurPage({
    super.key,
    required this.playerId,
  });


  @override
  State<ProfilJoueurPage> createState() => _ProfilJoueurPageState();
}

class _ProfilJoueurPageState extends State<ProfilJoueurPage> {

  bool chargement = true;


  Map<String, dynamic>? joueur;

  @override
  void initState() {
    super.initState();
    chargerProfil();
  }

  Future<void> chargerProfil() async {

    try {

      final data =
      await Supabase.instance.client
          .from("player")
          .select()
          .eq("id", widget.playerId)
          .single();


      setState(() {

        joueur = data;

        chargement = false;

      });


    } catch(e){

      print(e);

      setState(() {

        chargement = false;

      });

    }

  }

  @override
  Widget build(BuildContext context) {
    // 1. ÉCRAN DE CHARGEMENT ÉPURÉ
    if (chargement) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(), // S'adapte automatiquement à iOS/Android
        ),
      );
    }
    final estMonProfil =
        Supabase.instance.client.auth.currentUser?.id == joueur?["user_id"];



    final aUnePhoto = joueur?["photo_url"] != null && joueur!["photo_url"].toString().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Fond très clair et moderne
      appBar: AppBar(
        title:  Text(
          estMonProfil ? "Mon profil" : "Profil joueur",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0, // Évite que l'appbar change de couleur au défilement
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 2. BLOC AVATAR PREMIUM AVEC BORDURE ET OMBRE
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue.shade50,
                      backgroundImage: aUnePhoto ? NetworkImage(joueur!["photo_url"]) : null,
                      child: !aUnePhoto
                          ? Icon(Icons.person_rounded, size: 60, color: Colors.blue.shade400)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. INFOS D'IDENTITÉ
            Text(
              joueur?["nom"] ?? "Utilisateur",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            if (joueur?["poste"] != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  joueur!["poste"],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),

            // 4. MENU DE NAVIGATION STYLE "PARAMÈTRES PREMIUM"
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Option 1 : Informations personnelles
                  _buildMenuRow(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    iconColor: Colors.blue,
                    iconBgColor: Colors.blue.shade50,
                    label: "Informations personnelles",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) =>  InformationsPersonnellesPage(
                          playerId: widget.playerId,
                        )),
                      );
                    },
                  ),

                  // Séparateur discret entre les deux lignes
                  Divider(height: 1, indent: 60, endIndent: 16, color: Colors.grey.shade100),

                  // Option 2 : Informations professionnelles
                  _buildMenuRow(
                    context: context,
                    icon: Icons.sports_soccer_rounded,
                    iconColor: Colors.green,
                    iconBgColor: Colors.green.shade50,
                    label: "Informations professionnelles",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => InformationsProfessionnellesPage(
                          playerId: widget.playerId,

                        )),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// 5. FONCTION HELPER POUR CONSTRUIRE LES LIGNES DU MENU
  Widget _buildMenuRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20), // Assure un effet de vague propre
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Conteneur de l'icône stylisé
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),

              // Texte de l'option
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              // Flèche de navigation
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
