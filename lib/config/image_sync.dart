import 'dart:io';
import 'package:imager/config/app_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ssh2/ssh2.dart';

class ImageSync {

  Future<void> syncData() async {
    String result = '';
    List array = [];
    const String _stringPath = "/storage/emulated/0/DCIM/image-source/hitAdd/1654251929250_ncinga.jpg";

    var client = SSHClient(
      host: AppConfig.host,
      port: 22,
      username: AppConfig.username,
      passwordOrKey: {"privateKey": AppConfig.private_key},
    );

    try {
      result = await client.connect() ?? 'Null result';
      print("FTP Result : $result");
      if (result == "session_connected") {
        result = await client.connectSFTP() ?? 'Null result';
        if (result == "sftp_connected") {
          array = await client.sftpLs() ?? [];
         print(await client.sftpMkdir("ncinga-images"));

         print(await client.sftpUpload(
            path: _stringPath,
            toPath: AppConfig.ftp_path,
            callback: (progress) async {
              print(progress);
              // if (progress == 30) await client.sftpCancelUpload();
            },
          ) ??
              'Upload failed');

          /* // Create a test directory
          print(await client.sftpMkdir("testsftp"));

          // Rename the test directory
          print(await client.sftpRename(
            oldPath: "testsftp",
            newPath: "testsftprename",
          ));

          // Remove the renamed test directory
          print(await client.sftpRmdir("testsftprename"));

          // Get local device temp directory
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path;

          // Create local test file
          const String fileName = 'ssh2_test_upload.txt';
          final File file = File('$tempPath/$fileName');
          await file.writeAsString('Testing file upload');

          print('Local file path is ${file.path}');

          // Upload test file
          print(await client.sftpUpload(
                path: file.path,
                toPath: ".",
                callback: (progress) async {
                  print(progress);
                  // if (progress == 30) await client.sftpCancelUpload();
                },
              ) ??
              'Upload failed');

          */

        }
      }
    } catch (e) {
      print(e);
    }
  }


  Stream<int> generateNumbers = (() async* {


    for (int i = 1; i <= 100; i++) {

      await Future<void>.delayed(const Duration(seconds: 1));
      yield i;
    }
  })();

  Stream<int> fileUploading = (() async* {
    for (int i = 1; i <= 100; i++) {
      await Future<void>.delayed(const Duration(seconds: 1));
      yield i;
    }
  })();
}
