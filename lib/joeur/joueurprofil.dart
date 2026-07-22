import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:path/path.dart' as path;
class CreationComptePage extends StatefulWidget {
  const CreationComptePage({super.key});

  @override
  State<CreationComptePage> createState() => _CreationComptePageState();
}


class _CreationComptePageState extends State<CreationComptePage> {


  File? photoJoueur;

  final nomController = TextEditingController();
  final ageController = TextEditingController();
  final paysController = TextEditingController();
  final villeController = TextEditingController();
  final tailleController = TextEditingController();
  final whatsappController = TextEditingController();


  String? posteSelectionne;
  final List<String> disciplines = [

    "Football",
    "Basketball",
    "Handball",
    "Tennis",
    "Athlétisme",
    "Rugby",
    "Volleyball",

  ];


  String? disciplineSelectionnee;


  final List<String> postes = [
    "Gardien",
    "Défenseur",
    "Milieu",
    "Attaquant",
    "Ailier",
  ];

  Future<bool> profilExiste() async {

    final user =
        Supabase.instance.client.auth.currentUser;


    if(user == null){

      return false;

    }


    final data =
    await Supabase.instance.client
        .from("player")
        .select("id")
        .eq(
      "user_id",
      user.id,
    )
        .maybeSingle();


    return data != null;

  }
  Future<void> choisirPhoto() async {

    final ImagePicker picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );


