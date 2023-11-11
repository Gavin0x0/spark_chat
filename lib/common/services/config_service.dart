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
