import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:typed_data';
import 'dart:async';

class SoilSensorTestPage extends StatefulWidget {
  const SoilSensorTestPage({super.key});

  @override
  _SoilSensorAppState createState() => _SoilSensorAppState();
}

class _SoilSensorAppState extends State<SoilSensorTestPage> {
  UsbPort? _port;
  List<UsbDevice> _devices = [];
  bool _isConnected = false;
  bool _isLoading = false;
  String _statusMessage = 'Disconnected';
  DateTime? _lastUpdated;

  // Sensor data
  Map<String, dynamic> _sensorData = {
    'temperature': null,
    'moisture': null,
    'ec': null,
    'ph': null,
    'nitrogen': null,
    'phosphorus': null,
    'potassium': null,
    'salinity': null,
  };

  @override
  void initState() {
    super.initState();
    _refreshDevices();

    // Listen for USB device events
    UsbSerial.usbEventStream?.listen((UsbEvent event) {
      if (event.event == UsbEvent.ACTION_USB_ATTACHED) {
        print('USB device attached');
        _refreshDevices();
      } else if (event.event == UsbEvent.ACTION_USB_DETACHED) {
        print('USB device detached');
        _disconnect();
        _refreshDevices();
      }
    });
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

  Future<void> _refreshDevices() async {
    try {
      print('Checking for USB devices...');
      List<UsbDevice> devices = await UsbSerial.listDevices();
      print('Found ${devices.length} USB devices:');

      if (devices.isEmpty) {
        print('No USB devices found');
        print('Make sure:');
        print('1. USB device is connected to your computer');
        print('2. USB debugging is enabled on the device');
        print('3. You have proper USB permissions');
      } else {
        for (var device in devices) {
          print('Device: ${device.deviceName}');
          print('  Vendor ID: 0x${device.vid?.toRadixString(16) ?? 'unknown'}');
          print('  Product ID: 0x${device.pid?.toRadixString(16) ?? 'unknown'}');
          print('  Serial: ${device.serial ?? 'unknown'}');
          print('  Manufacturer: ${device.manufacturerName ?? 'unknown'}');
          print('  Product: ${device.productName ?? 'unknown'}');
        }
      }

      setState(() {
        _devices = devices;
      });
    } catch (e) {
      print('Error refreshing devices: $e');
      _showError('Error refreshing devices: $e');
    }
  }

  Future<void> _connectToSensor([UsbDevice? specificDevice]) async {
    if (_isConnected) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Connecting...';
    });

