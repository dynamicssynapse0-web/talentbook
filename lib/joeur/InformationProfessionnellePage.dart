import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'dart:math';

import '../stream/cashpage.dart';


class InformationProfessionnellePage extends StatefulWidget {
  final String playerId;
  final bool lectureSeule;

  const InformationProfessionnellePage({
    super.key,
    required this.playerId,
    this.lectureSeule = false,
  });


  @override
  State<InformationProfessionnellePage> createState() =>
      _InformationProfessionnellePageState();

}



class _InformationProfessionnellePageState
    extends State<InformationProfessionnellePage>{

  bool chargement = false;
  final clubController = TextEditingController();
  final anneeController = TextEditingController();
  final presentationController = TextEditingController();
  final videoUrlController = TextEditingController();

  bool profilTermine = false;

  List<File> photosJeu = [];

  Map<String,dynamic>? joueur;
  final picker = ImagePicker();
  @override
  void initState() {
    super.initState();

    chargerInformations();
  }
  Future<void> chargerInformations() async {

    try {

      final data = await Supabase.instance.client
          .from("player")
          .select()
          .eq("id", widget.playerId)
          .single();


      setState(() {

        joueur = data;

        clubController.text =
            data["club"] ?? "";

        anneeController.text =
            data["annee"] ?? "";

        presentationController.text =
            data["presentation"] ?? "";

      });

    }
    catch(e){

      print(e);

    }

  }
  void viderFormulaire(){

    clubController.clear();

    anneeController.clear();

    presentationController.clear();

    videoUrlController.clear();


    setState(() {

      photosJeu.clear();

    });

  }
  // AJOUT PHOTO

  Future ajouterPhoto() async{


    if(photosJeu.length >=4){
      return;
    }


    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality:80,
    );


    if(image != null){

      setState(() {

        photosJeu.add(
            File(image.path)
        );

      });

    }

  }

  Future<List<String>> uploadPhotos() async {


    List<String> urls = [];


    final user = Supabase.instance.client.auth.currentUser;


    if(user == null) return urls;



    for(var photo in photosJeu){


      final fileName =
          "${user.id}_${Random().nextInt(999999)}${path.extension(photo.path)}";


      await Supabase.instance.client.storage
          .from("images_produits")
          .upload(
        fileName,
        photo,
      );



      final url =
      Supabase.instance.client.storage
          .from("images_produits")
          .getPublicUrl(fileName);



      urls.add(url);


    }


    return urls;

  }

  Future<void> insererClub() async {

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final photosUrls = await uploadPhotos();

    final videoUrl = videoUrlController.text.trim();

    await Supabase.instance.client
        .from("player_clubs")
        .insert({

      "user_id": user.id,

      "club": clubController.text.trim(),

      "annee": anneeController.text.trim(),

      "presentation": presentationController.text.trim(),

      "photos": photosUrls,

      "video_url": videoUrl.isEmpty ? null : videoUrl,

    });


    viderFormulaire();

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("Club enregistré avec succès"),
      ),

    );

  }
  Future<void> enregistrerClub() async {

    print("====== DEBUT ENREGISTREMENT CLUB ======");

    if (clubController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Entre le nom du club"),
        ),

      );

      return;
    }

    setState(() {
      chargement = true;
    });

    try {

      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception("Aucun utilisateur connecté");
      }

      // Vérifie combien de clubs possède déjà le joueur
      final clubs = await Supabase.instance.client
          .from("player_clubs")
          .select("id")
          .eq("user_id", user.id);

      if (clubs.isEmpty) {

        // Premier club : gratuit
        await insererClub();

      } else {

        // Clubs suivants : paiement obligatoire

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) => CashPage(

            ),

          ),

        );

      }

    } catch (e, stack) {

      print(e);
      print(stack);

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text("Erreur : $e"),
        ),

      );

    } finally {

      if (mounted) {
        setState(() {
          chargement = false;
        });
      }

    }

  }


  Widget champ(
      String titre,
      IconData icon,
      TextEditingController controller,
      ){

    return Padding(

      padding: const EdgeInsets.only(bottom:15),

      child:TextField(

        controller:controller,
        readOnly: widget.lectureSeule,


        decoration:InputDecoration(

          labelText:titre,

          prefixIcon:Icon(
            icon,
            color:Colors.blueAccent,
          ),


          filled:true,

          fillColor:Colors.grey.shade100,


          border:OutlineInputBorder(

            borderRadius:BorderRadius.circular(15),

            borderSide:BorderSide.none,

          ),

        ),

      ),

    );

  }





  @override
  Widget build(BuildContext context){


    return Scaffold(


      backgroundColor:Colors.grey.shade100,



      appBar:AppBar(

        title:const Text(
          "Informations professionnelles",
          style:TextStyle(
            fontWeight:FontWeight.bold,
          ),
        ),

        centerTitle:true,

        backgroundColor:Colors.blueAccent.shade700,

      ),




      body:SingleChildScrollView(


        padding:const EdgeInsets.all(20),


        child:Column(

          crossAxisAlignment:CrossAxisAlignment.start,


          children:[




            const Text(

              "Mon parcours sportif",

              style:TextStyle(

                fontSize:22,

                fontWeight:FontWeight.bold,

              ),

            ),



            const SizedBox(height:20),





            champ(
              "Club actuel",
              Icons.shield,
              clubController,
            ),



            champ(
              "Année d'arrivée au club",
              Icons.calendar_month,
              anneeController,
            ),




            const SizedBox(height:15),



            const Text(

              "Présentation du joueur",

              style:TextStyle(

                fontWeight:FontWeight.bold,

                fontSize:17,

              ),

            ),



            const SizedBox(height:10),



            TextField(

              controller:presentationController,
              readOnly: widget.lectureSeule,


              maxLines:5,


              decoration:InputDecoration(

                hintText:
                "Décris ton parcours, tes qualités, tes objectifs...",


                filled:true,

                fillColor:Colors.grey.shade100,


                border:OutlineInputBorder(

                  borderRadius:BorderRadius.circular(15),

                  borderSide:BorderSide.none,

                ),


              ),

            ),




            const SizedBox(height:25),





// PHOTOS


            Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,


              children:[


                const Text(

                  "Photos de match (max 4)",

                  style:TextStyle(
                    fontWeight:FontWeight.bold,
                    fontSize:17,
                  ),

                ),



                IconButton(

                  onPressed:ajouterPhoto,

                  icon:const Icon(
                    Icons.add_a_photo,
                    color:Colors.blue,
                  ),

                )


              ],

            ),





            Wrap(


              spacing:10,

              children:


              photosJeu.map((photo){


                return ClipRRect(

                  borderRadius:
                  BorderRadius.circular(12),


                  child:Image.file(

                    photo,

                    height:80,

                    width:80,

                    fit:BoxFit.cover,

                  ),


                );


              }).toList(),


            ),




            const SizedBox(height:30),




// VIDEOS


            // VIDEO LIEN

            const Text(

              "Vidéo de jeu",

              style:TextStyle(

                fontWeight:FontWeight.bold,

                fontSize:17,

              ),

            ),


            const SizedBox(height:10),



            TextField(

              controller: videoUrlController,
              readOnly: widget.lectureSeule,

              keyboardType: TextInputType.url,


              decoration:InputDecoration(

                hintText:
                "Colle le lien YouTube, TikTok ou Vimeo",


                prefixIcon:const Icon(

                  Icons.video_library,

                  color:Colors.blue,

                ),


                filled:true,

                fillColor:Colors.grey.shade100,


                border:OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(15),

                  borderSide:BorderSide.none,

                ),

              ),

            ),




            const SizedBox(height:10),









            const SizedBox(height:40),



            if(!widget.lectureSeule)
            SizedBox(

              width:double.infinity,

              height:55,

              child:ElevatedButton(

                style:ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.blueAccent.shade700,


                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(15),

                  ),

                ),

                onPressed: chargement
                    ? null
                    : enregistrerClub,

                child: chargement

                    ? const SizedBox(

                  height:25,

                  width:25,

                  child: CircularProgressIndicator(

                    color: Colors.white,

                    strokeWidth:3,

                  ),

                )


                    : Text(
                  profilTermine
                      ?"Profil déjà terminé"
                      : "Terminer mon profil",

                  style:TextStyle(

                    color:Colors.white,

                    fontSize:18,

                    fontWeight:FontWeight.bold,

                  ),

                ),

              ),

            ),
            const
            SizedBox(height:40),
            ElevatedButton.icon(

              onPressed:(){

                setState(() {
                  profilTermine = false;
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:(context)=>
                    InformationProfessionnellePage( playerId: widget.playerId,),
                  ),
                );

              },


              icon:const Icon(
                Icons.add,
                color:Colors.white,
              ),


              label:const Text(
                "Ajouter un autre club",
                style:TextStyle(
                  color:Colors.white,
                ),
              ),


              style:ElevatedButton.styleFrom(

                backgroundColor:
                Colors.green,

                minimumSize:
                const Size(double.infinity,55),

                shape:
                RoundedRectangleBorder(

                  borderRadius:
                  BorderRadius.circular(15),

                ),

              ),

            )




          ],

        ),


      ),


    );


  }



}