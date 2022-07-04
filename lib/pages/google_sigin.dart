import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:imager/pages/home_page.dart';
import 'package:imager/providers/google_signin_provider.dart';
import 'package:imager/styles/global_style.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert' show json;

class GoogleLogin extends StatefulWidget {
  final BuildContext context;
  const GoogleLogin({required this.context, Key? key}) : super(key: key);

  @override
  State<GoogleLogin> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  late List<CameraDescription> cameras;
  GoogleSignInAccount? _currentUser;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
    var provider =
        Provider.of<GoogleSignInProvider>(widget.context, listen: false);
    provider.googleSignIn.signInSilently();
    provider.googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? user) {
      setState(() {
        _currentUser = user;
      });
      if (_currentUser != null) {
        _handleGetContact(_currentUser!);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage(user!)));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = 'Loading contact info...';
    });
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = 'People API gave a ${response.statusCode} '
            'response. Check logs for details.';
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = 'I see you know $namedContact!';
      } else {
        _contactText = 'No contacts to display.';
      }
    });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final Map<String, dynamic>? name = contact['names'].firstWhere(
        (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  Widget _buildBody() {
    Size size = MediaQuery.of(context).size;
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const SizedBox(height: 200),
          Column(
            children: [
              _buildMenu(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    primary: Colors.black87,
                    textStyle: GlobalTextStyle.button_text_16_black),
                icon: const Icon(Icons.logout),
                onPressed: () {
                  var provider = Provider.of<GoogleSignInProvider>(
                      widget.context,
                      listen: false);
                  provider.googleSignOut();
                },
                label: const Text("Singout"),
              )
            ],
          )
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/images/ncinga_pte.jpg", scale: 1.5),
          Column(
            children: <Widget>[
              const Text('Please signing before app use.'),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.black87,
                      textStyle: GlobalTextStyle.button_text_16_black),
                  onPressed: () {
                    var provider = Provider.of<GoogleSignInProvider>(
                        widget.context,
                        listen: false);
                    provider.googleLogin();
                  },
                  icon: const FaIcon(FontAwesomeIcons.google),
                  label: const Text("Sign with GOOGLE")),
            ],
          )
        ],
      );
    }
  }

  Widget _buildMenu() {
    return Column(
      children: [Text("kjhskdlfjlksdfj")],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              _buildBody(),
            ],
          ),
        ),
      )),
    );
  }
}
