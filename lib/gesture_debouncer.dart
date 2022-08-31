library gesture_debouncer;

import 'dart:async';
import 'package:flutter/material.dart';

class GestureDebouncer extends StatefulWidget {
  final Duration? cooldown;
  final Duration? cooldownAfterExecution;
  final Function(Object errorObj)? onError;
  final Widget Function(BuildContext context, Widget child)? cooldownBuilder;
  final Widget Function(
      BuildContext context, Future<void> Function()? onGesture) builder;
  final Future<void> Function() onGesture;

  /// This is the main Widget responsible for creating tap/gesture debounce.
  /// If [cooldown] and [cooldownAfterExecution] both parameters are not specified then the cooldown will the time taken by asyn function to finish.
  /// eg: [cooldown] and [cooldownAfterExecution] are null, future takes 5 seconds to finish. So in this case next click/other gesture will be available till that future finishes.
  ///
  /// If [cooldown] is specified it will be used to make next tap/click available after that time elapses.
  /// eg: [cooldown] is 3 seconds and future is taking 5 seconds to finish then the next tap/click action will be available after 3 seconds regardless of when future finishes.
  ///
  /// If [cooldownAfterExecution] is specified then the next tap/click will be available after the future finishes and [cooldownAfterExecution] is elapsed. This needs [cooldown] field to be null;
  /// eg: [cooldownAfterExecution] is 5 seconds and future takes 5 seconds to finish then the total time after the next tap/click will be available will be 5+5 seconds.
  ///
  /// [onError] callback will be triggered error occurs in future.
  ///
  /// [cooldownBuilder] will build the widget when the widget is in cooldown state.
  /// [builder] is the main builder.
  /// In [onGesture] the future should be specified which should run when the widget in [builder] is hit/pressed/tapped/double tapped.
  ///
  const GestureDebouncer({
    super.key,
    this.cooldown,
    this.cooldownAfterExecution,
    this.cooldownBuilder,
    this.onError,
    required this.builder,
    required this.onGesture,
  });

  @override
  State<GestureDebouncer> createState() => _GestureDebouncerState();
}

class _GestureDebouncerState extends State<GestureDebouncer> {
  Timer? _timer;
  ValueNotifier<bool> isFree = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    isFree.dispose();
    super.dispose();
  }

  _restartTimer(Duration duration) {
    isFree.value = false;
    _timer = Timer(duration, () {
      if (_timer?.isActive == true) {
        _timer?.cancel();
      }
      _timer = null;
      isFree.value = true;
    });
  }

  Future<void> _callFunction() async {
    try {
      await widget.onGesture.call();
      return;
    } catch (e) {
      widget.onError?.call(e);
      return;
    }
  }

  Widget get _getChild {
    return ValueListenableBuilder(
      valueListenable: isFree,
      builder: (BuildContext context, bool value, _) {
        if (value) {
          return widget.builder.call(
            context,
            () async {
              if (widget.cooldown != null) {
                _restartTimer(widget.cooldown!);
                await _callFunction();
              } else {
                isFree.value = false;
                await _callFunction();
                if (widget.cooldownAfterExecution != null) {
                  _restartTimer(widget.cooldownAfterExecution!);
                } else {
                  isFree.value = true;
                }
              }
            },
          );
        }
        if (widget.cooldownBuilder == null) {
          return widget.builder(context, null);
        } else {
          return widget.cooldownBuilder!(
              context, widget.builder(context, null));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getChild;
  }
}
