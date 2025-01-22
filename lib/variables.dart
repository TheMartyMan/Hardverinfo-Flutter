import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:system_info2/system_info2.dart';

class Variables {
// Egyéb változók


  Timer? _refreshTimer;

  bool _showGreeting = true;
  final String _snackMessage = "Vivát Csucsu Team";


  late Color _shadow;

  final _deviceInfoPlugin = DeviceInfoPlugin();
  String _selectedMenu = "";
  int _selectedIndex = 0;
  int _refreshTime = 1000;
  int _animationTime = 500;

  // Animáció a köszöntő widgethez

  late AnimationController _greetingAnimationController;
  late Animation<double> _greetAnimation;
  late Animation<double> _delayedAnimation;

  // Animáció az apphoz

  late AnimationController _appAnimationController;
  late Animation<Color?> _appColorAnimation;

// Eszköz

  String _deviceName = "";
  String _hardware = "";
  String _deviceModel = "";
  String _manufacturer = "";
  String _board = "";
  String _isPhysicalDevice = "- Virtuális eszköz -";



// Hálózat

  final _netInfo = NetworkInfo();


  String _networkStatus = "";
  String? _wifiGateway = "";
  String? _wifiBroadcast = "";
  String? _wifiSubmask = "";
  String? _wifiIP = "";
  String? _wifiIPv6 = "";
  String? _wifiBSSID = "";
  String? _wifiName = "";

// Akkumulátor
  final Battery _battery = Battery();

  StreamSubscription<BatteryState>? _batteryStateSubscription;
  BatteryState _batteryState = BatteryState.full;

  Color? batteryColor;
  String _batteryHealth = "";
  int _batteryVoltage = 0;
  int _batteryTemp = 0;
  String _batteryTech = "";
  String _batteryToFull = "";
  IconData _batteryIcon = Icons.battery_unknown;
  String _batteryLevelIndicator = "";
  String _batteryStateString = "";
  String _batteryIsInPowerSave = "";
  String _pluggedType = "";
  int _batteryLevel = 0;
  int _batteryCapacity = 0;

// Rendszer
  String _osVersion = "";
  String _fingerprint = "";
  String _isRooted = "";

// CPU
  int _cpuCores = 0;
  List<int> _cpuFreqList = [];

// Memória
  double _totalStorage = 0;
  double _freeStorage = 0;
  int _memoryTotal = 0;
  int _memoryFree = 0;

// Szenzor
  List<double> _accelData = List.filled(3, 0.0);
  List<double> _gyroData = List.filled(3, 0.0);
  List<double> _lightData = List.filled(1, 0.0);
  StreamSubscription? _accelSubscription;
  StreamSubscription? _gyroSubscription;
  StreamSubscription? _lightSubscription;

// Getterek


  get getRefreshTimer => _refreshTimer;

  get getShowGreeting => _showGreeting;

  get getSnackMessage => _snackMessage;

  get getGreetAnimationController => _greetingAnimationController;

  get getGreetAnimation => _greetAnimation;

  get getDelayedAnimation => _delayedAnimation;

  get getAppAnimationController => _appAnimationController;

  get getAppColorAnimation => _appColorAnimation;

  get getDeviceInfo => _deviceInfoPlugin;

  String get getDeviceModel => _deviceModel;

  String get getDeviceName => _deviceName;

  String get getOsVersion => _osVersion;

  String get getHardware => _hardware;

  String get getManufacturer => _manufacturer;

  String get getBoard => _board;

  String get getFingerprint => _fingerprint;

  Battery get getBattery => _battery;

  int get getBatteryLevel => _batteryLevel;

  String get getBatteryHealth => _batteryHealth;

  String get getPluggedType => _pluggedType;

  get getBatteryIcon => _batteryIcon;

  get getBatteryCapacity => _batteryCapacity;

  get getBatteryTech => _batteryTech;

  get getBatteryLevelIndicator => _batteryLevelIndicator;

  get getBatteryPowerState => _batteryIsInPowerSave;

  get getBatteryVoltage => _batteryVoltage;

  get getBatteryTemp => _batteryTemp;

  get getBatteryToFull => _batteryToFull;

  get getBatteryStateString => _batteryStateString;

  get getBatteryColor => batteryColor;

  get getCpuCores => _cpuCores;

  get getCpuFreqList => _cpuFreqList;

  get getAccelData => _accelData;

  get getGyroData => _gyroData;

  get getLightData => _lightData;

  StreamSubscription<BatteryState>? get getBatteryStreamSubscription =>
      _batteryStateSubscription;

  BatteryState get getBatteryState => _batteryState;

  StreamSubscription? get getAccelStreamSubscription => _accelSubscription;

  StreamSubscription? get getGyroStreamSubscription => _gyroSubscription;

  StreamSubscription? get getLightStreamSubscription => _lightSubscription;

  get getNetInfo => _netInfo;

  String get getSelectedMenu => _selectedMenu;

  get getIsPhysical => _isPhysicalDevice;

  get getIsRooted => _isRooted;

  get getUserName => SysInfo.userName.toString();

  get getKernelArch => SysInfo.kernelArchitecture;

  get getKernelBit => SysInfo.kernelBitness;

  get getKernelName => SysInfo.kernelName;

