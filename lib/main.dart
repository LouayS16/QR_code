import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(QRCodeApp());
}

class QRCodeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Generator & Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TextEditingController> controllers = [];

  @override
  void initState() {
    super.initState();
    // Start with one attribute field
    controllers.add(TextEditingController());
  }

  // Method to add a new attribute field
  void addAttributeField() {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  // Method to remove a specific attribute field
  void removeAttributeField(int index) {
    setState(() {
      if (controllers.length > 1) {
        controllers.removeAt(index);
      }
    });
  }

  // Method to generate the QR code data based on the form input
  String generateQRCodeData() {
    List<String> data = [];
    for (var controller in controllers) {
      if (controller.text.isNotEmpty) {
        data.add(controller.text);
      }
    }
    return data.join(','); // Join all attributes into a single string
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator & Scanner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form to add attributes dynamically
            Expanded(
              child: ListView.builder(
                itemCount: controllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controllers[index],
                          decoration: InputDecoration(
                            labelText: 'Attribute ${index + 1}',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () {
                          removeAttributeField(index);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: addAttributeField,
              child: Text('Add Attribute'),
            ),
            SizedBox(height: 20),
            // QR code generation
            QrImage(
              data: generateQRCodeData(),
              size: 200.0,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to QR Code Scanner page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRCodeScanner()),
                );
              },
              child: Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}

class QRCodeScanner extends StatefulWidget {
  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedData = '';

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Scanned Data: $scannedData'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedData = scanData.code!;
      });
    });
  }
}
