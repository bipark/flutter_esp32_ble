import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Device extends StatefulWidget {
  final BluetoothDevice device;
  Device(this.device);

  @override
  createState() => DeviceState();
}

class DeviceState extends State<Device> {
  List<BluetoothService> _services = [];

  @override
  void initState() {
    widget.device.connect();
    super.initState();
  }

  @override
  void dispose() {
    widget.device.disconnect();
    super.dispose();
  }

  void discoverService() async {
    _services = await widget.device.discoverServices();
    setState(() {});
    print("================");
    print(_services.length);
    print("================");
    _services.forEach((BluetoothService service) {
      print(service);
    });
  }

  Widget deviceStatus() {
    return StreamBuilder(
        stream: widget.device.state,
        initialData: BluetoothDeviceState.connecting,
        builder: (context, snapshot) {
          String text = "Connecting...";
          switch (snapshot.data) {
            case BluetoothDeviceState.connected:
              text = "Connected";
              break;
            case BluetoothDeviceState.disconnected:
              text = "Disconnect";
              break;
            default:
              text = "Connecting...";
              break;
          }

          return Text(text);
        });
  }

  Widget charCard(BluetoothCharacteristic char) {
    return Card(
        child: ListTile(
      title: Text(char.toString()),
      subtitle: Row(
        children: [
          OutlinedButton(
              onPressed: () {
                char.write([0x12, 0x34, 0x76]);
              },
              child: Text("Send")),
          OutlinedButton(
              onPressed: () async {
                var res = await char.read();
                print(res);
              },
              child: Text("Read")),
        ],
      ),
    ));
  }

  Widget serviceCard(BluetoothService e) {
    List<BluetoothCharacteristic> chars = e.characteristics;

    return Card(
        child: ListTile(
      title: Text("BluetoothService : " + e.uuid.toString()),
      // subtitle: Text(e.toString()),
      subtitle: Column(children: chars.map((e) => charCard(e)).toList()),
      trailing: Text(e.characteristics.length.toString()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.device.name)),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: deviceStatus(),
                  subtitle: Row(
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            widget.device.connect();
                          },
                          child: Text("Connect")),
                      OutlinedButton(
                          onPressed: () {
                            widget.device.disconnect();
                          },
                          child: Text("Disconnect")),
                      OutlinedButton(onPressed: discoverService, child: Text("Discover")),
                    ],
                  ),
                ),
              ),
              Column(children: _services.map((BluetoothService e) => serviceCard(e)).toList())
            ],
          ),
        ));
  }
}
