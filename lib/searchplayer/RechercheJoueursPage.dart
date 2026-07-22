import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../joeur/infospersonnelle.dart';



class RechercheJoueursPage extends StatefulWidget {

  const RechercheJoueursPage({super.key});


  @override
  State<RechercheJoueursPage> createState() =>
      _RechercheJoueursPageState();

}



class _RechercheJoueursPageState
    extends State<RechercheJoueursPage> {


  final supabase =
      Supabase.instance.client;


  List<dynamic> joueurs = [];

  List<dynamic> resultats = [];


  bool chargement = true;



  final rechercheController =
  TextEditingController();



  String? posteSelectionne;
  String? disciplineSelectionnee;
  String? paysSelectionne;



  final postes = [
    "Gardien",
    "Défenseur",
    "Milieu",
    "Attaquant",
  ];


  final disciplines = [
    "Football",
    "Athlétisme",
    "Basket",
    "Handball",
  ];



  @override
  void initState(){

    super.initState();

    chargerJoueurs();


    rechercheController.addListener((){

      filtrer();

    });

  }




  Future<void> chargerJoueurs() async {


    try{


      final data =
      await supabase
          .from("player")
          .select()
          .order(
          "created_at",
          ascending:false
      );



      setState(() {

        joueurs = data;

        resultats = data;

        chargement=false;

      });


    }

    catch(e){


      print(
          "Erreur joueurs : $e"
      );


      setState(() {

        chargement=false;

      });


    }


  }




  void filtrer(){


    final recherche =
    rechercheController.text
        .toLowerCase();



    setState(() {


      resultats =
          joueurs.where((joueur){



            final nom =
            joueur["nom"]
                .toString()
                .toLowerCase();



            final correspondNom =
                recherche.isEmpty ||
                    nom.contains(recherche);



            final correspondPoste =
                posteSelectionne == null ||
                    joueur["poste"] ==
                        posteSelectionne;



            final correspondDiscipline =
                disciplineSelectionnee == null ||
                    joueur["discipline"] ==
                        disciplineSelectionnee;



            final correspondPays =
                paysSelectionne == null ||
                    joueur["pays"] ==
                        paysSelectionne;



            return
              correspondNom &&
                  correspondPoste &&
                  correspondDiscipline &&
                  correspondPays;



          }).toList();



    });


  }





  Widget filtreDropdown({

    required String titre,

    required String? valeur,

    required List<String> items,

    required Function(String?) onChanged,

  }){


    return Expanded(

      child: DropdownButtonFormField<String>(


        value: valeur,


        decoration: InputDecoration(


          labelText: titre,


          filled:true,


          fillColor:
          Colors.white,


          border:
          OutlineInputBorder(

            borderRadius:
            BorderRadius.circular(15),

          ),

        ),


        items:
        [

          const DropdownMenuItem(

            value:null,

            child:
            Text("Tous"),

          ),


          ...items.map((e)=>

              DropdownMenuItem(

                value:e,

                child:
                Text(e),

              )

          )

        ],


        onChanged:onChanged,


      ),

    );


  }






  Widget carteJoueur(dynamic joueur){



    return GestureDetector(


      onTap:(){



        Navigator.push(


          context,


          MaterialPageRoute(


            builder:(context)=>

                InformationsPersonnellesPage(


                  playerId:
                  joueur["user_id"],


                  lectureSeule:true,

                ),


          ),


        );

      },



      child:Container(


        margin:
        const EdgeInsets.only(
            bottom:15
        ),



        padding:
        const EdgeInsets.all(15),



        decoration:
        BoxDecoration(


          color:
          Colors.white,


          borderRadius:
          BorderRadius.circular(22),



          boxShadow:[

            BoxShadow(

              color:
              Colors.black.withOpacity(.05),

              blurRadius:15,

              offset:
              const Offset(0,8),

            )

          ],

        ),



        child:Row(


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


              child:
              joueur["photo_url"] == null

                  ?

              const Icon(
                  Icons.person
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

                    joueur["nom"]
                        ??
                        "Sans nom",

                    style:
                    const TextStyle(

                      fontSize:18,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),



                  const SizedBox(height:5),



                  Text(

                    "${joueur["poste"] ?? "Poste inconnu"} • ${joueur["age"] ?? "--"} ans",

                    style:
                    TextStyle(

                      color:
                      Colors.grey.shade700,

                    ),

                  ),



                  const SizedBox(height:5),



                  Text(

                    "${joueur["ville"] ?? ""} - ${joueur["pays"] ?? ""}",

                    style:
                    TextStyle(

                      color:
                      Colors.grey.shade600,

                    ),

                  ),



                  const SizedBox(height:5),



                  Row(

                    children:[

                      const Icon(

                        Icons.people,

                        size:16,

                        color:Colors.blue,

                      ),


                      const SizedBox(width:5),


                      Text(

                        "${joueur["followers_count"] ?? 0} followers",

                      )

                    ],

                  )



                ],


              ),

            ),



            const Icon(

              Icons.chevron_right,

              color:Colors.grey,

            )


          ],


        ),



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
            "Recherche joueurs"
        ),


        backgroundColor:
        Colors.blueAccent.shade700,


        centerTitle:true,


      ),




      body:


      chargement


          ?


      const Center(
          child:
          CircularProgressIndicator()
      )



          :


      Column(


        children:[



          Padding(

            padding:
            const EdgeInsets.all(15),


            child:TextField(


              controller:
              rechercheController,


              decoration:
              InputDecoration(


                hintText:
                "Nom du joueur...",


                prefixIcon:
                const Icon(Icons.search),


                filled:true,


                fillColor:
                Colors.white,


                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(20),

                ),

              ),


            ),

          ),




          Padding(

            padding:
            const EdgeInsets.symmetric(
                horizontal:15
            ),


            child:Row(

              children:[


                filtreDropdown(

                  titre:"Poste",

                  valeur:
                  posteSelectionne,

                  items:
                  postes,

                  onChanged:(v){

                    posteSelectionne=v;

                    filtrer();

                  },

                ),


                const SizedBox(width:10),


                filtreDropdown(

                  titre:"Discipline",

                  valeur:
                  disciplineSelectionnee,

                  items:
                  disciplines,

                  onChanged:(v){

                    disciplineSelectionnee=v;

                    filtrer();

                  },

                ),


              ],

            ),

          ),




          const SizedBox(height:10),



          Expanded(


            child:
            ListView.builder(


              padding:
              const EdgeInsets.all(15),


              itemCount:
              resultats.length,


              itemBuilder:(context,index){


                return carteJoueur(

                    resultats[index]

                );


              },


            ),


          )


        ],


      ),


    );


  }



}