import 'package:flutter/material.dart';

class FTPServerSetting extends StatefulWidget {
  const FTPServerSetting({Key? key}) : super(key: key);

  @override
  State<FTPServerSetting> createState() => _FTPServerSettingState();
}

class _FTPServerSettingState extends State<FTPServerSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FTP Server Setting"),
      ),
      body: _buildSetting(),
    );
  }


  Widget _buildSetting(){
    return Container();
  }


}
