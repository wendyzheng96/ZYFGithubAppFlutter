import 'package:event_bus/event_bus.dart';

/// event
/// Create by zyf
/// Date: 2019/7/23

EventBus eventBus = EventBus();

class HttpErrorEvent {
  final int code;

  final String message;

  HttpErrorEvent(this.code, this.message);
}