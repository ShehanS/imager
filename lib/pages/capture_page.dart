import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../styles/global_style.dart';

class CapturePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String newsPaper;
  const CapturePage({required this.cameras, required this.newsPaper, Key? key}) : super(key: key);

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  late CameraController controller;
  bool _isFlashOn = false;
  double _zoom = 1;
  bool _isCapture = false;
  late XFile image;
  final String _stringPath = "/storage/emulated/0/DCIM/image-source";
  late Future<void> initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _loadCameras();
    print("Selected newspaper ${widget.newsPaper}");
  }

  _loadCameras() async {
    controller = CameraController(widget.cameras[0], ResolutionPreset.max);
    initializeControllerFuture = controller.initialize();
  }

  void _saveToLocal(XFile image) async {
    Directory imageDir = await getApplicationDocumentsDirectory();
    XFile xFile = image;
    xFile.saveTo(
        "${imageDir.path}/${widget.newsPaper}/${DateTime.now().millisecondsSinceEpoch}_ncinga.jpg");
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            FutureBuilder(
                future: initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Positioned(
                                child: CameraPreview(controller),
                              ),
                              Positioned(
                                  top: 10,
                                  right: 20,
                                  child: RotatedBox(
                                      quarterTurns: 1,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 50,
                                              width: 120,
                                              child: TextButton(
                                                onPressed: () async {
                                                  try {
                                                    if (controller != null) {
                                                      if (!_isFlashOn) {
                                                        controller.setFlashMode(
                                                            FlashMode.torch);
                                                        setState(() {
                                                          _isFlashOn = true;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          _isFlashOn = false;
                                                        });
                                                        controller.setFlashMode(
                                                            FlashMode.off);
                                                      }
                                                    }
                                                  } catch (e) {
                                                    print(e); //show error
                                                  }
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                        _isFlashOn
                                                            ? Icons.flash_on
                                                            : Icons.flash_off,
                                                        color:
                                                            GlobalColors.AMBER),
                                                    const SizedBox(width: 5),
                                                    const Text("Flash",
                                                        style: GlobalTextStyle
                                                            .camera_option_14_yellow)
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 50,
                                              width: 120,
                                              child: TextButton(
                                                onPressed: () async {
                                                  try {
                                                    if (controller != null) {
                                                      if (_zoom < 8) {
                                                        setState(() {
                                                          _zoom += 1;
                                                        });
                                                        controller.setZoomLevel(
                                                            _zoom);
                                                      } else {}
                                                    }
                                                  } catch (e) {
                                                    print(e); //show error
                                                  }
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(Icons.zoom_in,
                                                        color:
                                                            GlobalColors.AMBER),
                                                    SizedBox(width: 5),
                                                    Text("Zoom",
                                                        style: GlobalTextStyle
                                                            .camera_option_14_yellow)
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 50,
                                              width: 120,
                                              child: TextButton(
                                                onPressed: () async {
                                                  try {
                                                    if (controller != null) {
                                                      if (_zoom > 1) {
                                                        setState(() {
                                                          _zoom -= 1;
                                                        });
                                                        controller.setZoomLevel(
                                                            _zoom);
                                                      } else {}
                                                    }
                                                  } catch (e) {
                                                    print(e); //show error
                                                  }
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(Icons.zoom_out,
                                                        color:
                                                            GlobalColors.AMBER),
                                                    SizedBox(width: 5),
                                                    Text("Zoom",
                                                        style: GlobalTextStyle
                                                            .camera_option_14_yellow)
                                                  ],
                                                ),
                                              ),
                                            ),
                                            _isCapture
                                                ? const Center(
                                                    child: Text(
                                                        "Taking snapshot...",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20)),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ))),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  color: Colors.black87),
                              child: IconButton(
                                onPressed: () async {
                                  try {
                                    if (controller.value.isInitialized) {
                                      final image =
                                          await controller.takePicture();
                                      _saveToLocal(image);
                                      setState(() {
                                        _isCapture = true;
                                        Future.delayed(
                                            const Duration(milliseconds: 1000),
                                            () async {
                                          setState(() {
                                            _isCapture = false;
                                          });
                                        });
                                      });
                                    }
                                  } catch (e) {
                                    print(e); //show error
                                  }
                                },
                                icon: const Icon(Icons.camera,
                                    color: Colors.white, size: 60),
                              ))
                        ]);
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })
          ],
        ),
      ),
    );
  }
}
