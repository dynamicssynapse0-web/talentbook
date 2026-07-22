import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login.dart';

class DetailAnnoncePage extends StatefulWidget {

  final dynamic annonce;

  const DetailAnnoncePage({

    super.key,

    required this.annonce,

  });

  @override
  State<DetailAnnoncePage> createState() =>
      _DetailAnnoncePageState();

}

class _DetailAnnoncePageState
    extends State<DetailAnnoncePage> {

  bool chargement = false;

  final messageController =
  TextEditingController();

  Future<void> candidater() async {

    final user =
        Supabase.instance.client.auth.currentUser;
    if(user==null){

      Navigator.push(

        context,

        MaterialPageRoute(

          builder:(_)=> const LoginPage(),

        ),

      );


      return;

    }

    setState(() {

      chargement=true;

    });

    try{

      final existe =
      await Supabase.instance.client

          .from("candidatures")

          .select()

          .eq(
          "annonce_id",
          widget.annonce["id"]
      )

          .eq(
          "joueur_id",
          user.id
      );

      if(existe.isNotEmpty){

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            content: Text(
                "Vous avez déjà candidaté."
            ),

          ),

        );

        setState(() {

          chargement=false;

        });

        return;

      }

      await Supabase.instance.client

          .from("candidatures")

          .insert({

        "annonce_id":
        widget.annonce["id"],

        "recruteur_id":
        widget.annonce["recruteur_id"],

        "joueur_id":
        user.id,

        "message":
        messageController.text.trim(),

        "statut":
        "En attente",

      });
      // Notification recruteur
      print("ANNONCE COMPLETE : ${widget.annonce}");
      print("ID ANNONCE : ${widget.annonce["id"]}");

      // Notification recruteur

      await Supabase.instance.client
          .from("notifications")
          .insert({

        "user_id":
        widget.annonce["recruteur_id"],


        "titre":
        "Nouvelle candidature",


        "message":
        "Un joueur a candidaté pour ${widget.annonce["titre"]}",


        "type":
        "candidature",


        "annonce_id":
        widget.annonce["id"],


        "lu":
        false,


      });


      if(mounted){

        showDialog(

          context: context,

          builder:(_){

            return AlertDialog(

              shape: RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(20),

              ),

              title:
              const Text("Bravo 🎉"),

              content:
              const Text(

                "Votre candidature a été envoyée au recruteur.",

              ),

              actions:[

                TextButton(

                  onPressed:(){

                    Navigator.pop(context);

                    Navigator.pop(context);

                  },

                  child:
                  const Text("OK"),

                )

              ],

            );

          },

        );

      }

    }

    catch(e){

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content:
          Text(e.toString()),

        ),

      );

    }

    setState(() {

      chargement=false;

    });

  }

  Widget ligne(

      IconData icon,

      String texte){

    return Row(

      children:[

        Icon(

          icon,

          color:Colors.blue,

        ),

        const SizedBox(width:10),

        Expanded(

          child:Text(

            texte,

            style: const TextStyle(

              fontSize:15,

            ),

          ),

        )

      ],

    );

  }

  @override
  Widget build(BuildContext context){

    final annonce =
        widget.annonce;

    return Scaffold(

      backgroundColor:
      const Color(0xffF5F7FB),


      appBar: AppBar(

        elevation:0,

        backgroundColor:
        Colors.blueAccent.shade700,

        title:
        const Text(
          "Détails de l'annonce",
          style:TextStyle(
            fontWeight:FontWeight.bold,
          ),
        ),

      ),


      body:SingleChildScrollView(

        padding:
        const EdgeInsets.all(16),


        child:Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children:[


            // =========================
            // HEADER ANNONCE
            // =========================

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
                BorderRadius.circular(28),

              ),


              child:Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children:[


                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,


                    children:[


                      Expanded(

                        child:Text(

                          annonce["titre"] ?? "",

                          style:
                          const TextStyle(

                            color:
                            Colors.white,

                            fontSize:25,

                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),

                      ),


                      if(annonce["premium"] == true)

                        Container(

                          padding:
                          const EdgeInsets.symmetric(

                            horizontal:12,

                            vertical:6,

                          ),

                          decoration:
                          BoxDecoration(

                            color:
                            Colors.amber,

                            borderRadius:
                            BorderRadius.circular(20),

                          ),

                          child:
                          const Text(

                            "⭐ PREMIUM",

                            style:
                            TextStyle(

                              fontWeight:
                              FontWeight.bold,

                              fontSize:12,

                            ),

                          ),

                        ),


                    ],

                  ),


                  const SizedBox(height:15),


                  Row(

                    children:[


                      const Icon(

                        Icons.shield,

                        color:Colors.white,

                      ),


                      const SizedBox(width:8),


                      Text(

                        annonce["club"] ?? "",

                        style:
                        const TextStyle(

                          color:Colors.white,

                          fontSize:18,

                        ),

                      ),


                    ],

                  )


                ],

              ),

            ),


            const SizedBox(height:25),



            // =========================
            // INFORMATIONS
            // =========================


            const Text(

              "Informations",

              style:
              TextStyle(

                fontSize:20,

                fontWeight:
                FontWeight.bold,

              ),

            ),


            const SizedBox(height:12),


            Container(

              padding:
              const EdgeInsets.all(18),

              decoration:
              BoxDecoration(

                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(22),

              ),

              child:Column(

                children:[


                  ligne(

                    Icons.sports_soccer,

                    annonce["poste"] ?? "",

                  ),


                  const Divider(),


                  ligne(

                    Icons.location_on,

                    "${annonce["ville"]}, ${annonce["pays"]}",

                  ),


                  const Divider(),


                  ligne(

                    Icons.cake,

                    "${annonce["age_min"]} - ${annonce["age_max"]} ans",

                  ),


                  const Divider(),


                  ligne(

                    Icons.calendar_month,

                    annonce["date_limite"] ?? "",

                  ),


                ],

              ),

            ),



            const SizedBox(height:25),



            // =========================
            // DESCRIPTION
            // =========================


            const Text(

              "Présentation du poste",

              style:
              TextStyle(

                fontSize:20,

                fontWeight:
                FontWeight.bold,

              ),

            ),


            const SizedBox(height:12),


            Container(

              width:
              double.infinity,


              padding:
              const EdgeInsets.all(20),


              decoration:
              BoxDecoration(

                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(22),

              ),


              child:Text(

                annonce["description"] ?? "",


                style:
                const TextStyle(

                  fontSize:16,

                  height:1.6,

                ),

              ),

            ),



            const SizedBox(height:25),



            // =========================
            // MESSAGE
            // =========================


            TextField(

              controller:
              messageController,


              maxLines:4,


              decoration:
              InputDecoration(

                hintText:
                "Présentez-vous au recruteur...",


                filled:true,


                fillColor:
                Colors.white,


                prefixIcon:
                const Icon(
                  Icons.message,
                ),


                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(20),

                  borderSide:
                  BorderSide.none,

                ),

              ),

            ),



            const SizedBox(height:25),



            // =========================
            // BOUTON
            // =========================


            SizedBox(

              width:
              double.infinity,


              height:
              58,


              child:
              ElevatedButton.icon(


                icon:
                const Icon(

                  Icons.send,

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

                  "JE CANDIDATE",

                  style:
                  TextStyle(

                    fontSize:18,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),


                style:
                ElevatedButton.styleFrom(


                  backgroundColor:
                  Colors.green.shade600,


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
                candidater,


              ),

            ),



            const SizedBox(height:20),


          ],

        ),

      ),

    );

  }
}