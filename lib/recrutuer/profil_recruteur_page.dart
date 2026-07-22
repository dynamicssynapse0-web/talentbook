import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ProfilRecruteurPage extends StatefulWidget {


  final String? recruteurId;


  const ProfilRecruteurPage({

    super.key,

    this.recruteurId,

  });



  @override
  State<ProfilRecruteurPage> createState()
  => _ProfilRecruteurPageState();

}




class _ProfilRecruteurPageState
    extends State<ProfilRecruteurPage>{


  final supabase =
      Supabase.instance.client;



  final nomController =
  TextEditingController();


  final paysController =
  TextEditingController();


  final villeController =
  TextEditingController();


  final contactController =
  TextEditingController();


  final descriptionController =
  TextEditingController();



  File? logo;


  bool chargement=false;



  Future choisirLogo() async {


    final image =
    await ImagePicker()
        .pickImage(

        source:
        ImageSource.gallery

    );



    if(image!=null){

      setState(() {

        logo=
            File(image.path);

      });


    }


  }


  Future<String?> envoyerLogo() async {

    if(logo == null) return null;

    final user = supabase.auth.currentUser;

    if(user == null) return null;


    final chemin =
        "${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";


    await supabase.storage
        .from("logos_clubs")
        .upload(
      chemin,
      logo!,
    );


    return supabase.storage
        .from("logos_clubs")
        .getPublicUrl(chemin);
  }
  Future sauvegarder() async {


    final user =
        supabase.auth.currentUser;


    if(user==null)return;


    setState(() {

      chargement=true;

    });


    try{


      final logoUrl =
      await envoyerLogo();



      await supabase

          .from("profils_recruteurs")

          .insert({

        "user_id":

        user.id,


        "nom_club":

        nomController.text,


        "logo_url":

        logoUrl,


        "pays":

        paysController.text,


        "ville":

        villeController.text,


        "contact":

        contactController.text,


        "description":

        descriptionController.text,


      });



      ScaffoldMessenger.of(context)
          .showSnackBar(

          const SnackBar(

            content:
            Text(
                "Profil recruteur créé"
            ),

            backgroundColor:
            Colors.green,

          )

      );



      Navigator.pop(context);



    }

    catch(e){

      print(e);

    }


    setState(() {

      chargement=false;

    });


  }@override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(

        title: const Text(
          "Profil recruteur",
        ),

        backgroundColor:
        Colors.blueAccent.shade700,

        centerTitle: true,

      ),


      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          children: [


            GestureDetector(

              onTap: choisirLogo,

              child: CircleAvatar(

                radius: 55,

                backgroundColor:
                Colors.blue.shade50,

                backgroundImage:

                logo != null

                    ?

                FileImage(logo!)

                    :

                null,


                child:

                logo == null

                    ?

                const Icon(

                  Icons.add_a_photo,

                  size:40,

                  color:Colors.blue,

                )

                    :

                null,

              ),

            ),



            const SizedBox(height:25),



            TextField(

              controller:
              nomController,

              decoration:
              const InputDecoration(

                labelText:
                "Nom du club",

                prefixIcon:
                Icon(Icons.shield),

              ),

            ),



            const SizedBox(height:15),



            TextField(

              controller:
              paysController,

              decoration:
              const InputDecoration(

                labelText:
                "Pays",

                prefixIcon:
                Icon(Icons.public),

              ),

            ),



            const SizedBox(height:15),



            TextField(

              controller:
              villeController,

              decoration:
              const InputDecoration(

                labelText:
                "Ville",

                prefixIcon:
                Icon(Icons.location_city),

              ),

            ),



            const SizedBox(height:15),



            TextField(

              controller:
              contactController,

              decoration:
              const InputDecoration(

                labelText:
                "Contact WhatsApp",

                prefixIcon:
                Icon(Icons.phone),

              ),

            ),



            const SizedBox(height:15),



            TextField(

              controller:
              descriptionController,

              maxLines:5,

              decoration:
              const InputDecoration(

                labelText:
                "Présentation du club",

                prefixIcon:
                Icon(Icons.description),

              ),

            ),



            const SizedBox(height:30),



            SizedBox(

              width:
              double.infinity,


              child:
              ElevatedButton(

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.blueAccent.shade700,

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets.symmetric(

                    vertical:16,

                  ),

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(18),

                  ),

                ),


                onPressed:

                chargement

                    ?

                null

                    :

                sauvegarder,


                child:

                chargement

                    ?

                const CircularProgressIndicator(

                  color:Colors.white,

                )

                    :

                const Text(

                  "Créer mon profil recruteur",

                  style:
                  TextStyle(

                    fontSize:16,

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