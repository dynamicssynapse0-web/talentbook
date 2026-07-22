import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../recrutuer/detail_annonce_page.dart';


class ProfilPage extends StatefulWidget {

  const ProfilPage({
    super.key,
  });


  @override
  State<ProfilPage> createState() =>
      _ProfilPageState();

}



class _ProfilPageState extends State<ProfilPage>{


  final TextEditingController recherche =
  TextEditingController();
  List<Map<String,dynamic>> nouveauxProfils = [];
  List<Map<String,dynamic>> profilsPopulaires = [];
  List<Map<String,dynamic>> joueurs=[];
  List<Map<String,dynamic>> notificationsStream = [];
  List<Map<String,dynamic>> resultats=[];
  List<Map<String,dynamic>> notifications = [];
  List<Map<String,dynamic>> recruteurs = [];
  List<Map<String,dynamic>> annonces = [];

  Future<void> chargerNotifications() async {


    try{


      final data =
      await Supabase.instance.client
          .from("notifications")
          .select()
          .order(
        "created_at",
        ascending:false,
      )
          .limit(10);



      setState((){

        notifications =
        List<Map<String,dynamic>>
            .from(data);

      });


    }
    catch(e){

      print(
          "Erreur notifications : $e"
      );

    }


  }

  Future<void> chargerNouveauxProfils() async {

    final data = await Supabase.instance.client
        .from("player")
        .select()
        .order(
      "created_at",
      ascending:false,
    )
        .limit(10);


    setState((){

      nouveauxProfils =
      List<Map<String,dynamic>>.from(data);

    });

  }

  final List<String> disciplines=[

    "Tous",
    "Football",
    "Basket",
    "Handball",
    "Tennis",
    "Athlétisme",
    "Boxe"

  ];



  String disciplineSelectionnee="Tous";

