import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:stacked/stacked.dart';

import '../app/app.logger.dart';

class BluetoothService with ReactiveServiceMixin {
  final log = getLogger('BluetoothService');
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothState get bluetoothState => _bluetoothState;

  // Get the instance of the Bluetooth
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Track the Bluetooth connection with the remote device
  BluetoothConnection? _connection;
  BluetoothConnection? get connection => _connection;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => _connection != null && _connection!.isConnected;

  // This member variable will be used for tracking
// the Bluetooth device connection state
//   late int _deviceState;

  void init() {
    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;
      notifyListeners();
    });

    // _deviceState = 0; // neutral

    // If the Bluetooth of the device is not enabled,
    // then request permission to turn on Bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      _bluetoothState = state;
      log.i(_bluetoothState);
      if (_bluetoothState == BluetoothState.STATE_OFF) {
        _connected = false;
      }
      // For retrieving the paired devices list
      getPairedDevices();
      notifyListeners();
    });
  }

  Future<bool> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the Bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // for storing the devices list
  List<BluetoothDevice> _devicesList = [];
  List<BluetoothDevice> get devicesList => _devicesList;
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      log.e("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    // if (!mounted) {
    //   return;
    // }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class

    _devicesList = devices;
    notifyListeners();
  }

  BluetoothDevice? _device;
  BluetoothDevice? get device => _device;
  void setDevice(value) {
    _device = value;
    notifyListeners();
  }

  bool _connected = false;
  bool get connected => _connected;
  String _incomingData = "";
  String get incomingData => _incomingData;
  String _incomingDataRealtime = "";
  String get incomingDataRealtime => _incomingDataRealtime;
  Future<bool> connect(BluetoothDevice? device) async {
    if (device == null) {
      return false;
    } else {
      // Making sure the device is not connected
      if (!isConnected) {
        // Trying to connect to the device using
        // its address
        await BluetoothConnection.toAddress(device.address)
            .then((_connectionIn) {
          log.i('Connected to the device');
          _connection = _connectionIn;

          // Updating the device connectivity
          // status to [true]
          _connected = true;
          notifyListeners();

          // This is for tracking when the disconnecting process
          // is in progress which uses the [isDisconnecting] variable
          // defined before.
          // Whenever we make a disconnection call, this [onDone]
          // method is fired.
          _connection!.input!.listen((Uint8List data) {
            log.i('Data incoming: ${ascii.decode(data)}');
            // connection!.output.add(data); // Sending data
            _incomingDataRealtime = ascii.decode(data);
            _incomingData = _incomingData + _incomingDataRealtime;
            if (_incomingData.length > 200) {
              _incomingData = _incomingDataRealtime;
            }
            notifyListeners();

            if (ascii.decode(data).contains('!')) {
              disconnect();
              // connection!.finish(); // Closing connection
              // log.i('Disconnecting by local host');
            }
          }).onDone(() {
            if (isDisconnecting) {
              log.i('Disconnecting locally!');
            } else {
              log.i('Disconnected remotely!');
            }
            notifyListeners();
          });
        }).catchError((error) {
          log.e('Cannot connect, exception occurred');
          log.e(error);
        });
        return _connected;
      }
    }
    return _connected;
  }

  Future disconnect() async {
    // Closing the Bluetooth connection
    await connection!.close();

    // Update the [_connected] variable
    if (!_connection!.isConnected) {
      _connected = false;
      notifyListeners();
    }
  }

  void clearIncomingData() {
    _incomingData = "";
    notifyListeners();
  }

  Future sendToDevice(String value) {
    // connection!.output.add(Uint8List.fromList(utf8.encode(value + "\r\n")));
    //
    // return connection!.output.allSent;

    connection!.output.add(Uint8List.fromList(utf8.encode(value + "\r\n")));
    return connection!.output.allSent;
  }

  // when the disconnection is in progress
  bool isDisconnecting = false;
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      _connection!.dispose();
      _connection = null;
    }
  }
}
