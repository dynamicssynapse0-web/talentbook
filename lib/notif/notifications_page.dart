import 'package:LESWAYS/notif/payment_webview_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../recrutuer/candidature.dart';
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {

  List<Map<String,dynamic>> notifications = [];
  RealtimeChannel? channel;
  bool chargement = true;

  @override
  void initState() {
    super.initState();
    chargerNotifications();

    ecouterNotifications();
  }
  @override
  void dispose() {

    if(channel != null){

      Supabase.instance.client
          .removeChannel(channel!);

    }

    super.dispose();

  }
  Future<void> supprimerNotificationReactivation() async {

    final user =
        Supabase.instance.client.auth.currentUser;

    if(user == null) return;


    await Supabase.instance.client
        .from("notifications")
        .delete()
        .eq("user_id", user.id)
        .eq("type", "profile_expired");


    setState(() {

      notifications.removeWhere(
            (notif) =>
        notif["type"] == "profile_expired",
      );

    });

  }
  Future<void> ouvrirWhatsApp(String numero) async {

    final url =
    Uri.parse(
      "https://wa.me/$numero",
    );


    if(await canLaunchUrl(url)){

      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

    }

  }
  Future<void> reactiverProfil(
      Map<String,dynamic> notif
      ) async {


    final user =
        Supabase.instance.client.auth.currentUser;


    if(user == null){
      return;
    }


// récupérer le joueur

    final joueur = await Supabase
        .instance
        .client
        .from("player")
        .select()
        .eq(
      "user_id",
      user.id,
    )
        .single();



    try{


      final response =
      await http.post(
          Uri.parse(
              "https://remedial-computer-parking.ngrok-free.dev/api/reactivate-profile"
          ),
          headers:{

            "Content-Type":
            "application/json"

          },

          body:jsonEncode({

            "userId":user.id,

            "playerId":joueur["id"]

          })

      );



      final data =
      jsonDecode(response.body);



      if(data["success"] == true){


        final url =
        data["paymentUrl"];



        if(url != null){


          await launchUrl(

            Uri.parse(url),

            mode:
            LaunchMode.externalApplication,

          );


        }



      }



    }
    catch(e){


      print(
          "Erreur paiement : $e"
      );


    }



  }
  Future<void> lancerReactivation(
      Map<String,dynamic> notif
      ) async {


    final user =
        Supabase.instance.client.auth.currentUser;


    if(user == null){

      return;

    }


    try{


      // récupérer le joueur connecté

      final joueur =
      await Supabase.instance.client
          .from("player")
          .select()
          .eq(
        "user_id",
        user.id,
      )
          .single();



      print(
          "JOUEUR : $joueur"
      );



      final response =
      await http.post(


        Uri.parse(

            "https://remedial-computer-parking.ngrok-free.dev/api/reactivate-profile"

        ),


        headers:{


          "Content-Type":
          "application/json"


        },

        body: jsonEncode({

          "userId": user.id,

          "playerId": joueur["id"]

        }),

      );



      final resultat =
      jsonDecode(response.body);



      print(
          resultat
      );


      if(resultat["success"] == true){


        final url =
        resultat["paymentUrl"];


        if(context.mounted){


          Navigator.push(

            context,

            MaterialPageRoute(

              builder:(context)=>

                  PaymentWebViewPage(

                    url:url,

                    onSuccess: () async {

                      await supprimerNotificationReactivation();


                      if(context.mounted){

                        Navigator.pushNamedAndRemoveUntil(

                          context,

                          "/stream",

                              (route)=>false,

                        );

                      }

                    },

                  ),

            ),

          );


        }


      }



    }
    catch(e){


      print(
          "Erreur réactivation : $e"
      );


    }


  }
  Future<void> ecouterNotifications() async {

    final user =
        Supabase.instance.client.auth.currentUser;

    if(user == null) return;

    channel = Supabase.instance.client
        .channel("notifications-${user.id}")

        .onPostgresChanges(

      event: PostgresChangeEvent.insert,

      schema: "public",

      table: "notifications",

      filter: PostgresChangeFilter(

        type: PostgresChangeFilterType.eq,

        column: "user_id",

        value: user.id,

      ),

      callback: (payload){

        final nouvelleNotification =
        Map<String,dynamic>.from(
          payload.newRecord,
        );

        setState(() {

          notifications.insert(
            0,
            nouvelleNotification,
          );

        });

      },

    )

        .subscribe();

  }
  Future<void> chargerNotifications() async {

    final user =
        Supabase.instance.client.auth.currentUser;

    if(user == null){

      setState(() {
        chargement = false;
      });

      return;
    }

    try{

      final data =
      await Supabase.instance.client
          .from("notifications")
          .select()
          .eq(
        "user_id",
        user.id,
      )
          .order(
        "created_at",
        ascending:false,
      );

      setState(() {

        notifications =
        List<Map<String,dynamic>>
            .from(data);

        chargement = false;

      });

    }catch(e){

      print(e);

      setState(() {
        chargement = false;
      });

    }

  }
  Future<void> marquerCommeLues() async {


    final user =
        Supabase.instance.client.auth.currentUser;


    if(user == null) return;



    await Supabase.instance.client

        .from("notifications")

        .update({

      "is_read":true

    })

        .eq(

      "user_id",

      user.id,

    );


  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Notifications",
        ),

        backgroundColor:
        Colors.blueAccent.shade700,

      ),

      body: chargement

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : notifications.isEmpty

          ? const Center(
        child: Text(
          "Aucune notification",
        ),
      )

          : ListView.builder(

        padding:
        const EdgeInsets.all(15),

        itemCount:
        notifications.length,

        itemBuilder:(context,index){

          final notif =
          notifications[index];

          final expire =
              notif["type"] ==
                  "profile_expired";

          return Card(

            margin:
            const EdgeInsets.only(
              bottom:15,
            ),

            shape:
            RoundedRectangleBorder(

              borderRadius:
              BorderRadius.circular(
                15,
              ),

            ),


            child: InkWell(

              borderRadius:
              BorderRadius.circular(15),


              onTap:() async {


                if(notif["titre"] == "Candidature acceptée 🎉"){


                  final whatsapp =
                  notif["whatsapp"];


                  if(whatsapp != null &&
                      whatsapp.toString().isNotEmpty){


                    await ouvrirWhatsApp(
                        whatsapp.toString()
                    );


                  }


                }



                else if(notif["titre"] == "Candidature refusée"){


                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    const SnackBar(

                      content: Text(
                        "Cette candidature n'a pas été retenue.",
                      ),

                    ),

                  );


                }


              },


              child: Padding(

                padding:
                const EdgeInsets.all(
                  15,
                ),


                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,


                  children: [


                    Row(

                      children:[


                        Icon(

                          expire
                              ? Icons.warning_amber_rounded
                              : Icons.notifications,


                          color: expire

                              ? Colors.orange

                              : Colors.blue,


                        ),



                        const SizedBox(

                          width:10,

                        ),



                        Expanded(

                          child: Text(

                            notif["message"] ??

                                "",


                            style:

                            const TextStyle(


                              fontWeight:

                              FontWeight.bold,


                              fontSize:16,


                            ),


                          ),

                        ),


                      ],


                    ),



                    if(expire) ...[


                      const SizedBox(

                        height:15,

                      ),



                      SizedBox(


                        width:double.infinity,



                        child:

                        ElevatedButton(


                          onPressed:(){


                            lancerReactivation(notif);



                          },


                          style:

                          ElevatedButton.styleFrom(


                            backgroundColor:

                            Colors.blueAccent.shade700,


                            foregroundColor:

                            Colors.white,


                          ),



                          child:

                          const Text(


                            "Réactiver mon profil - 1000 FCFA",


                          ),


                        ),


                      )


                    ]



                  ],


                ),


              ),

            ),

          );

        },

      ),

    );

  }

}