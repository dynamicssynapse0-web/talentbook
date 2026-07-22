import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'detail_annonce_page.dart';

// La page de détail sera créée dans la PARTIE 3


class AnnoncesPage extends StatefulWidget {
  const AnnoncesPage({super.key});

  @override
  State<AnnoncesPage> createState() => _AnnoncesPageState();
}

class _AnnoncesPageState extends State<AnnoncesPage> {
  final supabase = Supabase.instance.client;

  final rechercheController = TextEditingController();

  List<dynamic> annonces = [];
  List<dynamic> resultats = [];

  bool chargement = true;

  String posteSelectionne = 'Tous';
  String paysSelectionne = 'Tous';

  final List<String> postes = [
    'Tous',
    'Gardien',
    'Défenseur',
    'Milieu',
    'Attaquant',
  ];

  final List<String> pays = [
    'Tous',
    'Cameroun',
    'Sénégal',

    'Maroc',
    'France',
  ];

  @override
  void initState() {
    super.initState();
    chargerAnnonces();

    rechercheController.addListener(() {
      filtrerAnnonces();
    });
  }

  Future<void> chargerAnnonces() async {
    try {
      final data = await supabase
          .from('annonces_recrutement')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        annonces = data;
        resultats = data;
        chargement = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement annonces : $e');

      setState(() {
        chargement = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void filtrerAnnonces() {
    final recherche = rechercheController.text.toLowerCase().trim();

    setState(() {
      resultats = annonces.where((annonce) {
        final titre =
        (annonce['titre'] ?? '').toString().toLowerCase();
        final club =
        (annonce['club'] ?? '').toString().toLowerCase();
        final poste =
        (annonce['poste'] ?? '').toString();
        final pays =
        (annonce['pays'] ?? '').toString();

        final correspondRecherche =
            recherche.isEmpty ||
                titre.contains(recherche) ||
                club.contains(recherche);

        final correspondPoste =
            posteSelectionne == 'Tous' ||
                poste == posteSelectionne;

        final correspondPays =
            paysSelectionne == 'Tous' ||
                pays == paysSelectionne;

        return correspondRecherche &&
            correspondPoste &&
            correspondPays;
      }).toList();
    });
  }

  Widget buildFiltre({
    required String valeur,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: valeur,
            isExpanded: true,
            items: items
                .map(
                  (e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ),
            )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  // La carte moderne sera ajoutée dans la PARTIE 2
  Widget carteAnnonce(dynamic annonce) {

    final dateLimite =
    annonce["date_limite"]?.toString();

    final DateTime? date =
    dateLimite != null
        ? DateTime.tryParse(dateLimite)
        : null;

    final bool urgent =
        date != null &&
            date.difference(DateTime.now()).inDays <= 7;

    final bool nouveau =
        DateTime.now()
            .difference(
            DateTime.parse(
                annonce["created_at"]))
            .inDays <
            3;

    return GestureDetector(

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) =>

                DetailAnnoncePage(
                  annonce: annonce,
                ),

          ),

        );

      },

      child: Container(

        margin:
        const EdgeInsets.only(
            bottom: 18),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.circular(25),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withOpacity(.05),

              blurRadius: 20,

              offset: const Offset(0, 10),

            )

          ],

        ),

        child: Padding(

          padding:
          const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              //--------------------------------
              // CLUB
              //--------------------------------

              Row(

                children: [

                  Container(

                    height: 60,

                    width: 60,

                    decoration: BoxDecoration(

                      color: Colors.blue.shade50,

                      borderRadius:
                      BorderRadius.circular(18),

                    ),

                    child: Icon(

                      Icons.shield,

                      color:
                      Colors.blue.shade700,

                      size: 34,

                    ),

                  ),

                  const SizedBox(width: 15),

                  Expanded(

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        Text(

                          annonce["club"] ??
                              "",

                          style:
                          const TextStyle(

                            fontWeight:
                            FontWeight.bold,

                            fontSize: 20,

                          ),

                        ),

                        const SizedBox(height: 4),

                        Text(

                          annonce["titre"],

                          style: TextStyle(

                            color:
                            Colors.grey.shade700,

                            fontSize: 15,

                          ),

                        ),

                      ],

                    ),

                  ),

                ],

              ),

              const SizedBox(height: 18),

              //--------------------------------
              // BADGES
              //--------------------------------

              Wrap(

                spacing: 8,

                runSpacing: 8,

                children: [

                  if (nouveau)

                    badge(

                      "NOUVEAU",

                      Colors.green,

                    ),

                  if (urgent)

                    badge(

                      "URGENT",

                      Colors.red,

                    ),

                  badge(

                    annonce["poste"],

                    Colors.blue,

                  ),

                ],

              ),

              const SizedBox(height: 20),

              //--------------------------------
              // INFOS
              //--------------------------------

              info(

                Icons.location_on,

                "${annonce["ville"]}, ${annonce["pays"]}",

              ),

              const SizedBox(height: 10),

              info(

                Icons.cake,

                "${annonce["age_min"]} - ${annonce["age_max"]} ans",

              ),

              const SizedBox(height: 10),

              info(

                Icons.calendar_month,

                "Date limite : ${annonce["date_limite"] ?? "-"}",

              ),

              const SizedBox(height: 18),

              //--------------------------------
              // DESCRIPTION
              //--------------------------------

              Text(

                annonce["description"] ?? "",

                maxLines: 3,

                overflow:
                TextOverflow.ellipsis,

                style: TextStyle(

                  color:
                  Colors.grey.shade700,

                  height: 1.4,

                ),

              ),

              const SizedBox(height: 22),

              //--------------------------------
              // BOUTON
              //--------------------------------

              SizedBox(

                width: double.infinity,

                child: ElevatedButton.icon(

                  icon:
                  const Icon(Icons.visibility),

                  label:
                  const Text("Voir l'annonce"),

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    Colors.blueAccent.shade700,

                    foregroundColor:
                    Colors.white,

                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 15,
                    ),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(15),

                    ),

                  ),

