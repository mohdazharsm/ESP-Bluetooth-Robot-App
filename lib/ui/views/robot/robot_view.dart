import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:stacked/stacked.dart';

import 'robot_viewmodel.dart';

class RobotView extends StatelessWidget {
  const RobotView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RobotViewModel>.reactive(
      onModelReady: (model) => model.onModelReady(),
      builder: (context, model, child) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('Robot control'),
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
            body: const _RobotBody());
      },
      viewModelBuilder: () => RobotViewModel(),
    );
  }
}

class _RobotBody extends ViewModelWidget<RobotViewModel> {
  const _RobotBody({Key? key}) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, RobotViewModel model) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonJ(
                    onTap: model.forward,
                    onTapCancel: model.stop,
                    icon: Icons.keyboard_arrow_up)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonJ(
                    onTap: model.left,
                    onTapCancel: model.stop,
                    icon: Icons.keyboard_arrow_left),
                const SizedBox(width: 60),
                ButtonJ(
                    onTap: model.right,
                    onTapCancel: model.stop,
                    icon: Icons.keyboard_arrow_right)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonJ(
                    onTap: model.backward,
                    onTapCancel: model.stop,
                    icon: Icons.keyboard_arrow_down)
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonJ extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onTapCancel;
  final IconData icon;
  const ButtonJ({
    Key? key,
    required this.onTap,
    required this.onTapCancel,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(100),
        ),
        child: GestureDetector(
          // onTap: onTap,
          // onTapCancel: onTapCancel,
          // onLongPress: onTap,
          // onTapCancel: onTapCancel,
          onTapDown: (_) {
            onTap();
          },
          onTapUp: (_) {
            onTapCancel();
          },
          // onLongPressCancel: onTapCancel,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
