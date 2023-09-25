import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:sunmi_printer/sunmi_printer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sunmi Printer',
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      debugShowCheckedModeBanner: false,
      home: const Home()
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late PrinterStatus _printerStatus;
  late PrinterMode _printerMode;

  @override
  void initState() {
    super.initState();

    _bindingPrinter().then( (bool? isBind) async => {
      if (isBind!) {
        _getPrinterStatus(),
        _printerMode = await _getPrinterMode(),
      }
    });

  }

  /// must binding ur printer at first init in app
  Future<bool?> _bindingPrinter() async {
    final bool? result = await SunmiPrinter.bindingPrinter();
    return result;
  }

  /// you can get printer status 
  Future<void> _getPrinterStatus() async {
    final PrinterStatus result = await SunmiPrinter.getPrinterStatus();
    setState(() {
      _printerStatus = result;
    });
  }

  Future<PrinterMode> _getPrinterMode() async {
    final PrinterMode mode = await SunmiPrinter.getPrinterMode();
    return mode;
  }

  Future<void> _printLabel(Uint8List img ) async {
    if (_printerStatus == PrinterStatus.NORMAL && _printerMode == PrinterMode.LABEL_MODE) {
        // must start with this function if you are print with label
        await SunmiPrinter.startLabelPrint();
        /// 0 align left, 1 center, 2 align right.
        await SunmiPrinter.setAlignment(PrintAlign.CENTER);
        // spacing line
        await SunmiPrinter.lineWrap(1);
        // print image only support Uint8List
        await SunmiPrinter.printImage(img);
        // only run exitLabelPrint at last index if you need print multiple label at once;
        await SunmiPrinter.exitLabelPrint();
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pingspace Demo Printer'),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () async {
              String url = 'https://pngimg.com/uploads/nike/small/nike_PNG18.png';
              // convert image to Uint8List format
              Uint8List byte = (await NetworkAssetBundle(Uri.parse(url)).load(url)).buffer.asUint8List();

              await _printLabel(byte);
            },
            child:  Container(
              color: Colors.red,
              width: 200,
              height: 100,
              child: const Text('Print Label')
            )
          ),
          GestureDetector(
            child: const Text('Example only')
          ),
        ],
      )
    );
  }
}