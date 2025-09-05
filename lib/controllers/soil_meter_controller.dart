import 'package:get/get.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:typed_data';
import 'dart:async';

class SoilMeterController extends GetxController {
  // USB connection variables
  UsbPort? _port;
  List<UsbDevice> _devices = [];
  StreamSubscription? _usbEventSubscription;
  Timer? _autoRefreshTimer;
  DateTime? _lastUpdated;

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isConnected = false.obs; // Sensor connection status
  final RxBool isLocked = false.obs; // Lock state for manual/auto refresh
  final RxInt currentStyle = 0.obs; // 0 = style 1, 1 = style 2, 2 = style 3
  final RxString statusMessage = 'Disconnected'.obs;
  final Rx<DateTime?> lastUpdated = Rx<DateTime?>(null);

  // Soil meter data (using humidity for moisture as in original design)
  final RxDouble temperature = 0.0.obs;
  final RxDouble humidity = 0.0.obs; // This represents soil moisture
  final RxDouble ph = 0.0.obs;
  final RxDouble ec = 0.0.obs;
  final RxDouble nitrogen = 0.0.obs;
  final RxDouble phosphorus = 0.0.obs;
  final RxDouble potassium = 0.0.obs;
  final RxDouble salinity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Start with disconnected state
    isConnected.value = false;
    _initializeUSBListener();
    refreshDevices();
    _startAutoRefreshTimer();
    _checkExistingConnection();
  }

  @override
  void onClose() {
    _disconnect();
    _usbEventSubscription?.cancel();
    _autoRefreshTimer?.cancel();
    super.onClose();
  }

  /// Initialize USB event listener
  void _initializeUSBListener() {
    _usbEventSubscription = UsbSerial.usbEventStream?.listen((UsbEvent event) {
      if (event.event == UsbEvent.ACTION_USB_ATTACHED) {
        print('USB device attached');
        refreshDevices().then((_) {
          if (!isConnected.value) {
            connectToSensor();
          }
        });
      } else if (event.event == UsbEvent.ACTION_USB_DETACHED) {
        print('USB device detached');
        _disconnect();
        refreshDevices();
      }
    });
  }

  /// Refresh available USB devices
  Future<void> refreshDevices() async {
    try {
      print('Checking for USB devices...');
      List<UsbDevice> devices = await UsbSerial.listDevices();
      print('Found ${devices.length} USB devices');

      _devices = devices;

      if (devices.isEmpty) {
        print('No USB devices found');
      } else {
        for (var device in devices) {
          print('Device: ${device.deviceName}');
          print('  Vendor ID: 0x${device.vid?.toRadixString(16) ?? 'unknown'}');
          print(
            '  Product ID: 0x${device.pid?.toRadixString(16) ?? 'unknown'}',
          );
        }
      }
    } catch (e) {
      print('Error refreshing devices: $e');
      errorMessage.value = 'Error refreshing devices: $e';
    }
  }

  /// Connect to HONDE soil sensor
  Future<void> connectToSensor([UsbDevice? specificDevice]) async {
    if (isConnected.value) return;

    isLoading.value = true;
    statusMessage.value = 'Connecting...';
    errorMessage.value = '';

    try {
      UsbDevice? targetDevice = specificDevice;

      // If no specific device provided, try to find HONDE sensor
      if (targetDevice == null) {
        if (_devices.isEmpty) {
          await refreshDevices();
          if (_devices.isEmpty) {
            throw Exception('No USB devices available');
          }
        }

        // Try to identify HONDE sensor by characteristics
        targetDevice = _devices.firstWhere(
          (device) =>
              device.deviceName?.toLowerCase().contains('usb') == true ||
              device.manufacturerName?.toLowerCase().contains('prolific') ==
                  true ||
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

      // Open connection with HONDE sensor settings
      bool openResult = await _port!.open();
      if (!openResult) {
        throw Exception('Failed to open USB port');
      }

      // Configure port settings according to HONDE manual
      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(
        9600, // Baud rate (from manual)
        UsbPort.DATABITS_8, // Data bits
        UsbPort.STOPBITS_1, // Stop bits
        UsbPort.PARITY_NONE, // Parity
      );

      isConnected.value = true;
      statusMessage.value = 'Connected to ${targetDevice.deviceName}';

      print('Successfully connected to HONDE sensor');

      // Start reading data automatically
      await loadSoilData();

      // Get.snackbar(
      //   'Success',
      //   'Connected to soil sensor successfully',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Get.theme.colorScheme.primary,
      //   colorText: Get.theme.colorScheme.onPrimary,
      // );
    } catch (e) {
      print('Connection error: $e');
      errorMessage.value = 'Connection failed: $e';
      statusMessage.value = 'Connection failed';

      Get.snackbar(
        'Error',
        'Failed to connect to soil sensor: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Disconnect from sensor
  Future<void> _disconnect() async {
    if (_port != null) {
      await _port!.close();
      _port = null;
    }

    isConnected.value = false;
    statusMessage.value = 'Disconnected';
  }

  /// Disconnect from sensor (public method)
  Future<void> disconnect() async {
    await _disconnect();
    Get.snackbar(
      'Disconnected',
      'Soil sensor disconnected',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Toggle between different UI styles
  void toggleStyle() {
    currentStyle.value = (currentStyle.value + 1) % 3;
  }

  /// Toggle lock state
  void toggleLock() {
    isLocked.value = !isLocked.value;
    // if (isLocked.value) {
    //   Get.snackbar(
    //     'Locked',
    //     'Auto-refresh disabled. Tap refresh manually.',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // } else {
    //   Get.snackbar(
    //     'Unlocked',
    //     'Auto-refresh enabled.',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // }
  }

  /// Start auto-refresh timer
  void _startAutoRefreshTimer() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isConnected.value && !isLocked.value) {
        _silentRefreshSoilData();
      }
    });
  }

  /// Check for existing USB connection when screen opens
  void checkConnectionOnScreenOpen() async {
    if (!isConnected.value) {
      await _checkExistingConnection();
    }
  }

  /// Check for existing USB connection
  Future<void> _checkExistingConnection() async {
    try {
      List<UsbDevice> devices = await UsbSerial.listDevices();
      if (devices.isNotEmpty && !isConnected.value) {
        // Try to connect to the first available device
        await connectToSensor(devices.first);
      }
    } catch (e) {
      print('Error checking existing connection: $e');
    }
  }

  /// Load soil sensor data from HONDE sensor
  Future<void> loadSoilData() async {
    if (!isConnected.value || _port == null) {
      errorMessage.value = 'Not connected to sensor';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Modbus RTU query for all 8 parameters (from HONDE manual)
      // Address: 0x01, Function: 0x03, Start: 0x0000, Length: 0x0008, CRC: 0x440C
      List<int> modbusQuery = [0x01, 0x03, 0x00, 0x00, 0x00, 0x08, 0x44, 0x0C];

      print(
        'Sending Modbus query: ${modbusQuery.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}',
      );

      // Set up stream subscription to read response
      StreamSubscription? subscription;
      Completer<List<int>> responseCompleter = Completer<List<int>>();
      List<int> responseBuffer = [];
      Timer? timeoutTimer;

      // Listen to incoming data stream
      subscription = _port!.inputStream?.listen(
        (Uint8List data) {
          print(
            'Received data chunk: ${data.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}',
          );
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
            responseCompleter.completeError(
              TimeoutException('No response from sensor', Duration(seconds: 3)),
            );
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

      print(
        'Received complete response: ${response.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}',
      );

      // Parse the Modbus response
      Map<String, double> parsedData = _parseModbusResponse(
        Uint8List.fromList(response),
      );

      // Update reactive variables with real sensor data
      temperature.value = parsedData['temperature'] ?? 0.0;
      humidity.value =
          parsedData['moisture'] ?? 0.0; // Using humidity for moisture
      ph.value = parsedData['ph'] ?? 0.0;
      ec.value = parsedData['ec']?.toDouble() ?? 0.0;
      nitrogen.value = parsedData['nitrogen']?.toDouble() ?? 0.0;
      phosphorus.value = parsedData['phosphorus']?.toDouble() ?? 0.0;
      potassium.value = parsedData['potassium']?.toDouble() ?? 0.0;
      salinity.value = parsedData['salinity']?.toDouble() ?? 0.0;

      _lastUpdated = DateTime.now();
      lastUpdated.value = _lastUpdated;

      print('Sensor data updated successfully');
    } catch (e) {
      print('Read error: $e');
      errorMessage.value = 'Failed to read sensor data: $e';

      // Fall back to mock data if sensor read fails but connection exists
      if (isConnected.value) {
        print('Using mock data due to read error');
        _loadMockData();
      }

      Get.snackbar(
        'Warning',
        'Sensor read failed, using mock data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load soil sensor data silently (no loading indicators)
  Future<void> _loadSoilDataSilently() async {
    if (!isConnected.value || _port == null) {
      return;
    }

    try {
      errorMessage.value = '';

      // Modbus RTU query for all 8 parameters (from HONDE manual)
      // Address: 0x01, Function: 0x03, Start: 0x0000, Length: 0x0008, CRC: 0x440C
      List<int> modbusQuery = [0x01, 0x03, 0x00, 0x00, 0x00, 0x08, 0x44, 0x0C];

      // Set up stream subscription to read response
      StreamSubscription? subscription;
      Completer<List<int>> responseCompleter = Completer<List<int>>();
      List<int> responseBuffer = [];
      Timer? timeoutTimer;

      // Listen to incoming data stream
      subscription = _port!.inputStream?.listen(
        (Uint8List data) {
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
            responseCompleter.completeError(
              TimeoutException('No response from sensor', Duration(seconds: 3)),
            );
          }
        }
      });

      // Send query to sensor
      await _port!.write(Uint8List.fromList(modbusQuery));

      // Wait for response
      List<int> response = await responseCompleter.future;

      if (response.isEmpty) {
        return;
      }

      // Parse the Modbus response
      Map<String, double> parsedData = _parseModbusResponse(
        Uint8List.fromList(response),
      );

      // Update reactive variables with real sensor data
      temperature.value = parsedData['temperature'] ?? temperature.value;
      humidity.value = parsedData['moisture'] ?? humidity.value;
      ph.value = parsedData['ph'] ?? ph.value;
      ec.value = parsedData['ec']?.toDouble() ?? ec.value;
      nitrogen.value = parsedData['nitrogen']?.toDouble() ?? nitrogen.value;
      phosphorus.value =
          parsedData['phosphorus']?.toDouble() ?? phosphorus.value;
      potassium.value = parsedData['potassium']?.toDouble() ?? potassium.value;
      salinity.value = parsedData['salinity']?.toDouble() ?? salinity.value;

      _lastUpdated = DateTime.now();
      lastUpdated.value = _lastUpdated;
    } catch (e) {
      // Silent failure - don't show errors for auto-refresh
      print('Silent refresh error: $e');
    }
  }

  /// Parse Modbus response from HONDE sensor
  Map<String, double> _parseModbusResponse(Uint8List response) {
    try {
      if (response.length < 21) {
        throw Exception('Response too short: ${response.length} bytes');
      }

      // Verify address and function code
      if (response[0] != 0x01 || response[1] != 0x03) {
        throw Exception('Invalid response header');
      }

      int dataLength = response[2];
      if (dataLength != 16) {
        throw Exception('Invalid data length: $dataLength');
      }

      // Parse 16-bit values according to HONDE manual
      Map<String, double> data = {
        'temperature': _parseTemperature(response[3], response[4]),
        'moisture': _parseMoisture(response[5], response[6]),
        'ec': _parseEC(response[7], response[8]).toDouble(),
        'ph': _parsePH(response[9], response[10]),
        'nitrogen': _parseNPK(response[11], response[12]).toDouble(),
        'phosphorus': _parseNPK(response[13], response[14]).toDouble(),
        'potassium': _parseNPK(response[15], response[16]).toDouble(),
        'salinity': _parseSalinity(response[17], response[18]).toDouble(),
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

  /// Load mock data for testing/fallback
  void _loadMockData() {
    temperature.value = 21.3;
    humidity.value = 28.0; // Soil moisture
    ph.value = 6.3;
    ec.value = 0.3;
    nitrogen.value = 93.0;
    phosphorus.value = 122.22;
    potassium.value = 22.03;
    salinity.value = 17.30;
    _lastUpdated = DateTime.now();
    lastUpdated.value = _lastUpdated;
  }

  /// Refresh soil data
  Future<void> refreshSoilData() async {
    await loadSoilData();
  }

  /// Silent refresh soil data (no loading indicators)
  Future<void> _silentRefreshSoilData() async {
    await _loadSoilDataSilently();
  }

  /// Toggle sensor connection (for UI compatibility)
  Future<void> toggleConnection() async {
    if (isConnected.value) {
      await disconnect();
    } else {
      await connectToSensor();
    }
  }

  /// Get available USB devices
  List<UsbDevice> get availableDevices => _devices;

  /// Get connection status message
  String get connectionStatus => statusMessage.value;

  /// Check if we have recent data
  bool get hasRecentData {
    if (_lastUpdated == null) return false;
    return DateTime.now().difference(_lastUpdated!).inMinutes < 5;
  }

  /// Get soil health status based on parameters
  String getSoilHealthStatus() {
    if (ph.value < 5.5 || ph.value > 8.5) return 'Poor';
    if (nitrogen.value < 20 || phosphorus.value < 10 || potassium.value < 100)
      return 'Fair';
    return 'Good';
  }

  /// Get recommendations based on soil data
  List<String> getRecommendations() {
    List<String> recommendations = [];

    if (ph.value < 6.0) {
      recommendations.add('Consider adding lime to increase soil pH');
    } else if (ph.value > 7.5) {
      recommendations.add('Consider adding sulfur to decrease soil pH');
    }

    if (nitrogen.value < 30) {
      recommendations.add(
        'Nitrogen levels are low, consider nitrogen-rich fertilizers',
      );
    }

    if (phosphorus.value < 15) {
      recommendations.add(
        'Phosphorus levels are low, consider phosphorus fertilizers',
      );
    }

    if (potassium.value < 150) {
      recommendations.add(
        'Potassium levels are low, consider potassium fertilizers',
      );
    }

    if (humidity.value < 30) {
      // Soil moisture
      recommendations.add('Soil moisture is low, consider irrigation');
    } else if (humidity.value > 80) {
      recommendations.add('Soil moisture is high, improve drainage');
    }

    if (ec.value > 2.0) {
      recommendations.add(
        'Electrical conductivity is high, check salinity levels',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('Soil conditions look good, continue monitoring');
    }

    return recommendations;
  }

  /// Get parameter status color
  String getParameterStatus(String parameter, double value) {
    switch (parameter.toLowerCase()) {
      case 'moisture':
      case 'humidity':
        if (value < 30) return 'low';
        if (value < 70) return 'medium';
        return 'high';

      case 'ph':
        if (value < 6.0 || value > 8.0) return 'warning';
        return 'good';

      case 'temperature':
        if (value < 10 || value > 35) return 'warning';
        return 'good';

      case 'nitrogen':
        if (value < 30) return 'low';
        if (value < 100) return 'medium';
        return 'high';

      case 'phosphorus':
        if (value < 15) return 'low';
        if (value < 50) return 'medium';
        return 'high';

      case 'potassium':
        if (value < 150) return 'low';
        if (value < 300) return 'medium';
        return 'high';

      default:
        return 'normal';
    }
  }
}
