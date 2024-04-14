import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vegetable Freshness Detection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Vegetable Freshness Detection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final imagepicker = ImagePicker();
  XFile? _image;

  dynamic staleFresh;

  List<dynamic>? _recognitions;

  Future loadModel(String? model) async {
    Tflite.close();

    switch (model) {
      case 'stale/fresh':
        await Tflite.loadModel(
            model: "assets/fresh_stale.tflite",
            labels: "freshness_class.txt"
        );
      default:
        await Tflite.loadModel(
            model: "assets/vegetable_classification.tflite",
            labels: "assets/classification.txt"
        );
    }

  }


  Future recognizeImage(XFile image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = recognitions!;
    });
  }

  @override
  void initState() {
    super.initState();

    loadModel('').then((val) {
      setState(() {
      });
    });
  }
  
  Future calculateFreshness() async {
    await loadModel('stale/fresh');
    var staleFresh = await Tflite.runModelOnImage(
      path: _image!.path,
      numResults: 1,
    );

    if (kDebugMode) {
      print(staleFresh);
    }
  }


  Future getImageFromCamera() async {
    var image = await imagepicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _image = image;
    });
    recognizeImage(image);
  }

  Future clearImage() async {
    setState(() {
      _image = null;
      _recognitions = null;
    });
  }

  String newMethod(XFile image) => image.path;

  Future getImageFromGallery() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = image;
    });
    recognizeImage(image);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Vegetable Freshness Detection',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Center(
              child: _image == null ? const Padding(padding: EdgeInsets.all(12), child: Text("Select an Image", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)): Image.file(File(_image!.path), height: 300, width: 300,) ,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: _recognitions != null ? Text('This is an${_recognitions?[0].toString().split('label:')[1].split('}')[0]}'): const Text(""),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(padding: const EdgeInsets.all(12.0), child: Center(
                  child: _recognitions != null ?TextButton(onPressed: calculateFreshness, child: const Text("Calculate Freshness"),): const Text(""),
                ),)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(onPressed: getImageFromGallery, child: const Text("Get Image From Gallery"),),
                TextButton(onPressed: getImageFromCamera, child: const Text("Get Image From Camera"))
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(onPressed: clearImage, child: const Text("Clear Image"))
            ],),
          ],
        ),
      ),
    );
  }
}
