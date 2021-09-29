import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';


class Device extends StatefulWidget {
  final BluetoothDevice device;
  Device(this.device);

  @override
  createState()=>DeviceState();
}

class DeviceState extends State<Device> {

  @override
  void initState() {
    widget.device.connect();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget deviceStatus() {
    return StreamBuilder(
      stream: widget.device.state,
      initialData: BluetoothDeviceState.connecting,
      builder: (context, snapshot) {
        String text = "연결중";
        switch(snapshot.data){
          case BluetoothDeviceState.connected:
            text = "연결됨";
            break;
          case BluetoothDeviceState.disconnected:
            text = "연결끊어짐";
            break;
          default:
            text = "연결중";
            break;
        }

        return Text(text);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.device.name)
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: deviceStatus(),
                subtitle: Row(
                  children: [
                    OutlinedButton(onPressed: (){
                      widget.device.connect();
                    }, child: Text("연결")),
                    OutlinedButton(onPressed: (){
                      widget.device.disconnect();
                    }, child: Text("연결끊기"))
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

}


