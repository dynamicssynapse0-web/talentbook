import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../notif/payment_webview_page.dart';


class CreerAnnoncePage extends StatefulWidget {

  const CreerAnnoncePage({super.key});


  @override
  State<CreerAnnoncePage> createState() =>
      _CreerAnnoncePageState();

}



class _CreerAnnoncePageState
    extends State<CreerAnnoncePage> {

  Future<void> payerAnnonce() async {


    final user =
        supabase.auth.currentUser;


    if(user == null) return;



    try{


      final response =
      await http.post(

        Uri.parse(
            "https://TON_SERVEUR/api/create-announcement-payment"
        ),

        headers:{

          "Content-Type":"application/json"

        },


        body:jsonEncode({

          "userId":user.id,

        }),


      );



      final data =
      jsonDecode(response.body);



      if(data["success"]==true){


        Navigator.push(

          context,

          MaterialPageRoute(

            builder:(context)=>

                PaymentWebViewPage(

                  url:data["paymentUrl"],


                  onSuccess:(){

// après paiement réussi

                    publierAnnonceApresPaiement();


                  },


                ),


          ),

        );


      }



    }catch(e){


      print(
          "ERREUR PAIEMENT ANNONCE : $e"
      );


    }


  }
  Future<void> publierAnnonceApresPaiement() async {


    final user =
        supabase.auth.currentUser;


    final profilRecruteur =
    await supabase
        .from("profils_recruteurs")
        .select("user_id")
        .eq(
      "user_id",
      user!.id,
    )
        .single();



    await supabase
        .from("annonces_recrutement")
        .insert({

      "recruteur_id":
      profilRecruteur["user_id"],


      "titre":
      titreController.text.trim(),


      "club":
      clubController.text.trim(),


      "poste":
      poste,


      "age_min":
      int.tryParse(ageMinController.text),


      "age_max":
      int.tryParse(ageMaxController.text),


      "pays":
      paysController.text.trim(),


      "ville":
      villeController.text.trim(),


      "description":
      descriptionController.text.trim(),


      "prix":2000,


      "premium":true,


      "date_expiration":
      DateTime.now()
          .add(
          const Duration(days:90)
      )
          .toIso8601String(),

    });


    if(mounted){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
              "Annonce publiée avec succès ✅"
          ),

          backgroundColor:
          Colors.green,

        ),

      );


      Navigator.pop(context);

    }


  }
  final supabase =
      Supabase.instance.client;



  final titreController =
  TextEditingController();


  final clubController =
  TextEditingController();


  final descriptionController =
  TextEditingController();


  final villeController =
  TextEditingController();



  final paysController =
  TextEditingController();



  final ageMinController =
  TextEditingController();


  final ageMaxController =
  TextEditingController();



  String? poste;



  bool chargement=false;



  final postes=[

    "Gardien",

    "Défenseur",

    "Milieu",

    "Attaquant",
    "Autres",


  ];




  Future<void> publierAnnonce() async {


    final user =
        supabase.auth.currentUser;



    if(user == null){

      return;

    }
    // ===============================
// VERIFIER NOMBRE D'ANNONCES
// ===============================

    final nombreAnnonces = await supabase
        .from("annonces_recrutement")
        .select("id")
        .eq(
      "recruteur_id",
      user.id,
    );


    final bool premiereAnnonce =
        nombreAnnonces.length == 0;


    final int prixAnnonce =
    premiereAnnonce ? 0 : 2000;



    if(!premiereAnnonce){


      final accepter =
      await showDialog<bool>(

        context: context,

        builder:(context){

          return AlertDialog(

            title:
            const Text(
              "Annonce payante",
            ),

            content:
            const Text(
              "Votre première annonce était gratuite.\n\n"
                  "Les prochaines annonces coûtent 2000 FCFA "
                  "et restent visibles pendant 3 mois.",
            ),


            actions:[

              TextButton(

                onPressed:(){

                  Navigator.pop(
                    context,
                    false,
                  );

                },

                child:
                const Text(
                  "Annuler",
                ),

              ),


              ElevatedButton(

                onPressed:(){

                  Navigator.pop(
                    context,
                    true,
                  );

                },

                child:
                const Text(
                  "Continuer - 2000 FCFA",
                ),

              )

            ],

          );

        },

      );


      if(accepter != true){

        return;

      }
      if(!premiereAnnonce){

        await payerAnnonce();

        return;

      }

    }



    setState(() {

      chargement=true;

    });



    try{


      // ===============================
      // RECUPERER LE PROFIL RECRUTEUR
      // ===============================

      final profilRecruteur = await supabase
          .from("profils_recruteurs")
          .select("user_id")
          .eq(
        "user_id",
        user.id,
      )
          .maybeSingle();


      print("PROFIL RECRUTEUR = $profilRecruteur");
      print("PROFIL RECRUTEUR = $profilRecruteur");



      if(profilRecruteur == null){


        throw Exception(
            "Vous devez créer un profil recruteur avant de publier une annonce"
        );


      }




      // ===============================
      // CREATION DE L'ANNONCE
      // ===============================
      print("USER CONNECTE = ${user.id}");

      await supabase
          .from("annonces_recrutement")
          .insert({

        "recruteur_id":
        profilRecruteur["user_id"],


        "titre":
        titreController.text.trim(),


        "club":
        clubController.text.trim(),


        "poste":
        poste,


        "age_min":
        int.tryParse(ageMinController.text),


        "age_max":
        int.tryParse(ageMaxController.text),


        "pays":
        paysController.text.trim(),


        "ville":
        villeController.text.trim(),


        "description":
        descriptionController.text.trim(),


// NOUVEAUX CHAMPS

        "prix":
        prixAnnonce,


        "premium":
        !premiereAnnonce,


        "date_expiration":
        DateTime.now()
            .add(
            const Duration(days:90)
        )
            .toIso8601String(),

      });



      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
              "Annonce publiée avec succès"
          ),

          backgroundColor:
          Colors.green,

        ),

      );



      Navigator.pop(context);



    }

    catch(e){


      print(
          "ERREUR ANNONCE : $e"
      );


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



    setState(() {

      chargement=false;

    });



  }







  Widget champ(

      String label,

      TextEditingController controller,

      ){

    return Padding(

      padding:
      const EdgeInsets.only(bottom:15),

      child:TextField(

        controller:controller,


        decoration:InputDecoration(

          labelText:label,


          filled:true,


          fillColor:
          Colors.grey.shade100,


          border:
          OutlineInputBorder(

            borderRadius:
            BorderRadius.circular(15),

          ),

        ),

      ),

    );

  }





  @override
  Widget build(BuildContext context){

    return Scaffold(

      backgroundColor:
      const Color(0xffF5F7FB),


      appBar:
      AppBar(

        elevation:0,

        backgroundColor:
        Colors.blueAccent.shade700,


        title:
        const Text(

          "Créer une annonce",

          style:
          TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),



      body:

      SingleChildScrollView(


        padding:
        const EdgeInsets.all(18),



        child:Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children:[



            // ======================
            // INTRO
            // ======================


            Container(

              width:
              double.infinity,


              padding:
              const EdgeInsets.all(22),


              decoration:
              BoxDecoration(

                gradient:
                LinearGradient(

                  colors:[

                    Colors.blueAccent.shade700,

                    Colors.blue.shade400,

                  ],

                ),


                borderRadius:
                BorderRadius.circular(25),

              ),


              child:Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,


                children:[


                  const Icon(

                    Icons.search,

                    color:
                    Colors.white,

                    size:35,

                  ),


                  const SizedBox(height:10),


                  const Text(

                    "Trouvez votre prochain talent",

                    style:
                    TextStyle(

                      color:
                      Colors.white,

                      fontSize:22,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),


                  const SizedBox(height:5),


                  const Text(

                    "Publiez une annonce et recevez des candidatures de joueurs",

                    style:
                    TextStyle(

                      color:
                      Colors.white70,

                      fontSize:14,

                    ),

                  ),


                ],

              ),

            ),



            const SizedBox(height:25),



            // ======================
            // INFORMATIONS
            // ======================


            const Text(

              "Informations générales",

              style:
              TextStyle(

                fontSize:20,

                fontWeight:
                FontWeight.bold,

              ),

            ),


            const SizedBox(height:12),



            champ(
                "Titre de l'annonce",
                titreController
            ),



            const SizedBox(height:12),



            champ(
                "Club / Structure",
                clubController
            ),



            const SizedBox(height:15),




            Container(

              padding:
              const EdgeInsets.symmetric(

                horizontal:15,

                vertical:5,

              ),


              decoration:
              BoxDecoration(

                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(18),

              ),


              child:
              DropdownButtonFormField<String>(


                decoration:
                const InputDecoration(

                  labelText:
                  "Poste recherché",

                  border:
                  InputBorder.none,

                ),



                items:

                postes.map((e)=>

                    DropdownMenuItem(

                      value:e,

                      child:
                      Text(e),

                    )

                ).toList(),



                onChanged:(v){

                  setState(() {

                    poste=v;

                  });

                },


              ),

            ),



            const SizedBox(height:25),




            // ======================
            // PROFIL RECHERCHE
            // ======================


            const Text(

              "Profil recherché",

              style:
              TextStyle(

                fontSize:20,

                fontWeight:
                FontWeight.bold,

              ),

            ),



            const SizedBox(height:12),



            Row(

              children:[


                Expanded(

                  child:
                  champ(

                      "Age minimum",

                      ageMinController

                  ),

                ),


                const SizedBox(width:12),


                Expanded(

                  child:
                  champ(

                      "Age maximum",

                      ageMaxController

                  ),

                ),


              ],

            ),




            const SizedBox(height:15),




            Row(

              children:[


                Expanded(

                  child:
                  champ(

                      "Pays",

                      paysController

                  ),

                ),


                const SizedBox(width:12),


                Expanded(

                  child:
                  champ(

                      "Ville",

                      villeController

                  ),

                ),


              ],

            ),




            const SizedBox(height:25),




            const Text(

              "Présentation de l'offre",

              style:
              TextStyle(

                fontSize:20,

                fontWeight:
                FontWeight.bold,

              ),

            ),



            const SizedBox(height:12),




            champ(

                "Description",

                descriptionController

            ),



            const SizedBox(height:30),




            // ======================
            // PUBLICATION
            // ======================


            SizedBox(

              width:
              double.infinity,


              height:
              60,


              child:
              ElevatedButton.icon(


                icon:

                const Icon(

                  Icons.publish,

                ),



                label:

                chargement

                    ?

                const CircularProgressIndicator(

                  color:
                  Colors.white,

                )


                    :

                const Text(

                  "PUBLIER L'ANNONCE",

                  style:
                  TextStyle(

                    fontSize:17,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),



                style:
                ElevatedButton.styleFrom(


                  backgroundColor:
                  Colors.blueAccent.shade700,


                  foregroundColor:
                  Colors.white,


                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(20),

                  ),

                ),



                onPressed:

                chargement

                    ?

                null

                    :

                publierAnnonce,


              ),

            ),



            const SizedBox(height:20),


          ],

        ),

      ),

    );
  }
  }