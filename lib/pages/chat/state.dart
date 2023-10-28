import 'package:get/get.dart';

class ChatState {
  // title
  final _title = "".obs;
  set title(value) => _title.value = value;
  get title => _title.value;

  // uid
  final _uid = "".obs;
  set uid(value) => _uid.value = value;
  get uid => _uid.value;

  // token usage
  final _tokenUsage = 0.obs;
  set tokenUsage(int value) => _tokenUsage.value = value;
  int get tokenUsage => _tokenUsage.value;
}
