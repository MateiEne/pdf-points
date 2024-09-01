import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

extension SafeSetState on State {
  void safeSetState(VoidCallback fn) {
    void callSetState() {
      // Can only call setState if mounted
      if (mounted) {
        // ignore: invalid_use_of_protected_member
        setState(fn);
      }
    }

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      // Currently building, can't call setState -- need to add post-frame callback
      SchedulerBinding.instance.addPostFrameCallback((_) => callSetState());
    } else {
      callSetState();
    }
  }
}
