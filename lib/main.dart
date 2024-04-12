import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_genie/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

class QRCodeGenerator extends StatefulWidget {
  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  final _qrKey = GlobalKey();
  String _qrData = '';

  _generateQRCode() {
    if (_qrData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a URL first'),
        ),
      );
      return;
    }
    setState(() {
      _qrData = Uri.parse(_qrData).toString();
    });
  }

  _downloadQRCode() async {
    final qrCodeImage =
        _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
    if (qrCodeImage != null) {
      final image = await qrCodeImage.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final dir = await getExternalStorageDirectory();
      final file = File("${dir!.path}/qr_code.png");
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('QR Code saved to ${file.path}',
            style: TextStyle(color: Colors.black)),
        duration: Duration(seconds: 7),
        backgroundColor: Colors.orange,
      ));

      print('QR code saved to ${file.path}');
    }
  }

// Future<void> _downloadQRCode() async {
//   if (_qrData.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Please enter a URL first'),
//       ),
//     );
//     return;
//   }

//   final dir = await getExternalStorageDirectory();
//   final file = File("${dir!.path}/qr_code.png");

//   final qrImage = QrPainter(
//     data: _qrData,
//     version: QrVersions.auto,
//     eyeStyle: QrEyeStyle(
//       color: Colors.black,
//       size: 10,
//     ),
//     dataModuleStyle: QrDataModuleStyle(
//       color: Colors.white,
//       dataModuleShape: QrDataModuleShape.round,
//     ),
//   );

//   final image = await qrImage.toImage(320);
//   final imageData = await image.png;

//   await file.writeAsBytes(imageData!);

//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text('QR code saved to ${file.path}'),
//     ),
//   );
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text('QR Genie'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Image.asset(
          'assets/icon_logo.png',
          color: Colors.black,
        ),
      ),
      body: Stack(
        children: [
          _background(),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(30, 120, 30, 30),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "Enter Url...",
                          labelText: "https://www.youtube.com",
                          labelStyle: TextStyle(color: Colors.orange),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                color: Colors.orange,
                              )),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                color: Colors.orange,
                              ))),
                      cursorColor: Colors.orange,
                      style: TextStyle(color: Colors.white),
                      onChanged: (value) {
                        _qrData = value;
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _generateQRCode,
                    child: Text(
                      'Generate QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Center(
                    child: _qrData.isNotEmpty
                        ? RepaintBoundary(
                            key: _qrKey,
                            child: Container(
                              color: Colors.white,
                              child: QrImageView(
                                data: _qrData,
                                size: 200,
                              ),
                            ))
                        : Container(),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _qrData.isNotEmpty ? _downloadQRCode : null,
                    child: Text(
                      'Download QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _background() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Colors.black,
            Colors.orange,
          ], // Your gradient colors here
        ),
      ),
    );
  }
}
