import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ssh2/ssh2.dart';

import '../config/app_config.dart';

class ImageUploader extends StatefulWidget {
  const ImageUploader({Key? key}) : super(key: key);

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  bool isConnected = false;
  var client;
  String serverStatus = "";

  Future<void> _connectedToServer() async{
    client = SSHClient(
      host: AppConfig.host,
      port: 22,
      username: AppConfig.username,
      passwordOrKey: {"privateKey": AppConfig.private_key},
    );
    try {
      serverStatus = await client.connect();
      print(serverStatus);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _disconnectServer() async{
    serverStatus = await client.disconnect();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Uploader"),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI(){
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
     child: Column(
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             const Text("Server Status"),
             ElevatedButton(onPressed: (){
               _connectedToServer();

             }, child: isConnected ? const Text("Disconnect") : const Text("Connect"))
           ],
         )
       ],
     ),
    );
  }

}
