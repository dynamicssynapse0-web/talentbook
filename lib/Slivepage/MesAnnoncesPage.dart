import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../recrutuer/candidature.dart';




class MesAnnoncesPage extends StatefulWidget {

  const MesAnnoncesPage({super.key});


  @override
  State<MesAnnoncesPage> createState() =>
      _MesAnnoncesPageState();

}



class _MesAnnoncesPageState
    extends State<MesAnnoncesPage> {


  final supabase =
      Supabase.instance.client;


  List annonces = [];

  bool chargement = true;



  @override
  void initState(){

    super.initState();

    chargerAnnonces();

  }



  Future<void> chargerAnnonces() async {


    final user =
        supabase.auth.currentUser;


    if(user == null) return;



    try{


      final data = await supabase

          .from("annonces_recrutement")

          .select('''

            id,
            titre,
            club,
            poste,
            created_at

          ''')

          .eq(
          "recruteur_id",
          user.id
      )

          .order(
          "created_at",
          ascending:false
      );



      setState((){

        annonces=data;

        chargement=false;

      });



    }

    catch(e){

      print(
          "ERREUR MES ANNONCES : $e"
      );


      setState((){

        chargement=false;

      });

    }


  }





  Widget carteAnnonce(dynamic annonce){


    return Card(

      margin:
      const EdgeInsets.only(bottom:15),


      shape:
      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(20),

      ),


      child:ListTile(


        leading:
        const CircleAvatar(

          backgroundColor:
          Colors.blue,

          child:
          Icon(

            Icons.sports_soccer,

            color:Colors.white,

          ),

        ),



        title:
        Text(

          annonce["titre"] ?? "Annonce",

          style:
          const TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),



        subtitle:
        Text(

          "${annonce["club"] ?? ""} - ${annonce["poste"] ?? ""}",

        ),



        trailing:
        const Icon(
            Icons.arrow_forward_ios
        ),



        onTap:(){


          Navigator.push(

            context,

            MaterialPageRoute(

              builder:(_)=>

                  CandidaturesRecuesPage(

                    annonceId:
                    annonce["id"],

                  ),

            ),

          );


        },


      ),


    );


  }





  @override
  Widget build(BuildContext context){


    return Scaffold(


      appBar:
      AppBar(

        title:
        const Text(
            "Mes annonces"
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


      annonces.isEmpty

          ?

      const Center(

        child:
        Text(
            "Vous n'avez aucune annonce"
        ),

      )


          :


      ListView.builder(

        padding:
        const EdgeInsets.all(20),


        itemCount:
        annonces.length,


        itemBuilder:(context,index){


          return carteAnnonce(

              annonces[index]

          );


        },


      ),



    );


  }



}