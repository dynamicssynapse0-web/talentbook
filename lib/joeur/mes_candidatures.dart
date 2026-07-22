import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class MesCandidaturesPage extends StatefulWidget {

  const MesCandidaturesPage({
    super.key,
  });


  @override
  State<MesCandidaturesPage> createState() =>
      _MesCandidaturesPageState();

}



class _MesCandidaturesPageState
    extends State<MesCandidaturesPage> {


  final supabase =
      Supabase.instance.client;


  List candidatures = [];

  bool chargement = true;



  @override
  void initState(){

    super.initState();

    chargerMesCandidatures();

  }




  Future<void> chargerMesCandidatures() async {


    final user =
        supabase.auth.currentUser;


    if(user == null){

      return;

    }



    try{


      final data = await supabase

          .from("candidatures")

          .select('''

          *,

          annonces_recrutements(

            titre,
            club,
            ville

          )

          ''')

          .eq(
          "joueur_id",
          user.id
      )

          .order(
          "created_at",
          ascending:false
      );



      setState((){

        candidatures = data;

        chargement = false;

      });



    }catch(e){


      print(
          "ERREUR MES CANDIDATURES : $e"
      );


      setState((){

        chargement=false;

      });


    }


  }





  @override
  Widget build(BuildContext context){


    return Scaffold(


      appBar: AppBar(

        title:
        const Text(
            "Mes candidatures"
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
            "Vous n'avez envoyé aucune candidature"
        ),

      )


          :



      ListView.builder(

        padding:
        const EdgeInsets.all(20),


        itemCount:
        candidatures.length,


        itemBuilder:(context,index){


          final candidature =
          candidatures[index];


          final annonce =
          candidature["annonces_recrutements"];



          return Container(


            margin:
            const EdgeInsets.only(
                bottom:15
            ),


            padding:
            const EdgeInsets.all(18),


            decoration:
            BoxDecoration(

              color:
              Colors.white,

              borderRadius:
              BorderRadius.circular(20),

            ),


            child:Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,


              children:[


                Text(

                  annonce["titre"]
                      ??
                      "Annonce",

                  style:
                  const TextStyle(

                    fontSize:18,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),


                const SizedBox(height:8),



                Text(

                  annonce["club"]
                      ??
                      "",

                ),


                Text(

                  annonce["ville"]
                      ??
                      "",

                ),



                const SizedBox(height:15),



                Text(

                  "Statut : ${candidature["statut"]}",

                  style:
                  const TextStyle(

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),



              ],

            ),



          );


        },


      ),


    );


  }


}