    try {
      UsbDevice? targetDevice = specificDevice;

      // If no specific device provided, try to find HONDE sensor
      if (targetDevice == null) {
        if (_devices.isEmpty) {
          throw Exception('No USB devices available');
        }

        // Try to identify HONDE sensor by characteristics
        // You may need to adjust these criteria based on your actual device
        targetDevice = _devices.firstWhere(
              (device) =>
          device.deviceName?.toLowerCase().contains('usb') == true ||
              device.manufacturerName?.toLowerCase().contains('prolific') == true ||
              device.manufacturerName?.toLowerCase().contains('ftdi') == true ||
              device.vid == 0x067b, // Common USB-to-Serial chip vendor IDs
          orElse: () => _devices.first, // Fallback to first device
        );
      }

      print('Attempting to connect to: ${targetDevice.deviceName}');

      // Create USB port
      _port = await targetDevice.create();
      if (_port == null) {
        throw Exception('Failed to create USB port');
      }

      // Open connection with HONDE sensor settings (from manual)
      bool openResult = await _port!.open();
      if (!openResult) {
        throw Exception('Failed to open USB port');
      }

      // Configure port settings according to HONDE manual
      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(
        9600,     // Baud rate (from manual)
        UsbPort.DATABITS_8,  // Data bits
        UsbPort.STOPBITS_1,  // Stop bits
        UsbPort.PARITY_NONE, // Parity
      );

      setState(() {
        _isConnected = true;
        _statusMessage = 'Connected to ${targetDevice!.deviceName}';
      });

      print('Successfully connected to HONDE sensor');

      // Start reading data automatically
      await _readSensorData();

    } catch (e) {
      print('Connection error: $e');
      _showError('Connection failed: $e');
      setState(() {
        _statusMessage = 'Connection failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _disconnect() async {
    if (_port != null) {
      await _port!.close();
      _port = null;
    }

    setState(() {
      _isConnected = false;
      _statusMessage = 'Disconnected';
    });
  }

  Future<void> _readSensorData() async {
    if (!_isConnected || _port == null) {
      _showError('Not connected to sensor');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Modbus RTU query for all 8 parameters (from HONDE manual)
      // Address: 0x01, Function: 0x03, Start: 0x0000, Length: 0x0008, CRC: 0x440C
      List<int> modbusQuery = [0x01, 0x03, 0x00, 0x00, 0x00, 0x08, 0x44, 0x0C];

      print('Sending Modbus query: ${modbusQuery.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');

      // Set up stream subscription to read response
      StreamSubscription? subscription;
      Completer<List<int>> responseCompleter = Completer<List<int>>();
      List<int> responseBuffer = [];
      Timer? timeoutTimer;

      // Listen to incoming data stream
      subscription = _port!.inputStream?.listen(
            (Uint8List data) {
          print('Received data chunk: ${data.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
          responseBuffer.addAll(data);

          // Check if we have a complete Modbus response
          // Expected: Address(1) + Function(1) + DataLength(1) + Data(16) + CRC(2) = 21 bytes
          if (responseBuffer.length >= 21) {
            timeoutTimer?.cancel();
            subscription?.cancel();
            if (!responseCompleter.isCompleted) {
              responseCompleter.complete(List<int>.from(responseBuffer));
            }
          }
        },
        onError: (error) {
          print('Stream error: $error');
          timeoutTimer?.cancel();
          subscription?.cancel();
          if (!responseCompleter.isCompleted) {
            responseCompleter.completeError(error);
          }
        },
      );

      // Set up timeout
      timeoutTimer = Timer(Duration(seconds: 3), () {
        subscription?.cancel();
        if (!responseCompleter.isCompleted) {
          if (responseBuffer.isNotEmpty) {
            // Return partial response if we got some data
            responseCompleter.complete(List<int>.from(responseBuffer));
          } else {
            responseCompleter.completeError(TimeoutException('No response from sensor', Duration(seconds: 3)));
          }
        }
      });

      // Send query to sensor
      await _port!.write(Uint8List.fromList(modbusQuery));
      print('Query sent, waiting for response...');

      // Wait for response
      List<int> response = await responseCompleter.future;

      if (response.isEmpty) {
        throw Exception('No response from sensor');
      }

      print('Received complete response: ${response.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
      print('Response length: ${response.length} bytes');

      // Parse the Modbus response
      Map<String, dynamic> parsedData = _parseModbusResponse(Uint8List.fromList(response));

      setState(() {
        _sensorData = parsedData;
        _lastUpdated = DateTime.now();
      });

      print('Sensor data updated successfully');

    } catch (e) {
      print('Read error: $e');
      _showError('Failed to read sensor data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _parseModbusResponse(Uint8List response) {
    try {
      // Expected response format (from HONDE manual):
      // [Address][Function][DataLength][Data1High][Data1Low]...[Data8High][Data8Low][CRCLow][CRCHigh]

      if (response.length < 21) { // Minimum expected length: 1+1+1+16+2 = 21 bytes
        throw Exception('Response too short: ${response.length} bytes');
      }

      // Verify address and function code
      if (response[0] != 0x01 || response[1] != 0x03) {
        throw Exception('Invalid response header');
      }

      int dataLength = response[2];
      if (dataLength != 16) { // 8 parameters × 2 bytes each
        throw Exception('Invalid data length: $dataLength');
      }

      // Parse 16-bit values (high byte first) according to manual
      Map<String, dynamic> data = {
        'temperature': _parseTemperature(response[3], response[4]),
        'moisture': _parseMoisture(response[5], response[6]),
        'ec': _parseEC(response[7], response[8]),
        'ph': _parsePH(response[9], response[10]),
        'nitrogen': _parseNPK(response[11], response[12]),
        'phosphorus': _parseNPK(response[13], response[14]),
        'potassium': _parseNPK(response[15], response[16]),
        'salinity': _parseSalinity(response[17], response[18]),
      };

      print('Parsed sensor data: $data');
      return data;

    } catch (e) {
      print('Parse error: $e');
      throw Exception('Failed to parse sensor response: $e');
    }
  }

  // Parse temperature (expand 10 times according to manual)
  double _parseTemperature(int highByte, int lowByte) {
    int rawValue = (highByte << 8) | lowByte;
    return rawValue / 10.0;
  }

  // Parse moisture (expand 10 times according to manual)
  double _parseMoisture(int highByte, int lowByte) {
    int rawValue = (highByte << 8) | lowByte;
    return rawValue / 10.0;
  }

  // Parse EC (direct value)
  int _parseEC(int highByte, int lowByte) {
    return (highByte << 8) | lowByte;
  }

  // Parse pH (extend 100 times according to manual)
  double _parsePH(int highByte, int lowByte) {
    int rawValue = (highByte << 8) | lowByte;
    return rawValue / 100.0;
  }

  // Parse NPK (direct values in mg/kg)
  int _parseNPK(int highByte, int lowByte) {
    return (highByte << 8) | lowByte;
  }

  // Parse salinity (direct value)
  int _parseSalinity(int highByte, int lowByte) {
    return (highByte << 8) | lowByte;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Color _getStatusColor(String parameter, dynamic value) {
    if (value == null) return Colors.grey;

    switch (parameter) {
      case 'moisture':
        double moisture = value is double ? value : double.tryParse(value.toString()) ?? 0;
        if (moisture < 30) return Colors.red;
        if (moisture < 70) return Colors.orange;
        return Colors.green;

      case 'ph':
        double ph = value is double ? value : double.tryParse(value.toString()) ?? 0;
        if (ph < 6.0 || ph > 8.0) return Colors.orange;
        return Colors.green;

      case 'temperature':
        double temp = value is double ? value : double.tryParse(value.toString()) ?? 0;
        if (temp < 10 || temp > 35) return Colors.orange;
        return Colors.green;

      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HONDE Soil Sensor'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshDevices,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.usb : Icons.usb_off,
                          color: _isConnected ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isConnected ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_lastUpdated != null) ...[
                      SizedBox(height: 8),
                      Text(
                        'Last updated: ${_lastUpdated!.toLocal().toString().substring(0, 19)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _connectToSensor(),
                    icon: _isLoading
                        ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Icon(_isConnected ? Icons.check : Icons.usb),
                    label: Text(_isConnected ? 'Connected' : 'Connect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isConnected ? Colors.green : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_isConnected && !_isLoading) ? _readSensorData : null,
                    icon: Icon(Icons.sensors),
                    label: Text('Read Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isConnected ? _disconnect : null,
                  icon: Icon(Icons.close),
                  label: Text('Disconnect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Sensor Data Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
                children: [
                  _buildSensorCard('Temperature', _sensorData['temperature'], '°C', '🌡️', 'temperature'),
                  _buildSensorCard('Moisture', _sensorData['moisture'], '%', '💧', 'moisture'),
                  _buildSensorCard('Conductivity', _sensorData['ec'], 'μS/cm', '⚡', 'ec'),
                  _buildSensorCard('pH Level', _sensorData['ph'], 'pH', '🧪', 'ph'),
                  _buildSensorCard('Nitrogen', _sensorData['nitrogen'], 'mg/kg', '🌱', 'nitrogen'),
                  _buildSensorCard('Phosphorus', _sensorData['phosphorus'], 'mg/kg', '🌾', 'phosphorus'),
                  _buildSensorCard('Potassium', _sensorData['potassium'], 'mg/kg', '🌿', 'potassium'),
                  _buildSensorCard('Salinity', _sensorData['salinity'], 'mg/kg', '🧂', 'salinity'),
                ],
              ),
            ),

            // Device List (when not connected)
            if (!_isConnected && _devices.isNotEmpty) ...[
              SizedBox(height: 16),
              Text('Available USB Devices:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                height: 120,
                child: ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    UsbDevice device = _devices[index];
                    return ListTile(
                      leading: Icon(Icons.usb),
                      title: Text(device.deviceName ?? 'Unknown Device'),
                      subtitle: Text('VID: 0x${device.vid?.toRadixString(16) ?? '?'} '
                          'PID: 0x${device.pid?.toRadixString(16) ?? '?'}'),
                      trailing: IconButton(
                        icon: Icon(Icons.connect_without_contact),
                        onPressed: () => _connectToSensor(device),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(String title, dynamic value, String unit, String emoji, String parameter) {
    Color statusColor = _getStatusColor(parameter, value);
    String displayValue = value != null ? '$value $unit' : 'No Data';

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border(left: BorderSide(color: statusColor, width: 4)),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}