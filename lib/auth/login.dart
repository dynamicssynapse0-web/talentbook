import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import '../Slivepage/streampage.dart';
import '../joeur/ProfilJoueurPage.dart';
import 'creationcompte.dart';


class LoginPage extends StatefulWidget {

  const LoginPage({
    super.key,
  });


  @override
  State<LoginPage> createState() =>
      _LoginPageState();

}



class _LoginPageState extends State<LoginPage> {


  final emailController =
  TextEditingController();


  final passwordController =
  TextEditingController();



  bool afficherMotDePasse = false;

  bool chargement = false;



  Future<void> connexion() async {


    if(emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty){

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text(
              "Remplis tous les champs"
          ),
        ),

      );

      return;

    }



    setState(() {

      chargement = true;

    });



    try {


      final response =
      await Supabase.instance.client.auth
          .signInWithPassword(

        email:
        emailController.text.trim(),

        password:
        passwordController.text.trim(),

      );



      if(response.user != null){



        final joueur = await Supabase
            .instance
            .client
            .from("player")
            .select("id")
            .eq(
            "user_id",
            response.user!.id
        )
            .maybeSingle();




        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content:
            Text("Connexion réussie"),
          ),

        );




        if(joueur != null){


          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder: (_) =>
              const StreamPage(),
            ),

          );


        }
        else{


          // compte créé mais profil joueur absent

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder: (_) =>
              const CreationCompte(),

            ),

          );


        }


      }



    }

    on AuthException catch(e){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(e.message),

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
          ),

        ),

      );


    }



    if(mounted){

      setState(() {

        chargement = false;

      });

    }


  }







  Future<void> motDePasseOublie() async {



    if(emailController.text.trim().isEmpty){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
              "Entre ton email avant"
          ),

        ),

      );


      return;

    }




    try{

      await Supabase.instance.client.auth
          .resetPasswordForEmail(
        emailController.text.trim(),


      );



      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
              "Lien envoyé par email"
          ),

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
          ),

        ),

      );


    }


  }






  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
      Colors.white,


      body: SafeArea(


        child: SingleChildScrollView(


          padding:
          const EdgeInsets.all(25),



          child: Column(


            crossAxisAlignment:
            CrossAxisAlignment.start,


            children:[



              const SizedBox(
                  height:50
              ),



              const Text(

                "Connexion",

                style:
                TextStyle(

                  fontSize:32,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              const SizedBox(height:10),



              const Text(

                "Connecte-toi à ton compte",

                style:
                TextStyle(

                  color:Colors.grey,

                  fontSize:16,

                ),

              ),




              const SizedBox(height:40),





              TextField(

                controller:
                emailController,


                keyboardType:
                TextInputType.emailAddress,


                decoration:
                InputDecoration(

                  labelText:"Email",

                  prefixIcon:
                  const Icon(
                      Icons.email
                  ),


                  border:
                  OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(15),

                  ),

                ),

              ),





              const SizedBox(height:20),





              TextField(

                controller:
                passwordController,


                obscureText:
                !afficherMotDePasse,


                decoration:
                InputDecoration(

                  labelText:
                  "Mot de passe",


                  prefixIcon:
                  const Icon(
                      Icons.lock
                  ),



                  suffixIcon:
                  IconButton(


                    icon:
                    Icon(

                      afficherMotDePasse
                          ?
                      Icons.visibility
                          :
                      Icons.visibility_off,

                    ),



                    onPressed:(){

                      setState(() {

                        afficherMotDePasse =
                        !afficherMotDePasse;

                      });

                    },

                  ),


                  border:
                  OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(15),

                  ),

                ),

              ),





              const SizedBox(height:15),





              Align(

                alignment:
                Alignment.centerRight,


                child:
                GestureDetector(


                  onTap:
                  motDePasseOublie,


                  child:
                  const Text(

                    "Mot de passe oublié ?",


                    style:
                    TextStyle(

                      color:
                      Colors.blue,


                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                ),

              ),





              const SizedBox(height:30),





              SizedBox(

                width:
                double.infinity,


                height:55,


                child:
                ElevatedButton(


                  onPressed:
                  chargement
                      ?
                  null
                      :
                  connexion,


                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    Colors.blue,


                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(15),

                    ),

                  ),



                  child:
                  chargement

                      ?

                  const CircularProgressIndicator(
                    color:Colors.white,
                  )

                      :

                  const Text(

                    "Se connecter",

                    style:
                    TextStyle(

                      color:
                      Colors.white,

                      fontSize:18,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                ),

              ),





              const SizedBox(height:25),





              Center(

                child:
                Row(

                  mainAxisAlignment:
                  MainAxisAlignment.center,


                  children:[


                    const Text(
                        "Pas encore de compte ? "
                    ),



                    GestureDetector(

                      onTap:(){

                        Navigator.pushReplacement(

                          context,

                          MaterialPageRoute(

                            builder:(_)=>
                            const CreationCompte(),

                          ),

                        );

                      },


                      child:
                      const Text(

                        "Créer un compte",

                        style:
                        TextStyle(

                          color:
                          Colors.blue,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                    )


                  ],

                ),

              )


            ],

          ),

        ),

      ),

    );


  }


}