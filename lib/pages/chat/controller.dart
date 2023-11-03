import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:spark_chat/common/models/chat_model.dart';
import 'package:spark_chat/common/utils/auth_util.dart';
import 'package:spark_chat/common/utils/type_writer.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'index.dart';

class ChatController extends GetxController {
  ChatController();

  final state = ChatState();

  final messageInputController = TextEditingController();

  final messageOutputController = TextEditingController();

  final messageOutputFocusNode = FocusNode();

  late final typeWriter = TypeWriter(
      target: messageOutputController,
      focusNode: messageOutputFocusNode,
      speed: 100,
      cursor: "_");

  // tap
  void handleSend() {
    hideKeyboard();
    if (typeWriter.isBusy) {
      Get.snackbar(
        "Error",
        "正在输入中，请稍后再试",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    typeWriter.initTypeWriter();
    startOutput();
  }

  /// 开始输出
  void startOutput() {
    String appId = dotenv.env['APPID'] ?? '';
    ChatRequest chatRequest = ChatRequest(
      appId: appId,
      domain: 'generalv3',
      messages: [
        Message(role: 'user', content: messageInputController.text),
      ],
    );
    String jsonStr = jsonEncode(chatRequest.toJson());
    debugPrint("Send message 📤: \n$jsonStr");

    String path = '/v3.1/chat';
    String authUrl = AuthUtil.generateAuthUrl(path);
    final ws = WebSocketChannel.connect(
      Uri.parse(authUrl),
    );
    ws.sink.add(jsonStr);
    ws.stream.listen(
      (event) {
        ChatResponse chatResponse = ChatResponse.fromJson(jsonDecode(event));
        if (chatResponse.header.code != 0) {
          Get.snackbar(
            "Error",
            chatResponse.header.message,
            snackPosition: SnackPosition.BOTTOM,
          );
          typeWriter.addText(chatResponse.header.message);
        } else if (chatResponse.payload != null) {
          String eachResponse = "";
          for (var e in chatResponse.payload!.choices.text) {
            debugPrint("Got message 📩: \n${e.content}");
            eachResponse += e.content;
          }
          typeWriter.addText(eachResponse);
          if (chatResponse.payload!.usage != null) {
            debugPrint(
                "🪙 Used tokens: ${chatResponse.payload!.usage!.totalTokens}");
            typeWriter.inputFinished();
            state.tokenUsage += chatResponse.payload!.usage!.totalTokens;
          }
        }
      },
      onDone: () {
        debugPrint("🔌 Disconnected");
        ws.sink.close();
      },
      onError: (e) {
        debugPrint("Error: $e");
        Get.snackbar(
          "Error",
          "连接服务器失败，请检查网络或 APIKey",
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void hideKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  /// 在 widget 内存中分配后立即调用。
  @override
  void onInit() {
    super.onInit();
    // 生成用户id
    state.uid = DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// 在 onInit() 之后调用 1 帧。这是进入的理想场所
  @override
  void onReady() {
    super.onReady();
  }

  /// 在 [onDelete] 方法之前调用。
  @override
  void onClose() {
    super.onClose();
  }

  /// dispose 释放内存
  @override
  void dispose() {
    super.dispose();
  }
}
