import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login.dart';

class NouveauMotDePassePage extends StatefulWidget {

  const NouveauMotDePassePage({
    super.key,
  });


  @override
  State<NouveauMotDePassePage> createState() =>
      _NouveauMotDePassePageState();

}



class _NouveauMotDePassePageState
    extends State<NouveauMotDePassePage>{


  final passwordController =
  TextEditingController();


  final confirmationController =
  TextEditingController();


  bool chargement = false;



  Future<void> changerMotDePasse() async {


    if(passwordController.text.isEmpty ||
        confirmationController.text.isEmpty){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
            content:
            Text("Remplis tous les champs")
        ),

      );

      return;

    }



    if(passwordController.text !=
        confirmationController.text){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
            content:
            Text("Les mots de passe sont différents")
        ),

      );


      return;

    }



    setState(() {
      chargement=true;
    });



    try{


      await Supabase.instance.client.auth
          .updateUser(

        UserAttributes(

          password:
          passwordController.text.trim(),

        ),

      );



      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
            content:
            Text("Mot de passe modifié")
        ),

      );



      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder:(_)=>
          const LoginPage(),

        ),

      );


    }

    catch(e){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
            content:
            Text(
                "Erreur : $e"
            )
        ),

      );


    }



    setState(() {
      chargement=false;
    });


  }






  @override
  Widget build(BuildContext context){


    return Scaffold(


      appBar:
      AppBar(
        title:
        const Text(
            "Nouveau mot de passe"
        ),
      ),


      body:
      Padding(

        padding:
        const EdgeInsets.all(25),


        child:
        Column(

          children:[


            TextField(

              controller:
              passwordController,

              obscureText:true,

              decoration:
              const InputDecoration(

                labelText:
                "Nouveau mot de passe",

              ),

            ),



            const SizedBox(height:20),



            TextField(

              controller:
              confirmationController,

              obscureText:true,

              decoration:
              const InputDecoration(

                labelText:
                "Confirmer le mot de passe",

              ),

            ),



            const SizedBox(height:30),



            ElevatedButton(

              onPressed:
              chargement
                  ?
              null
                  :
              changerMotDePasse,


              child:
              chargement

                  ?
              const CircularProgressIndicator()

                  :

              const Text(
                  "Changer"
              ),

            )


          ],

        ),

      ),

    );


  }

}