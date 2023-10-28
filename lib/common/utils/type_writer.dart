import 'dart:async';

import 'package:flutter/material.dart';

/// 打字机效果助手
class TypeWriter {
  /// 目标文本框
  final TextEditingController _target;

  /// 目标文件框焦点
  final FocusNode _focusNode;

  /// 打字速度 1-1000
  final int _speed;

  /// 光标字符
  final String _cursor;

  /// 当前文本框是否被聚焦
  bool get _isFocused => _focusNode.hasFocus;

  /// 当前是否存在选择区域
  bool get _hasSelection =>
      _target.selection.baseOffset != _target.selection.extentOffset;

  /// 当前打字机状态
  TypeWriterStatus _status = TypeWriterStatus.finish;

  /// 原始文本
  String _text = "";

  /// 已经上屏的文本
  String _displayedText = "";

  /// 未输出的文本
  String _undisplayedText = "";

  /// 文字动画定时器
  Timer _textTimer = Timer(Duration.zero, () {});

  /// 等待中光标动画定时器
  Timer _cursorTimer = Timer(Duration.zero, () {});

  bool get _isTyping => _status == TypeWriterStatus.running;

  bool get _nothingToType => _undisplayedText.isEmpty;

  TypeWriter({
    required TextEditingController target,
    required FocusNode focusNode,
    String cursor = "|",
    int speed = 1,
  })  : _cursor = cursor,
        _speed = speed,
        _target = target,
        _focusNode = focusNode,
        assert(speed >= 1 && speed <= 1000, "Speed must between 1-1000");

  /// 设置文本
  /// TODO 关于自动变速，当检测到输入词汇迅速累加的时候，可以适当自动调节输出速度，检测到剩余字符不再增加时，恢复预设速度
  void setText(String text) {
    if (_text.isEmpty) {
      _text = text;
      _undisplayedText = text;
      _startType();
      return;
    }

    /// 将传入的text与原始text进行比较，如果存在追加更新，则添加进未输出的文本
    if (text.length > _text.length) {
      final String newTextHead = text.substring(0, _text.length);
      if (newTextHead == _text) {
        final String newText = text.substring(_text.length);
        _undisplayedText += newText;
        _startType();
      } else {
        debugPrint("原始文本发生变化++");
      }
    } else {
      debugPrint("原始文本发生变化--/==");
    }
    _text = text;
  }

  /// 结束
  /// FIXME 结束不是立即结束，而是等剩余的文本输出完毕后结束
  void finish() {
    _textTimer.cancel();
    _cursorTimer.cancel();
    _focusNode.unfocus();
    _status = TypeWriterStatus.finish;
    _setTargetText(_text);
    _text = "";
    _displayedText = "";
    _undisplayedText = "";
  }

  /// 开始输出
  void _startType() {
    if (_isTyping) return;
    _status = TypeWriterStatus.running;
    _cursorTimer.cancel();
    _displayTextPerDuration();
    _textTimer = Timer.periodic(
      Duration(milliseconds: (1000 / _speed).round()),
      (t) => _displayTextPerDuration(),
    );
  }

  /// 停止输出（进入等待状态）
  void _stopType() {
    _status = TypeWriterStatus.waiting;
    _textTimer.cancel();
    _cursorBlink();
    _cursorTimer = Timer.periodic(
      Duration(milliseconds: (300).round()),
      (t) => _cursorBlink(),
    );
  }

  void _displayTextPerDuration() {
    // debugPrint("displayTextPerDuration tick : ${t.tick}");
    // 取出未输入的第一个字符，插入至已输入的最后
    final String char = _undisplayedText.substring(0, 1);
    _undisplayedText = _undisplayedText.substring(1);
    _displayedText += char;
    if (_isFocused) {
      _setTargetText(_displayedText);
    } else {
      _setTargetText(_displayedText + _cursor);
    }
    if (_nothingToType) {
      _stopType();
      _setTargetText(_displayedText);
    }
  }

  // 闪烁光标
  void _cursorBlink() {
    if (_isFocused && !_hasSelection) {
      return;
    }
    if (_target.text.endsWith(_cursor)) {
      _setTargetText(_displayedText);
    } else {
      _setTargetText(_displayedText + _cursor);
    }
  }

  void _setTargetText(String text) {
    if (_hasSelection) {
      MapEntry<int, int> selectionPos;
      selectionPos = _saveSelection();
      _target.text = text;
      // 还原选中区域
      _restoreSelection(selectionPos.key, selectionPos.value);
    } else {
      if (_isFocused) {
        _target.value = TextEditingValue(
          text: text,
          selection: TextSelection.fromPosition(
            TextPosition(offset: text.length),
          ),
        );
      } else {
        _target.text = text;
      }
    }
  }

  /// 缓存选中的区域
  MapEntry<int, int> _saveSelection() {
    return MapEntry(
        _target.selection.baseOffset, _target.selection.extentOffset);
  }

  /// 选中区域保持不变
  void _restoreSelection(int baseOffset, int extentOffset) {
    _target.selection = TextSelection(
      baseOffset: baseOffset,
      extentOffset: extentOffset,
    );
  }
}

enum TypeWriterStatus {
  waiting,
  running,
  finish,
}
