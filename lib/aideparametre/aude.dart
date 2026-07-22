import 'package:flutter/material.dart';


class AidePage extends StatelessWidget {

  const AidePage({
    super.key,
  });


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
      Colors.grey.shade100,


      appBar: AppBar(

        title:
        const Text(
          "Aide",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),


        centerTitle:true,

        backgroundColor:
        Colors.blueAccent.shade700,

        foregroundColor:
        Colors.white,

      ),



      body:SingleChildScrollView(

        padding:
        const EdgeInsets.all(20),


        child:Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children:[



            Card(

              child:ListTile(

                leading:
                const Icon(
                  Icons.person,
                  color:Colors.blue,
                ),

                title:
                const Text(
                  "Créer un profil joueur",
                  style:TextStyle(
                    fontWeight:FontWeight.bold,
                  ),
                ),


                subtitle:
                const Text(
                  "Ajoutez vos informations personnelles, "
                      "votre parcours sportif et vos vidéos.",
                ),

              ),

            ),




            Card(

              child:ListTile(

                leading:
                const Icon(
                  Icons.video_library,
                  color:Colors.green,
                ),


                title:
                const Text(
                  "Publier une vidéo",
                  style:TextStyle(
                    fontWeight:FontWeight.bold,
                  ),
                ),


                subtitle:
                const Text(
                  "Présentez vos performances "
                      "au public.",
                ),

              ),

            ),





            Card(

              child:ListTile(

                leading:
                const Icon(
                  Icons.security,
                  color:Colors.orange,
                ),


                title:
                const Text(
                  "Confidentialité",
                  style:TextStyle(
                    fontWeight:FontWeight.bold,
                  ),
                ),


                subtitle:
                const Text(
                  "Vous contrôlez vos informations "
                      "et votre profil.",
                ),

              ),

            ),



          ],

        ),

      ),


    );


  }


}