import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../joeur/infospersonnelle.dart';

class CandidaturesRecuesPage extends StatefulWidget {

  final String annonceId;

  const CandidaturesRecuesPage({

    super.key,

    required this.annonceId,

  });


  @override
  State<CandidaturesRecuesPage> createState() =>
      _CandidaturesRecuesPageState();

}




class _CandidaturesRecuesPageState
    extends State<CandidaturesRecuesPage> {


  final supabase =
      Supabase.instance.client;


  List candidatures=[];


  bool chargement=true;




  @override
  void initState(){

    super.initState();

    chargerCandidatures();

  }

  Future<void> confirmerDecision(
      String candidatureId,
      String statut,
      dynamic candidature,
      ) async {


    final confirmation = await showDialog<bool>(

      context: context,

      builder:(context){

        return AlertDialog(

          title:
          const Text("Confirmation"),

          content:
          const Text(
            "Cette action va supprimer cette candidature.\n\n"
                "Voulez-vous continuer ?",
          ),

          actions:[

            TextButton(

              onPressed:(){

                Navigator.pop(context,false);

              },

              child:
              const Text("Annuler"),

            ),


            ElevatedButton(

              style:
              ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),

              onPressed:(){

                Navigator.pop(context,true);

              },

              child:
              const Text("Continuer"),

            ),

          ],

        );

      },

    );


    if(confirmation != true){
      return;
    }



    try{


      String titre;
      String message;
      String? whatsapp;



      if(statut == "Acceptée"){


        whatsapp =
        candidature["profils_recruteurs"]?["contact"];


        titre =
        "Candidature acceptée 🎉";


        message =
        "Votre candidature a été acceptée.\n\n"
            "Le recruteur souhaite vous contacter.\n\n"
            "WhatsApp : ${whatsapp ?? ''}";



      }else{


        titre =
        "Candidature refusée";


        message =
        "Votre candidature n'a pas été retenue.";


      }




      // CREATION NOTIFICATION JOUEUR

      await supabase
          .from("notifications")
          .insert({


        "user_id":
        candidature["joueur_id"],


        "titre":
        titre,


        "message":
        message,


        "type":
        "recrutement",


        // seulement si acceptée
        if(whatsapp != null)
          "whatsapp": whatsapp,


      });



      // SUPPRESSION CANDIDATURE

      await supabase
          .from("candidatures")
          .delete()
          .eq(
        "id",
        candidatureId,
      );



      await chargerCandidatures();



      if(mounted){

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content: Text(
                statut == "Acceptée"
                    ? "Candidature acceptée"
                    : "Candidature refusée"
            ),

            backgroundColor:
            Colors.green,

          ),

        );

      }



    }catch(e){


      print(
          "ERREUR DECISION : $e"
      );


      if(mounted){

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content:
            Text(
                "Erreur : $e"
            ),

            backgroundColor:
            Colors.red,

          ),

        );

      }

    }


  }

  Future<void> chargerCandidatures() async {


    try{


      final data = await supabase

          .from("candidatures")

          .select('''
          
          *,
          
          player(
          
            nom,
            age,
            ville,
            poste,
            photo_url,
            whatsapp
          
          )
          
          profils_recruteurs(

         contact,
         nom_club

      )
          
          ''')

          .eq(
          "annonce_id",
          widget.annonceId
      )

          .order(

          "created_at",

          ascending:false

      );




      setState((){


        candidatures=data;

        chargement=false;


      });



    }

    catch(e){


      print(e);


      setState((){

        chargement=false;

      });


    }


  }

  Future<void> changerStatut(

      String id,

      String statut,

      dynamic candidature

      ) async {



    await supabase

        .from("candidatures")

        .update({

      "statut": statut

    })

        .eq(

        "id",

        id

    );





    String message;



    if(statut=="Acceptée"){


      final contact =
      candidature["profils_recruteurs"]["contact"];


      message =
      "Votre candidature a été acceptée.\n\n"
          "Le recruteur souhaite vous contacter.";
    }

    else{


      message =

      "Votre candidature n'a pas été retenue.";

    }





    await supabase

        .from("notifications")

        .insert({

      "user_id":
      candidature["joueur_id"],


      "titre":

      statut=="Acceptée"

          ?

      "Candidature acceptée 🎉"

          :

      "Candidature refusée",



      "message":
      message,


      "type":
      "recrutement"


    });



    chargerCandidatures();


  }












  Widget carteCandidat(dynamic candidature){


    final joueur =
    candidature["player"];



    return Container(


      margin:
      const EdgeInsets.only(

          bottom:15

      ),



      padding:
      const EdgeInsets.all(18),



      decoration:
      BoxDecoration(

        color:Colors.white,

        borderRadius:
        BorderRadius.circular(22),

      ),



      child:Column(

        children:[



          Row(

            children:[



              CircleAvatar(

                radius:35,


                backgroundImage:

                joueur["photo_url"] != null

                    ?

                NetworkImage(
                    joueur["photo_url"]
                )

                    :

                null,


              ),



              const SizedBox(width:15),



              Expanded(

                child:Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children:[



                    Text(

                      joueur["nom"],

                      style:
                      const TextStyle(

                        fontSize:18,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),



                    Text(

                      "${joueur["poste"]} • ${joueur["age"]} ans",

                    ),



                    Text(

                      joueur["ville"] ?? "",

                      style:
                      TextStyle(

                        color:
                        Colors.grey.shade600,

                      ),

                    ),



                  ],


                ),

              ),



            ],

          ),



          const SizedBox(height:15),
          SizedBox(

            width: double.infinity,

            child: OutlinedButton.icon(

              icon:
              const Icon(
                Icons.person_search,
              ),


              label:
              const Text(
                "Voir le profil sportif",
              ),


              style:
              OutlinedButton.styleFrom(

                foregroundColor:
                Colors.blueAccent.shade700,


                padding:
                const EdgeInsets.symmetric(

                  vertical:14,

                ),


                shape:
                RoundedRectangleBorder(

                  borderRadius:
                  BorderRadius.circular(15),

                ),

              ),



              onPressed:(){

                print("CANDIDATURE COMPLETE : $candidature");
                print("JOUEUR : $joueur");

                print("CANDIDATURE : $candidature");
                print("JOUEUR ID : ${candidature["joueur_id"]}");
                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:(context)=>

                        InformationsPersonnellesPage(

                          playerId:

                          candidature["joueur_id"].toString(),

                          lectureSeule:true,

                        ),

                  ),

                );


              },


            ),

          ),


          const SizedBox(height:15),



          if(candidature["message"] != null)

            Text(

              candidature["message"],

            ),



          const SizedBox(height:15),




          Row(

            children:[


              Expanded(

                child:ElevatedButton(

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    Colors.green,

                  ),

                  onPressed:(){

                    confirmerDecision(

                      candidature["id"],

                      "Acceptée",

                      candidature,

                    );

                  },

                  child:
                  const Text(
                      "Accepter"
                  ),

                ),

              ),



              const SizedBox(width:10),



              Expanded(

                child:ElevatedButton(

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    Colors.red,

                  ),

                  onPressed:(){

                    confirmerDecision(

                      candidature["id"],

                      "Refusée",

                      candidature,

                    );

                  },

                  child:
                  const Text(
                      "Refuser"
                  ),

                ),

              ),



            ],

          )


        ],

      ),


    );


  }







  @override
  Widget build(BuildContext context){


    return Scaffold(


      appBar:AppBar(

        title:
        const Text(
            "Candidatures reçues"
        ),

        backgroundColor:
        Colors.blueAccent.shade700,

      ),




      backgroundColor:
      Colors.grey.shade100,




      body:


      chargement

          ?

      const Center(

        child:
        CircularProgressIndicator(),

      )


          :


      candidatures.isEmpty

          ?


      const Center(

        child:
        Text(
            "Aucune candidature"
        ),

      )


          :


      ListView.builder(


        padding:
        const EdgeInsets.all(20),



        itemCount:
        candidatures.length,



        itemBuilder:(context,index){


          return carteCandidat(

              candidatures[index]

          );


        },


      ),


    );


  }


}