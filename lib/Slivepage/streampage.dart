import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../aideparametre/aude.dart';
import '../aideparametre/parametre.dart';
import '../joeur/InformationProfessionnellePage.dart';
import '../joeur/ProfilJoueurPage.dart';
import '../joeur/joueurprofil.dart';
import '../joeur/mes_candidatures.dart';
import '../notif/notifications_page.dart';
import '../recrutuer/RecruteurStreamPage.dart';
import '../recrutuer/creer_annonce_page.dart';
import '../recrutuer/detailrecruteur.dart';
import '../recrutuer/profil_recruteur_page.dart';
import '../stream/conseilpagestream.dart';
import 'MesAnnoncesPage.dart';
import 'bodustream.dart';



class StreamPage extends StatefulWidget {

  const StreamPage({
    super.key,
  });


  @override
  State<StreamPage> createState()
  => _StreamPageState();

}




class _StreamPageState extends State<StreamPage>
    with SingleTickerProviderStateMixin {


  final supabase =
      Supabase.instance.client;
  late TabController tabController;

  RealtimeChannel? notificationChannel;

  int nombreNotifications = 0;
  // ==============================
  // PROFILS CONNECTES
  // ==============================


  Map<String,dynamic>? player;


  Map<String,dynamic>? recruteur;



  bool chargement = true;



  bool profilTermine = false;

  int ongletActuel = 0;

  // ==============================
  // LISTE JOUEURS PUBLIC
  // ==============================


  List<Map<String,dynamic>> joueurs = [];


  List<Map<String,dynamic>> joueursFiltres = [];


  final TextEditingController rechercheController =
  TextEditingController();





  bool get utilisateurConnecte {

    return supabase.auth.currentUser != null;

  }




  @override
  void initState(){

    super.initState();

    chargerNombreNotifications();

    ecouterNotifications();
    tabController = TabController(
      length: 3,
      vsync: this,
    );


    tabController.addListener((){

      setState((){

        ongletActuel =
            tabController.index;

      });

    });


    chargerProfils();

    chargerJoueurs();


    rechercheController.addListener(
        filtrerJoueurs
    );


  }
  @override
  void dispose(){

    if(notificationChannel != null){

      supabase.removeChannel(
        notificationChannel!,
      );

    }


    rechercheController.dispose();

    tabController.dispose();


    super.dispose();

  }

  Future<void> chargerNombreNotifications() async {

    final user =
        supabase.auth.currentUser;

    if(user == null){
      return;
    }


    final data = await supabase
        .from("notifications")
        .select("id")
        .eq(
      "user_id",
      user.id,
    )
        .eq(
      "lu",
      false,
    );


    setState(() {

      nombreNotifications = data.length;

    });


  }

  Future<void> ecouterNotifications() async {

    final user =
        supabase.auth.currentUser;

    if(user == null) return;


    notificationChannel = supabase
        .channel(
      "stream-notifications-${user.id}",
    )

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

        print(
          "🔔 Nouvelle notification reçue",
        );


        if(!mounted) return;


        setState(() {

          nombreNotifications++;

        });
        print(
            "Nombre notifications : $nombreNotifications"
        );


        // Optionnel : afficher une alerte temporaire

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content: Text(

              payload.newRecord["message"]
                  ??
                  "Nouvelle notification",

            ),

            duration:
            const Duration(seconds:3),

          ),

        );


      },

    )

        .subscribe();

  }
  // ==================================================
  // CHARGEMENT DU PROFIL SPORTIF + RECRUTEUR
  // ==================================================


  Future<void> chargerProfils() async {

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {

      setState(() {
        player = null;
        recruteur = null;
        chargement = false;
      });

      return;
    }

    try {

      // ===========================
      // PROFIL SPORTIF
      // ===========================

      final joueur = await Supabase.instance.client
          .from("player")
          .select()
          .eq("user_id", user.id)
          .maybeSingle();

      // ===========================
      // PROFIL RECRUTEUR
      // ===========================

      final club = await Supabase.instance.client
          .from("profils_recruteurs")
          .select()
          .eq("user_id", user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {

        player = joueur;
        recruteur = club;
        chargement = false;

      });

    } catch (e) {

      debugPrint("Erreur chargement profils : $e");

      if (!mounted) return;

      setState(() {

        player = null;
        recruteur = null;
        chargement = false;

      });

    }

  }







  // ==================================================
  // CHARGEMENT DES JOUEURS PUBLICS
  // ==================================================


  Future chargerJoueurs() async {


    try{


      final data = await supabase

          .from("player")

          .select(

          "id,nom,prenom,photo_url,discipline,poste,club"

      );




      if(mounted){


        setState(() {


          joueurs =
          List<Map<String,dynamic>>
              .from(data);



          joueursFiltres =
              joueurs;


        });


      }


    }

    catch(e){


      debugPrint(
          "ERREUR JOUEURS : $e"
      );


    }


  }







  // ==================================================
  // RECHERCHE JOUEURS
  // ==================================================


  void filtrerJoueurs(){


    final recherche =

    rechercheController.text

        .toLowerCase()

        .trim();




    if(recherche.isEmpty){


      setState(() {

        joueursFiltres =
            joueurs;

      });


      return;

    }




    setState(() {


      joueursFiltres =

          joueurs.where((joueur){



            final nom =

            "${joueur["nom"] ?? ""}"

                .toLowerCase();



            final prenom =

            "${joueur["prenom"] ?? ""}"

                .toLowerCase();



            final discipline =

            "${joueur["discipline"] ?? ""}"

                .toLowerCase();



            final poste =

            "${joueur["poste"] ?? ""}"

                .toLowerCase();



            final club =

            "${joueur["club"] ?? ""}"

                .toLowerCase();





            return

              nom.contains(recherche)

                  ||

                  prenom.contains(recherche)

                  ||

                  discipline.contains(recherche)

                  ||

                  poste.contains(recherche)

                  ||

                  club.contains(recherche);



          }).toList();



    });



  }





