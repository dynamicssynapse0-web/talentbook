import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:LESWAYS/notif/payment_webview_page.dart';

class InformationsPersonnellesPage extends StatefulWidget {
  final String playerId;

  final bool lectureSeule;

  const InformationsPersonnellesPage({
    super.key,
    required this.playerId,
    this.lectureSeule = false,
  });


  @override
  State<InformationsPersonnellesPage> createState() =>
      _InformationsPersonnellesPageState();

}



class _InformationsPersonnellesPageState
    extends State<InformationsPersonnellesPage> {


  Map<String,dynamic>? joueur;

  bool chargement = true;
  bool modeEdition = false;

  final nomController = TextEditingController();
  final ageController = TextEditingController();
  final paysController = TextEditingController();
  final villeController = TextEditingController();
  final tailleController = TextEditingController();
  final posteController = TextEditingController();
  final whatsappController = TextEditingController();

  void modifierChamps(){

    nomController.text = joueur!["nom"] ?? "";
    ageController.text = joueur!["age"]?.toString() ?? "";
    paysController.text = joueur!["pays"] ?? "";
    villeController.text = joueur!["ville"] ?? "";
    tailleController.text = joueur!["taille"]?.toString() ?? "";
    posteController.text = joueur!["poste"] ?? "";
    whatsappController.text = joueur!["whatsapp"] ?? "";


    setState((){

      modeEdition = true;

    });

  }
  Future<void> rendrePremium() async {

    final user =
        Supabase.instance.client.auth.currentUser;


    if(user == null){
      return;
    }


    try{


      final response = await http.post(

        Uri.parse(
            "https://talentbook-api.onrender.com/api/make-premium"
        ),

        headers:{

          "Content-Type":"application/json"

        },

        body:jsonEncode({

          "userId":user.id,

          "playerId":widget.playerId

        }),

      );



      final data =
      jsonDecode(response.body);



      print(data);



      if(data["success"] == true){


        final paymentUrl =
        data["paymentUrl"];



        if(paymentUrl != null && mounted){


          Navigator.push(

            context,

            MaterialPageRoute(

              builder:(context)=>

                  PaymentWebViewPage(

                    url: paymentUrl,

                    onSuccess: () async {

                      await chargerInformations();

                    },

                  ),

            ),

          ).then((_){

            chargerInformations();

          });


        }


      }


    }catch(e){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text("Erreur : $e"),

          backgroundColor:
          Colors.red,

        ),

      );


    }

  }
  Future<void> enregistrerModifications() async {


    await Supabase.instance.client
        .from("player")
        .update({

      "nom": nomController.text,

      "age": ageController.text,

      "pays": paysController.text,

      "ville": villeController.text,

      "taille": tailleController.text,

      "poste": posteController.text,

      "whatsapp": whatsappController.text,

    })
        .eq("user_id", widget.playerId);


    setState((){

      modeEdition = false;

    });


    chargerInformations();

  }

  @override
  void initState(){

    super.initState();

    chargerInformations();

  }




  Future<void> chargerInformations() async {

    try {

      final data = await Supabase.instance.client
          .from("player")
          .select()
          .eq("user_id", widget.playerId)
          .single();


      setState(() {

        joueur = data;

        chargement = false;

      });


    } catch(e){

      print("ERREUR PROFIL : $e");


      setState(() {

        chargement = false;

      });

    }

  }

  Widget _buildInfoRow({
    required String titre,
    required String? valeur,
    required IconData icon,
    required Color color,
    required VoidCallback onModifier,
    required bool peutModifier,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(width:16),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  titre,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize:13,
                  ),
                ),

                const SizedBox(height:3),

                Text(
                  valeur != null && valeur.isNotEmpty
                      ? valeur
                      : "Non renseigné",
                  style: const TextStyle(
                    fontSize:16,
                    fontWeight:FontWeight.w600,
                  ),
                ),

              ],
            ),
          ),

          if(peutModifier)
            IconButton(
              onPressed: onModifier,
              icon: Icon(
                Icons.edit_outlined,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
  Future<void> modifierChamp(
      String colonne,
      String titre,
      String? ancienneValeur,
      ) async {

    final controller = TextEditingController(
      text: ancienneValeur ?? "",
    );


    final nouvelleValeur = await showDialog<String>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: Text(
            "Modifier $titre",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),


          content: TextField(

            controller: controller,

            decoration: InputDecoration(
              labelText: titre,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

          ),


          actions: [

            TextButton(

              onPressed: (){

                Navigator.pop(context);

              },

              child: const Text("Annuler"),

            ),


            ElevatedButton(

              onPressed: (){

                Navigator.pop(
                  context,
                  controller.text,
                );

              },

              child: const Text("Enregistrer"),

            ),

          ],

        );

      },

    );


    if(nouvelleValeur == null ||
        nouvelleValeur.trim().isEmpty){

      return;

    }



    try {


      await Supabase.instance.client
          .from("player")
          .update({

        colonne: nouvelleValeur.trim(),

      })
          .eq(
        "user_id",
        widget.playerId,
      );


      await chargerInformations();



      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(
            "$titre modifié avec succès",
          ),
          backgroundColor: Colors.green,
        ),

      );


    } catch(e){


      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(
            "Erreur : $e",
          ),
          backgroundColor: Colors.red,
        ),

      );


    }

  }
  @override
  Widget build(BuildContext context) {
    // 1. ÉCRAN DE CHARGEMENT ÉPURÉ
    if (chargement) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    // 2. ÉCRAN ERREUR / INTROUVABLE
    if (joueur == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                "Profil introuvable",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }
    final estMonProfil =
        Supabase.instance.client.auth.currentUser?.id ==
            joueur?["user_id"];

    final aUnePhoto = joueur!["photo_url"] != null && joueur!["photo_url"].toString().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Fond très doux
      appBar: AppBar(
        actions: [

          if(estMonProfil)

            IconButton(

              icon: Icon(
                modeEdition
                    ? Icons.save
                    : Icons.edit,
                color: Colors.blue,
              ),

              onPressed: (){

                if(modeEdition){

                  enregistrerModifications();

                }else{

                  modifierChamps();

                }

              },

            ),

        ],
        title: Text(
          estMonProfil
              ? "Mes informations"
              : "Informations joueur",

          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // 3. EN-TÊTE COMPACT (AVATAR + BADGE)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: aUnePhoto ? NetworkImage(joueur!["photo_url"]) : null,
                  child: !aUnePhoto ? Icon(Icons.person_rounded, size: 54, color: Colors.blue.shade300) : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              joueur!["nom"] ?? "Joueur",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 32),
            Text(
              joueur!["nom"] ?? "Joueur",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),


// BADGE PREMIUM

            if(joueur!["premium"] == true)

            // BADGE PREMIUM

              if(joueur!["premium"] == true)

                Container(

                  margin:
                  const EdgeInsets.only(top:8),

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal:14,
                    vertical:7,
                  ),

                  decoration:BoxDecoration(

                    color:
                    Colors.green.shade100,

                    borderRadius:
                    BorderRadius.circular(20),

                  ),

                  child:
                  const Text(

                    "⭐ Profil Premium",

                    style:

                    TextStyle(

                      color:
                      Colors.green,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                ),



            const SizedBox(height:20),



// CARTE PREMIUM

            if(estMonProfil && joueur!["premium"] != true)

              Container(

                margin:
                const EdgeInsets.only(bottom:20),


                padding:
                const EdgeInsets.all(20),


                decoration:BoxDecoration(

                  color:
                  Colors.amber.shade50,

                  borderRadius:
                  BorderRadius.circular(20),

                  border:Border.all(

                    color:
                    Colors.amber.shade200,

                  ),

                ),


                child:Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,


                  children:[


                    const Text(

                      "⭐ Boostez votre profil",

                      style:

                      TextStyle(

                        fontSize:20,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),



                    const SizedBox(height:10),



                    const Text(

                      "Votre profil apparaîtra en priorité "
                          "dans le Stream et sera plus visible "
                          "par les recruteurs.",

                    ),



                    const SizedBox(height:15),



                    SizedBox(

                      width:
                      double.infinity,


                      child:
                      ElevatedButton(

                        onPressed:
                        rendrePremium,


                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          Colors.amber.shade700,

                          foregroundColor:
                          Colors.white,

                        ),


                        child:
                        const Text(
                          "⭐ Rendre mon profil Premium",
                        ),

                      ),

                    ),


                  ],

                ),

              ),



            const SizedBox(height:20),

            // 4. LE BLOC DE FICHE UNIQUE BLANCHE (PREMIUM CARD)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [

                  _buildInfoRow(
                    titre: "Nom complet",
                    valeur: joueur!["nom"],
                    icon: Icons.person_outline_rounded,
                    color: Colors.blue,
                    onModifier: (){
                      modifierChamp("nom", "Nom complet", joueur!["nom"]);
                    },
                    peutModifier: estMonProfil,
                  ),

                  _buildDivider(),


                  _buildInfoRow(
                    titre: "Âge",
                    valeur: joueur!["age"]?.toString(),
                    icon: Icons.calendar_today_rounded,
                    color: Colors.orange,
                    onModifier: (){
                      modifierChamp("age", "Âge", joueur!["age"]?.toString());
                    },
                    peutModifier: estMonProfil,
                  ),

                  _buildDivider(),


                  _buildInfoRow(
                    titre: "Pays d'origine",
                    valeur: joueur!["pays"],
                    icon: Icons.public_rounded,
                    color: Colors.purple,
                    onModifier: (){
                      modifierChamp("pays", "Pays d'origine", joueur!["pays"]);
                    },
                    peutModifier: estMonProfil,

                  ),

                  _buildDivider(),


                  _buildInfoRow(
                    titre: "Ville actuelle",
                    valeur: joueur!["ville"],
                    icon: Icons.location_city_rounded,
                    color: Colors.teal,
                    onModifier: (){
                      modifierChamp("ville", "Ville actuelle", joueur!["ville"]);
                    },
                    peutModifier: estMonProfil,
                  ),

                  _buildDivider(),


                  _buildInfoRow(
                    titre: "Taille",
                    valeur: joueur!["taille"]?.toString(),
                    icon: Icons.straighten_rounded,
                    color: Colors.indigo,
                    onModifier: (){
                      modifierChamp("taille", "Taille", joueur!["taille"]?.toString());
                    },
                    peutModifier: estMonProfil,
                  ),

                  _buildDivider(),


                  _buildInfoRow(
                    titre: "Poste de jeu",
                    valeur: joueur!["poste"],
                    icon: Icons.sports_soccer_rounded,
                    color: Colors.green,
                    onModifier: (){
                      modifierChamp("poste", "Poste de jeu", joueur!["poste"]);
                    },
                    peutModifier: estMonProfil,
                  ),

                  _buildDivider(),


                  _buildInfoRow(
                    titre: "Numéro WhatsApp",
                    valeur: joueur!["whatsapp"],
                    icon: Icons.phone_android_rounded,
                    color: Colors.lightGreen,
                    onModifier: (){
                      modifierChamp("whatsapp", "Numéro WhatsApp", joueur!["whatsapp"]);
                    },
                    peutModifier: estMonProfil,
                  ),

                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

// Séparateur fin et élégant entre les lignes
  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 52, // Aligne la ligne parfaitement après l'icône
      color: Colors.grey.shade100,
    );
  }
}
