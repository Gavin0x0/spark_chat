import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../index.dart';

class SettingDrawer extends GetView<ChatController> {
  const SettingDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeadBar(),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "接口配置",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 10,
                ),
                const TextField(
                  decoration: InputDecoration(
                    labelText: "APP ID",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const TextField(
                  decoration: InputDecoration(
                    labelText: "API KEY",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const TextField(
                  decoration: InputDecoration(
                    labelText: "API SECRET",
                    border: OutlineInputBorder(),
                  ),
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
                    text: controller.state.uid,
                  ),
                  decoration: const InputDecoration(
                    labelText: "User ID",
                    border: OutlineInputBorder(),
                  ),
                ),
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
                _buildCountText("请求次数：", "mock-10"),
                const SizedBox(
                  height: 10,
                ),
                _buildCountText("Tokens 用量：", "mock-8718"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.close,
            color: Colors.grey,
          ),
        ),
      ],
    );
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