// ==================================================
// MENU ESPACE UTILISATEUR
// SPORTIF / RECRUTEUR
// ==================================================


  void afficherMenuProfil(){


    showModalBottomSheet(

      context: context,


      shape:
      const RoundedRectangleBorder(

        borderRadius:
        BorderRadius.vertical(

          top:
          Radius.circular(25),

        ),

      ),



      builder:(context){


        return Padding(

          padding:
          const EdgeInsets.all(20),



          child:
          Column(


            mainAxisSize:
            MainAxisSize.min,



            children:[



              const Text(

                "Choisir un espace",

                style:
                TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              const SizedBox(
                  height:20
              ),






              // =================================
              // COMPTE SPORTIF
              // =================================


              ListTile(


                leading:
                const Icon(

                  Icons.sports_soccer,

                  color:
                  Colors.blue,

                ),




                title:
                Text(

                  player != null

                      ?

                  "Profil sportif actif"

                      :

                  "Compte sportif",

                ),




                trailing:

                player != null

                    ?

                const Icon(

                  Icons.check_circle,

                  color:
                  Colors.green,

                )

                    :

                null,





                onTap:() async {

                  Navigator.pop(context);

                  if(player != null){

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:(_)=>ProfilJoueurPage(
                          playerId: player!["id"],
                        ),
                      ),
                    );

                  } else {

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:(_)=>const CreationComptePage(),
                      ),
                    );

                  }

                  await chargerProfils();

                },

              ),







              // =================================
              // COMPTE RECRUTEUR
              // =================================


              ListTile(


                leading:
                const Icon(

                  Icons.business_center,

                  color:
                  Colors.orange,

                ),





                title:
                Text(

                  recruteur != null

                      ?

                  "Profil recruteur actif"

                      :

                  "Compte recruteur",

                ),




                trailing:


                recruteur != null

                    ?

                const Icon(

                  Icons.check_circle,

                  color:
                  Colors.green,

                )

                    :

                null,







                onTap:() async {

                  Navigator.pop(context);

                  if(recruteur != null){

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:(_)=>DetailRecruteurPage(
                          recruteur: recruteur!,
                        ),
                      ),
                    );

                  } else {

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:(_)=>const ProfilRecruteurPage(),
                      ),
                    );

                  }

                  await chargerProfils();

                },
              ),



            ],


          ),


        );


      },


    );


  }







