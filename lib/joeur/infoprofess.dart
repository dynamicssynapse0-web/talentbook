import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Slivepage/GaleriePhotosPage.dart';
import '../Slivepage/photo.dart';


class InformationsProfessionnellesPage extends StatefulWidget {
  final String playerId;
  final bool lectureSeule;

  const InformationsProfessionnellesPage({

    super.key,
    required this.playerId,
    this.lectureSeule = false,
  });


  @override
  State<InformationsProfessionnellesPage> createState() =>
      _InformationsProfessionnellesPageState();

}




class _InformationsProfessionnellesPageState
    extends State<InformationsProfessionnellesPage> {


  List<dynamic> clubs = [];

  bool chargement = true;



  @override
  void initState(){

    super.initState();

    chargerClubs();

  }


  Future<void> supprimerClub(dynamic club) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Supprimer"),
          content: const Text(
            "Voulez-vous vraiment supprimer cette expérience professionnelle ?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );

    if (confirmer != true) return;

    try {
      await Supabase.instance.client
          .from("player_clubs")
          .delete()
          .eq("id", club["id"]);

      setState(() {
        clubs.removeWhere((c) => c["id"] == club["id"]);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Expérience supprimée."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<void> chargerClubs() async {


    try {


      final user =
          Supabase.instance.client.auth.currentUser;



      if(user == null){

        setState(() {

          chargement=false;

        });

        return;

      }



      final data =
      await Supabase.instance.client
          .from("player_clubs")
          .select()
          .eq(
          "user_id",
          user.id
      )
          .order(
          "created_at",
          ascending:false
      );




      setState(() {

        clubs=data;

        chargement=false;

      });



    }

    catch(e){


      print(
          "ERREUR CHARGEMENT CLUB : $e"
      );


      setState(() {

        chargement=false;

      });


    }


  }



  Widget afficherPhotos(dynamic photos){

    if(photos == null || photos.isEmpty){

      return const Text(
        "Aucune photo disponible",
      );

    }


    return SizedBox(

      height:130,


      child:ListView.builder(


        scrollDirection:
        Axis.horizontal,


        itemCount:
        photos.length,


        itemBuilder:(context,index){


          return GestureDetector(


            onTap:(){


              Navigator.push(


                context,


                MaterialPageRoute(


                  builder:(context)=>GaleriePhotosPage(


                    photos:
                    List<String>.from(photos),


                    indexInitial:
                    index,


                  ),


                ),


              );


            },



            child:Container(


              margin:
              const EdgeInsets.only(

                right:12,

              ),



              width:130,



              child:ClipRRect(


                borderRadius:
                BorderRadius.circular(15),



                child:Image.network(


                  photos[index],


                  fit:
                  BoxFit.cover,


                ),


              ),


            ),


          );


        },


      ),


    );


  }



  Future<void> ouvrirVideo(String? url) async {


    print(
        "OUVERTURE VIDEO : $url"
    );


    if(url==null ||
        url.trim().isEmpty){


      print(
          "URL VIDEO VIDE"
      );


      return;

    }



    final Uri uri =
    Uri.parse(
        url.trim()
    );



    try{


      bool ouvert =
      await launchUrl(

        uri,

        mode:
        LaunchMode.externalApplication,

      );



      if(!ouvert){

        print(
            "Impossible ouvrir URL"
        );

      }


    }

    catch(e){

      print(
          "ERREUR URL : $e"
      );

    }



  }



  Widget carteClub(dynamic club) {
    final user = Supabase.instance.client.auth.currentUser;

    final bool estProprietaire =
        user != null && club["user_id"] == user.id;
    final video = club["video_url"]?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. EN-TÊTE PRINCIPAL (Nom, Année & Badge)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.blue.shade100],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.blue, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club["club"] ?? "Club anonyme",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Text(
                            "Saison ${club["annee"] ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. PRÉSENTATION
          if (club["presentation"] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                club["presentation"],
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ),

          const SizedBox(height: 20),

          // 3. PHOTOS (Section intégrée de façon plus fluide)
          if (club["photos"] != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.collections_outlined, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    "Galerie photos",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: afficherPhotos(club["photos"]),
            ),
            const SizedBox(height: 20),
          ],

          // 4. VIDÉO DE JEU (Format "Card" cliquable)
          if (video != null && video.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.grey.shade50,
                  child: InkWell(
                    onTap: () => ouvrirVideo(video),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Voir la vidéo du match",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  video,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (estProprietaire)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => supprimerClub(club),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text("Supprimer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }










  @override
  Widget build(BuildContext context){



    return Scaffold(



      backgroundColor:
      Colors.grey.shade100,




      appBar:
      AppBar(



        title:
        const Text(

          "Informations professionnelles",

          style:
          TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),



        centerTitle:true,



        backgroundColor:
        Colors.blueAccent.shade700,



      ),





      body:



      chargement



          ?



      const Center(

        child:
        CircularProgressIndicator(),

      )




          : clubs.isEmpty



          ?



      const Center(

        child:

        Text(

          "Aucune expérience professionnelle",

          style:
          TextStyle(

            fontSize:18,

          ),

        ),

      )





          :



      ListView.builder(



        padding:
        const EdgeInsets.all(20),



        itemCount:
        clubs.length,



        itemBuilder:(context,index){


          return carteClub(
              clubs[index]
          );


        },


      ),



    );


  }


}