                  onPressed: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>

                            DetailAnnoncePage(

                              annonce:
                              annonce,

                            ),

                      ),

                    );

                  },

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }
  Widget badge(

      String texte,

      Color couleur,

      ) {

    return Container(

      padding:
      const EdgeInsets.symmetric(

        horizontal: 12,

        vertical: 6,

      ),

      decoration: BoxDecoration(

        color:
        couleur.withOpacity(.12),

        borderRadius:
        BorderRadius.circular(20),

      ),

      child: Text(

        texte,

        style: TextStyle(

          color: couleur,

          fontWeight: FontWeight.bold,

          fontSize: 12,

        ),

      ),

    );

  }
  Widget info(

      IconData icon,

      String texte,

      ) {

    return Row(

      children: [

        Icon(

          icon,

          color: Colors.blue,

          size: 18,

        ),

        const SizedBox(width: 8),

        Expanded(

          child: Text(

            texte,

            style: TextStyle(

              color:
              Colors.grey.shade700,

              fontSize: 14,

            ),

          ),

        ),

      ],

    );

  }

  @override
  void dispose() {
    rechercheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Opportunités',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent.shade700,
        elevation: 0,
      ),
      body: chargement
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // En-tête bleu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            decoration: BoxDecoration(
              color: Colors.blueAccent.shade700,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trouvez votre prochaine opportunité',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${resultats.length} annonce(s) disponible(s)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 18),

                // Barre de recherche
                TextField(
                  controller: rechercheController,
                  decoration: InputDecoration(
                    hintText: 'Club, poste ou mot-clé...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Filtres
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                buildFiltre(
                  valeur: posteSelectionne,
                  items: postes,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => posteSelectionne = v);
                    filtrerAnnonces();
                  },
                ),
                const SizedBox(width: 12),
                buildFiltre(
                  valeur: paysSelectionne,
                  items: pays,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => paysSelectionne = v);
                    filtrerAnnonces();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Liste des annonces
          Expanded(
            child: resultats.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune annonce trouvée',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Essayez de modifier vos filtres.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: resultats.length,
              itemBuilder: (context, index) {
                return carteAnnonce(resultats[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
Widget carteAnnonce(    BuildContext context,
    dynamic annonce,) {

  final dateLimite =
  annonce["date_limite"]?.toString();

  final DateTime? date =
  dateLimite != null
      ? DateTime.tryParse(dateLimite)
      : null;

  final bool urgent =
      date != null &&
          date.difference(DateTime.now()).inDays <= 7;

  final bool nouveau =
      DateTime.now()
          .difference(
          DateTime.parse(
              annonce["created_at"]))
          .inDays <
          3;

  return GestureDetector(

    onTap: () {

      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) =>

              DetailAnnoncePage(
                annonce: annonce,
              ),

        ),

      );

    },

    child: Container(

      margin:
      const EdgeInsets.only(
          bottom: 18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(25),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(.05),

            blurRadius: 20,

            offset: const Offset(0, 10),

          )

        ],

      ),

      child: Padding(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            //--------------------------------
            // CLUB
            //--------------------------------

            Row(

              children: [

                Container(

                  height: 60,

                  width: 60,

                  decoration: BoxDecoration(

                    color: Colors.blue.shade50,

                    borderRadius:
                    BorderRadius.circular(18),

                  ),

                  child: Icon(

                    Icons.shield,

                    color:
                    Colors.blue.shade700,

                    size: 34,

                  ),

                ),

                const SizedBox(width: 15),

                Expanded(

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(

                        annonce["club"] ??
                            "",

                        style:
                        const TextStyle(

                          fontWeight:
                          FontWeight.bold,

                          fontSize: 20,

                        ),

                      ),

                      const SizedBox(height: 4),

                      Text(

                        annonce["titre"],

                        style: TextStyle(

                          color:
                          Colors.grey.shade700,

                          fontSize: 15,

                        ),

                      ),

                    ],

                  ),

                ),

              ],

            ),

            const SizedBox(height: 18),

            //--------------------------------
            // BADGES
            //--------------------------------

            Wrap(

              spacing: 8,

              runSpacing: 8,

              children: [

                if (nouveau)

                  badge(

                    "NOUVEAU",

                    Colors.green,

                  ),

                if (urgent)

                  badge(

                    "URGENT",

                    Colors.red,

                  ),

                badge(

                  annonce["poste"],

                  Colors.blue,

                ),

              ],

            ),

            const SizedBox(height: 20),

            //--------------------------------
            // INFOS
            //--------------------------------

            info(

              Icons.location_on,

              "${annonce["ville"]}, ${annonce["pays"]}",

            ),

            const SizedBox(height: 10),

            info(

              Icons.cake,

              "${annonce["age_min"]} - ${annonce["age_max"]} ans",

            ),

            const SizedBox(height: 10),

            info(

              Icons.calendar_month,

              "Date limite : ${annonce["date_limite"] ?? "-"}",

            ),

            const SizedBox(height: 18),

            //--------------------------------
            // DESCRIPTION
            //--------------------------------

            Text(

              annonce["description"] ?? "",

              maxLines: 3,

              overflow:
              TextOverflow.ellipsis,

              style: TextStyle(

                color:
                Colors.grey.shade700,

                height: 1.4,

              ),

            ),

            const SizedBox(height: 22),

            //--------------------------------
            // BOUTON
            //--------------------------------

            SizedBox(

              width: double.infinity,

              child: ElevatedButton.icon(

                icon:
                const Icon(Icons.visibility),

                label:
                const Text("Voir l'annonce"),

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.blueAccent.shade700,

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 15,
                  ),

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(15),

                  ),

                ),

                onPressed: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>

                          DetailAnnoncePage(

                            annonce:
                            annonce,

                          ),

                    ),

                  );

                },

              ),

            ),

          ],

        ),

      ),

    ),

  );

}
Widget info(
    IconData icon,
    String texte,
    ) {

  return Row(

    children: [

      Icon(

        icon,

        color: Colors.blueAccent.shade700,

        size: 19,

      ),


      const SizedBox(width: 10),


      Expanded(

        child: Text(

          texte,

          style: TextStyle(

            color: Colors.grey.shade700,

            fontSize: 14,

          ),

        ),

      ),

    ],

  );

}

Widget badge(

    String texte,

    Color couleur,

    ) {

  return Container(

    padding:
    const EdgeInsets.symmetric(

      horizontal: 12,

      vertical: 6,

    ),

    decoration: BoxDecoration(

      color:
      couleur.withOpacity(.12),

      borderRadius:
      BorderRadius.circular(20),

    ),

    child: Text(

      texte,

      style: TextStyle(

        color: couleur,

        fontWeight: FontWeight.bold,

        fontSize: 12,

      ),

    ),

  );

}