import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:stacked/stacked.dart';

import 'face_viewmodel.dart';

class FaceView extends StatelessWidget {
  const FaceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FaceViewModel>.reactive(
      onModelReady: (model) => model.onModelReady(),
      builder: (context, model, child) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('LED Control'),
              actions: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text(
                        model.device != null &&
                                model.connected &&
                                model.connection != null &&
                                model.connection!.isConnected
                            ? model.device!.name!
                            : "",
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.lightGreen),
                      ),
                    ),
                    Container(
                      child: model.connection == null ||
                              !model.connected ||
                              !model.connection!.isConnected
                          ? const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.stop_screen_share,
                                color: Colors.red,
                              ),
                            )
                          : null,
                    )
                  ],
                )
              ],
            ),
            body: const _LEDBody());
      },
      viewModelBuilder: () => FaceViewModel(),
    );
  }
}

class _LEDBody extends ViewModelWidget<FaceViewModel> {
  const _LEDBody({Key? key}) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, FaceViewModel model) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (model.isLedOn)
              const Icon(
                Icons.lightbulb,
                size: 150,
                color: Colors.blue,
              )
            else
              const Icon(
                Icons.lightbulb_outline,
                size: 150,
                // color: Colors.blue,
              ),
            ElevatedButton(
              onPressed: model.setLed,
              child: Text(model.isLedOn ? "LED OFF" : 'LED ON'),
            ),
          ],
        ),
      ),
    );
  }
}
