package com.hemanthraj.fluttercompass;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;


import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public final class FlutterCompassPlugin implements StreamHandler {
    private double currentAzimuth;
    private double newAzimuth;
    private double filter;
    private SensorEventListener sensorEventListener;

    private final SensorManager sensorManager;
    private final Sensor sensor;
    private final float[] orientation;
    private final float[] rMat;

    public static void registerWith(Registrar registrar) {
        EventChannel channel = new EventChannel(registrar.messenger(), "hemanthraj/flutter_compass");
        channel.setStreamHandler(new FlutterCompassPlugin(registrar.context(), Sensor.TYPE_ROTATION_VECTOR));
    }


    public void onListen(Object arguments, EventSink events) {
        @SuppressWarnings("unchecked") final Map<String, Object> argumentMap = (Map<String, Object>) arguments;

        int sensorDelay = mapSensorDelay(argumentMap.get("delay"));

        sensorEventListener = createSensorEventListener(events);
        sensorManager.registerListener(sensorEventListener, this.sensor, sensorDelay);
    }

    public void onCancel(Object arguments) {
        this.sensorManager.unregisterListener(this.sensorEventListener);
    }

    private SensorEventListener createSensorEventListener(final EventSink events) {
        return new SensorEventListener() {
            public void onAccuracyChanged(Sensor sensor, int accuracy) {
            }

            public void onSensorChanged(SensorEvent event) {
                SensorManager.getRotationMatrixFromVector(rMat, event.values);
                newAzimuth = ((Math.toDegrees((double) SensorManager.getOrientation(rMat, orientation)[0]) + (double) 360) % (double) 360 - Math.toDegrees((double) SensorManager.getOrientation(rMat, orientation)[2]) + (double) 360) % (double) 360;
                if (Math.abs(currentAzimuth - newAzimuth) >= filter) {
                    currentAzimuth = newAzimuth;
                    events.success(newAzimuth);
                }
            }
        };
    }

    private FlutterCompassPlugin(Context context, int sensorType) {
        filter = 1.0F;

        sensorManager = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
        orientation = new float[3];
        rMat = new float[9];
        sensor = this.sensorManager.getDefaultSensor(sensorType);
    }

    private int mapSensorDelay(Object delay) {
        if (!(delay instanceof Integer)) {
            return SensorManager.SENSOR_DELAY_UI;
        }

        switch ((Integer) delay) {
            case 0:
                return SensorManager.SENSOR_DELAY_FASTEST;
            case 1:
                return SensorManager.SENSOR_DELAY_GAME;
            case 2:
                return SensorManager.SENSOR_DELAY_UI;
            case 3:
            default:
                return SensorManager.SENSOR_DELAY_NORMAL;
        }
    }
}
