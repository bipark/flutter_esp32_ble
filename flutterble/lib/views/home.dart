import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'device.dart';

class MainPage extends StatefulWidget {
  @override
  _mainPage createState() => new _mainPage();
}

class _mainPage extends State<MainPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BlueTooth'),
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth),
            onPressed: () {
              FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
            },
          ),
        ],
      ),
      body: StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return deviceList();
          } else {
            return Center(
              child: Text("BT 사용불가"),
            );
          }
        },
      )
    );
  }

  Widget deviceList() {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBlue.instance.scanResults,
      initialData: [],
      builder: (context, snapshot) {
        return SingleChildScrollView(
          child: Column(
            children: snapshot.data!.map((ScanResult r)=>deviceTile(r)).toList(),
          )
        );
      }
    );
  }

  Widget deviceTile(ScanResult r) {
    return ListTile(
      title: Text(r.device.name),
      subtitle: Text(r.device.toString()),
      trailing: GestureDetector(onTap: (){
        // r.device.connect();
        Navigator.push(context, MaterialPageRoute(builder: (context) => Device(r.device)),);
      },child: Icon(Icons.bluetooth, size: 40,),),
    );
  }
}