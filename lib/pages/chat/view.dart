import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'index.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            // 带边框的 TextField
            child: TextField(
              controller: controller.messageOutputController,
              focusNode: controller.messageOutputFocusNode,
              maxLines: 100,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Output",
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: controller.messageInputController,
              maxLines: 100,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Input",
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (details) {
                    /// 触发键盘收起事件
                    controller.hideKeyboard();
                  },
                  child: SizedBox(
                    height: double.infinity,
                    child: Obx(
                      () => Text(
                        "Token Usage: ${controller.state.tokenUsage}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.blue,
                    width: 1,
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 1.618,
                  child: TextButton(
                    onPressed: () {
                      controller.handleSend();
                    },
                    child: const Text("Send"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
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
