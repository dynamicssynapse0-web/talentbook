import 'package:LESWAYS/recrutuer/profil_recruteur_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class DetailRecruteurPage extends StatefulWidget {


  final Map<String,dynamic> recruteur;


  const DetailRecruteurPage({

    super.key,

    required this.recruteur,

  });



  @override
  State<DetailRecruteurPage> createState()
  => _DetailRecruteurPageState();


}





class _DetailRecruteurPageState
    extends State<DetailRecruteurPage>{


  final supabase =
      Supabase.instance.client;



  bool suppression = false;



  Future supprimerProfil() async {


    final confirmation =
    await showDialog<bool>(

      context: context,

      builder:(context){

        return AlertDialog(

          title:
          const Text(
              "Supprimer le profil"
          ),


          content:
          const Text(
              "Voulez-vous supprimer définitivement ce profil recruteur ?"
          ),


          actions:[


            TextButton(

              onPressed:(){

                Navigator.pop(
                    context,
                    false
                );

              },

              child:
              const Text(
                  "Annuler"
              ),

            ),



            ElevatedButton(

              style:
              ElevatedButton.styleFrom(

                backgroundColor:
                Colors.red,

              ),

              onPressed:(){

                Navigator.pop(
                    context,
                    true
                );

              },

              child:
              const Text(
                  "Supprimer"
              ),

            ),


          ],

        );


      },

    );



    if(confirmation != true)
      return;



    setState(() {

      suppression=true;

    });



    try{


      await supabase

          .from("profils_recruteurs")

          .delete()

          .eq(

          "id",

          widget.recruteur["id"]

      );



      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
              "Profil recruteur supprimé"
          ),

          backgroundColor:
          Colors.green,

        ),

      );



      Navigator.pop(context);



    }

    catch(e){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
              "Erreur : $e"
          ),

        ),

      );


    }


    setState(() {

      suppression=false;

    });



  }







  Widget info(

      String titre,

      String? valeur,

      IconData icon

      ){


    return Card(

      elevation:2,

      margin:
      const EdgeInsets.symmetric(
          vertical:8
      ),


      child:
      ListTile(

        leading:
        Icon(
            icon,
            color:
            Colors.blueAccent
        ),


        title:
        Text(

          titre,

          style:
          const TextStyle(

            fontSize:13,

            color:
            Colors.grey,

          ),

        ),


        subtitle:
        Text(

          valeur ??
              "Non renseigné",

          style:
          const TextStyle(

            fontSize:17,

            fontWeight:
            FontWeight.w600,

          ),

        ),

      ),


    );


  }







  @override
  Widget build(BuildContext context){


    final r =
        widget.recruteur;



    return Scaffold(


      backgroundColor:
      Colors.grey.shade100,


      appBar:
      AppBar(

        backgroundColor:
        Colors.blueAccent.shade700,


        title:
        const Text(
            "Profil recruteur"
        ),


        centerTitle:true,


      ),




      body:
      SingleChildScrollView(


        padding:
        const EdgeInsets.all(20),


        child:
        Column(


          children:[




            // LOGO

            CircleAvatar(

              radius:
              60,


              backgroundColor:
              Colors.white,


              backgroundImage:

              r["logo_url"] != null

                  ?

              NetworkImage(
                  r["logo_url"]
              )

                  :

              null,


              child:

              r["logo_url"] == null

                  ?

              const Icon(

                Icons.business,

                size:50,

                color:
                Colors.blue,

              )

                  :

              null,


            ),




            const SizedBox(
                height:20
            ),




            Text(

              r["nom_club"] ?? "",


              style:
              const TextStyle(

                fontSize:26,

                fontWeight:
                FontWeight.bold,

              ),

            ),



            const SizedBox(
                height:25
            ),





            info(

                "Pays",

                r["pays"],

                Icons.public

            ),




            info(

                "Ville",

                r["ville"],

                Icons.location_city

            ),





            info(

                "Contact WhatsApp",

                r["contact"],

                Icons.phone

            ),





            info(

                "Présentation",

                r["description"],

                Icons.description

            ),





            const SizedBox(
                height:25
            ),





            // MODIFIER

            SizedBox(

              width:
              double.infinity,


              child:
              ElevatedButton.icon(


                icon:
                const Icon(
                    Icons.edit
                ),


                label:
                const Text(
                    "Modifier"
                ),



                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.blueAccent,

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets.all(15),

                ),



                onPressed:(){


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder:(_)=>

                          ProfilRecruteurPage(

                            recruteurId:
                            r["id"],

                          ),

                    ),

                  );


                },


              ),


            ),





            const SizedBox(
                height:15
            ),






            // SUPPRIMER


            SizedBox(

              width:
              double.infinity,


              child:
              ElevatedButton.icon(


                icon:

                suppression

                    ?

                const CircularProgressIndicator(

                  color:Colors.white,

                )

                    :

                const Icon(
                    Icons.delete
                ),



                label:

                const Text(
                    "Supprimer"
                ),



                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.red,

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets.all(15),

                ),



                onPressed:

                suppression

                    ?

                null

                    :

                supprimerProfil,


              ),

            ),



          ],


        ),


      ),


    );


  }


}