import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class sitepage extends StatefulWidget {
  const sitepage({super.key});

  @override
  State<sitepage> createState() => _sitepageState();
}

class _sitepageState extends State<sitepage> {
  late final user;
  late final oobcode;
  TextEditingController cont1=TextEditingController();
  TextEditingController cont2=TextEditingController();
  ValueNotifier errornoti=ValueNotifier(false);
  ValueNotifier loadingscreen=ValueNotifier(false);
  late Stream<DocumentSnapshot> studentFuture;

  @override
  void initState(){
    super.initState();
    
    // Read query parameter from URL
    Uri uri = Uri.base; // e.g. https://yourapp.com/reset-password?oobCode=12345
    oobcode = uri.queryParameters['oobCode'];
    user = uri.queryParameters['user'];
    print("OOB code: $oobcode");
    
    
  }

  void confirmreset()async{
    if(oobcode!=null){
      
      try{
        loadingscreen.value=true;
        await FirebaseAuth.instance.confirmPasswordReset(
          code: oobcode,
          newPassword: cont1.text
        );
        loadingscreen.value=false;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Container(width: double.infinity,child: Text('Password changed successfully',style: TextStyle(fontWeight: FontWeight.w600),),),

            );
          },
        );
      }catch(e){
        loadingscreen.value=false;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Container(width: double.infinity,child: Text('Sorry, process failed',style: TextStyle(fontWeight: FontWeight.w600),),),

            );
          },
        );
      }
      
    }
    else{
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Container(width: double.infinity,child: Text('Invalid attempt',style: TextStyle(fontWeight: FontWeight.w600),),),

            );
          },
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double containerwidth=constraints.maxWidth;
          return StreamBuilder(
            stream: FirebaseFirestore.instance
            .collection('students')
            .doc(user)
            .snapshots(),
            builder: (context, snapshot) {
              if(snapshot.connectionState==ConnectionState.waiting){
                return Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                );
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text("Invalid or unknown user"));
              }
              return ValueListenableBuilder(
                valueListenable: loadingscreen,
                builder: (context, value, child) {
                  return Stack(
                    children: [
                      if(loadingscreen.value==true)
                      Expanded(child: Container(
                        color: const Color.fromARGB(255, 193, 47, 47),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            Text('Processing...')
                          ],

                        ),
                      )),
                      Center(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 255, 255, 255),
                            border: Border.all(width: 1)
                          ),
                          width: containerwidth*0.9,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            
                            children: [
                              Text('Hello, ${(snapshot.data!.data()! as Map)['name']}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: cont1,
                                  cursorColor: const Color.fromARGB(255, 79, 79, 79),
                                  decoration: InputDecoration(
                                    labelText: 'New Password',
                                    labelStyle: TextStyle(
                                      color: Colors.black
                                    ),
                                    floatingLabelStyle: TextStyle(color: const Color.fromARGB(255, 113, 113, 113)),
                                   
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2,color: const Color.fromARGB(255, 0, 0, 0)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                                    filled: true,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ValueListenableBuilder(
                                  valueListenable: errornoti,
                                  builder: (context, value, child) {
                                    return TextField(
                                      obscureText: true,
                                      controller: cont2,
                                      cursorColor: const Color.fromARGB(255, 79, 79, 79),
                                      decoration: InputDecoration(
                                        errorText: errornoti.value==true?'Both fields should match':null,
                                        labelText: 'Confirm Password',
                                        labelStyle: TextStyle(
                                          color: Colors.black
                                        ),
                                        floatingLabelStyle: TextStyle(color: const Color.fromARGB(255, 113, 113, 113)),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(width: 1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(width: 2,color: const Color.fromARGB(255, 0, 0, 0)),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        
                                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                                        filled: true,
                                      ),
                                    );
                                  }
                                ),
                              ),
                              SizedBox(height: 10,),
                              ElevatedButton(
                                onPressed: () {
                                  if(cont1.text!=cont2.text){
                                    errornoti.value=true;
                                  }
                                  else{
                                    errornoti.value=false;
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          alignment: Alignment.center,
                                          title: Container(width: double.infinity,alignment: Alignment.center,child: Text('Confirmation',style: TextStyle(fontWeight: FontWeight.bold),)),
                                          content: Text('Are you sure you want to change the password?',style: TextStyle(fontWeight: FontWeight.w600),),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () async{
                                                Navigator.pop(context);
                                                confirmreset();
                                              },
                                              style: ButtonStyle(
                                                side: WidgetStatePropertyAll(BorderSide(width: 1)),
                                                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                                backgroundColor: WidgetStatePropertyAll(Colors.black),
                                                foregroundColor: WidgetStatePropertyAll(Colors.white)
                                              ),
                                              child: Text('Confirm',style: TextStyle(fontWeight: FontWeight.bold),),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                style: ButtonStyle(
                                  side: WidgetStatePropertyAll(BorderSide(width: 1)),
                                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  backgroundColor: WidgetStatePropertyAll(Colors.black),
                                  foregroundColor: WidgetStatePropertyAll(Colors.white)
                                ),
                                child: Text('Change Password'),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              );
            }
          );
        },
      ),
    );
  }
}