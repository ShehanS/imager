import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:imager/models/news_paper.dart';
import 'package:imager/pages/capture_page.dart';
import 'package:imager/pages/drawer_widget.dart';
import 'package:imager/utilits/custom_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ssh2/ssh2.dart';
import 'package:wakelock/wakelock.dart';
import '../config/app_config.dart';
import '../styles/global_style.dart';
import '../utilits/tile_widget.dart';

class HomePage extends StatefulWidget {
  final GoogleSignInAccount user;
  const HomePage(this.user, {Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NewsPaper? selectedNewsPaper;
  late List<CameraDescription> cameras;
  String uplodingDir = '';
  String uploadingPresentage = '';
  String serverStatus = '';
  int veeraCount = 0;
  int hitadCount = 0;
  int lahipitaCount = 0;
  var client;
  bool buttonState = false;
  bool isConnected = false;
  String response = '';
  String currentUploadFile = "";
  int currentCount = 0;
  int remCount = 0;
  TextEditingController console = TextEditingController();
  ScrollController scrollController = ScrollController();
  Timer? refreshTimer;

  Future<void> connectServer() async {
    CustomDialog.loadingDialog(context, "Connecting....");
    client = SSHClient(
      host: AppConfig.host,
      port: 22,
      username: AppConfig.username,
      passwordOrKey: {"privateKey": AppConfig.private_key},
    );
    try {
      serverStatus = await client.connect();
      setState(() {
        serverStatus = "Connected";
        Navigator.pop(context);
        isConnected = true;
      });
    } catch (e) {
      isConnected = false;
      CustomDialog.simpleDialog(context, "Connection Error", e.toString());
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> disconnectServer() async {
    try {
      await client.disconnect();
      console.text = "";
      setState(() {
        serverStatus = "Disconnected";
        isConnected = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _serverCallback() async {
    String result;
    List array = [];
    try {
      result = await client.connect() ?? 'Null result';
      if (result == "session_connected") {
        await client.startShell(
            ptyType: 'xterm',
            callback: (res) {
              client.writeToShell("ls\n");
              setState(() {
                result += res;
              });
            });
        if (kDebugMode) {
          print("Server result : $result");
        }

        if (result == "shell_started") {}
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> processData() async {
    try {
      NewsPaper selected = (await showNewPaperType()) as NewsPaper;

      var result = await client.execute(
          "${AppConfig.shell_script_path}/${selected.name}.sh");
      //var result = await client.execute("sudo imager-test/delay.sh");
      setState(() {
        response = result;
        console.text += result;
      });

      Future.delayed(const Duration(milliseconds: 10), () {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> webDataProcess() async {
    try {
      /* var result = await client.startShell(
          ptyType: 'xterm',
          callback: (res) {
            client.writeToShell("ls\n");
            print(res);
          });*/

      String result = await client.execute("sudo ncinga-images/web.sh");
      if (kDebugMode) {
        print(result);
      }
      setState(() {
        response = result;
        console.text += result;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> deleteFile() async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      for(NewsPaper paper in AppConfig.newspapers){

        Directory imageDir = Directory("${dir.path}/${paper.name}");
        imageDir.deleteSync(recursive: true);

      }
    } catch (e) {
      print(e);
    }
  }


  Future<void> getFileCounts() async {
    Directory imageDir = await getApplicationDocumentsDirectory();
    try {
      setState(() {
        hitadCount = 0;
        lahipitaCount = 0;
        veeraCount = 0;
      });
      for (FileSystemEntity entity
          in Directory(imageDir.path).listSync()) {
        if (entity is Directory) {
          for (FileSystemEntity dir in Directory(entity.path).listSync()) {
            if (dir.path.contains("hitad")) {
              setState(() {
                hitadCount += 1;
              });
            }
            if (dir.path.contains("veera")) {
              setState(() {
                veeraCount += 1;
              });
            }
            if (dir.path.contains("lahipita")) {
              setState(() {
                lahipitaCount += 1;
              });
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> startFileUploading() async {
    Directory imageDir = await getApplicationDocumentsDirectory();
    String result = '';
    List array = [];
    setState(() {
      remCount = veeraCount+lahipitaCount+hitadCount;
    });
    try {
      result = await client.connect() ?? 'Null result';
      if (kDebugMode) {
        print("FTP Result : $result");
      }
      if (result == "session_connected") {
        result = await client.connectSFTP() ?? 'Null result';
        setState(() {
          serverStatus = result;
        });
        if (result == "sftp_connected") {
          CustomDialog.loadingDialog(context, "Uploading images");
          array = await client.sftpLs() ?? [];
          List files = [];

          for(NewsPaper paper in AppConfig.newspapers){
            Directory subPath = Directory("${imageDir.path}/${paper.name}");

            if (subPath.path.contains("hitad")) {
              List subFiles = subPath.listSync();
              for (File subFile in subFiles) {
                if (kDebugMode) {
                  print("${subPath.path} - ${subPath.path}");
                }
                setState(() {
                  uplodingDir = ("${subPath.path} - ${subFile.path}");
                  currentUploadFile = subFile.path.replaceAll(
                      "/data/user/0/com.example.imager/app_flutter/hitad", "");
                  currentCount +=1;
                  remCount -= 1;
                  print(remCount);
                });

                String uploadResult = (await client.sftpUpload(
                  path: subFile.path,
                  toPath: "${AppConfig.ftp_path}/hitad",
                  callback: (progress) async {
                    setState(() {
                      uploadingPresentage = progress.toString();
                    });
                    // if (progress == 30) await client.sftpCancelUpload();
                  },
                ) ??
                    'Upload failed');
              }
            }else if(subPath.path.contains("lahipita")){
              {
                List subFiles = (subPath.listSync());
                for (File subFile in subFiles) {
                  if (kDebugMode) {
                    print("${(subPath.path)}>>>>${subFile.path}");
                  }
                  setState(() {
                    uplodingDir = ("${(subPath.path)} - ${(subFile.path)}");
                    currentUploadFile = subFile.path.replaceAll(
                        "/data/user/0/com.example.imager/app_flutter/lahipita/", "");
                    currentCount +=1;
                    remCount -= 1;
                    print(remCount);
                  });
                  if (kDebugMode) {
                    String uploadResult = (await client.sftpUpload(
                      path: subFile.path,
                      toPath: "${AppConfig.ftp_path}/lahipita",
                      callback: (progress) async {
                        setState(() {
                          uploadingPresentage = progress.toString();
                        });
                      },
                    ) ??
                        'Upload failed');
                  }
                }
              }
            }else if(subPath.path.contains("veera")){
              {
                List subFiles = subPath.listSync();
                for (File subFile in subFiles) {
                  if (kDebugMode) {
                    print("${subPath.path}>>>>${subFile.path}");
                  }
                  setState(() {
                    uplodingDir = ("${subPath.path} - ${subFile.path}");
                    currentUploadFile = subFile.path.replaceAll(
                        "/data/user/0/com.example.imager/app_flutter/veera/", "");
                    currentCount +=1;
                    remCount -= 1;
                    print(remCount);
                  });
                  if (kDebugMode) {
                    print(await client.sftpUpload(
                      path: subFile.path,
                      toPath: "${AppConfig.ftp_path}/veera",
                      callback: (progress) async {
                        setState(() {
                          uploadingPresentage = progress.toString();
                        });
                      },
                    ) ??
                        'Upload failed');
                  }
                }
              }
            }
          }

       /*
          for (Directory file in files) {
            if (file.path.contains("hitad")) {
              List subFiles = file.listSync();
              for (File subFile in subFiles) {
                if (kDebugMode) {
                  print("${file.path} - ${subFile.path}");
                }
                setState(() {
                  uplodingDir = ("${file.path} - ${subFile.path}");
                  currentUploadFile = subFile.path.replaceAll(
                      "/storage/emulated/0/DCIM/image-source/hitad/", "");
                  currentCount +=1;
                  remCount -= 1;
                  print(remCount);
                });

                String uploadResult = (await client.sftpUpload(
                      path: subFile.path,
                      toPath: "${AppConfig.ftp_test_path}/hitad",
                      callback: (progress) async {
                        setState(() {
                          uploadingPresentage = progress.toString();
                        });
                        // if (progress == 30) await client.sftpCancelUpload();
                      },
                    ) ??
                    'Upload failed');
              }
            } else if (file.path.contains("lahipita")) {
              List subFiles = file.listSync();
              for (File subFile in subFiles) {
                if (kDebugMode) {
                  print("${file.path}>>>>${subFile.path}");
                }
                setState(() {
                  uplodingDir = ("${file.path} - ${subFile.path}");
                  currentUploadFile = subFile.path.replaceAll(
                      "/storage/emulated/0/DCIM/image-source/lahipita/", "");
                  currentCount +=1;
                  remCount -= 1;
                  print(remCount);
                });
                if (kDebugMode) {
                  String uploadResult = (await client.sftpUpload(
                        path: subFile.path,
                        toPath: "${AppConfig.ftp_test_path}/lahipita",
                        callback: (progress) async {
                          setState(() {
                            uploadingPresentage = progress.toString();
                          });
                        },
                      ) ??
                      'Upload failed');
                }
              }
            } else if (file.path.contains("veera")) {
              List subFiles = file.listSync();
              for (File subFile in subFiles) {
                if (kDebugMode) {
                  print("${file.path}>>>>${subFile.path}");
                }
                setState(() {
                  uplodingDir = ("${file.path} - ${subFile.path}");
                  currentUploadFile = subFile.path.replaceAll(
                      "/storage/emulated/0/DCIM/image-source/veera/", "");
                  currentCount +=1;
                  remCount -= 1;
                  print(remCount);
                });
                if (kDebugMode) {
                  print(await client.sftpUpload(
                        path: subFile.path,
                        toPath: "${AppConfig.ftp_test_path}/veera",
                        callback: (progress) async {
                          setState(() {
                            uploadingPresentage = progress.toString();
                          });
                        },
                      ) ??
                      'Upload failed');
                }
              }
            }
          }
*/
          //print(await client.sftpMkdir("ncinga-images"));

          /*  print(await client.sftpUpload(
            path: _stringPath,
            toPath: AppConfig.FTP_PATH,
            callback: (progress) async {
              print(progress);
              // if (progress == 30) await client.sftpCancelUpload();
            },
          ) ??
              'Upload failed');*/

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
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
    }
  }

  loadCameras() async {
    cameras = await availableCameras();
  }

  @override
  void initState() {
    super.initState();
    loadCameras();
    createFolder();
    getFileCounts();
    refreshCount();
  }

  @override
  void dispose() {
    super.dispose();
    refreshTimer?.cancel();
  }

  void refreshCount() {
    refreshTimer = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => getFileCounts());
  }

  Future<void> createFolder() async {
    Directory imageDir = await getApplicationDocumentsDirectory();
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    for (var newspaper in AppConfig.newspapers) {
      Directory('${imageDir.path}/${newspaper.name}').create(recursive: true).then((Directory directory) {
        print('Path of New Dir: ${directory.path}');
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    //Wakelock.enable();
    return WillPopScope(
      onWillPop: () async{
        DialogAction action = await CustomDialog.simpleDialog(context, "Exit ", "Do you want to exit ?");
        if(action == DialogAction.yes){
          exit(0);
          return  true;
        }else{
          return false;
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: GlobalColors.BLACK,
            title: const Text("Dashboard"),
          ),
          drawer: DrawerWidget(user: widget.user),
          body: _buildMenu(),
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, //Center Column contents vertically,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            buildConnection(),
            buildHeader("MENU"),
            actionBar(),
            const SizedBox(height: 15),
            infoBar(),
            const SizedBox(height: 15),
            buildConsoleBox()
            /*Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Please select newspaper : ",
                    style: GlobalTextStyle.button_text_16_black),
                DropdownButton<NewsPaper>(
                  hint: const Text("Newspaper"),
                  value: selectedNewsPaper,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (NewsPaper? newValue) {
                    setState(() {
                      selectedNewsPaper = newValue!;
                    });
                  },
                  items: AppConfig.newspapers
                      .map<DropdownMenuItem<NewsPaper>>((NewsPaper value) {
                    return DropdownMenuItem<NewsPaper>(
                      value: value,
                      child: Text(value.displayName),
                    );
                  }).toList(),
                )
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 50),
                  primary: Colors.black87,
                  textStyle: GlobalTextStyle.button_text_16_black),
              icon: const Icon(Icons.next_plan_rounded),
              onPressed: () {
                if (selectedNewsPaper != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CapturePage(
                              cameras: cameras,
                              newsPaper: selectedNewsPaper!.name)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please select newspaper..")));
                }
              },
              label: const Text("Next"),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 50),
                  primary: Colors.black87,
                  textStyle: GlobalTextStyle.button_text_16_black),
              icon: const Icon(Icons.upload),
              onPressed: isConnected
                  ? () async {
                      DialogAction confirm = await CustomDialog.simpleDialog(
                          context,
                          "Upload Image",
                          "Do you want to upload images");
                      if (confirm == DialogAction.yes) {
                        startFileUploading();
                      }
                    }
                  : () {},
              label: const Text("Upload Images"),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 50),
                      primary: Colors.black87,
                      textStyle: GlobalTextStyle.button_text_16_black),
                  icon: const Icon(Icons.web),
                  onPressed: isConnected
                      ? () async {
                          DialogAction confirm =
                              await CustomDialog.simpleDialog(
                                  context,
                                  "Web Process",
                                  "Do you want to run this process");
                          if (confirm == DialogAction.yes) {
                            _webDataProcess();
                          }
                        }
                      : () {},
                  label: const Text("WEB Process"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 50),
                      primary: Colors.black87,
                      textStyle: GlobalTextStyle.button_text_16_black),
                  icon: const Icon(Icons.run_circle),
                  onPressed: isConnected
                      ? () async {
                          DialogAction confirm =
                              await CustomDialog.simpleDialog(
                                  context,
                                  "Image Process",
                                  "Do you want to run this process");

                          _processData();
                        }
                      : () {},
                  label: const Text("Image Process"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
                scrollController: scrollController,
                controller: console,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                focusNode: null,
                minLines: 1,
                maxLines: 20)*/
          ],
        ),
      ),
    );
  }

  Widget buildHeader(String title) => Padding(
        padding: const EdgeInsets.all(10),
        child: Text(title, style: GlobalTextStyle.header_text_16_orange),
      );

  Widget buildConnection() {
    return (Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                  color: GlobalColors.GRAY_BLACK,
                  width: 1,
                  style: BorderStyle.solid)),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Connect to the server",
                      style: GlobalTextStyle.button_text_16_black),
                  ElevatedButton.icon(
                    icon: Icon(Icons.wifi_protected_setup_sharp,
                        color: isConnected
                            ? Colors.greenAccent
                            : Colors.deepOrange),
                    onPressed: () async {
                      if (buttonState == true) {
                        await disconnectServer();
                        setState(() {
                          buttonState = false;
                        });
                      } else {
                        setState(() {
                          buttonState = true;
                        });
                        await connectServer();
                      }
                    },
                    label: Text(isConnected ? "Disconnect" : "Connect"),
                    style:
                        ElevatedButton.styleFrom(primary: GlobalColors.BLACK),
                  )
                ],
              ),
              isConnected
                  ? Text("Server IP : ${AppConfig.host}")
                  : const SizedBox(),
              isConnected
                  ? Text("Path : ${AppConfig.ftp_path}")
                  : const SizedBox()
            ],
          ),
        )
      ],
    ));
  }

  Widget actionBar() {
    return (Wrap(
      children: [
        Tile(
            name: "Take Images",
            icon: Icons.newspaper,
            onClick: () async {
              createFolder();
              NewsPaper selected = (await showNewPaperType()) as NewsPaper;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CapturePage(
                          cameras: cameras, newsPaper: selected.name)));
            },
            disabled: false),
        Tile(
            name: "Upload",
            icon: Icons.upload,
            onClick: () async {
              DialogAction action = await CustomDialog.simpleDialog(
                  context, "Uploading", "Do you want to upload images?");
              if (action == DialogAction.yes) {
                startFileUploading();
              }
            },
            disabled: !isConnected),
        Tile(
            name: "New Week Start",
            icon: Icons.clear_all,
            onClick: () async {
              DialogAction result = await CustomDialog.simpleDialog(context, "Reset", "Do you want to reset all images?");
              if(DialogAction.yes == result){
                await deleteFile();
              }

            },
            disabled: false),
        Tile(
            name: "Web Process",
            icon: Icons.web,
            onClick: () async{
              DialogAction result = await CustomDialog.simpleDialog(context, "Image Process", "Do you need to start this task?");
              if(DialogAction.yes == result){
                webDataProcess();
              }
            },
            disabled: true),
        Tile(
            name: "Image Process",
            icon: Icons.image_search,
            onClick: () async{
             DialogAction result = await CustomDialog.simpleDialog(context, "Image Process", "Do you need to start this task?");
             if(DialogAction.yes == result){
               processData();
             }
            },
            disabled: true),
        Tile(
            name: "Setting",
            icon: Icons.settings,
            onClick: () async{
              Directory imageDir = await getApplicationDocumentsDirectory();

              for(NewsPaper paper in AppConfig.newspapers){
                print("${imageDir.path}/${paper.name}");
              }



            },
            disabled: false),

      ],
    ));
  }
//
  Widget infoBar() {
    return (Column(
      children: [totalImages(), const SizedBox(height: 15), uploadImages()],
    ));
  }

  Widget totalImages() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
          color: Colors.deepOrange,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: (Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text("TOTAL IMAGES ${lahipitaCount + hitadCount + veeraCount}",
                  style: GlobalTextStyle.dashboard_text_20)
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text("Veera $veeraCount".toUpperCase(),
                  style: GlobalTextStyle.button_text_16_black),
              Text(" | hitad $hitadCount | ".toUpperCase(),
                  style: GlobalTextStyle.button_text_16_black),
              Text("lahipita $lahipitaCount".toUpperCase(),
                  style: GlobalTextStyle.button_text_16_black)
            ],
          ),
        ],
      )),
    );
  }

  Widget buildConsoleBox() {
    return (
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Console"),
            Container(
              child: TextField(
                  readOnly: true,
                  autofocus: false,
                  scrollController: scrollController,
                  controller: console,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none)

                  ),
                  focusNode: null,
                  minLines: 1,
                  maxLines: 20),
              decoration: const BoxDecoration(
                color: Colors.black12
              ),
            )
          ],
        )
       );
  }

  Widget uploadImages() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: (Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: const [
              Text("UPLOADING", style: GlobalTextStyle.dashboard_text_20)
            ],
          ),
          const SizedBox(height: 15),
          Text("Current File name : $currentUploadFile".toUpperCase(),
              style: GlobalTextStyle.button_text_16_black),
          Text("Upload Percentage : $uploadingPresentage".toUpperCase(),
              style: GlobalTextStyle.button_text_16_black),
          Text("Remaining : $remCount".toUpperCase(),
              style: GlobalTextStyle.button_text_16_black),
        ],
      )),
    );
  }

  Future<void> showNewPaperType() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please select Newspaper'),
          content: SingleChildScrollView(
            child: Container(
                constraints:
                    const BoxConstraints(minWidth: 200, minHeight: 150),
                width: 200,
                height: 150,
                child: ListView.builder(
                    itemCount: AppConfig.newspapers.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.newspaper),
                        title: Text(AppConfig.newspapers[index].displayName),
                        onTap: () =>
                            Navigator.pop(context, AppConfig.newspapers[index]),
                      );
                    })),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CLOSE'),
              onPressed: () {
                Navigator.pop(context, null);
              },
            ),
          ],
        );
      },
    );
  }
}
