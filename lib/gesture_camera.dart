import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class GestureCameraPage extends StatefulWidget {
  final CameraDescription camera;

  const GestureCameraPage({super.key, required this.camera});

  @override
  GestureCameraPageState createState() => GestureCameraPageState();
}

class GestureCameraPageState extends State<GestureCameraPage> {
  late CameraController _controller;
  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadModel().then((_) {
      _initCamera();
    });
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
      setState(() {
        _isModelLoaded = true;
      });
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  void _initCamera() async {
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    await _controller.initialize();
    setState(() {});

    _controller.startImageStream((CameraImage image) async {
      if (!_isModelLoaded) return;

      // Preprocess image
      var input = await _convertImageToInputList(image);

      // Run model
      var output = List.filled(1, 0).cast<double>(); // Adjust based on your model
      _interpreter.run(input, output);

      // Interpret result
      var gesture = _interpretGestureOutput(output);
      _handleGesture(gesture);
    });
  }

  Future<List<double>> _convertImageToInputList(CameraImage image) async {
    // NOTE: This is a simplified placeholder logic.
    // You must resize, normalize, and maybe convert to grayscale or RGB based on your model.
    int width = image.width;
    int height = image.height;

    // Just create dummy values — replace with actual pixel values from image.planes
    return List.generate(width * height * 3, (_) => 0.5);
  }

  String _interpretGestureOutput(List<double> output) {
    int index = output.indexWhere((element) => element == output.reduce((a, b) => a > b ? a : b));
    switch (index) {
      case 1:
        return "open_palm";
      case 2:
        return "fist";
      case 3:
        return "peace_sign";
      case 4:
        return "index_finger";
      default:
        return "unknown";
    }
  }

  void _handleGesture(String gesture) {
    switch (gesture) {
      case 'open_palm':
        print("Adjusting brightness");
        break;
      case 'fist':
        print("Adjusting volume");
        break;
      case 'peace_sign':
        print("Performing action for peace sign");
        break;
      case 'index_finger':
        print("Moving cursor with index finger");
        break;
      default:
        print("No action for $gesture");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GestureMe Camera')),
      body: Center(
        child: _controller.value.isInitialized
            ? CameraPreview(_controller)
            : CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _interpreter.close();
    super.dispose();
  }
}
