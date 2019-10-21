import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ray_camera/Dropdown.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CameraExampleHome extends StatefulWidget {
  @override
  _CameraExampleHomeState createState() {
    return _CameraExampleHomeState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  String type = 'back';
  final List<int> numbers = [1, 2, 3];
  var path = [];

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void initState() {
    super.initState();
    controller = new CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      loadCamera();
      setState(() {
        controller = new CameraController(cameras[1], ResolutionPreset.medium);
      });
    });
  }

  void loadCamera() {
    for (CameraDescription cameraDescription in cameras) {
      if (cameraDescription.lensDirection == CameraLensDirection.front) {
        onNewCameraSelected(cameraDescription);
      }
    }
  }


  void backCamera() {
    for (CameraDescription cameraDescription in cameras) {
      if (cameraDescription.lensDirection == CameraLensDirection.back) {
        onNewCameraSelected(cameraDescription);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
     
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changedirection() {

    if(type.compareTo('front')==0)
    {
      loadCamera();
      setState(() {
         type='back';
      });
       
    }else{
      backCamera();
      setState(() {
         type='front';
      });
       
    }
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      // print( controller.value.isInitialized);
      // print(controller);
      return Column(
        children: <Widget>[
          const Text(
            'Tap a camera',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          Container(
            
             margin: const EdgeInsets.only(top: 350.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // _cameraTogglesRowWidget(),
                  // _thumbnailWidget(),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
          Column(
  //          crossAxisAlignment: CrossAxisAlignment.center,
 // mainAxisSize: MainAxisSize.max,
  mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                
               // margin: const EdgeInsets.only(top: 300.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      //  width: 150 ,
                      child: CarouselSlider(
                        aspectRatio: 20,
                        height: 40.0,
                        items: [
                          'assets/images/user.png',
                          'assets/images/download.png'
                        ].map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 0.0),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                  ),
                                  child: Image.asset(i)
                                  //  Text(
                                  //   'text $i',
                                  //   style: TextStyle(fontSize: 16.0),
                                  // )
                                  );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            onTap: changedirection,
                            child: Image.asset(
                                'assets/images/ic_switch_camera_3.png',
                                color: Colors.black,
                                width: 60.0,
                                height: 60.0),
                          ),

                          //_cameraTogglesRowWidget(),
                          Container(child: _thumbnailWidget()),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          DropdownExample(),
                          Container(
                              margin: EdgeInsets.only(left: 60),
                              child: GestureDetector(
                                onTap: controller != null &&
                                        controller.value.isInitialized &&
                                        !controller.value.isRecordingVideo
                                    ? onTakePictureButtonPressed
                                    : null,
                                child: Image.asset('assets/images/ic_shutter_1.png',
                                    width: 72.0, height: 72.0),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

List<Widget> getLastImages(imageList){
    double a = 10;
    List<Widget> images=new List();
    imageList.map((tx) {
                              var index = path.indexOf(tx);
                              var last = path.length - 1;
                          
                            //  print("element=${index}");
                              if(index >=last-3){
                                 a = a + 6;
                      images.add(new Positioned(
                        left: a,
                        top: a,
                        child: Image.file(
                          File(tx),
                          height: 90,
                          width: 90,
                        ),
                      ));
                              }                            
    });
    return images;
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
      double a = 10;
    List<Widget> images=new List();
    path.map((tx) {
                              var index = path.indexOf(tx);
                              var last = path.length - 1;
                          
                            //  print("element=${index}");
                              if(index >=last-3){
                                 a = a + 6;
                      images.add(new Positioned(
                        left: a,
                        top: a,
                        child: Image.file(
                          File(tx),
                          height: 60,
                          width: 60,
                        ),
                      ));
                              }                            
    });
  
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            videoController == null && imagePath == null
                ? Container()
                : SizedBox(
                    width: 90.0,
                    height: 90.0,
                    child: Container(
                        child:  Stack(
                                 children: path.map((tx) {
                                        var index = path.indexOf(tx);
                                        var last = path.length;
                                    
                                      //  print("element=${index}");
                                        if(index >=last-3){
                                          a = a + 6;
                                          return(new Positioned(
                                              left: a,
                                              top: a,
                                              child: Image.file(
                                                File(tx),
                                                height: 60,
                                                width: 60,
                                              ),
                                            ));}
                                      else{
                                        return Text("");
                                      }}
                                      ).toList()))

                    ),
          ],
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        if (cameraDescription.lensDirection == CameraLensDirection.front) {
          onNewCameraSelected(cameraDescription);
        }
        print(cameraDescription.toString());
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: controller != null && controller.value.isRecordingVideo
                  ? null
                  : onNewCameraSelected,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
        path.add(filePath);
        print(path);
      }
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraExampleHome(),
    );
  }
}

List<CameraDescription> cameras;

Future<void> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(CameraApp());
}
