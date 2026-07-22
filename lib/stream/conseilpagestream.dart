import 'package:flutter/material.dart';

class ConseilPage extends StatelessWidget {
  const ConseilPage({super.key});

  Widget sectionTitre(String titre, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            titre,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget conseil(String texte) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texte,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget question(String q, String r) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          q,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(r),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [

        sectionTitre(
          "Conseils pour améliorer votre profil",
          Icons.sports_soccer,
        ),

        const SizedBox(height: 15),

        conseil("Ajoutez une photo de profil professionnelle."),
        conseil("Complétez toutes vos informations personnelles."),
        conseil("Indiquez votre discipline sportive."),
        conseil("Ajoutez votre poste de jeu."),
        conseil("Renseignez votre club actuel."),
        conseil("Ajoutez vos expériences sportives."),
        conseil("Publiez plusieurs photos en action."),
        conseil("Ajoutez une vidéo de vos meilleures performances."),
        conseil("Décrivez vos objectifs sportifs."),
        conseil("Mettez régulièrement votre profil à jour."),

        const SizedBox(height: 35),

        sectionTitre(
          "Conseils pour les recruteurs",
          Icons.business_center,
        ),

        const SizedBox(height: 15),

        conseil("Complétez les informations de votre club."),
        conseil("Ajoutez le logo officiel du club."),
        conseil("Publiez uniquement des annonces sérieuses."),
        conseil("Décrivez précisément le profil recherché."),
        conseil("Répondez rapidement aux candidats."),
        conseil("Mettez vos annonces à jour."),

        const SizedBox(height: 35),

        sectionTitre(
          "Publier une annonce",
          Icons.campaign,
        ),

        const SizedBox(height: 15),

        conseil("Créez votre profil recruteur."),
        conseil("Accédez à l'onglet Recruteurs."),
        conseil("Cliquez sur 'Créer une annonce'."),
        conseil("Indiquez le poste recherché."),
        conseil("Ajoutez les critères souhaités."),
        conseil("Publiez votre annonce."),
        conseil("Consultez les candidatures reçues."),

        const SizedBox(height: 35),

        sectionTitre(
          "Pourquoi utiliser MARKETPROFILES ?",
          Icons.star,
        ),

        const SizedBox(height: 15),

        conseil("Créer gratuitement votre CV sportif."),
        conseil("Être visible auprès des recruteurs."),
        conseil("Publier des photos et vidéos."),
        conseil("Découvrir des talents."),
        conseil("Publier des annonces de recrutement."),
        conseil("Contacter directement joueurs et clubs."),
        conseil("Développer votre réseau sportif."),
        conseil("Une plateforme dédiée au monde du sport."),

        const SizedBox(height: 35),

        sectionTitre(
          "Questions fréquentes",
          Icons.help,
        ),

        const SizedBox(height: 15),

        question(
          "L'application est-elle gratuite ?",
          "Oui. La création d'un profil est gratuite. Certaines fonctionnalités avancées pourront être proposées sous forme d'abonnement.",
        ),

        question(
          "Puis-je modifier mon profil ?",
          "Oui, à tout moment depuis votre espace personnel.",
        ),

        question(
          "Comment être plus visible ?",
          "Complétez entièrement votre profil, ajoutez des photos, une vidéo et gardez vos informations à jour.",
        ),

        question(
          "Les recruteurs voient-ils mon profil ?",
          "Oui, les profils publics peuvent être consultés par les recruteurs inscrits sur MARKETPROFILES.",
        ),

        question(
          "Comment publier une annonce ?",
          "Il suffit de créer un profil recruteur puis d'utiliser le bouton 'Créer une annonce' dans l'espace Recruteurs.",
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}