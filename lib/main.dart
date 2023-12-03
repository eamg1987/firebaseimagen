import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options:DefaultFirebaseOptions.currentPlatform);
    runApp(MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _selectedImage;

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
  }

  Future _pickImageFromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
  }

Future _uploadImageToFirebase() async {
    if (_selectedImage == null) {
      print('No image selected.');
      return;
    }

    try {
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

      await firebaseStorageRef.putFile(_selectedImage!);

      print('Image uploaded to Firebase Storage.');
      setState(() {
      _selectedImage = null;
    });
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardar Imagen Firebase'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _selectedImage == null
                ? Text('No hay imagen.')
                : Image.file(
                    _selectedImage!,
                    height: 400,
                    width: 400,
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _pickImageFromGallery();
              },
              child: Text('Desde la Galeria'),
            ),
            ElevatedButton(
              onPressed: () {
                _pickImageFromCamera();
              },
              child: Text('desde la camara'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _uploadImageToFirebase();
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
