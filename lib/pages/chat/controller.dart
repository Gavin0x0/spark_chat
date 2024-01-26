import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:fast_menu/common/models/chat_model.dart';
import 'package:fast_menu/common/index.dart';
import 'package:fast_menu/common/utils/text_type_writer_helper.dart';
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

  final chatViewScrollController = ScrollController();

  double maxScrollExtentCache = 0;

  late final inputTypeWriter = TextFieldTypeWriterHelper(
    target: messageOutputController,
    scrollController: messageOutputScrollController,
    focusNode: messageOutputFocusNode,
    speed: 50,
    cursor: "_",
  );

  late final typeWriter = TextTypeWriterHelper(
    onTextChanged: (value) {
      state.typeWriterOutput = value;
      _tryToScrollChatViewToBottom();
    },
    onFinished: (value) {
      chatHistory.addMessage(
        Message(role: 'assistant', content: value),
      );
      state.isTypeWriterRunning = false;
      // FIXME 临时方案，后续优化
      state.chatLength = chatHistory.messages.length;
    },
    speed: 50,
    cursor: "_",
  );

  // 触发发送事件
  void handleSend() {
    HapticFeedback.mediumImpact();
    hideKeyboard();
    if (inputTypeWriter.isBusy) {
      // Get.snackbar(
      //   "Error",
      //   "正在输入中，请稍后再试",
      //   snackPosition: SnackPosition.BOTTOM,
      // );
      showToast('正在输入中，请稍后再试');
      // Get.tip
      return;
    }
    inputTypeWriter.initTypeWriter();
    typeWriter.initTypeWriter();
    state.isTypeWriterRunning = true;
    state.typeWriterOutput = "";
    state.outputContent = "";
    startOutput();
  }

  /// 开始输出
  void startOutput() {
    String appId = ConfigService.ins.appIdOrLocal;
    chatHistory.addMessage(
      Message(role: 'user', content: messageInputController.text),
    );
    // FIXME 临时方案，后续优化
    state.chatLength = chatHistory.messages.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryToScrollChatViewToBottom();
    });
    if (state.displayAsChat) {
      messageInputController.text = "";
    }
    ChatRequest chatRequest = ChatRequest(
      appId: appId,
      domain: 'generalv3',
      uid: ConfigService.ins.userId,
      messages: chatHistory.nomalMessages,
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
          // print("发生报错，此时应该 setErrorFlag");
          chatHistory.setErrorFlag();
          inputTypeWriter.addText(chatResponse.header.message);
          typeWriter.addText(chatResponse.header.message);
        } else if (chatResponse.payload != null) {
          String eachResponse = "";
          for (var e in chatResponse.payload!.choices.text) {
            debugPrint("Got message 📩: \n${e.content}");
            eachResponse += e.content;
          }
          inputTypeWriter.addText(eachResponse);
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
        inputTypeWriter.inputFinished();
        typeWriter.inputFinished();
      },
      onError: (e) {
        debugPrint("Error: $e");
        inputTypeWriter.addText("连接服务器失败，请检查网络或 APIKey。");
        typeWriter.addText("连接服务器失败，请检查网络或 APIKey。");
      },
    );
  }

  /// 隐藏键盘
  void hideKeyboard() {
    if (PlatformInfo.isAppOS()) {
      if (FocusManager.instance.primaryFocus != null) {
        FocusManager.instance.primaryFocus!.unfocus();
      }
    }
  }

  /// 复制到剪贴板
  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: messageOutputController.text));
    HapticFeedback.mediumImpact();
  }

  /// 尝试滚动至底部
  void _tryToScrollChatViewToBottom() {
    if (!chatViewScrollController.hasClients) {
      return;
    }
    final double kMaxScrollExtent =
        chatViewScrollController.position.maxScrollExtent;
    if (maxScrollExtentCache < kMaxScrollExtent) {
      chatViewScrollController.animateTo(
        kMaxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    maxScrollExtentCache = kMaxScrollExtent;
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
