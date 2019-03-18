import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _direction;
  StreamSubscription<double> _compassSubscription;
  CompassDelay _delay = CompassDelay.normal;

  @override
  void initState() {
    super.initState();

    _initSubscription(_delay);
  }

  @override
  void dispose() {
    super.dispose();

    _compassSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Flutter Compass'),
              Text(
                'Delay: $_delay',
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .apply(color: Colors.white),
              ),
            ],
          ),
          actions: <Widget>[
            Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(_delayIcon()),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Delay'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: CompassDelay.values.map((cd) {
                              return ListTile(
                                title: Text('$cd'),
                                onTap: () {
                                  _initSubscription(cd);
                                  Navigator.pop(context);
                                },
                              );
                            }).toList(),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: new Container(
          alignment: Alignment.center,
          color: Colors.white,
          child: new Transform.rotate(
            angle: ((_direction ?? 0) * (math.pi / 180) * -1),
            child: new Image.asset('assets/compass.jpg'),
          ),
        ),
      ),
    );
  }

  void _initSubscription(CompassDelay delay) {
    _compassSubscription =
        FlutterCompass.events(delay: delay).listen((double direction) {
      setState(() {
        _direction = direction;
      });
    });

    setState(() {
      _delay = delay;
    });
  }

  IconData _delayIcon() {
    switch (_delay) {
      case CompassDelay.fastest:
        return Icons.filter_1;
      case CompassDelay.game:
        return Icons.filter_2;
      case CompassDelay.ui:
        return Icons.filter_3;
      case CompassDelay.normal:
      default:
        return Icons.filter_4;
    }
  }
}
