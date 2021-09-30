import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'device.dart';

class MainPage extends StatefulWidget {
  @override
  _mainPage createState() => new _mainPage();
}

class _mainPage extends State<MainPage> {
  List<ScanResult> _scanList = [];

  @override
  void initState() {
    _startScan();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _startScan() async {
    _scanList = [];
    await FlutterBlue.instance.scan().listen((scanResult) {
      if (scanResult.device.name == 'ESP32') {
        print(scanResult.device.name);
        setState(() {
          _scanList.add(scanResult);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Devices'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _startScan,
            ),
          ],
        ),
        body: deviceList());
  }

  Widget deviceList() {
    if (_scanList.length > 0) {
      return ListView.builder(
          itemCount: _scanList.length,
          itemBuilder: (context, index) {
            ScanResult r = _scanList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Device(r.device)),
                );
              },
              child: Card(
                child: ListTile(
                  title: Text(r.device.name),
                  subtitle: Text(r.device.toString()),
                ),
              ),
            );
          });
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