// ==================================================
// NAVIGATION PROFIL PRINCIPAL
// ==================================================


  void _gererNavigationProfil(){


    // ==========================
    // UTILISATEUR NON CONNECTE
    // ==========================

    if(!utilisateurConnecte){

      Navigator.pushNamed(
        context,
        "/login",
      );

      return;

    }



    // ==========================
    // PROFIL SPORTIF EXISTANT
    // ==========================

    if(player != null){


      Navigator.push(

        context,

        MaterialPageRoute(

          builder:(_)=>
              ProfilJoueurPage(

                playerId:
                player!["id"],

              ),

        ),

      );


    }



    // ==========================
    // PROFIL RECRUTEUR EXISTANT
    // ==========================

    else if(recruteur != null){


      Navigator.push(

        context,

        MaterialPageRoute(

          builder:(_)=>
              DetailRecruteurPage(

                recruteur:
                recruteur!,

              ),

        ),

      );


    }



    // ==========================
    // CONNECTE MAIS PAS DE PROFIL
    // ==========================

    else{


      Navigator.pushNamed(
        context,
        "/creation",
      );


    }


  }






// ==================================================
// AVATAR UTILISATEUR
// ==================================================


  Widget avatarUtilisateur() {

    final user =
        Supabase.instance.client.auth.currentUser;


    // Pas connecté
    if(user == null){

      return CircleAvatar(

        backgroundColor: Colors.white,

        child: Image.asset(
          "assets/logo.png",
          fit: BoxFit.contain,
        ),

      );

    }



    // =========================
    // PROFIL SPORTIF
    // =========================

    if(player != null){

      final photo =
      player!["photo_url"];


      if(photo != null &&
          photo.toString().isNotEmpty){

        return CircleAvatar(

          backgroundImage:
          NetworkImage(
            photo,
          ),

        );

      }

    }



    // =========================
    // PROFIL RECRUTEUR
    // =========================

    if(recruteur != null){

      final logo =
      recruteur!["logo_url"];


      if(logo != null &&
          logo.toString().isNotEmpty){

        return CircleAvatar(

          backgroundImage:
          NetworkImage(
            logo,
          ),

        );

      }

    }



    // Compte sans photo

    return const CircleAvatar(

      backgroundColor:Colors.white,

      child:Icon(
        Icons.person,
        color:Colors.blue,
      ),

    );

  }








