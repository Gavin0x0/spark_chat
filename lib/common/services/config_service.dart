import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:spark_chat/common/index.dart';

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

  late Box _localConfigBox;

  /// 服务初始化
  Future<void> init() async {
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
    await Hive.initFlutter();
    _localConfigBox = await Hive.openBox('localConfig');
    String? localUserId = _localConfigBox.get('userId');
    String? localAppId = _localConfigBox.get('appId');
    String? localApiKey = _localConfigBox.get('apiKey');
    String? localApiSecret = _localConfigBox.get('apiSecret');
    bool? localUseMaterial3 = _localConfigBox.get('useMaterial3');
    bool? localDarkMode = _localConfigBox.get('darkMode');
    if (localUserId.isNotNullOrEmpty) {
      Log.i("存在用户ID： $localUserId");
      _userId = localUserId!;
    } else {
      String newUserId = DateTime.now().millisecondsSinceEpoch.toString();
      _userId = newUserId;
      _localConfigBox.put('userId', _userId);
    }
    if (localAppId.isNotNullOrEmpty) {
      Log.i("存在APPID： $localAppId");
      _appId = localAppId!;
    }
    if (localApiKey.isNotNullOrEmpty) {
      Log.i("存在APIKEY： $localApiKey");
      _apiKey = localApiKey!;
    }
    if (localApiSecret.isNotNullOrEmpty) {
      Log.i("存在APISECRET： $localApiSecret");
      _apiSecret = localApiSecret!;
    }
    if (localUseMaterial3 != null) {
      Log.i("存在useMaterial3： $localUseMaterial3");
      useMaterial3 = localUseMaterial3;
    }
    if (localDarkMode != null) {
      Log.i("存在darkMode： $localDarkMode");
      _themeMode = localDarkMode ? ThemeMode.dark : ThemeMode.light;
      Get.changeThemeMode(_themeMode);
    }
  }

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _localConfigBox.put('darkMode', themeMode == ThemeMode.dark);
    Get.changeThemeMode(themeMode);
  }

  void setMaterial3(bool value) {
    useMaterial3 = value;
    _localConfigBox.put('useMaterial3', value);
  }

  void setUserId(String userId) {
    _userId = userId;
    _localConfigBox.put('userId', userId);
  }

  void setAppId(String appId) {
    _appId = appId;
    _localConfigBox.put('appId', appId);
  }

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
    _localConfigBox.put('apiKey', apiKey);
  }

  void setApiSecret(String apiSecret) {
    _apiSecret = apiSecret;
    _localConfigBox.put('apiSecret', apiSecret);
  }

  /// 服务销毁
  @override
  void onClose() {
    super.onClose();
  }
}