    if(image != null){

      setState(() {
        photoJoueur = File(image.path);
      });

    }

  }
  bool chargement = false;

  Future<String?> uploadPhotoProfil() async {

    print("===== DEBUT UPLOAD PHOTO PROFIL =====");


    if(photoJoueur == null){

      print("❌ Aucune photo sélectionnée");

      return null;

    }


    final user = Supabase.instance.client.auth.currentUser;


    if(user == null){

      print("❌ Aucun utilisateur connecté");

      return null;

    }


    print("USER ID : ${user.id}");



    try{


      final extension =
      path.extension(photoJoueur!.path);


      final fileName =
          "${user.id}$extension";


      print("NOM FICHIER : $fileName");


      print(
          "CHEMIN LOCAL : ${photoJoueur!.path}"
      );


      final taille =
      await photoJoueur!.length();


      print(
          "TAILLE IMAGE : $taille octets"
      );



      print(
          "UPLOAD VERS BUCKET images_produits..."
      );


      await Supabase.instance.client.storage
          .from("images_produits")
          .upload(
        fileName,
        photoJoueur!,
        fileOptions: const FileOptions(
          upsert:true,
          contentType:"image/jpeg",
        ),
      );



      print("✅ UPLOAD IMAGE OK");



      final url =
      Supabase.instance.client.storage
          .from("images_produits")
          .getPublicUrl(fileName);



      print("URL IMAGE : $url");


      return url;



    }

    catch(e, stack){


      print("===== ERREUR UPLOAD IMAGE =====");


      print(e);


      print(stack);


      return null;

    }

  }

  Future<void> creerProfil() async {


    print("====== DEBUT CREATION PROFIL ======");


    print("Nom : ${nomController.text}");
    print("Age : ${ageController.text}");
    print("Pays : ${paysController.text}");
    print("Ville : ${villeController.text}");
    print("Taille : ${tailleController.text}");
    print("Discipline : $disciplineSelectionnee");
    print("Poste : $posteSelectionne");
    print("Whatsapp : ${whatsappController.text}");



    final user =
        Supabase.instance.client.auth.currentUser;



    if(user == null){

      print("❌ UTILISATEUR NON CONNECTE");

      return;

    }
// Vérifier si le profil existe déjà

    final existe = await profilExiste();


    if(existe){

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content:
          Text(
            "Vous avez déjà créé votre profil.",
          ),

        ),

      );


      return;

    }

    print("USER ID : ${user.id}");



    setState(() {

      chargement=true;

    });



    try{


      // UPLOAD PHOTO

      final photoUrl =
      await uploadPhotoProfil();



      print(
          "PHOTO URL RETOURNEE : $photoUrl"
      );




      print("INSERT TABLE PLAYER...");



      final response =
      await Supabase.instance.client
          .from("player")
          .insert({

        "user_id": user.id,

        "nom":
        nomController.text.trim(),

        "age":
        ageController.text.trim(),

        "pays":
        paysController.text.trim(),

        "ville":
        villeController.text.trim(),

        "taille":
        tailleController.text.trim(),

        "discipline":
        disciplineSelectionnee,

        "poste":
        posteSelectionne,

        "whatsapp":
        whatsappController.text.trim(),
        "actif": true,

        "photo_url":
        photoUrl,

      })
          .select();



      print("✅ INSERT PLAYER OK");
      print("✅ INSERT PLAYER OK");


      print(response);


// AJOUTER LA NOTIFICATION ICI
      await Supabase.instance.client
          .from("notifications")
          .insert({

        "type": "nouveau_profil",

        "message":
        "${nomController.text.trim()} vient de créer son profil",

        "player_id": user.id,

        "created_at":
        DateTime.now().toIso8601String(),

      });


      print("✅ NOTIFICATION CREEE");


      print(response);



    }


    catch(e, stack){


      print(
          "===== ERREUR CREATION PLAYER ====="
      );


      print(e);


      print(stack);



    }



    setState(() {

      chargement=false;

    });


  }



  Widget champTexte(
      String label,
      IconData icon,
      TextEditingController controller,
      {TextInputType type = TextInputType.text}
      ){

    return Padding(
      padding: const EdgeInsets.only(bottom:15),

      child: TextField(

        controller: controller,

        keyboardType: type,

        decoration: InputDecoration(

          labelText: label,

          prefixIcon: Icon(icon,color: Colors.blueAccent),

          filled: true,

          fillColor: Colors.grey.shade100,

          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(15),

            borderSide: BorderSide.none,

          ),

        ),

      ),

    );

  }





  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: Colors.grey.shade100,


      appBar: AppBar(

        title: const Text(
          "Créer mon profil joueur",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle:true,

        backgroundColor: Colors.blueAccent.shade700,

        elevation:0,

      ),



      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),


        child: Column(

          children: [



            // PHOTO

            GestureDetector(

              onTap: choisirPhoto,

              child: Container(

                height:120,

                width:120,

                decoration:BoxDecoration(

                  shape: BoxShape.circle,

                  color:Colors.white,

                  boxShadow:[

                    BoxShadow(

                      color:Colors.black.withOpacity(0.15),

                      blurRadius:10,

                    )

                  ],

                ),


                child: photoJoueur == null ?

                const Icon(
                  Icons.add_a_photo,
                  size:45,
                  color:Colors.blueAccent,
                )

                    :

                ClipOval(

                  child:Image.file(

                    photoJoueur!,

                    fit:BoxFit.cover,

                  ),

                ),

              ),

            ),



            const SizedBox(height:25),



            const Text(

              "Photo du joueur",

              style:TextStyle(

                fontSize:16,

                fontWeight:FontWeight.bold,

              ),

            ),
            const SizedBox(height:8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(
                  color: Colors.orange,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Important : utilisez une photo réelle et clairement identifiable du joueur. "
                          "Les photos de célébrités, logos, dessins, paysages ou toute image ne représentant pas le joueur sont interdites. "
                          "Après vérification, tout compte utilisant une fausse photo de profil pourra être définitivement supprimé.",
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height:25),




            champTexte(
              "Nom du joueur",
              Icons.person,
              nomController,
            ),



            champTexte(
              "Âge",
              Icons.calendar_month,
              ageController,
              type:TextInputType.number,
            ),



            champTexte(
              "Pays",
              Icons.flag,
              paysController,
            ),



            champTexte(
              "Ville",
              Icons.location_city,
              villeController,
            ),



            champTexte(
              "Taille (ex: 1m80)",
              Icons.height,
              tailleController,
            ),


// DISCIPLINE

            Container(

              padding: const EdgeInsets.symmetric(horizontal:15),

              margin: const EdgeInsets.only(bottom:15),

              decoration: BoxDecoration(

                color: Colors.grey.shade100,

                borderRadius: BorderRadius.circular(15),

              ),


              child: DropdownButtonHideUnderline(

                child: DropdownButton<String>(

                  hint: const Text("Choisir la discipline"),

                  value: disciplineSelectionnee,

                  isExpanded:true,


                  items: disciplines.map((discipline){

                    return DropdownMenuItem(

                      value: discipline,

                      child: Text(discipline),

                    );

                  }).toList(),


                  onChanged:(value){

                    setState(() {

                      disciplineSelectionnee = value;

                    });

                  },

                ),

              ),

            ),
            // POSTE

            Container(

              padding:const EdgeInsets.symmetric(horizontal:15),

              margin:const EdgeInsets.only(bottom:15),

              decoration:BoxDecoration(

                color:Colors.grey.shade100,

                borderRadius:BorderRadius.circular(15),

              ),


              child:DropdownButtonHideUnderline(

                child:DropdownButton<String>(

                  hint:const Text("Choisir le poste"),

                  value:posteSelectionne,

                  isExpanded:true,

                  items:postes.map((poste){

                    return DropdownMenuItem(

                      value:poste,

                      child:Text(poste),

                    );

                  }).toList(),


                  onChanged:(value){

                    setState(() {

                      posteSelectionne=value;

                    });

                  },

                ),

              ),

            ),





            champTexte(

              "Numéro WhatsApp",

              Icons.phone,

              whatsappController,

              type:TextInputType.phone,

            ),




            const SizedBox(height:20),



            SizedBox(

              width:double.infinity,

              height:55,


              child:ElevatedButton(

                style:ElevatedButton.styleFrom(

                  backgroundColor:Colors.blueAccent.shade700,

                  shape:RoundedRectangleBorder(

                    borderRadius:BorderRadius.circular(15),

                  ),

                ),

                onPressed: chargement ? null : creerProfil,


                child:const Text(

                  "Créer mon profil",

                  style:TextStyle(

                    fontSize:18,

                    color:Colors.white,

                    fontWeight:FontWeight.bold,

                  ),

                ),

              ),

            )




          ],

        ),

      ),

    );


  }


}