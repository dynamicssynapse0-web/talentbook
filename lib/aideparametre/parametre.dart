import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../joeur/ProfilJoueurPage.dart';



class ParametresPage extends StatelessWidget {


  const ParametresPage({
    super.key,
  });



  Future<void> deconnexion(BuildContext context) async {


    await Supabase.instance.client.auth.signOut();



    Navigator.pushNamedAndRemoveUntil(

      context,

      "/login",

          (route)=>false,

    );


  }




  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor:
      Colors.grey.shade100,



      appBar:AppBar(


        title:
        const Text(
          "Paramètres",
          style:TextStyle(
            fontWeight:FontWeight.bold,
          ),
        ),


        centerTitle:true,


        backgroundColor:
        Colors.blueAccent.shade700,


        foregroundColor:
        Colors.white,


      ),




      body:Column(

        children:[



          const SizedBox(height:20),




          Card(

            margin:
            const EdgeInsets.symmetric(
              horizontal:20,
            ),


            child:ListTile(

              leading:
              const Icon(
                Icons.person,
                color:Colors.blue,
              ),


              title:
              const Text(
                "Modifier mon profil",
              ),


              trailing:
              const Icon(
                Icons.chevron_right,
              ),

              onTap: () async {

                final user =
                    Supabase.instance.client.auth.currentUser;


                if(user == null){

                  Navigator.pushNamed(
                    context,
                    "/login",
                  );

                  return;
                }



                final player = await Supabase.instance.client
                    .from("player")
                    .select("id")
                    .eq(
                  "user_id",
                  user.id,
                )
                    .single();



                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context) => ProfilJoueurPage(

                      playerId: player["id"],

                    ),

                  ),

                );


              },

            ),

          ),





          Card(

            margin:
            const EdgeInsets.symmetric(
              horizontal:20,
            ),


            child:ListTile(

              leading:
              const Icon(
                Icons.notifications,
                color:Colors.orange,
              ),


              title:
              const Text(
                "Notifications",
              ),


              trailing:
              Switch(

                value:true,

                onChanged:(v){},

              ),

            ),

          ),






          Card(

            margin:
            const EdgeInsets.symmetric(
              horizontal:20,
            ),


            child:ListTile(

              leading:
              const Icon(
                Icons.logout,
                color:Colors.red,
              ),


              title:
              const Text(
                "Déconnexion",
              ),


              onTap:(){

                deconnexion(context);

              },

            ),

          ),




        ],

      ),


    );


  }


}