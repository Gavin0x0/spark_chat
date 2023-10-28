import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spark_chat/common/routers/index.dart';
import 'index.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // _buildRouterButton(RouteNames.home),
          _buildRouterButton(RouteNames.chat),
        ],
      ),
    );
  }

  Widget _buildRouterButton(String routeName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: () {
          Get.toNamed(routeName);
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          child: const Text(
            "Create new chat",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      id: "home",
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text("Spark Chat")),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
