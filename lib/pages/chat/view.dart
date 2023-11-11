import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'index.dart';
import 'widgets/widgets.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return Column(
      children: [
        Flexible(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(10),
            // 带边框的 TextField
            child: Obx(
              () {
                if (controller.state.displayAsMarkdown) {
                  return _buildMarkdownOutput();
                } else {
                  return _buildOutput();
                }
              },
            ),
          ),
        ),
        const Divider(height: 1),
        Flexible(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: _buildInput(),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (details) {
                      /// 触发键盘收起事件
                      controller.hideKeyboard();
                    },
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   "Token Usage: ${controller.state.tokenUsage}",
                          //   style:
                          //       const TextStyle(color: Colors.grey, fontSize: 10),
                          // ),
                          Row(
                            children: [
                              const Text("Markdown"),
                              Switch(
                                value: controller.state.displayAsMarkdown,
                                splashRadius: 15,
                                onChanged: (value) {
                                  controller.state.displayAsMarkdown = value;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildCopyButton(),
              _buildSendButton(),
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
          key: controller.scaffoldKey,
          appBar: AppBar(
            title: const Text("Spark Chat"),
            actions: [
              _buildSettingIconBtn(context),
            ],
          ),
          endDrawer: const SettingDrawer(),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }

  Widget _buildMarkdownOutput() {
    return Markdown(
      selectable: true,
      data: controller.state.outputContent,
    );
  }

  Widget _buildOutput() {
    return TextField(
      controller: controller.messageOutputController,
      focusNode: controller.messageOutputFocusNode,
      scrollController: controller.messageOutputScrollController,
      maxLines: 100,
      style: const TextStyle(
        fontSize: 12,
      ),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: "Output",
      ),
    );
  }

  Widget _buildInput() {
    return TextField(
      controller: controller.messageInputController,
      focusNode: controller.messageInputFocusNode,
      maxLines: 100,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: "Input",
      ),
    );
  }

  Widget _buildCopyButton() {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: AspectRatio(
        aspectRatio: 1,
        child: ElevatedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
          ),
          onPressed: () {
            controller.copyToClipboard();
          },
          child: const Center(child: Icon(Icons.copy)),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: 80,
      child: AspectRatio(
        aspectRatio: 1.618,
        child: ElevatedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
          ),
          onPressed: () {
            controller.handleSend();
          },
          child: const Text("Send"),
        ),
      ),
    );
  }

  Widget _buildSettingIconBtn(BuildContext ctx) {
    return IconButton(
      onPressed: () {
        if (controller.scaffoldKey.currentState != null) {
          controller.scaffoldKey.currentState!.openEndDrawer();
        }
      },
      icon: const Icon(Icons.settings),
    );
  }
}
