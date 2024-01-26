import 'package:fast_menu/common/index.dart';

class ChatHistory {
  final String name;
  final DateTime createTime;
  final List<Message> messages;

  ChatHistory({
    required this.name,
    required this.createTime,
    required this.messages,
  });

  /// 空构造函数
  ChatHistory.empty()
      : name = '',
        createTime = DateTime.now(),
        messages = [];

  bool get isEmpty => messages.isEmpty;

  bool kAnswerIsError = false;

  void addMessages(List<Message> newMessages) {
    messages.addAll(newMessages);
  }

  void addMessage(Message message) {
    if (kAnswerIsError) {
      message.setError();
      kAnswerIsError = false;
    }
    messages.add(message);
  }

  /// 将当前消息以及下一条回答标记为 error
  void setErrorFlag() {
    messages.last.setError();
    kAnswerIsError = true;
  }

  void countTokens() {
    int tokens = 0;
    for (var message in messages) {
      tokens += message.content.length;
    }
    Log.i('tokens: $tokens');
  }

  // 获取正常消息
  List<Message> get nomalMessages => messages
      .where((element) => element.status == MessageStatus.normal)
      .toList();
}

class ChatRequest {
  final String appId;
  final String uid; // 最大长度32	每个用户的id，用于区分不同用户
  final String domain; // 取值为[general,generalv2,generalv3]
  final double temperature; // 取值为[0,1],默认为0.5
  final int
      maxTokens; // V1.5取值为[1,4096]，V2.0取值为[1,8192]。默认为2048，模型回答的tokens的最大长度
  final List<Message> messages;

  ChatRequest({
    required this.appId,
    this.uid = 'guest',
    required this.domain,
    this.temperature = 0.5,
    this.maxTokens = 2048,
    required this.messages,
  });

  /// 转换为 json
  Map<String, dynamic> toJson() {
    return {
      'header': {
        'app_id': appId,
        'uid': uid,
      },
      'parameter': {
        'chat': {
          'domain': domain,
          'temperature': temperature,
          'max_tokens': maxTokens,
        }
      },
      'payload': {
        'message': {
          'text': messages
              .map((e) => {
                    'role': e.role,
                    'content': e.content,
                  })
              .toList(),
        }
      }
    };
  }
}

class Message {
  final String role; // 取值为 [user,assistant]
  final String content; // 所有content的累计tokens需控制8192以内
  MessageStatus status;

  void setError() {
    status = MessageStatus.error;
  }

  Message({
    required this.role,
    required this.content,
    this.status = MessageStatus.normal,
  })  : assert(content.length <= 8192),
        assert(role == 'user' || role == 'assistant',
            'role 取值必须为 [user,assistant]');
}

// 消息状态：正常、异常
enum MessageStatus {
  normal,
  error,
}

class ChatResponse {
  final ChatResponseHeader header; // 错误码，0表示正常，非0表示出错；详细释义可在接口说明文档最后的错误码说明了解
  final ChatResponsePayload? payload;

  ChatResponse({
    required this.header,
    required this.payload,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    ChatResponsePayload? payload;
    if (json['payload'] != null) {
      payload = ChatResponsePayload.fromJson(json['payload']);
    }
    return ChatResponse(
      header: ChatResponseHeader.fromJson(json['header']),
      payload: payload,
    );
  }
}

class ChatResponseHeader {
  final int code; // 错误码，0表示正常，非0表示出错；详细释义可在接口说明文档最后的错误码说明了解
  final String message; // 会话是否成功的描述信息
  final String sid; // 会话的唯一id，用于讯飞技术人员查询服务端会话日志使用,出现调用错误时建议留存该字段
  final int status; // 会话状态，取值为[0,1,2]；0代表首次结果；1代表中间结果；2代表最后一个结果

  ChatResponseHeader({
    required this.code,
    required this.message,
    required this.sid,
    required this.status,
  });

  factory ChatResponseHeader.fromJson(Map<String, dynamic> json) {
    return ChatResponseHeader(
      code: json['code'],
      message: json['message'],
      sid: json['sid'],
      status: json['status'],
    );
  }
}

class ChatResponsePayload {
  final Choices choices;
  final Usage? usage;

  ChatResponsePayload({
    required this.choices,
    required this.usage,
  });

  factory ChatResponsePayload.fromJson(Map<String, dynamic> json) {
    Usage? usage;
    if (json['usage'] != null) {
      usage = Usage.fromJson(json['usage']);
    }
    return ChatResponsePayload(
      choices: Choices.fromJson(json['choices']),
      usage: usage,
    );
  }
}

class Choices {
  final int status; // 文本响应状态，取值为[0,1,2]; 0代表首个文本结果；1代表中间文本结果；2代表最后一个文本结果
  final int seq; // 返回的数据序号，取值为[0,9999999]
  final List<TextModel> text; // AI的回答内容
  Choices({
    required this.status,
    required this.seq,
    required this.text,
  });

  factory Choices.fromJson(Map<String, dynamic> json) {
    return Choices(
      status: json['status'],
      seq: json['seq'],
      text: (json['text'] as List<dynamic>)
          .map((e) => TextModel.fromJson(e))
          .toList(),
    );
  }
}

class TextModel {
  final String content; // AI的回答内容
  final String role; // 角色标识，固定为assistant，标识角色为AI
  final int index; // 结果序号，取值为[0,10]; 当前为保留字段，开发者可忽略

  TextModel({
    required this.content,
    required this.role,
    required this.index,
  });

  factory TextModel.fromJson(Map<String, dynamic> json) {
    return TextModel(
      content: json['content'],
      role: json['role'],
      index: json['index'],
    );
  }
}

class Usage {
  final int questionTokens; // 保留字段，可忽略
  final int promptTokens; // 包含历史问题的总tokens大小
  final int completionTokens; // 回答的tokens大小
  final int totalTokens; // prompt_tokens和completion_tokens的和，也是本次交互计费的tokens大小

  Usage({
    required this.questionTokens,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      questionTokens: json['text']['question_tokens'],
      promptTokens: json['text']['prompt_tokens'],
      completionTokens: json['text']['completion_tokens'],
      totalTokens: json['text']['total_tokens'],
    );
  }
}
