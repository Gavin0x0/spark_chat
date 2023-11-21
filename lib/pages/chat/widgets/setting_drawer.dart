import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spark_chat/common/index.dart';

import '../index.dart';

class SettingDrawer extends GetView<ChatController> {
  const SettingDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController appIdController = TextEditingController(
      text: ConfigService.ins.appId,
    );
    TextEditingController apiKeyController = TextEditingController(
      text: ConfigService.ins.apiKey,
    );
    TextEditingController apiSecretController = TextEditingController(
      text: ConfigService.ins.apiSecret,
    );
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // _buildHeadBar(),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "接口配置",
                        style: TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () {
                          /// TODO 抽取到 controller 中
                          appIdController.text = "";
                          apiKeyController.text = "";
                          apiSecretController.text = "";
                          ConfigService.ins.setAppId("");
                          ConfigService.ins.setApiKey("");
                          ConfigService.ins.setApiSecret("");
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: appIdController,
                    decoration: const InputDecoration(
                      labelText: "APP ID",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      ConfigService.ins.setAppId(value);
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: apiKeyController,
                    decoration: const InputDecoration(
                      labelText: "API KEY",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      ConfigService.ins.setApiKey(value);
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: apiSecretController,
                    decoration: const InputDecoration(
                      labelText: "API SECRET",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      ConfigService.ins.setApiSecret(value);
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "用户配置",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: TextEditingController(
                      text: ConfigService.ins.userId,
                    ),
                    decoration: const InputDecoration(
                      labelText: "User ID",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      ConfigService.ins.setUserId(value);
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "通用配置",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildDarkModeMenu(),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildMaterialVersion(),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // _buildKeepKeyboardOnMobile(),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "用量统计",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildCountText("请求次数：", "TODO"),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildCountText("Tokens 用量：", "TODO"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("深色模式"),
        // 使用下拉 select 三种切换【跟随系统，深色，浅色】
        DropdownMenu<ThemeMode>(
          width: 180,
          requestFocusOnTap: false,
          controller: TextEditingController(
            text: _getDarkModeLabel(ConfigService.ins.themeMode),
          ),
          dropdownMenuEntries: <ThemeMode>[
            ThemeMode.system,
            ThemeMode.dark,
            ThemeMode.light,
          ].map<DropdownMenuEntry<ThemeMode>>((ThemeMode value) {
            return DropdownMenuEntry<ThemeMode>(
              value: value,
              label: _getDarkModeLabel(value),
            );
          }).toList(),
          onSelected: (value) {
            if (value != null) {
              ConfigService.ins.setThemeMode(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildMaterialVersion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Material 3 风格"),
        Obx(
          () => Switch(
            value: ConfigService.ins.useMaterial3,
            onChanged: (value) {
              HapticFeedback.mediumImpact();
              ConfigService.ins.setMaterial3(value);
            },
          ),
        ),
      ],
    );
  }

  // Widget _buildKeepKeyboardOnMobile() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       const Text("TODO:发送后不收起键盘"),
  //       Switch(
  //         value: false,
  //         onChanged: (value) {
  //           HapticFeedback.mediumImpact();
  //           // ConfigService.ins.setMaterial3(value);
  //         },
  //       ),
  //     ],
  //   );
  // }

  String _getDarkModeLabel(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return "跟随系统";
      case ThemeMode.dark:
        return "打开";
      case ThemeMode.light:
        return "关闭";
      default:
        return "跟随系统";
    }
  }

  Widget _buildCountText(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(value,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            )),
      ],
    );
  }
}
