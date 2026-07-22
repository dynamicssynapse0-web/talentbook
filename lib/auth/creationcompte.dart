import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Slivepage/streampage.dart';
import '../stream/streampage.dart';
import 'login.dart';


class CreationCompte extends StatefulWidget {
  const CreationCompte({super.key});

  @override
  State<CreationCompte> createState() => _CreationCompteState();
}

class _CreationCompteState extends State<CreationCompte> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
  TextEditingController();

  bool afficherMotDePasse = false;
  bool afficherRepeatMotDePasse = false;
  bool chargement = false;


  Future<void> creerCompte() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }


    if (passwordController.text != repeatPasswordController.text) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Les deux mots de passe ne correspondent pas",
          ),
        ),
      );

      return;
    }


    setState(() {
      chargement = true;
    });


    try {

      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );


      if (response.user != null) {


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Compte créé avec succès",
            ),
          ),
        );


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const StreamPage(),
          ),
        );

      }


    } on AuthException catch(e){

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );


    } catch(e){

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur : $e",
          ),
        ),
      );


    }


    setState(() {
      chargement = false;
    });

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,


      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(25),


          child: Form(

            key: _formKey,


            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [


                const SizedBox(height: 40),


                const Text(
                  "Créer un compte",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                const SizedBox(height: 10),


                const Text(
                  "Inscris-toi pour accéder à StreamPage",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),


                const SizedBox(height: 40),


                TextFormField(
                  controller: emailController,

                  keyboardType: TextInputType.emailAddress,


                  decoration: InputDecoration(

                    labelText: "Email",

                    prefixIcon:
                    const Icon(Icons.email),


                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),

                  ),


                  validator: (value){

                    if(value == null || value.isEmpty){

                      return "Entre ton email";

                    }

                    if(!value.contains("@")){

                      return "Email invalide";

                    }


                    return null;

                  },


                ),


                const SizedBox(height: 20),
                TextFormField(

                  controller: passwordController,


                  obscureText: !afficherMotDePasse,


                  decoration: InputDecoration(

                    labelText: "Mot de passe",


                    prefixIcon:
                    const Icon(Icons.lock),


                    suffixIcon: IconButton(

                      icon: Icon(

                        afficherMotDePasse
                            ? Icons.visibility
                            : Icons.visibility_off,

                      ),


                      onPressed: (){

                        setState(() {

                          afficherMotDePasse =
                          !afficherMotDePasse;

                        });

                      },

                    ),


                    border: OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(15),

                    ),

                  ),



                  validator: (value){

                    if(value == null || value.isEmpty){

                      return "Entre un mot de passe";

                    }


                    if(value.length < 6){

                      return "Minimum 6 caractères";

                    }


                    return null;

                  },


                ),



                const SizedBox(height: 20),




                TextFormField(


                  controller: repeatPasswordController,


                  obscureText: !afficherRepeatMotDePasse,


                  decoration: InputDecoration(


                    labelText: "Répéter le mot de passe",


                    prefixIcon:
                    const Icon(Icons.lock_outline),



                    suffixIcon: IconButton(


                      icon: Icon(

                        afficherRepeatMotDePasse

                            ? Icons.visibility

                            : Icons.visibility_off,

                      ),


                      onPressed: (){


                        setState(() {


                          afficherRepeatMotDePasse =
                          !afficherRepeatMotDePasse;


                        });


                      },


                    ),



                    border: OutlineInputBorder(


                      borderRadius:
                      BorderRadius.circular(15),


                    ),


                  ),




                  validator: (value){


                    if(value == null || value.isEmpty){


                      return "Répète ton mot de passe";


                    }



                    if(value != passwordController.text){


                      return "Les mots de passe sont différents";


                    }



                    return null;


                  },



                ),




                const SizedBox(height: 30),




                SizedBox(


                  width: double.infinity,


                  height: 55,



                  child: ElevatedButton(


                    style: ElevatedButton.styleFrom(


                      backgroundColor:
                      Colors.blue,


                      shape:
                      RoundedRectangleBorder(


                        borderRadius:
                        BorderRadius.circular(15),


                      ),


                    ),



                    onPressed: chargement
                        ? null
                        : creerCompte,



                    child: chargement


                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )


                        : const Text(


                      "Créer mon compte",


                      style: TextStyle(


                        fontSize: 18,


                        color: Colors.white,


                        fontWeight:
                        FontWeight.bold,


                      ),


                    ),



                  ),


                ),




                const SizedBox(height: 25),




                Center(


                  child: Row(


                    mainAxisAlignment:
                    MainAxisAlignment.center,


                    children: [



                      const Text(

                        "Déjà un compte ? ",

                        style:
                        TextStyle(fontSize:16),

                      ),




                      GestureDetector(


                        onTap: (){


                          Navigator.push(


                            context,


                            MaterialPageRoute(


                              builder:
                                  (context)=> const LoginPage(),


                            ),


                          );


                        },



                        child: const Text(


                          "Se connecter",


                          style: TextStyle(


                            color: Colors.blue,


                            fontWeight:
                            FontWeight.bold,


                            fontSize:16,


                          ),


                        ),


                      ),



                    ],


                  ),


                ),



              ],


            ),


          ),


        ),


      ),


    );


  }


}