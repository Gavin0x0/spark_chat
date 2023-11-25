// import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          child: Obx(
            () {
              if (controller.state.displayAsChat) {
                // return _buildMarkdownOutput();
                return _buildAsChatMessages();
              } else {
                return Container(
                    padding: const EdgeInsets.all(10), child: _buildOutput());
              }
            },
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
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Text("Chat Mode"),
                            Switch(
                              value: controller.state.displayAsChat,
                              splashRadius: 15,
                              onChanged: (value) {
                                HapticFeedback.mediumImpact();
                                controller.state.displayAsChat = value;
                              },
                            ),
                          ],
                        ),
                        // Row(
                        //   children: [
                        //     const Text("Markdown"),
                        //     Switch(
                        //       value: controller.state.displayAsMarkdown,
                        //       splashRadius: 15,
                        //       onChanged: (value) {
                        //         HapticFeedback.mediumImpact();
                        //         controller.state.displayAsMarkdown = value;
                        //       },
                        //     ),
                        //   ],
                        // ),
                      ],
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
        return GestureDetector(
          onTap: () => controller.hideKeyboard(),
          child: Obx(() => Scaffold(
                key: controller.scaffoldKey,
                appBar: AppBar(
                  title: const Text("Chat"),
                  actions: [
                    _buildSettingIconBtn(context),
                  ],
                ),
                resizeToAvoidBottomInset: !controller.state.isDrawerOpening,
                endDrawer: const SettingDrawer(),
                onEndDrawerChanged: (isOpened) {
                  if (isOpened) {
                    controller.state.isDrawerOpening = isOpened;
                  } else {
                    /// 延迟到动画结束再设置
                    Future.delayed(const Duration(milliseconds: 600), () {
                      controller.state.isDrawerOpening = isOpened;
                    });
                  }
                },
                body: SafeArea(
                  maintainBottomViewPadding: true,
                  child: _buildView(),
                ),
              )),
        );
      },
    );
  }

  // Widget _buildMarkdownOutput() {
  //   return Markdown(
  //     selectable: true,
  //     data: controller.state.outputContent,
  //   );
  // }

  List<Widget> _buildChatHistory() {
    List<Widget> chatHistory = [];
    final messageLength = controller.state.chatLength;
    for (int i = 0; i < messageLength; i++) {
      final message = controller.chatHistory.messages[i];
      chatHistory.add(
        ChatBubble(
          role: message.role,
          content: message.content,
        ),
      );
    }
    return chatHistory;
  }

  Widget _buildOutputingMessage() {
    return Obx(() {
      if (controller.state.isTypeWriterRunning) {
        return ChatBubble(
          role: "assistant",
          content: controller.state.typeWriterOutput,
        );
      } else {
        return Container();
      }
    });
  }

  Widget _buildAsChatMessages() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        controller: controller.chatViewScrollController,
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            ..._buildChatHistory(),
            _buildOutputingMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildOutput() {
    return TextField(
      autofocus: false,
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
    /// command + enter 触发消息发送
    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.enter, LogicalKeyboardKey.meta): () {
          controller.handleSend();
        },
      },
      child: TextField(
        autofocus: false,
        controller: controller.messageInputController,
        focusNode: controller.messageInputFocusNode,
        maxLines: 100,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Input",
        ),
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
        HapticFeedback.mediumImpact();
        if (controller.scaffoldKey.currentState != null) {
          controller.hideKeyboard();
          controller.scaffoldKey.currentState!.openEndDrawer();
        }
      },
      icon: const Icon(Icons.settings),
    );
  }
}
