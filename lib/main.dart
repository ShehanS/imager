import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:imager/pages/google_sigin.dart';
import 'package:imager/pages/image_uploader.dart';
import 'package:imager/providers/google_signin_provider.dart';
import 'package:provider/provider.dart';
import 'providers/ftp_status_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FTPStatusProvider>(create: (context) => FTPStatusProvider()),
        ChangeNotifierProvider<GoogleSignInProvider>(create: (context) => GoogleSignInProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GoogleLogin(context: context),
    );
  }
}