  Widget sectionNotifications(){


    if(notifications.isEmpty){

      return const SizedBox();

    }


    return SizedBox(

      height:55,


      child:ListView.builder(

        scrollDirection:
        Axis.horizontal,


        padding:
        const EdgeInsets.symmetric(
          horizontal:16,
        ),


        itemCount:
        notifications.length,


        itemBuilder:(context,index){


          final notif =
          notifications[index];


          return Container(

            margin:
            const EdgeInsets.only(
              right:12,
            ),


            padding:
            const EdgeInsets.symmetric(
              horizontal:15,
            ),


            decoration:BoxDecoration(

              color:Colors.blueAccent,

              borderRadius:
              BorderRadius.circular(25),

            ),


            child:Row(

              children:[


                const Icon(
                  Icons.notifications,
                  color:Colors.white,
                  size:20,
                ),


                const SizedBox(width:8),


                Text(

                  notif["message"]
                      ??
                      "Nouveau profil",

                  style:
                  const TextStyle(

                    color:Colors.white,

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

  @override
  void initState(){

    super.initState();
    chargerRecruteurs();


    chargerJoueurs();
    chargerNouveauxProfils();

    chargerNotifications();
    recherche.addListener((){

      chargerNotifications();

      filtrer();

    });

  }


  Widget bandeauNotifications(){


    if(notificationsStream.isEmpty){

      return const SizedBox();

    }



    return SizedBox(

      height:45,


      child:ListView.builder(

        scrollDirection:
        Axis.horizontal,


        padding:
        const EdgeInsets.symmetric(
          horizontal:15,
        ),


        itemCount:
        notificationsStream.length,


        itemBuilder:(context,index){


          final notif =
          notificationsStream[index];



          return Container(


            margin:
            const EdgeInsets.only(
              right:10,
            ),


            padding:
            const EdgeInsets.symmetric(
              horizontal:15,
            ),


            decoration:
            BoxDecoration(

              color:
              Colors.blue.shade50,

              borderRadius:
              BorderRadius.circular(20),

            ),



            child:Center(

              child:Text(

                notif["message"] ??
                    "",


                style:
                const TextStyle(

                  fontWeight:
                  FontWeight.w600,

                  color:
                  Colors.blue,

                ),


              ),


            ),


          );


        },


      ),


    );


  }
  Future<void> chargerJoueurs() async {


    final data =
    await Supabase.instance.client
        .from("player")
        .select();


    setState((){

      joueurs =
      List<Map<String,dynamic>>.from(data);


      resultats=joueurs;

    });


  }
  Future<void> chargerRecruteurs() async {

    final data = await Supabase.instance.client

        .from("profils_recruteurs")

        .select()

        .order(
      "created_at",
      ascending: false,
    )

        .limit(10);

    setState(() {

      recruteurs =
      List<Map<String,dynamic>>.from(data);

    });

  }




  void filtrer(){


    final texte =
    recherche.text.toLowerCase();



    setState((){


      resultats =
          joueurs.where((j){


            final nom =
            "${j["nom"] ?? ""}"
                .toLowerCase();


            final discipline =
            "${j["discipline"] ?? ""}"
                .toLowerCase();



            bool rechercheOK =
                nom.contains(texte)
                    ||
                    discipline.contains(texte);



            bool disciplineOK =
                disciplineSelectionnee=="Tous"
                    ||
                    j["discipline"]==
                        disciplineSelectionnee;



            return rechercheOK
                &&
                disciplineOK;



          }).toList();



    });


  }
  Widget sectionConseilsProfil(){


    return Column(

      crossAxisAlignment:
      CrossAxisAlignment.start,


      children:[


        Padding(

          padding:
          const EdgeInsets.symmetric(
            horizontal:16,
            vertical:10,
          ),


          child:Text(

            "💡 Conseils pour améliorer ton profil",

            style:
            const TextStyle(

              fontSize:18,

              fontWeight:
              FontWeight.bold,

            ),

          ),

        ),



      ],

    );

  }

  Widget sectionProfilsPopulaires(){

    if(profilsPopulaires.isEmpty){
      return const SizedBox();
    }


    return Column(

      crossAxisAlignment:
      CrossAxisAlignment.start,

      children:[


        const Padding(

          padding:
          EdgeInsets.symmetric(
            horizontal:16,
            vertical:10,
          ),

          child:Text(

            "🔥 Profils les plus suivis",

            style:TextStyle(

              fontSize:18,

              fontWeight:
              FontWeight.bold,

            ),

          ),

        ),



        SizedBox(

          height:120,


          child:ListView.builder(

            scrollDirection:
            Axis.horizontal,


            padding:
            const EdgeInsets.symmetric(
                horizontal:16
            ),


            itemCount:
            profilsPopulaires.length,


            itemBuilder:(context,index){


              final joueur =
              profilsPopulaires[index];


              final photo =
              joueur["photo_url"];


              return GestureDetector(

                onTap:(){

                  Navigator.pushNamed(

                    context,

                    "/profil_joueur",

                    arguments:
                    joueur["id"],

                  );

                },


                child:Container(

                  width:90,

                  margin:
                  const EdgeInsets.only(
                    right:15,
                  ),


                  child:Column(

                    children:[


                      CircleAvatar(

                        radius:35,


                        backgroundImage:

                        photo != null &&
                            photo.toString().isNotEmpty

                            ?

                        NetworkImage(
                          photo,
                        )

                            :

                        null,


                        child:
                        photo == null

                            ?

                        const Icon(
                          Icons.person,
                          size:35,
                        )

                            :

                        null,


                      ),



                      const SizedBox(height:8),



                      Text(

                        joueur["nom"] ??
                            "Joueur",


                        maxLines:1,


                        overflow:
                        TextOverflow.ellipsis,


                        style:
                        const TextStyle(

                          fontSize:13,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),



                      Text(

                        "${joueur["followers_count"] ?? 0} abonnés",


                        style:
                        TextStyle(

                          fontSize:11,

                          color:
                          Colors.grey,

                        ),

                      ),


                    ],

                  ),

                ),

              );


            },


          ),

        ),


      ],

    );


  }
  Widget sectionRecruteurs() {

    if (recruteurs.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "🏢 Clubs & Recruteurs",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recruteurs.length,
            itemBuilder: (context, index) {

              final recruteur = recruteurs[index];

              return Container(
                width: 250,
                margin: const EdgeInsets.only(left: 20, right: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 12,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    CircleAvatar(
                      radius: 28,
                      backgroundImage: recruteur["logo_url"] != null
                          ? NetworkImage(recruteur["logo_url"])
                          : null,
                      child: recruteur["logo_url"] == null
                          ? const Icon(Icons.shield)
                          : null,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      recruteur["nom_club"] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "${recruteur["ville"]}, ${recruteur["pays"]}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const Spacer(),

                    if (recruteur["verifie"] == true)
                      const Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Recruteur vérifié",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 30),

      ],
    );
  }
  Widget sectionAnnonces() {

    if (annonces.isEmpty) {
      return const SizedBox();
    }


    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,


      children: [


        const Padding(

          padding: EdgeInsets.symmetric(horizontal: 20),

          child: Text(

            "📢 Dernières annonces recruteurs",

            style: TextStyle(

              fontSize: 22,

              fontWeight: FontWeight.bold,

            ),

          ),

        ),


        const SizedBox(height: 15),



        SizedBox(

          height: 245,


          child: ListView.builder(


            scrollDirection: Axis.horizontal,


            itemCount: annonces.length,


            itemBuilder: (context,index){


              final Map<String,dynamic> annonce = annonces[index];



              return GestureDetector(


                onTap: () {


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) => DetailAnnoncePage(

                        annonce: annonce,

                      ),

                    ),

                  );


                },



                child: Container(


                  width: 320,


                  margin: const EdgeInsets.only(

                    left:20,

                    right:10,

                  ),



                  padding: const EdgeInsets.all(18),



                  decoration: BoxDecoration(


                    color: Colors.white,


                    borderRadius: BorderRadius.circular(22),



                    boxShadow: [

                      BoxShadow(

                        color: Colors.black.withOpacity(.06),

                        blurRadius: 18,

                        offset: const Offset(0,8),

                      )

                    ],


                  ),



                  child: Column(


                    crossAxisAlignment: CrossAxisAlignment.start,


                    children: [



                      Row(


                        children: [



                          Container(


                            height:55,

                            width:55,


                            decoration: BoxDecoration(


                              color: Colors.green.shade50,


                              borderRadius: BorderRadius.circular(16),


                            ),



                            child: Icon(

                              Icons.sports_soccer,

                              color: Colors.green.shade700,

                              size:30,

                            ),


                          ),



                          const SizedBox(width:12),



                          Expanded(


                            child: Column(


                              crossAxisAlignment: CrossAxisAlignment.start,


                              children: [



                                Text(


                                  annonce["club"]?.toString() ?? "Club",

                                  maxLines:1,

                                  overflow:TextOverflow.ellipsis,


                                  style:const TextStyle(

                                    fontSize:17,

                                    fontWeight:FontWeight.bold,

                                  ),

                                ),



                                const SizedBox(height:4),



                                Text(


                                  annonce["poste"]?.toString() ?? "Recherche joueur",


                                  maxLines:1,

                                  overflow:TextOverflow.ellipsis,


                                  style:TextStyle(

                                    color:Colors.grey.shade600,

                                  ),

                                ),


                              ],

                            ),

                          )



                        ],


                      ),




                      const SizedBox(height:18),




                      Text(


                        annonce["titre"]?.toString() ?? "Annonce",


                        maxLines:2,

                        overflow:TextOverflow.ellipsis,


                        style:const TextStyle(

                          fontSize:18,

                          fontWeight:FontWeight.bold,

                        ),


                      ),





                      const SizedBox(height:10),




                      Text(


                        annonce["description"]?.toString() ?? "",


                        maxLines:3,

                        overflow:TextOverflow.ellipsis,


                        style:TextStyle(

                          color:Colors.grey.shade700,

                          height:1.4,

                        ),


                      ),





                      const Spacer(),





                      Row(


                        children: [



                          const Icon(

                            Icons.location_on,

                            color:Colors.red,

                            size:18,

                          ),



                          const SizedBox(width:5),




                          Expanded(


                            child: Text(


                              "${annonce["ville"]?.toString() ?? ""}, ${annonce["pays"]?.toString() ?? ""}",


                              maxLines:1,

                              overflow:TextOverflow.ellipsis,


                              style:TextStyle(

                                color:Colors.grey.shade600,

                              ),


                            ),

                          )


                        ],


                      ),





                      const SizedBox(height:12),





                      SizedBox(


                        width:double.infinity,


                        height:40,



                        child:ElevatedButton(


                          onPressed:(){


                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder:(_)=>DetailAnnoncePage(

                                  annonce:annonce,

                                ),

                              ),

                            );


                          },



                          style:ElevatedButton.styleFrom(


                            backgroundColor:Colors.blueAccent.shade700,


                            foregroundColor:Colors.white,


                            shape:RoundedRectangleBorder(

                              borderRadius:BorderRadius.circular(15),

                            ),


                          ),



                          child:const Text(

                            "Voir l'annonce",

                          ),


                        ),


                      )


                    ],


                  ),


                ),


              );


            },


          ),


        ),



        const SizedBox(height:30),


      ],


    );

  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // ============================
        // NOUVEAUX PROFILS
        // ============================

        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: nouveauxProfils.length,
            itemBuilder: (context, index) {
              final joueur = nouveauxProfils[index];

              final photo =
                  joueur["photo_url"] != null &&
                      joueur["photo_url"].toString().isNotEmpty;

              return Container(
                width: 310,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff0D47A1),
                        Color(0xff1976D2),
                        Color(0xff42A5F5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [

                        /// PHOTO
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: photo
                              ? Image.network(
                            joueur["photo_url"],
                            fit: BoxFit.cover,
                          )
                              : Container(
                            color: Colors.white24,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        /// TEXTE
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  "NOUVEAU",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                joueur["nom"] ?? "Joueur",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                "Vient de rejoindre MARKETPROFILES",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // 1. BARRE DE RECHERCHE DESIGN SANS BORDURES AGRESSIVES


        // 🔥 Profils suivis
        sectionProfilsPopulaires(),




        // 💡 Conseils
        sectionConseilsProfil(),
        sectionAnnonces(),
        sectionProfilsPopulaires(),
        sectionNotifications(),
        const SizedBox(height:10),



        // 2. FILTRES HORIZONTAUX ÉPURÉS (CHOICECHIPS CUSTOM)
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            itemCount: disciplines.length,
            itemBuilder: (context, index) {
              final d = disciplines[index];
              final estSelectionne = disciplineSelectionnee == d;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ChoiceChip(
                  label: Text(d),
                  selected: estSelectionne,
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: estSelectionne ? Colors.white : Colors.grey.shade700,
                    fontWeight: estSelectionne ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: estSelectionne ? Colors.blue : Colors.grey.shade200,
                    ),
                  ),
                  elevation: 0,
                  pressElevation: 0,
                  showCheckmark: false,
                  onSelected: (v) {
                    setState(() {
                      disciplineSelectionnee = d;
                    });
                    filtrer();
                  },
                ),
              );
            },
          ),
        ),

        // 3. LISTE DES JOUEURS MODERNISÉE + OPTION ACTUALISER
        Expanded(
          // L'indicateur entoure la zone de liste
          child: RefreshIndicator(
            color: Colors.blue, // Couleur de la flèche de chargement
            backgroundColor: Colors.white, // Couleur du fond de la bulle
            onRefresh: () async {
              // Appel de votre fonction existante qui charge les données depuis Supabase
              await chargerJoueurs();
            },
            child: resultats.isEmpty
                ? ListView( // Utilisation d'un ListView ici pour que le "Pull-to-Refresh" fonctionne même si la liste est vide
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Center(
                  child: Text(
                    "Aucun joueur trouvé",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                  ),
                ),
              ],
            )
                : ListView.builder(
              // TRÈS IMPORTANT : Force la liste à toujours être scrollable pour déclencher le RefreshIndicator
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: resultats.length,
              itemBuilder: (context, index) {
                final joueur = resultats[index];
                final aUnePhoto = joueur["photo_url"] != null && joueur["photo_url"].toString().isNotEmpty;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/profil_joueur",
                          arguments: joueur["id"],
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.blue.shade50, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 150,
                                  height: 100,
                                  child: aUnePhoto
                                      ? Image.network(
                                    joueur["photo_url"],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.blue.shade50,
                                        child: const Icon(
                                          Icons.person_rounded,
                                          color: Colors.blue,
                                        ),
                                      );
                                    },
                                  )
                                      : Container(
                                    color: Colors.blue.shade50,
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    joueur["nom"] ?? "Joueur",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          joueur["discipline"] ?? "N/A",
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (joueur["poste"] != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          joueur["poste"],
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}

