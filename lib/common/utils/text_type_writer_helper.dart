import 'dart:async';

import 'package:flutter/material.dart';

import 'index.dart';

/// 普通文本打字机效果助手
class TextTypeWriterHelper {
  /// 打字速度 1-1000
  final int _speed;

  /// 光标字符
  final String _cursor;

  /// 显示输入光标
  bool _isShowCursor = true;

  /// 文本变化回调
  final ValueChanged<String>? _onTextChanged;

  /// 输出结束事件
  final ValueChanged<String>? _onFinished;

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

  bool get isBusy => _status != TypeWriterStatus.finish;

  bool get _isRunning => _status == TypeWriterStatus.running;

  bool get _nothingToType => _undisplayedText.isEmpty;

  bool _gotTheLastChar = false;

  TextTypeWriterHelper({
    required ValueChanged<String>? onTextChanged,
    required ValueChanged<String>? onFinished,
    String cursor = "|",
    int speed = 1,
  })  : _cursor = cursor,
        _speed = speed,
        _onTextChanged = onTextChanged,
        _onFinished = onFinished,
        assert(speed >= 1 && speed <= 1000, "Speed must between 1-1000");

  void initTypeWriter() {
    _gotTheLastChar = false;
    _turnToWaiting();
  }

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
    _onFinished?.call(_text);
    _typeWriterTimer.cancel();
    _cursorBlinkTimer.cancel();
    if (PlatformInfo.isAppOS()) {
      if (FocusManager.instance.primaryFocus != null) {
        FocusManager.instance.primaryFocus!.unfocus();
      }
    }
    _status = TypeWriterStatus.finish;
    _setTargetText(_text);
    _text = "";
    _displayedText = "";
    _undisplayedText = "";
  }

  void _typeOneChar() {
    if (!_isRunning) {
      return;
    }
    if (_undisplayedText.runes.isNotEmpty) {
      final int char = _undisplayedText.runes.first;
      if (char > 65535) {
        _undisplayedText = _undisplayedText.substring(2);
      } else {
        _undisplayedText = _undisplayedText.substring(1);
      }
      _displayedText += String.fromCharCode(char);
    }
    if (_isShowCursor) {
      _setTargetText(_displayedText + _cursor);
    } else {
      _setTargetText(_displayedText);
    }
    if (_nothingToType) {
      if (_gotTheLastChar) {
        _turnToFinish();
      } else {
        _turnToWaiting();
      }
    }
  }

  // 闪烁光标
  void _cursorBlink() {
    if (_isShowCursor) {
      _isShowCursor = false;
      _setTargetText(_displayedText);
    } else {
      _isShowCursor = true;
      _setTargetText(_displayedText + _cursor);
    }
  }

  void _setTargetText(String text) {
    _onTextChanged?.call(text);
  }
}

enum TypeWriterStatus {
  waiting,
  running,
  finish,
}
