import 'package:get/get.dart';

class ChatState {
  // output str
  final _outputContent = "".obs;
  set outputContent(String value) => _outputContent.value = value;
  String get outputContent => _outputContent.value;

  // uid
  final _uid = "".obs;
  set uid(value) => _uid.value = value;
  get uid => _uid.value;

  // token usage
  final _tokenUsage = 0.obs;
  set tokenUsage(int value) => _tokenUsage.value = value;
  int get tokenUsage => _tokenUsage.value;

  // 是否显示为 Markdown
  final _displayAsMarkdown = false.obs;
  set displayAsMarkdown(bool value) => _displayAsMarkdown.value = value;
  bool get displayAsMarkdown => _displayAsMarkdown.value;
}
