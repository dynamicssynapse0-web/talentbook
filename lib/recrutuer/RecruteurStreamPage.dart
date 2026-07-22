import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Assure-toi que cet import est là
import 'detail_annonce_page.dart';

class RecruteurStreamPage extends StatefulWidget {
  const RecruteurStreamPage({
    super.key,
  });

  @override
  State<RecruteurStreamPage> createState() => _RecruteurStreamPageState();
}

class _RecruteurStreamPageState extends State<RecruteurStreamPage> {
  List<Map<String, dynamic>> annonces = [];
  List<Map<String, dynamic>> recruteurs = [];
  bool chargement = true;

  @override
  void initState() {
    super.initState();
    charger();
  }

  Future charger() async {
    try {
      final clubs = await Supabase.instance.client
          .from("profils_recruteurs")
          .select()
          .order("created_at", ascending: false);

      final annoncesData = await Supabase.instance.client
          .from("annonces_recrutement")
          .select("""
          *,
          profils_recruteurs(
            nom_club,
            logo_url,
            ville,
            pays,
            verifie
          )
        """)
          .order("created_at", ascending: false);
      debugPrint(annoncesData.toString());

      setState(() {
        recruteurs = List<Map<String, dynamic>>.from(clubs);
        annonces = List<Map<String, dynamic>>.from(annoncesData);
        chargement = false;
      });
    } catch (e) {
      debugPrint("ERREUR STREAM RECRUTEURS : $e");
      setState(() {
        chargement = false;
      });
    }
  }
  Widget carteRecruteur(Map<String, dynamic> recruteur) {
    final String? logoUrl =recruteur["logo_url"]?.toString();
    final String nomClub = recruteur["nom_club"] ?? "Club";
    final String ville = recruteur["ville"] ?? "";
    final String pays = recruteur["pays"] ?? "";

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 14, bottom: 8, top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey.shade50,
              backgroundImage: logoUrl != null ? NetworkImage(logoUrl) : null,
              child: logoUrl == null
                  ? Icon(Icons.sports_soccer, color: Colors.grey.shade600, size: 26)
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            nomClub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "$ville, $pays",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget carteAnnonce(
      Map<String,dynamic> annonce
      ){

    final recruteur =
        annonce["profils_recruteurs"] as Map<String, dynamic>? ?? {};
    final logoUrl =
    recruteur["logo_url"]?.toString();


    return GestureDetector(

      onTap:(){

        Navigator.push(

          context,

          MaterialPageRoute(

            builder:(_)=>
                DetailAnnoncePage(

                  annonce: annonce,

                ),

          ),

        );

      },


      child:Container(

        margin:
        const EdgeInsets.only(bottom:15),


        padding:
        const EdgeInsets.all(15),


        decoration:BoxDecoration(

          color:Colors.white,

          borderRadius:
          BorderRadius.circular(20),

          boxShadow:[

            BoxShadow(

              color:Colors.black12,

              blurRadius:8,

              offset:
              const Offset(0,3),

            )

          ],

        ),


        child:Row(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children:[


            // =========================
            // LOGO CLUB A GAUCHE
            // =========================

            Container(

              width:90,

              height:120,


              decoration:BoxDecoration(

                color:
                Colors.grey.shade100,

                borderRadius:
                BorderRadius.circular(15),

              ),


              child:ClipRRect(

                borderRadius:
                BorderRadius.circular(15),

                child: logoUrl != null && logoUrl.isNotEmpty

                    ? Image.network(

                  logoUrl,

                  fit: BoxFit.contain,

                  errorBuilder: (context, error, stackTrace){

                    debugPrint(
                        "Erreur chargement logo : $error"
                    );

                    return const Icon(
                      Icons.broken_image,
                      size:40,
                      color:Colors.grey,
                    );

                  },

                )   :

                const Icon(

                  Icons.shield,

                  size:40,

                  color:Colors.grey,

                ),

              ),

            ),



            const SizedBox(width:15),




            // =========================
            // DETAILS A DROITE
            // =========================

            Expanded(

              child:Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,


                children:[


                  // TITRE

                  Text(

                    annonce["titre"]
                        ??
                        "Annonce recrutement",

                    maxLines:2,

                    overflow:
                    TextOverflow.ellipsis,


                    style:
                    const TextStyle(

                      fontSize:17,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),



                  const SizedBox(height:10),



                  // CLUB

                  Text(

                    recruteur["nom_club"]
                        ??
                        annonce["club"]
                        ??
                        "Club",

                    style:
                    const TextStyle(

                      color:Colors.blue,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),



                  const SizedBox(height:8),




                  // POSTE

                  Text(

                    "⚽ Poste : ${annonce["poste"] ?? "Non précisé"}",

                    style:
                    const TextStyle(

                      fontWeight:
                      FontWeight.w600,

                    ),

                  ),



                  const SizedBox(height:6),



                  // LOCALISATION

                  Text(

                    "📍 ${recruteur["ville"] ?? annonce["ville"] ?? ""}, ${recruteur["pays"] ?? annonce["pays"] ?? ""}",

                    style:
                    TextStyle(

                      color:
                      Colors.grey.shade700,

                    ),

                  ),



                  const SizedBox(height:8),



                  // DESCRIPTION

                  Text(

                    annonce["description"]
                        ??
                        "",


                    maxLines:2,


                    overflow:
                    TextOverflow.ellipsis,


                    style:
                    TextStyle(

                      color:
                      Colors.grey.shade800,

                    ),

                  ),



                  const SizedBox(height:8),



                  // DATE

                  if(annonce["created_at"] != null)

                    Text(

                      "📅 ${annonce["created_at"].toString().substring(0,10)}",

                      style:
                      TextStyle(

                        fontSize:12,

                        color:
                        Colors.grey.shade600,

                      ),

                    ),


                ],

              ),

            ),


          ],

        ),

      ),

    );

  }
  @override
  Widget build(BuildContext context) {
    if (chargement) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fond gris clair moderne
      body: RefreshIndicator(
        onRefresh: charger,
        color: const Color(0xFF0F172A),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 16),
            const Text(
              "🏢 Clubs recruteurs",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 14),
            const SizedBox(height: 14),
            SizedBox(
              height: 165, // Changed from 150 to 165 to prevent the bottom overflow
              child: recruteurs.isEmpty
                  ? Center(child: Text("Aucun club disponible", style: TextStyle(color: Colors.grey.shade400)))
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recruteurs.length,
                itemBuilder: (context, index) {
                  return carteRecruteur(recruteurs[index]);
                },
              ),
            ),

            const SizedBox(height: 28),
            const Text(
              "📢 Annonces de recrutement",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 14),
            if (annonces.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    "Aucune annonce disponible",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                ),
              )
            else
              ...annonces.map((a) => carteAnnonce(a)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} // Fin de la classe _RecruteurStreamPageState
