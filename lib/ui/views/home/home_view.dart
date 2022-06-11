import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:lottie/lottie.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      onModelReady: (model) => model.onModelReady(),
      builder: (context, model, child) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('Spark 2.0 Robotics'),
              actions: [
                IconButton(
                    onPressed: model.bluetoothEnableDisable,
                    icon: model.bluetoothState.isEnabled
                        ? const Icon(
                            Icons.bluetooth,
                            color: Colors.lightGreen,
                          )
                        : const Icon(Icons.bluetooth_disabled))
              ],
            ),
            body: const _HomeBody());
      },
      viewModelBuilder: () => HomeViewModel(),
    );
  }
}

class _HomeBody extends ViewModelWidget<HomeViewModel> {
  const _HomeBody({Key? key}) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, HomeViewModel model) {
    List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
      List<DropdownMenuItem<BluetoothDevice>> items = [];
      if (model.devicesList.isEmpty) {
        items.add(const DropdownMenuItem(
          child: Text('NONE'),
        ));
      } else {
        for (var device in model.devicesList) {
          items.add(DropdownMenuItem(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  device.name ?? "No name",
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 18),
                )),
            value: device,
          ));
        }
      }
      return items;
    }

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        'Devices:',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton(
                          items: _getDeviceItems(),
                          onChanged: model.setDevice,
                          value: model.devicesList.isNotEmpty
                              ? model.device
                              : null,
                          underline: Container(
                            height: 0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(width: 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: model.isBusy
                      ? null
                      : model.connected
                          ? model.disconnect
                          : model.connect,
                  child: Text(model.isBusy
                      ? 'Loading..'
                      : model.connected
                          ? 'Disconnect'
                          : 'Connect'),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              Option(
                  name: 'Communication',
                  onTap: model.openSerialView,
                  file: 'assets/code.json'),
              Option(
                  name: 'LED Control',
                  onTap: model.openLedView,
                  file: 'assets/led.json'),
              Option(
                  name: 'Digital Read',
                  onTap: model.openInputView,
                  file: 'assets/input.json'),
              Option(
                  name: 'Robot Control',
                  onTap: model.openRobotView,
                  file: 'assets/robot.json'),
            ],
          ),
        )
      ],
    );
  }
}

class Option extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final String file;
  const Option(
      {Key? key, required this.name, required this.onTap, required this.file})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 1.5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onTap,
          child: Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Lottie.asset(file),
                      )),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6)),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
