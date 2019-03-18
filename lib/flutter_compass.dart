import 'dart:async';

import 'package:flutter/services.dart';

/// Specifies the compass delay.
///
/// The value is only used on Android and corresponds to the constants in the
/// SensorManager class.
enum CompassDelay {
  /// SensorManager.SENSOR_DELAY_FASTEST
  fastest,

  /// SensorManager.SENSOR_DELAY_GAME
  game,

  /// SensorManager.SENSOR_DELAY_UI
  ui,

  /// SensorManager.SENSOR_DELAY_NORMAL
  normal
}

/// [FlutterCompass] is a singleton class that provides assess to compass events
/// The heading varies from 0-360, 0 being north.
class FlutterCompass {
  static final FlutterCompass _instance = new FlutterCompass._();

  factory FlutterCompass() {
    return _instance;
  }

  FlutterCompass._();

  static const EventChannel _compassChannel =
      const EventChannel('hemanthraj/flutter_compass');

  /// Holds the current stream of compass events.
  Stream<double> _compassEvents;

  /// Holds the current delay for a [_compassEvents].
  CompassDelay _delay;

  /// Provides a [Stream] of compass events that can be listened to.
  ///
  /// A custom [delay] can be specified to change the frequency of which events
  /// are delivered. Calling this method on a existing stream instance but with
  /// a different [delay] setting than previously specified will *restart* the
  /// stream.
  static Stream<double> events({
    CompassDelay delay = CompassDelay.ui,
  }) {
    if (_instance._compassEvents == null || _instance._delay != delay) {
      _instance._delay = delay;
      _instance._compassEvents = _compassChannel.receiveBroadcastStream({
        'delay': delay.index,
      }).map<double>((s) => s);
    }

    return _instance._compassEvents;
  }
}
