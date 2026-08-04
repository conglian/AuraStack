import 'package:flutter/animation.dart';

class ASAnima {
  late final AnimationController controller;
  late final Animation<double> animation;

  ASAnima({
    required TickerProvider vsync,
    double begin = 0,
    double end = 1,
    Curve curve = Curves.linear,
    Duration? duration,
    Function(double)? valueCall,
    Function()? completedCall,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    animation = Tween<double>(
      begin: begin,
      end: end,
    ).chain(CurveTween(curve: curve)).animate(controller);

    controller.addListener(() {
      valueCall?.call(getValue());
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        completedCall?.call();
      }
    });
  }

  double getValue() => animation.value;

  setDuration(Duration duration) {
    controller.duration = duration;
    controller.stop();
  }

  stop() {
    controller.stop();
  }

  Future forward([double from = 0]) => controller.forward(from: from);

  repeat([bool reverse = false]) => controller.repeat(reverse: reverse);

  reset() => controller.reset();

  dispose() {
    controller.dispose();
  }
}