// ==================================================
// APPBAR
// ==================================================


  PreferredSizeWidget appBar(){


    return AppBar(


      backgroundColor:
      Colors.blueAccent.shade700,


      elevation:0,


      scrolledUnderElevation:0,


      centerTitle:true,



      title:
      const Text(

        "TALENTBOOK",

        style:
        TextStyle(

          color:Colors.white,

          fontWeight:
          FontWeight.bold,

          letterSpacing:1.2,

          fontSize:18,

        ),

      ),





      leading:

      Padding(

        padding:
        const EdgeInsets.only(left:12),


        child:

        GestureDetector(

          onTap:
          afficherMenuProfil,


          child:

          SizedBox(

            height:38,

            width:38,


            child:
            avatarUtilisateur(),

          ),


        ),


      ),




      actions:[
        Stack(

          children: [

            IconButton(

              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
              ),

              onPressed:() async {


                await Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                    const NotificationsPage(),

                  ),

                );


                // Après retour de NotificationsPage

                chargerNombreNotifications();


              },

            ),



            if(nombreNotifications > 0)

              Positioned(

                right: 8,

                top: 8,

                child: Container(

                  padding:
                  const EdgeInsets.all(4),


                  decoration:
                  const BoxDecoration(

                    color: Colors.red,

                    shape:
                    BoxShape.circle,

                  ),


                  child: Text(

                    nombreNotifications > 99
                        ? "99+"
                        : nombreNotifications.toString(),

                    style:
                    const TextStyle(

                      color: Colors.white,

                      fontSize:10,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                ),

              ),


          ],

        ),







        PopupMenuButton<String>(


          icon:
          const Icon(

            Icons.more_vert_rounded,

            color:
            Colors.white,

          ),



          itemBuilder:(context)=>[



            PopupMenuItem(

              value:"profil",

              child:Row(

                children:[

                  const Icon(
                    Icons.person,
                  ),

                  const SizedBox(width:10),


                  Text(

                    player != null

                        ?

                    "Mon profil sportif"


                        :

                    recruteur != null

                        ?

                    "Mon profil recruteur"


                        :

                    "Créer mon profil",

                  ),

                ],

              ),

            ),
            if(player != null)

              const PopupMenuItem(

                value: "espace_pro",

                child: Row(

                  children: [

                    Icon(
                      Icons.workspace_premium,
                      color: Colors.orange,
                    ),

                    SizedBox(width: 10),

                    Text(
                      "Créer espace professionnel",
                    ),

                  ],

                ),

              ),
            if(recruteur != null)

              const PopupMenuItem(

                value:"annonce",

                child:Row(

                  children:[

                    Icon(
                      Icons.add_business,
                      color:Colors.green,
                    ),

                    SizedBox(width:10),

                    Text(
                      "Créer une annonce",
                    ),

                  ],

                ),

              ),
            // ===============================
// JOUEUR : MES CANDIDATURES
// ===============================

            if(player != null)

              const PopupMenuItem(

                value:"mes_candidatures",

                child:Row(

                  children:[

                    Icon(
                      Icons.send,
                      color:Colors.blue,
                    ),

                    SizedBox(width:10),

                    Text(
                      "Mes candidatures",
                    ),

                  ],

                ),

              ),



// ===============================
// RECRUTEUR : CANDIDATURES RECUES
// ===============================

            if(recruteur != null)

              const PopupMenuItem(

                value:"candidatures_recues",

                child:Row(

                  children:[

                    Icon(
                      Icons.people,
                      color:Colors.green,
                    ),

                    SizedBox(width:10),

                    Text(
                      "Candidatures reçues",
                    ),

                  ],

                ),

              ),




            const PopupMenuItem(

              value:"aide",

              child:
              Text("Aide"),

            ),



            const PopupMenuItem(

              value:"parametres",

              child:
              Text("Paramètres"),

            ),





            if(utilisateurConnecte)

              const PopupMenuItem(

                value:"logout",

                child:
                Text(

                  "Déconnexion",

                  style:
                  TextStyle(

                    color:
                    Colors.red,

                  ),

                ),

              ),



          ],





          onSelected:(value) async {



            switch(value){



              case "profil":

                _gererNavigationProfil();

                break;
              case "espace_pro":

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                    InformationProfessionnellePage(
                      playerId: player!["id"],

                    ),

                  ),

                );

                break;
              case "annonce":

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:(_)=>
                    const CreerAnnoncePage(),

                  ),

                );
              case "mes_candidatures":

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:(_)=>
                    const MesCandidaturesPage(),

                  ),

                );

                break;



              case "candidatures_recues":

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:(_)=>
                    const MesAnnoncesPage(),

                  ),

                );

                break;



                break;

              case "mes_annonces":


                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:(_)=>

                    const MesAnnoncesPage(),

                  ),

                );


                break;


              case "aide":


                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:(_)=>

                    const AidePage(),

                  ),

                );


                break;





              case "parametres":


                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:(_)=>

                    const ParametresPage(),

                  ),

                );


                break;





              case "logout":

                await supabase.auth.signOut();


                if(mounted){

                  setState((){

                    player = null;
                    recruteur = null;
                    chargement = false;

                  });


                  Navigator.pushNamedAndRemoveUntil(

                    context,

                    "/login",

                        (route)=>false,

                  );

                }



                break;



            }


          },


        ),



        const SizedBox(width:8),


      ],



    );



  }
  // ==================================================
// BUILD PRINCIPAL
// ==================================================


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
      Colors.grey.shade100,


      appBar:
      appBar(),


      body:

      Column(

        children:[


          Container(

            color:Colors.white,

            child:

            TabBar(
              controller: tabController,

              tabs:[


                Tab(
                  icon: Icon(Icons.sports_soccer),
                  text:"Joueurs",
                ),



                Tab(
                  icon: Icon(Icons.business),
                  text:"Recruteurs",
                ),



                Tab(
                  icon: Icon(Icons.lightbulb_outline),
                  text:"Conseils",
                ),


              ],


            ),

          ),


          Expanded(
            child: switch (ongletActuel) {
              0 => const ProfilPage(),
              1 => const RecruteurStreamPage(),
              _ => const ConseilPage(),
            },
          )


        ],


      ),

    );


  }



}