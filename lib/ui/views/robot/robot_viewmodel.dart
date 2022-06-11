import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../services/bluetooth_service.dart';
import '../../setup_snackbar_ui.dart';

class RobotViewModel extends ReactiveViewModel {
  final log = getLogger('HomeViewModel');

  final _bluetoothService = locator<BluetoothService>();
  final _snackBarService = locator<SnackbarService>();

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_bluetoothService];

  void onModelReady() {
    log.i(_bluetoothService.device?.name);
    log.i(_bluetoothService.connection?.isConnected);
    log.i(_bluetoothService.connected);
    if (_bluetoothService.connection != null &&
        _bluetoothService.connection!.isConnected) {
      // _bluetoothService.setupListener();
    }
  }

  BluetoothDevice? get device => _bluetoothService.device;
  // bluetooth device connection
  bool get connected => _bluetoothService.connected;
  BluetoothConnection? get connection => _bluetoothService.connection;

  void forward() {
    if (connected && connection != null) send("f");
  }

  void backward() {
    if (connected && connection != null) send("b");
  }

  void left() {
    if (connected && connection != null) send("l");
  }

  void right() {
    if (connected && connection != null) send("r");
  }

  void stop() {
    if (connected && connection != null) send("s");
  }

  void send(String letter) {
    log.e(letter);
    if (letter != "") {
      try {
        _bluetoothService.sendToDevice(letter);
      } catch (e) {
        _snackBarService.showCustomSnackBar(
            variant: SnackbarType.error, message: "Not connected");
      }
    } else {
      _snackBarService.showCustomSnackBar(
          variant: SnackbarType.error, message: 'No input');
    }
  }
}
