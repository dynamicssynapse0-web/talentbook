import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class PaymentWebViewPage extends StatefulWidget {

  final String url;
  final VoidCallback onSuccess;


  const PaymentWebViewPage({

    super.key,

    required this.url,

    required this.onSuccess,

  });


  @override
  State<PaymentWebViewPage> createState() =>
      _PaymentWebViewPageState();

}

class _PaymentWebViewPageState
    extends State<PaymentWebViewPage>{


  late WebViewController controller;



  @override
  void initState(){

    super.initState();


    controller =
    WebViewController()

      ..setJavaScriptMode(
          JavaScriptMode.unrestricted
      )

      ..loadRequest(
          Uri.parse(widget.url)
      );


  }



  @override
  Widget build(BuildContext context){


    return Scaffold(

      appBar:AppBar(

        title:
        const Text(
          "Paiement sécurisé",
        ),

      ),


      body:
      WebViewWidget(

        controller:controller,

      ),


    );


  }


}