import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:imager/pages/google_sigin.dart';
import '../providers/google_signin_provider.dart';

class DrawerWidget extends StatefulWidget {
  final GoogleSignInAccount user;
  const DrawerWidget({Key? key, required this.user}) : super(key: key);

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
           DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepOrange),
              child: Column(

                children: [
                  GoogleUserCircleAvatar(identity: widget.user),
                 Text(widget.user.email),


                ],
              )),

          ListTile(
            title: const Text("Logout"),
            onTap: () {
              provider.googleSignOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> GoogleLogin(context: context)));
            },
          ),
        ],
      ),
    );
  }
}
