import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GaleriePhotosPage extends StatefulWidget {


  final List<String> photos;

  final int indexInitial;



  const GaleriePhotosPage({

    super.key,

    required this.photos,

    required this.indexInitial,

  });



  @override
  State<GaleriePhotosPage> createState() =>
      _GaleriePhotosPageState();

}





class _GaleriePhotosPageState
    extends State<GaleriePhotosPage> {


  late PageController controller;



  @override
  void initState(){


    super.initState();


    controller = PageController(

      initialPage:
      widget.indexInitial,

    );


  }





  @override
  void dispose(){


    controller.dispose();


    super.dispose();


  }





  @override
  Widget build(BuildContext context){


    return Scaffold(


      backgroundColor:
      Colors.black,



      appBar:AppBar(


        backgroundColor:
        Colors.black,


        elevation:
        0,


        iconTheme:
        const IconThemeData(

          color:
          Colors.white,

        ),



        title:Text(

          "${widget.indexInitial + 1}/${widget.photos.length}",

          style:
          const TextStyle(

            color:
            Colors.white,

          ),

        ),


      ),





      body:PageView.builder(


        controller:
        controller,



        itemCount:
        widget.photos.length,



        itemBuilder:(context,index){


          return Center(


            child:
            InteractiveViewer(


              minScale:
              0.8,


              maxScale:
              4,


              child:
              Image.network(


                widget.photos[index],



                fit:
                BoxFit.contain,



                loadingBuilder:
                    (context,child,loading){


                  if(loading==null){

                    return child;

                  }



                  return const Center(

                    child:
                    CircularProgressIndicator(

                      color:
                      Colors.white,

                    ),

                  );


                },


              ),


            ),


          );


        },


      ),


    );


  }


}