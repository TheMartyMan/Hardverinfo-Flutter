import 'dart:async';

import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cpu_reader/cpu_reader.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:hardverinfo/exit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:root/root.dart';
import 'package:system_info2/system_info2.dart';

import 'about.dart';
import 'app.dart';
import 'greeting.dart';
import 'homepage.dart';
import 'variables.dart';

void main() {
  runApp(const App());
}

class HomePageState extends State<HomePage> {
  Variables variables = Variables();

  @override
  void initState() {
    _getDeviceInformation();
    _getBatteryDetailsInfo();
    _getCPUInfo();
    super.initState();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    variables.getRefreshTimer?.cancel();
    variables.setRefreshTimer = Timer.periodic(
        Duration(milliseconds: variables.getRefreshTime), (timer) {
      _getBatteryInfo();
      _getCPUFreq();
      _getMemory();
      _checkNetworkStatus();
    });
  }

  @override
  void dispose() {
    variables.getBatteryStreamSubscription?.cancel();
    variables.getAccelStreamSubscription?.cancel();
    variables.getGyroStreamSubscription?.cancel();
    variables.getLightStreamSubscription?.cancel();
    super.dispose();
  }

  // ---- Metódusok ----

  // Eszköz & rendszer adatok
  Future<void> _getDeviceInformation() async {
    final info = await variables.getDeviceInfo.androidInfo;

    bool? result = await Root.isRooted();
    setState(() {
      variables.setDeviceName = info.device;
      variables.setDeviceModel = info.model;
      variables.setOsVersion = info.version.release;
      variables.setBoard = info.board;
      variables.setFingerprint = info.fingerprint;
      variables.setHardware = info.hardware;
      variables.setManufacturer = info.manufacturer;

      if (info.isPhysicalDevice) {
        variables.setPhysicalDevice = "- Valós fizikai eszköz -";
      }

      if (result == true) {
        setState(() {
          variables.setRooted = "*Rootolt eszköz*";
        });
      }
    });
  }

  Future<void> _getMemory() async {
    double freeStorage = (await DiskSpace.getFreeDiskSpace)!;
    double totalStorage = (await DiskSpace.getTotalDiskSpace)!;
    int freeMemory = SysInfo.getFreeVirtualMemory();
    int totalMemory = SysInfo.getTotalPhysicalMemory();
      variables.setFreeStorage = freeStorage;
      variables.setTotalStorage = totalStorage;
      variables.setFreeMemory = freeMemory;
      variables.setTotalMemory = totalMemory;
  }

  // Akku kapacitás és épség - nem szükséges folyamatos lekérés
  Future<void> _getBatteryDetailsInfo() async {
    variables.setBatteryStreamSubscription =
        variables.getBattery.onBatteryStateChanged.listen((state) {
      variables.setBatteryState = state;
      setState(() {});
    });

    int? batteryCapacity =
        (await BatteryInfoPlugin().androidBatteryInfo)?.batteryCapacity;
    String? batteryHealth =
        (await BatteryInfoPlugin().androidBatteryInfo)?.health;
    String? batteryTech =
        (await BatteryInfoPlugin().androidBatteryInfo)?.technology;
    setState(() {
      variables.setBatteryCapacity = batteryCapacity!;
      variables.setBatteryHealth = batteryHealth!;
      variables.setBatteryTech = batteryTech!;
    });
  }

