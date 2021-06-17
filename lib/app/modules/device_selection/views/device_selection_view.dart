import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:home_fi/app/global_widgets/scan_result_tile.dart';
import 'package:home_fi/app/modules/device_selection/controllers/device_selection_controller.dart';
import 'package:home_fi/app/modules/home/views/home_view.dart';
import 'package:home_fi/app/theme/text_theme.dart';

class DeviceSelectionView extends GetView<DeviceSelectionController> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
      stream: FlutterBlue.instance.state,
      initialData: BluetoothState.unknown,
      builder: (c, snapshot) {
        final state = snapshot.data;
        if (state == BluetoothState.on) {
          return FindDevicesScreen();
        }
        return BluetoothOffScreen(state: state);
      },
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, required this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is\n${state.toString().substring(15)}.',
              style: HomeFiTextTheme.kSubHeadTextStyle
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Find Devices',
          style:
              HomeFiTextTheme.kSub2HeadTextStyle.copyWith(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: Get.height * 0.01),
              // StreamBuilder<List<BluetoothDevice>>(
              //   stream: Stream.periodic(Duration(seconds: 2))
              //       .asyncMap((_) => FlutterBlue.instance.connectedDevices),
              //   initialData: [],
              //   builder: (c, snapshot) => Column(
              //     children: snapshot.data!
              //         .map(
              //           (d) => ListTile(
              //             title: Text(d.name),
              //             subtitle: Text(d.id.toString()),
              //             trailing: StreamBuilder<BluetoothDeviceState>(
              //               stream: d.state,
              //               initialData: BluetoothDeviceState.disconnected,
              //               builder: (c, snapshot) {
              //                 if (snapshot.data ==
              //                     BluetoothDeviceState.connected) {}
              //                 return Text(snapshot.data.toString());
              //               },
              //             ),
              //           ),
              //         )
              //         .toList(),
              //   ),
              // ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () {
                            // Navigator.of(context)
                            //     .push(MaterialPageRoute(builder: (context) {
                            //
                            //   return SensorPage(device: r.device);
                            // }));
                            r.device.connect();
                            Get.off(HomeView());
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data == true) {
            return FloatingActionButton(
              child: Icon(Icons.stop, color: Colors.white),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.6),
            );
          } else {
            return FloatingActionButton(
              child: Icon(Icons.search, color: Colors.white),
              onPressed: () => FlutterBlue.instance.startScan(
                timeout: Duration(seconds: 4),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            );
          }
        },
      ),
    );
  }
}
