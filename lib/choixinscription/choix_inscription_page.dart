import 'package:flutter/material.dart';

import '../joeur/joueurprofil.dart';
import '../recrutuer/profil_recruteur_page.dart';




class ChoixInscriptionPage extends StatelessWidget {

  const ChoixInscriptionPage({super.key});



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
      Colors.grey.shade100,


      body: SafeArea(

        child: SingleChildScrollView(

          padding:
          const EdgeInsets.all(25),


          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.center,


            children: [


              const SizedBox(height:30),



              Container(

                height:90,

                width:90,

                decoration:
                BoxDecoration(

                  color:
                  Colors.blue.shade50,

                  shape:
                  BoxShape.circle,

                ),


                child:
                Icon(

                  Icons.sports_soccer,

                  size:50,

                  color:
                  Colors.blueAccent.shade700,

                ),

              ),



              const SizedBox(height:25),



              const Text(

                "Bienvenue dans la plateforme sportive",

                textAlign:
                TextAlign.center,

                style:
                TextStyle(

                  fontSize:24,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              const SizedBox(height:12),



              Text(

                "Choisissez votre profil pour commencer.\n"
                    "Votre choix permettra de vous proposer "
                    "la meilleure expérience.",


                textAlign:
                TextAlign.center,


                style:
                TextStyle(

                  fontSize:15,

                  color:
                  Colors.grey.shade700,

                  height:1.5,

                ),

              ),



              const SizedBox(height:40),





              // =============================
              // SPORTIF
              // =============================


              carteChoix(

                context,


                couleur:
                Colors.green,


                icone:
                Icons.person_search,


                titre:
                "Je suis un sportif",


                description:

                "Créez votre profil joueur.\n\n"

                    "✓ Ajoutez votre photo\n"

                    "✓ Indiquez votre poste et discipline\n"

                    "✓ Présentez vos expériences\n"

                    "✓ Recevez des opportunités de clubs\n"

                    "✓ Candidatez aux annonces",



                bouton:
                "Créer mon profil sportif",


                action:(){


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder:(_)=>

                      const CreationComptePage(),

                    ),

                  );


                },

              ),




              const SizedBox(height:25),





              // =============================
              // RECRUTEUR
              // =============================


              carteChoix(

                context,


                couleur:
                Colors.blueAccent,


                icone:
                Icons.business,


                titre:
                "Je suis un recruteur / club",


                description:

                "Créez votre espace recruteur.\n\n"

                    "✓ Présentez votre club\n"

                    "✓ Ajoutez votre logo\n"

                    "✓ Publiez vos recherches\n"

                    "✓ Recevez des candidatures\n"

                    "✓ Contactez les joueurs",



                bouton:
                "Créer mon profil recruteur",


                action:(){


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder:(_)=>

                      const ProfilRecruteurPage(),

                    ),

                  );


                },

              ),




              const SizedBox(height:30),



              Text(

                "Vous pourrez modifier votre profil plus tard.",


                style:
                TextStyle(

                  color:
                  Colors.grey.shade600,

                  fontSize:13,

                ),

              )



            ],

          ),

        ),

      ),

    );


  }







  Widget carteChoix(

      BuildContext context,

      {

        required Color couleur,

        required IconData icone,

        required String titre,

        required String description,

        required String bouton,

        required VoidCallback action,

      }

      ){



    return Container(


      padding:
      const EdgeInsets.all(22),


      decoration:
      BoxDecoration(


        color:
        Colors.white,


        borderRadius:
        BorderRadius.circular(25),



        boxShadow:[


          BoxShadow(

            color:
            Colors.black.withOpacity(.06),

            blurRadius:20,

            offset:
            const Offset(0,10),

          )


        ],


      ),



      child:Column(


        crossAxisAlignment:
        CrossAxisAlignment.start,


        children:[



          Row(

            children:[


              Container(

                height:60,

                width:60,


                decoration:
                BoxDecoration(

                  color:
                  couleur.withOpacity(.12),

                  borderRadius:
                  BorderRadius.circular(18),

                ),


                child:
                Icon(

                  icone,

                  color:
                  couleur,

                  size:32,

                ),

              ),


              const SizedBox(width:15),



              Expanded(

                child:
                Text(

                  titre,

                  style:
                  const TextStyle(

                    fontSize:20,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),

              )


            ],

          ),



          const SizedBox(height:20),



          Text(

            description,


            style:
            TextStyle(

              color:
              Colors.grey.shade700,

              height:1.5,

              fontSize:14,

            ),

          ),



          const SizedBox(height:25),



          SizedBox(

            width:
            double.infinity,


            child:
            ElevatedButton(

              onPressed:
              action,


              style:
              ElevatedButton.styleFrom(

                backgroundColor:
                couleur,


                foregroundColor:
                Colors.white,


                padding:
                const EdgeInsets.symmetric(

                  vertical:16,

                ),


                shape:
                RoundedRectangleBorder(

                  borderRadius:
                  BorderRadius.circular(18),

                ),

              ),



              child:
              Text(

                bouton,

                style:
                const TextStyle(

                  fontSize:16,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),

            ),

          )



        ],


      ),


    );

  }


}