  // Akku szint, töltési mód és energiatakarékos mód - folyamatos lekérés szükséges
  Future<void> _getBatteryInfo() async {
    int batteryLevel = await variables.getBattery.batteryLevel;
    final batteryInfo = await BatteryInfoPlugin().androidBatteryInfo;
    String? plugged = batteryInfo?.pluggedStatus.toString();
    bool isInPowerSaveMode = await variables.getBattery.isInBatterySaveMode;
    int? batteryVoltage =
        (await BatteryInfoPlugin().androidBatteryInfo)?.voltage;
    int? batteryTemp =
        (await BatteryInfoPlugin().androidBatteryInfo)?.temperature;
    int? batteryToFull =
        (await BatteryInfoPlugin().androidBatteryInfo)?.chargeTimeRemaining;

    if (isInPowerSaveMode) {
        variables.setPowerState = 'Energiatakarékos mód: Be';
    } else {
        variables.setPowerState = 'Energiatakarékos mód: Ki';
    }
      variables.setBatteryLevel = batteryLevel;
      variables.setPlugType = plugged!;
      variables.setBatteryVoltage = batteryVoltage!;
      variables.setBatteryTemp = batteryTemp!;
      if (batteryToFull! <= 0) {
        variables.setBatteryToFull = "";
      } else {
        batteryToFull / 60000 < 60
            ? variables.setBatteryToFull =
                'Hátralévő töltési idő: ${(batteryToFull / 60000).toStringAsFixed(0)} perc'
            : variables.setBatteryToFull =
                'Hátralévő töltési idő: ${(batteryToFull / 3600000).toStringAsFixed(0)} óra';
      }
  }

  // CPU
  Future<void> _getCPUInfo() async {
    var cpuInfo = await CpuReader.cpuInfo;
    setState(() {
      variables.setCPUCores = cpuInfo.numberOfCores!;
    });
  }

  // CPU frekvencia
  Future<void> _getCPUFreq() async {
    final cpuInfo = await CpuReader.cpuInfo;
    var frequencies = cpuInfo.currentFrequencies;
    List<int>? freqList =
        frequencies?.entries.map((entry) => entry.value).toList();
    setState(() {
      variables.setCpuFreqList = freqList!;
    });
  }

  // Szenzor adatok
  Future<void> _startAccel() async {
    if (variables.getAccelStreamSubscription != null) return;
    final stream = await SensorManager().sensorUpdates(sensorId: Sensors.ACCELEROMETER);
    variables.setAccelSubscription = stream.listen((sensorEvent) {
      setState(() {
        variables.setAccelData = sensorEvent.data;
      });
    });
  }

  void _stopAccel() {
    if (variables.getAccelStreamSubscription == null) return;
    variables.getAccelStreamSubscription?.cancel();
    variables.setAccelSubscription = null;
    variables.setAccelData = [0, 0, 0];
  }

  Future<void> _startGyro() async {
    if (variables.getGyroStreamSubscription != null) return;
    final stream =
        await SensorManager().sensorUpdates(sensorId: Sensors.GYROSCOPE);
    variables.setGyroSubscription = stream.listen((sensorEvent) {
      setState(() {
        variables.setGyroData = sensorEvent.data;
      });
    });
  }

  void _stopGyro() {
    if (variables.getGyroStreamSubscription == null) return;
    variables.getGyroStreamSubscription?.cancel();
    variables.setGyroSubscription = null;
    variables.setGyroData = [0, 0, 0];
  }

  Future<void> _startLight() async {
    if (variables.getLightStreamSubscription != null) return;
    final stream = await SensorManager().sensorUpdates(sensorId: 5);
    variables.setLightSubscription = stream.listen((sensorEvent) {
      setState(() {
        variables.setLightData = sensorEvent.data;
      });
    });
  }

  void _stopLight() {
    if (variables.getLightStreamSubscription == null) return;
    variables.getLightStreamSubscription?.cancel();
    variables.setLightSubscription = null;
    variables.setLightData = [0];
  }

