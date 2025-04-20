import 'package:flutter/material.dart';
import 'gesture_camera.dart';
import 'package:camera/camera.dart';
//import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';


List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Add the key parameter to the constructor
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GestureMe',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GestureCameraPage(camera: cameras![0]),
    );
  }

}