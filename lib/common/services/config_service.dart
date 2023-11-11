import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class ConfigService extends GetxService {
  static ConfigService get ins => Get.find<ConfigService>();

  String _appId = "";
  String get appId => _appId;

  String _apiKey = "";
  String get apiKey => _apiKey;

  String _apiSecret = "";
  String get apiSecret => _apiSecret;

  String _userId = "";
  String get userId => _userId;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  final RxBool _useMaterial3 = true.obs;
  bool get useMaterial3 => _useMaterial3.value;
  set useMaterial3(bool value) => _useMaterial3.value = value;

  /// 服务初始化
  Future<void> init() async {
    /// 优先读编译环境的值
    await _loadDevEnvConfig();
    await _loadLocalConfig();
  }

  Future<void> _loadDevEnvConfig() async {
    await dotenv.load(fileName: ".env");
    _appId = dotenv.env['APPID'] ?? '';
    _apiKey = dotenv.env['APIKEY'] ?? '';
    _apiSecret = dotenv.env['APISECRET'] ?? '';
  }

  Future<void> _loadLocalConfig() async {
    // TODO 读本地用户配置的值
    _userId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    Get.changeThemeMode(themeMode);
  }

  void setMaterial3(bool value) {
    useMaterial3 = value;
  }

  @override
  void onInit() {
    super.onInit();
    init();
  }

  /// 服务销毁
  @override
  void onClose() {
    super.onClose();
  }
}
