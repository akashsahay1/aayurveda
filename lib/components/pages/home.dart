import 'package:flutter/material.dart';
import '../../constants/texts.dart';
import '../common/layout.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.amber,
        width: double.infinity,
        height: double.infinity,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo.png", width: 200.0, height: 200.0, fit: BoxFit.contain),
                const SizedBox(height: 15.0,),
                const Text(
                  AppStrings.welcomeMessage, 
                  style: TextStyle(
                    fontSize: 16.0, 
                    fontWeight: FontWeight.w600,
                    fontFamily: 'OpenSans',
                    color: Colors.black
                  ),
                ),
                const SizedBox(height: 15.0,),
                ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Layout(),
                      ),
                    );
                  },
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.deepPurple),
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                    shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3.0)),
                        side: BorderSide(color: Colors.deepPurple)
                      )
                    )  
                  ), 
                  child: const Text(
                    "Get Started", 
                    style: TextStyle(
                      color:Colors.white, 
                      fontFamily: 'OpenSans', 
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.0
                    )
                  ),
                )               
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.amber,
    );
  }
}