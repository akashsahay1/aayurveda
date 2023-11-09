import 'package:flutter/material.dart';

class Contactd extends StatefulWidget {
  const Contactd({super.key});

  @override
  State<Contactd> createState() => _ContactdState();
}

class _ContactdState extends State<Contactd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SizedBox(height: 35.0,),
                Container(
                  alignment: Alignment.centerLeft,
                  height: 50.0,                    
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Aayurveda Categories",                   
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white                      
                    )
                  )
                ),          
                SizedBox(height: 5.0,),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      15,
                      (index) => Container(
                        height: 180,
                        width: 150,
                        margin: EdgeInsets.all(8),
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            'Item $index',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.0,),
                Container(
                  alignment: Alignment.centerLeft,
                  height: 50.0,
                  color: Colors.deepPurple,
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Popular Cure Techniques",                   
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white                      
                    )
                  )
                ),          
                SizedBox(height: 5.0,),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      15,
                      (index) => Container(
                        height: 180,
                        width: 150,
                        margin: EdgeInsets.all(8),
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            'Item $index',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.0,),                                  
              ],
            )
          )
        ]
      ),
    );

  }
}