  Future<void> _requestPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      Permission.location.request();
    }
  }

  Future<void> _checkNetworkStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      variables.setNetworkStatus = 'Mobilhálózat elérhető';
      variables.setWifiName = "";
      variables.setWifiBSSID = "";
      variables.setWifiIP = "";
      variables.setWifiIPv6 = "";
      variables.setWifiSubmask = "";
      variables.setWifiBroadcast = "";
      variables.setWifiGateway = "";
    } else if (connectivityResult == ConnectivityResult.wifi) {
      variables.setNetworkStatus = 'WiFi elérhető';
      _requestPermission();
      if (await Permission.location.isRestricted ||
          await Permission.location.isDenied ||
          await Permission.location.isPermanentlyDenied) {
        variables.setWifiName = "További adatokért engedélyezze a helyadatokat";
        variables.setWifiBSSID = "valamint kapcsolja be a tartózkodási helyet";
        variables.setWifiIP = "a rendszer beállításokban";
      } else {
        variables.setWifiName =
            "WiFi neve (SSID): ${await variables.getNetInfo.getWifiName()}";

        variables.setWifiBSSID =
            "BSSID: ${await variables.getNetInfo.getWifiBSSID()}";

        variables.setWifiIP =
            "IP cím: ${await variables.getNetInfo.getWifiIP()}";

        variables.setWifiIPv6 =
            "IPv6 cím: ${await variables.getNetInfo.getWifiIPv6()}";

        variables.setWifiSubmask =
            "Alhálózati maszk: ${await variables.getNetInfo.getWifiSubmask()}";

        variables.setWifiBroadcast =
            "Broadcast cím: ${await variables.getNetInfo.getWifiBroadcast()}";

        variables.setWifiGateway =
            "Átjáró cím: ${await variables.getNetInfo.getWifiGatewayIP()}";
      }
    } else {
      variables.setNetworkStatus = 'Nincs kapcsolat';
      variables.setWifiName = "";
      variables.setWifiBSSID = "";
      variables.setWifiIP = "";
      variables.setWifiIPv6 = "";
      variables.setWifiSubmask = "";
      variables.setWifiBroadcast = "";
      variables.setWifiGateway = "";
    }
  }

  // Eszköz
  Widget _buildDevice(BuildContext context) {
    final deviceInfo = [
      {'title': 'Eszköz neve', 'value': variables.getDeviceName},
      {'title': 'Alaplap', 'value': variables.getBoard},
      {'title': 'Hardver', 'value': variables.getHardware},
      {'title': 'Gyártó', 'value': variables.getManufacturer},
      {'title': 'Eszköz modell', 'value': variables.getDeviceModel},
      {'title': '', 'value': variables.getIsPhysical},
    ];

    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: variables.getAnimationTime),
        width: 300,
        height: 380,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[800],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.developer_mode_outlined,
              color: Colors.white,
              size: 40,
            ),
            const Text(
              'Eszköz',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            for (var item in deviceInfo)
              if (item['title']
                  .isNotEmpty) // Csak akkor jelenítse meg a címet, ha nem üres
                Column(
                  children: [
                    Text(
                      '${item['title']}: ${item['value']}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                )
              else
                Text(
                  item['value'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  // Akkumulátor
  Widget _buildBattery() {
    variables.setBatteryColor = Colors.green[700];
    variables.setShadow = Colors.green.withOpacity(0.5);
    variables.setBatteryIcon = Icons.battery_full_outlined;

    if (variables.getBatteryLevel <= 70) {
      variables.setBatteryColor = Colors.green[400];
      variables.setShadow = Colors.green.withOpacity(0.5);
      variables.setBatteryIcon = Icons.battery_6_bar_outlined;
    }
    if (variables.getBatteryLevel <= 60) {
      variables.setBatteryColor = Colors.yellow[600];
      variables.setShadow = Colors.yellow.withOpacity(0.5);
      variables.setBatteryIcon = Icons.battery_5_bar_outlined;
    }
    if (variables.getBatteryLevel <= 50) {
      variables.setBatteryColor = Colors.orange[600];
      variables.setShadow = Colors.orange.withOpacity(0.5);
      variables.setBatteryIcon = Icons.battery_4_bar_outlined;
    }
    if (variables.getBatteryLevel <= 40) {
      variables.setBatteryColor = Colors.red[600];
      variables.setShadow = Colors.red.withOpacity(0.5);
      variables.setBatteryIcon = Icons.battery_3_bar_outlined;
    }
    if (variables.getBatteryLevel < 30) {
      variables.setBatteryColor = Colors.red[800];
      variables.setShadow = Colors.red.withOpacity(0.5);
      variables.setBatteryIcon = Icons.battery_2_bar_outlined;
    }
    if (variables.getBatteryLevel <= 20) {
      variables.setBatteryColor = Colors.grey[600];
      variables.setShadow = Colors.grey.withOpacity(0.5);
      variables.setBatteryIcon = Icons.battery_1_bar_outlined;
    }
    if (variables.getBatteryLevel <= 10) {
      variables.setBatteryColor = Colors.black;
      variables.setShadow = Colors.black.withOpacity(0.5);
      variables.setBatteryIcon = Icons.battery_0_bar_outlined;
    }

    switch (variables.getBatteryState) {
      case BatteryState.discharging:
        {
          variables.setBatteryStateString = "Merülés";
          variables.setBatteryLevelIndicator =
              '${variables.getBatteryLevel}' '%';
          variables.setPlugType = "";
        }
        break;

      case BatteryState.charging:
        {
          variables.setBatteryStateString = "Töltés";
          variables.setBatteryLevelIndicator =
              '${variables.getBatteryLevel}' '+%';
          variables.setBatteryIcon = Icons.battery_charging_full_outlined;
        }
        break;

      case BatteryState.unknown:
        {
          variables.setBatteryStateString = "Ismeretlen";
          variables.setBatteryIcon = Icons.battery_unknown_outlined;
        }
        break;

      default:
        {
          variables.setBatteryStateString = "Betöltés...";
          variables.setBatteryIcon = Icons.battery_unknown_outlined;
        }
        break;
    }

    switch (variables.getBatteryHealth) {
      case "health_good":
        {
          variables.setBatteryHealth = "Jó";
        }
        break;

      case "health_bad":
        {
          variables.setBatteryHealth = "Rossz";
        }
        break;
    }

    switch (variables.getPluggedType) {
      case "USB":
        {
          variables.setPlugType = "(USB)";
        }
        break;

      case "AC":
        {
          variables.setPlugType = "(AC)";
        }
        break;

      case "unknown":
        {
          variables.setPlugType = "(Ismeretlen)";
        }
        break;
    }

    final batteryInfo = [
      {
        'title': 'Töltöttségi szint',
        'value': variables.getBatteryLevelIndicator
      },
      {
        'title': 'Állapot',
        'value':
            '${variables.getBatteryStateString} ${variables.getPluggedType}'
      },
      {'title': '', 'value': variables.getBatteryPowerState},
      {'title': 'Épség', 'value': variables.getBatteryHealth},
      {
        'title': 'Töltöttség számláló',
        'value':
            '${(variables.getBatteryCapacity / 1000).toStringAsFixed(0)} mAh'
      },
      {'title': 'Technológia', 'value': variables.getBatteryTech},
      {
        'title': 'Feszültség',
        'value': '${variables.getBatteryVoltage / 1000} V'
      },
      {'title': 'Hőmérséklet', 'value': '${variables.getBatteryTemp} C°'},
      {'title': '', 'value': variables.getBatteryToFull},
    ];

    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: variables.getAnimationTime),
        width: 300,
        height: 450,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: variables.getBatteryColor.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(30),
          color: variables.getBatteryColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              variables.getBatteryIcon,
              color: Colors.white,
              size: 40,
            ),
            const Text(
              'Akkumulátor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            for (var item in batteryInfo)
              if (item['title'].isNotEmpty)
                Column(
                  children: [
                    Text(
                      '${item['title']}: ${item['value']}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                )
              else
                Column(
                  children: [
                    Text(
                      item['value'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                )
          ],
        ),
      ),
    );
  }

  // CPU
  Widget _buildCPU(BuildContext context) {
    final cpuInfo = [
      {'title': 'CPU magok száma', 'value': variables.getCpuCores.toString()},
    ];

    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: variables.getAnimationTime),
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(30),
          color: Colors.teal[700],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.developer_board_outlined,
              color: Colors.white,
              size: 40,
            ),
            const Text(
              'CPU',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            for (var item in cpuInfo)
              Column(
                children: [
                  Text(
                    '${item['title']}: ${item['value']}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item['title'] == 'CPU magok száma')
                    const SizedBox(height: 15),
                ],
              ),
            const Text(
              'Frekvenciatábla',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 42,
              width: 100,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: variables.getCpuFreqList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      '${index + 1}. mag: ${variables.getCpuFreqList[index]} MHz',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Rendszer
  Widget _buildSystem(BuildContext context) {
    final systemInfo = [
      {
        'title': 'Operációs rendszer',
        'value': 'Android ${variables.getOsVersion}'
      },
      {'title': 'Kernel', 'value': variables.getKernelName},
      {
        'title': 'Kernel architektúra',
        'value': '${variables.getKernelArch} (${variables.getKernelBit} bit)'
      },
      {'title': 'Rendszer lenyomat', 'value': ''},
      {'title': '', 'value': variables.getFingerprint},
      {'title': '', 'value': variables.getIsRooted},
    ];

    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: variables.getAnimationTime),
        width: 310,
        height: 380,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
          color: Colors.red[800],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.adb_rounded,
              color: Colors.white,
              size: 40,
            ),
            const Text(
              'Rendszer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            for (var item in systemInfo)
              if (item['title'].isNotEmpty)
                Column(
                  children: [
                    Text(
                      '${item['title']}: ${item['value']}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                )
              else
                Column(
                  children: [
                    Text(
                      item['value'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                )
          ],
        ),
      ),
    );
  }

  // Memória
  Widget _buildMemory(BuildContext context) {
    final memoryInfo = [
      {
        'title': 'Összes RAM',
        'value': (variables.getTotalMemory / 1048576).toStringAsFixed(2),
        'unit': 'MB',
      },
      {
        'title': 'Szabad RAM',
        'value': (variables.getFreeMemory / 1048576).toStringAsFixed(2),
        'unit': 'MB',
      },
      {
        'title': 'Összes tárhely',
        'value': (variables.getTotalStorage / 1024).toStringAsFixed(2),
        'unit': 'GB',
      },
      {
        'title': 'Szabad tárhely',
        'value': (variables.getFreeStorage / 1024).toStringAsFixed(2),
        'unit': 'GB',
      },
    ];

    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: variables.getAnimationTime),
        width: 250,
        height: 300,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
          color: Colors.orange[800],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.memory_outlined,
              color: Colors.white,
              size: 40,
            ),
            const Text(
              'Memória',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            for (var item in memoryInfo)
              Column(
                children: [
                  Text(
                    '${item['title']}: ${item['value']} ${item['unit']}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Szenzor
  Widget _buildSensor(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: variables.getAnimationTime),
        width: 250,
        height: 500,
        decoration: _buildSensorContainerDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSensorIconAndTitle(Icons.double_arrow_rounded, 'Gyorsulás'),
            _buildSensorData('X', variables.getAccelData[0], 'm/s²'),
            _buildSensorData('Y', variables.getAccelData[1], 'm/s²'),
            _buildSensorData('Z', variables.getAccelData[2], 'm/s²'),
            const SizedBox(height: 30),
            _buildSensorIconAndTitle(Icons.screen_rotation_alt_outlined, 'Giroszkóp'),
            _buildSensorData('X', variables.getGyroData[0], 'rad/s'),
            _buildSensorData('Y', variables.getGyroData[1], 'rad/s'),
            _buildSensorData('Z', variables.getGyroData[2], 'rad/s'),
            const SizedBox(height: 30),
            _buildSensorIconAndTitle(Icons.light_mode_outlined, 'Fény'),
            _buildSensorData('', variables.getLightData[0], 'lx'),
            _buildSensorButtons(),
          ],
        ),
      ),
    );
  }

  Decoration _buildSensorContainerDecoration() {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: const Offset(0, 3),
        ),
      ],
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
    );
  }

  Widget _buildSensorIconAndTitle(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 40),
        Text(
          title,
          style: _buildSensorTextStyle(24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildSensorData(String label, double data, String unit) {
    return Text(
      label == '' ? '${data.toStringAsFixed(4)} $unit'
    : '$label = ${data.toStringAsFixed(4)} $unit',
      textAlign: TextAlign.center,
      style: _buildSensorTextStyle(16, fontWeight: FontWeight.w500),
    );
  }
  TextStyle _buildSensorTextStyle(double fontSize, {FontWeight? fontWeight}) {
    return TextStyle(
      color: Colors.black,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  Widget _buildSensorButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSensorButton('Indítás', () {
          _startAccel();
          _startGyro();
          _startLight();
        }),
        _buildSensorButton('Leállítás', () {
          _stopAccel();
          _stopGyro();
          _stopLight();
        }),
      ],
    );
  }

  Widget _buildSensorButton(String label, Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: _buildSensorTextStyle(16),
        ),
      ),
    );
  }



  // Hálózat
  Widget _buildNetwork(BuildContext context) {
    final networkInfo = [
      variables.getNetworkStatus,
      variables.getWifiName,
      variables.getWifiBSSID,
      variables.getWifiIP,
      variables.getWifiBroadcast,
      variables.getWifiIPv6,
      variables.getWifiGateway,
      variables.getWifiSubmask,
    ];

    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: variables.getAnimationTime),
        width: variables.getNetworkStatus == 'WiFi elérhető' ? 330 : 200,
        height: variables.getNetworkStatus == 'WiFi elérhető' ? 450 : 150,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(30),
          color: Colors.deepPurple,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              // Itt állíthatod be a padding méretét
              child: Icon(
                Icons.network_wifi,
                color: Colors.white,
                size: 40,
              ),
            ),
            const Text(
              'Hálózat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            for (var info in networkInfo)
              Column(
                children: [
                  Text(
                    info,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15), // 15-pixel SizedBox
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Beállítások
  Widget _buildSettings(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beállítások'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCard(
              'Adatlekérési gyakoriság',
              variables.getRefreshTime,
              [500, 1000, 1500, 2000],
              (newRefreshTime) {
                variables.setRefreshTime(newRefreshTime!);
                _startRefreshTimer();
              },
            ),
            _buildCard(
              'Animáció időtartam beállítása',
              variables.getAnimationTime,
              [0, 200, 500, 1000],
              (newAnimationTime) {
                variables.setAnimationTime(newAnimationTime!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, int value, List<int> options,
      void Function(int?) onChanged) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: DropdownButton<int>(
                value: value,
                items: options.map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value ms'),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      variables.setSelectedIndex = index;
      variables.setSelectedMenu = "";
      variables.setShowGreeting = false;
    });
  }

  // App
  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = [
      _buildDevice(context),
      _buildBattery(),
      _buildCPU(context),
      _buildSystem(context),
      _buildMemory(context),
      _buildSensor(context),
      _buildNetwork(context),
    ];

    final selectedWidget = _getSelectedWidget(widgetOptions);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          variables.getShowGreeting == true ? const Greeting() : selectedWidget,
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _getSelectedWidget(List<Widget> widgetOptions) {
    switch (variables.getSelectedMenu) {
      case "settings":
        return _buildSettings(context);
      case "exit":
        return const Exit();
      case "about":
        return const About();
      default:
        return widgetOptions.elementAt(variables.getSelectedIndex);
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Hardver-Infó'),
      actions: [
        if (!variables.getShowGreeting) _buildPopupMenuButton(),
      ],
    );
  }

  PopupMenuButton<String> _buildPopupMenuButton() {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        setState(() {
          variables.setSelectedMenu = value;
        });
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(
            value: 'settings',
            child: Text('Beállítások'),
          ),
          const PopupMenuItem(
            value: 'exit',
            child: Text('Kilépés'),
          ),
          const PopupMenuItem(
            value: 'about',
            child: Text('Névjegy'),
          ),
        ];
      },
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        _buildBottomNavigationBarItem(
            Icons.developer_mode_outlined, 'Eszköz', Colors.blue[800]!),
        _buildBottomNavigationBarItem(
            Icons.battery_full, 'Akkumulátor', variables.getBatteryColor),
        _buildBottomNavigationBarItem(
            Icons.developer_board_outlined, 'CPU', Colors.teal),
        _buildBottomNavigationBarItem(
            Icons.system_update, 'Rendszer', Colors.red[800]!),
        _buildBottomNavigationBarItem(
            Icons.memory, 'Memória', Colors.orange[800]!),
        _buildBottomNavigationBarItem(Icons.sensors, 'Szenzor', Colors.black),
        _buildBottomNavigationBarItem(
            Icons.network_wifi, 'Hálózat', Colors.deepPurple),
      ],
      currentIndex: variables.getSelectedIndex,
      selectedItemColor: Colors.white,
      onTap: onItemTapped,
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      IconData icon, String label, Color backgroundColor) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
      backgroundColor: backgroundColor,
    );
  }
}
