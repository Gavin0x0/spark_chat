import 'package:get/get.dart';

class ChatState {
  // output str
  final _outputContent = "".obs;
  set outputContent(String value) => _outputContent.value = value;
  String get outputContent => _outputContent.value;

  // token usage
  final _tokenUsage = 0.obs;
  set tokenUsage(int value) => _tokenUsage.value = value;
  int get tokenUsage => _tokenUsage.value;

  // 是否显示为 Markdown
  final _displayAsMarkdown = false.obs;
  set displayAsMarkdown(bool value) => _displayAsMarkdown.value = value;
  bool get displayAsMarkdown => _displayAsMarkdown.value;

  // 是否使用连续对话视图
  final _displayAsChat = true.obs;
  set displayAsChat(bool value) => _displayAsChat.value = value;
  bool get displayAsChat => _displayAsChat.value;

  // 连续对话长度 [用于简单控制对话UI刷新]
  final _chatLength = 0.obs;
  set chatLength(int value) => _chatLength.value = value;
  int get chatLength => _chatLength.value;

  // 抽屉是否打开
  final _isDrawerOpening = false.obs;
  set isDrawerOpening(bool value) => _isDrawerOpening.value = value;
  bool get isDrawerOpening => _isDrawerOpening.value;
}
