import 'dart:async';

import 'package:flutter/material.dart';

/// 打字机效果助手
class TypeWriter {
  /// 目标文本框
  final TextEditingController _target;

  /// 目标文件框滚动控制器
  final ScrollController _scrollController;

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
  Timer _typeWriterTimer = Timer(Duration.zero, () {});

  /// 等待中光标动画定时器
  Timer _cursorBlinkTimer = Timer(Duration.zero, () {});

  /// 可滚动高度缓存
  double _maxScrollExtentCache = 0;

  bool get isBusy => _status != TypeWriterStatus.finish;

  bool get _isRunning => _status == TypeWriterStatus.running;

  bool get _nothingToType => _undisplayedText.isEmpty;

  bool _gotTheLastChar = false;

  TypeWriter({
    required TextEditingController target,
    required ScrollController scrollController,
    required FocusNode focusNode,
    String cursor = "|",
    int speed = 1,
  })  : _cursor = cursor,
        _speed = speed,
        _target = target,
        _scrollController = scrollController,
        _focusNode = focusNode,
        assert(speed >= 1 && speed <= 1000, "Speed must between 1-1000");

  void initTypeWriter() {
    _gotTheLastChar = false;
    _turnToWaiting();
  }

  /// 设置文本【完整文本】
  // void setText(String text) {
  //   if (_text.isEmpty) {
  //     _text = text;
  //     _undisplayedText = text;
  //     _turnToRunning();
  //     return;
  //   }

  //   /// 将传入的text与原始text进行比较，如果存在追加更新，则添加进未输出的文本
  //   if (text.length > _text.length) {
  //     final String newTextHead = text.substring(0, _text.length);
  //     if (newTextHead == _text) {
  //       final String newText = text.substring(_text.length);
  //       _undisplayedText += newText;
  //       _turnToRunning();
  //     } else {
  //       debugPrint("原始文本发生变化++");
  //     }
  //   } else {
  //     debugPrint("原始文本发生变化--/==");
  //   }
  //   _text = text;
  // }

  /// 追加文本
  void addText(String text) {
    _text += text;
    _undisplayedText += text;
    _turnToRunning();
  }

  /// 输入完了
  void inputFinished() {
    _gotTheLastChar = true;
    if (_nothingToType) {
      _turnToFinish();
    }
  }

  /// 开始输出
  void _turnToRunning() {
    if (_isRunning) return;
    _status = TypeWriterStatus.running;
    _cursorBlinkTimer.cancel();
    _typeOneChar();
    _typeWriterTimer.cancel();
    _typeWriterTimer = Timer.periodic(
      Duration(milliseconds: (1000 / _speed).round()),
      (t) => _typeOneChar(),
    );
  }

  /// 进入等待状态
  void _turnToWaiting() {
    _status = TypeWriterStatus.waiting;
    _typeWriterTimer.cancel();
    _cursorBlink();
    _cursorBlinkTimer.cancel();
    _cursorBlinkTimer = Timer.periodic(
      Duration(milliseconds: (300).round()),
      (t) => _cursorBlink(),
    );
  }

  void _turnToFinish() {
    _typeWriterTimer.cancel();
    _cursorBlinkTimer.cancel();
    _focusNode.unfocus();
    _status = TypeWriterStatus.finish;
    _setTargetText(_text);
    _text = "";
    _displayedText = "";
    _undisplayedText = "";
    _maxScrollExtentCache = 0;
  }

  void _typeOneChar() {
    if (!_isRunning) {
      return;
    }
    final int char = _undisplayedText.runes.first;
    if (char > 65535) {
      _undisplayedText = _undisplayedText.substring(2);
    } else {
      _undisplayedText = _undisplayedText.substring(1);
    }
    _displayedText += String.fromCharCode(char);
    if (_isFocused) {
      _setTargetText(_displayedText);
    } else {
      _setTargetText(_displayedText + _cursor);
    }
    if (_nothingToType) {
      if (_gotTheLastChar) {
        _turnToFinish();
      } else {
        _turnToWaiting();
      }
    }
  }

  /// 滚动至底部
  void _scrollToBottom() {
    if (_isFocused) {
      return;
    }
    if (!_scrollController.hasClients) {
      return;
    }
    final double kMaxScrollExtent = _scrollController.position.maxScrollExtent;
    if (_maxScrollExtentCache < kMaxScrollExtent) {
      _scrollController.animateTo(
        kMaxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    _maxScrollExtentCache = kMaxScrollExtent;
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
        _scrollToBottom();
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
    try {
      _target.selection = TextSelection(
        baseOffset: baseOffset,
        extentOffset: extentOffset,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

enum TypeWriterStatus {
  waiting,
  running,
  finish,
}
