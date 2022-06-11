import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:spark/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../services/bluetooth_service.dart';
import '../../setup_snackbar_ui.dart';

class HomeViewModel extends ReactiveViewModel {
  final log = getLogger('HomeViewModel');

  final _bluetoothService = locator<BluetoothService>();
  final _snackBarService = locator<SnackbarService>();
  final _navigationService = locator<NavigationService>();

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_bluetoothService];

  void onModelReady() {
    if (_bluetoothService.devicesList.isNotEmpty) {
      setDevice(_bluetoothService.devicesList.first);
      notifyListeners();
    }
  }

  // the current device connectivity status
  BluetoothState get bluetoothState => _bluetoothService.bluetoothState;
  void bluetoothEnableDisable() async {
    if (!bluetoothState.isEnabled) {
      // Enable Bluetooth
      await FlutterBluetoothSerial.instance.requestEnable();
      log.i('Enable');
    } else {
      // Disable Bluetooth
      await FlutterBluetoothSerial.instance.requestDisable();
      log.i('Disable');
    }

    // In order to update the devices list
    await _bluetoothService.getPairedDevices();
    // _isButtonUnavailable = false;

    // Disconnect from any device before
    // turning off Bluetooth
    if (connected) {
      disconnect();
    }

    notifyListeners();
  }

  // each device from the dropdown items
  BluetoothDevice? get device => _bluetoothService.device;
  List<BluetoothDevice> get devicesList => _bluetoothService.devicesList;
  void setDevice(value) {
    _bluetoothService.setDevice(value);
  }

  // bluetooth device connection
  bool get connected => _bluetoothService.connected;
  BluetoothConnection? get connection => _bluetoothService.connection;
  void connect() async {
    setBusy(true);
    bool isConnect = await _bluetoothService.connect(device);
    if (!isConnect) {
      _snackBarService.showCustomSnackBar(
          variant: SnackbarType.error, message: 'Not connected');
    } else {
      _snackBarService.showCustomSnackBar(
          variant: SnackbarType.success, message: 'Device connected');
    }
    setBusy(false);
  }

  void disconnect() async {
    await _bluetoothService.disconnect();
    _snackBarService.showCustomSnackBar(
        variant: SnackbarType.success, message: 'Device disconnected');
  }

  @override
  void dispose() {
    _bluetoothService.dispose();
    super.dispose();
  }

  void openSerialView() {
    _navigationService.navigateTo(Routes.serialView);
  }

  void openLedView() {
    _navigationService.navigateTo(Routes.ledView);
  }

  void openInputView() {
    _navigationService.navigateTo(Routes.inputView);
  }

  void openRobotView() {
    _navigationService.navigateTo(Routes.robotView);
  }
}
