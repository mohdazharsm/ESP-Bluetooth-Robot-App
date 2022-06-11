import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../services/bluetooth_service.dart';
import '../../setup_snackbar_ui.dart';

class LedViewModel extends ReactiveViewModel {
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
  // String get data => _bluetoothService.incomingData;
  bool _isLedOn = false;
  bool get isLedOn => _isLedOn;
  void setLed() {
    if (_isLedOn) {
      _isLedOn = false;
      send("0");
    } else {
      _isLedOn = true;
      send("1");
    }
    notifyListeners();
  }

  void send(String letter) {
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