  get getTotalMemory => _memoryTotal;

  get getFreeMemory => _memoryFree;

  get getTotalStorage => _totalStorage;

  get getFreeStorage => _freeStorage;

  get getShadow => _shadow;

  get getRefreshTime => _refreshTime;

  get getAnimationTime => _animationTime;

  get getSelectedIndex => _selectedIndex;

  get getNetworkStatus => _networkStatus;

  get getWifiName => _wifiName;

  get getWifiBroadcast => _wifiBroadcast;

  get getWifiBSSID => _wifiBSSID;

  get getWifiIP => _wifiIP;

  get getWifiIPv6 => _wifiIPv6;

  get getWifiGateway => _wifiGateway;

  get getWifiSubmask => _wifiSubmask;

  // Setterek

  set setRefreshTimer(Timer value) {
    _refreshTimer = value;
  }


  set setShowGreeting(bool value) {
    _showGreeting = value;
  }

  set setAnimationController(AnimationController value) {
    _greetingAnimationController = value;
  }

  set setAnimation(Animation<double> value) {
    _greetAnimation = value;
  }

  set setDelayedAnimation(Animation<double> value) {
    _delayedAnimation = value;
  }

  set setAppAnimationController(AnimationController value) {
    _appAnimationController = value;
  }

  set setAppColorAnimation(Animation<Color?> value) {
    _appColorAnimation = value;
  }

  set setDeviceName(String value) {
    _deviceName = value;
  }

  set setDeviceModel(String value) {
    _deviceModel = value;
  }

  set setOsVersion(String value) {
    _osVersion = value;
  }

  set setBoard(String value) {
    _board = value;
  }

  set setHardware(String value) {
    _hardware = value;
  }

  set setManufacturer(String value) {
    _manufacturer = value;
  }

  set setFingerprint(String value) {
    _fingerprint = value;
  }

  set setFreeMemory(int value) {
    _memoryFree = value;
  }

  set setTotalMemory(int value) {
    _memoryTotal = value;
  }


  set setFreeStorage(double value) {
    _freeStorage = value;
  }

  set setTotalStorage(double value) {
    _totalStorage = value;
  }

  set setPhysicalDevice(String value) {
    _isPhysicalDevice = value;
  }

  set setRooted(String value) {
    _isRooted = value;
  }

  set setBatteryCapacity(int value) {
    _batteryCapacity = value;
  }

  set setBatteryHealth(String value) {
    _batteryHealth = value;
  }

  set setBatteryTech(String value) {
    _batteryTech = value;
  }

  set setBatteryState(BatteryState value) {
    _batteryState = value;
  }

  set setBatteryStateString(String value) {
    _batteryStateString = value;
  }

  set setBatteryLevelIndicator(String value) {
    _batteryLevelIndicator = value;
  }

  set setBatteryStreamSubscription(StreamSubscription<BatteryState> value) {
    _batteryStateSubscription = value;
  }

  set setPowerState(String value) {
    _batteryIsInPowerSave = value;
  }

  set setBatteryLevel(int value) {
    _batteryLevel = value;
  }

  set setPlugType(String value) {
    _pluggedType = value;
  }

  set setBatteryVoltage(int value) {
    _batteryVoltage = value;
  }

  set setBatteryTemp(int value) {
    _batteryTemp = value;
  }

  set setBatteryToFull(String value) {
    _batteryToFull = value;
  }

  set setBatteryColor(Color? value) {
    batteryColor = value;
  }

  set setCPUCores(int value) {
    _cpuCores = value;
  }

  set setCpuFreqList(List<int> value) {
    _cpuFreqList = value;
  }

  set setAccelSubscription(StreamSubscription? value) {
    _accelSubscription = value;
  }

  set setAccelData(List<double> value) {
    _accelData = value;
  }

  set setGyroSubscription(StreamSubscription? value) {
    _gyroSubscription = value;
  }

  set setGyroData(List<double> value) {
    _gyroData = value;
  }

  set setLightSubscription(StreamSubscription? value) {
    _lightSubscription = value;
  }

  set setLightData(List<double> value) {
    _lightData = value;
  }

  set setSelectedMenu(String value) {
    _selectedMenu = value;
  }

  set setSelectedIndex(int value) {
    _selectedIndex = value;
  }

  set setShadow(Color value) {
    _shadow = value;
  }

  set setBatteryIcon(IconData value) {
    _batteryIcon = value;
  }

  void setRefreshTime(int newRefreshTime) {
    _refreshTime = newRefreshTime;
  }

  void setAnimationTime(int newAnimationTime) {
    _animationTime = newAnimationTime;
  }

  set setNetworkStatus(String value) {
    _networkStatus = value;
  }

  set setWifiGateway(String? value) {
    _wifiGateway = value;
  }

  set setWifiBroadcast(String? value) {
    _wifiBroadcast = value;
  }

  set setWifiSubmask(String? value) {
    _wifiSubmask = value;
  }

  set setWifiIP(String? value) {
    _wifiIP = value;
  }

  set setWifiIPv6(String? value) {
    _wifiIPv6 = value;
  }

  set setWifiBSSID(String? value) {
    _wifiBSSID = value;
  }

  set setWifiName(String? value) {
    _wifiName = value;
  }
}
