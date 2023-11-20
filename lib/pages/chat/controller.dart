import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spark_chat/common/models/chat_model.dart';
import 'package:spark_chat/common/index.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'index.dart';

class ChatController extends GetxController {
  ChatController();

  final state = ChatState();

  final messageInputController = TextEditingController();

  final messageInputFocusNode = FocusNode();

  final messageOutputController = TextEditingController();

  final messageOutputScrollController = ScrollController();

  final messageOutputFocusNode = FocusNode();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  ChatHistory chatHistory = ChatHistory.empty();

  late final typeWriter = TypeWriter(
      target: messageOutputController,
      scrollController: messageOutputScrollController,
      focusNode: messageOutputFocusNode,
      speed: 50,
      cursor: "_");

  // tap
  void handleSend() {
    HapticFeedback.mediumImpact();
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
    state.outputContent = "";
    startOutput();
  }

  /// 开始输出
  void startOutput() {
    String appId = ConfigService.ins.appIdOrLocal;
    chatHistory.addMessages([
      Message(role: 'user', content: messageInputController.text),
    ]);
    // FIXME 临时方案，后续优化
    state.chatLength = chatHistory.messages.length;
    if (state.displayAsChat) {
      messageInputController.text = "";
    }
    ChatRequest chatRequest = ChatRequest(
      appId: appId,
      domain: 'generalv3',
      uid: ConfigService.ins.userId,
      messages: chatHistory.messages,
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
          typeWriter.addText(chatResponse.header.message);
        } else if (chatResponse.payload != null) {
          String eachResponse = "";
          for (var e in chatResponse.payload!.choices.text) {
            debugPrint("Got message 📩: \n${e.content}");
            eachResponse += e.content;
          }
          typeWriter.addText(eachResponse);
          state.outputContent += eachResponse;
          if (chatResponse.payload!.usage != null) {
            debugPrint(
                "🪙 Used tokens: ${chatResponse.payload!.usage!.totalTokens}");
            state.tokenUsage += chatResponse.payload!.usage!.totalTokens;
          }
        }
      },
      onDone: () {
        debugPrint("🔌 Disconnected");
        ws.sink.close();
        chatHistory.addMessages([
          Message(role: 'assistant', content: state.outputContent),
        ]);
        // FIXME 临时方案，后续优化
        state.chatLength = chatHistory.messages.length;
        typeWriter.inputFinished();
      },
      onError: (e) {
        debugPrint("Error: $e");
        typeWriter.addText("连接服务器失败，请检查网络或 APIKey。");
      },
    );
  }

  /// 隐藏键盘
  void hideKeyboard() {
    if (FocusManager.instance.primaryFocus != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  /// 复制到剪贴板
  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: messageOutputController.text));
    HapticFeedback.mediumImpact();
  }

  /// 在 widget 内存中分配后立即调用。
  @override
  void onInit() {
    super.onInit();
    // 生成用户id
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
