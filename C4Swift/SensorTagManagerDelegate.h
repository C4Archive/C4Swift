//
//  SensorTagManagerDelegate.h
//  SensorTagTest
//
//  Created by Shing Trinh on 2015-05-27.
//  Copyright (c) 2015 SAP. All rights reserved.
//

#include "SensorTag.h"

@protocol SensorTagManagerDelegate <NSObject>

@required
- (void)bluetoothStateChanged:(BOOL)on;
- (void)didDiscoverSensorTag:(SensorTag *)sensorTag;
- (void)didConnectSensorTag:(SensorTag *)sensorTag;
- (void)didDisconnectSensorTag:(SensorTag *)sensorTag;

@optional
- (void)sensorTag:(SensorTag *)sensorTag didUpdateAmbientTemperature:(float)ambientTemperature targetTemperature:(float)targetTemperature;
- (void)sensorTag:(SensorTag *)sensorTag didUpdateHumidity:(float)humidity temperature:(float)temperature;
- (void)sensorTag:(SensorTag *)sensorTag didUpdateBarometer:(float)barometer temperature:(float)temperature;
- (void)sensorTag:(SensorTag *)sensorTag didUpdateLuxometer:(float)lux;
- (void)sensorTag:(SensorTag *)sensorTag didUpdateAccelerometer:(Point3D)accelerometer gyroscope:(Point3D)gyroscope magnetometer:(Point3D)magnetometer;
- (void)sensorTag:(SensorTag *)sensorTag didUpdateButton1:(BOOL)button1 button2:(BOOL)button2;
- (void)sensorTag:(SensorTag *)sensorTag didUpdateRSSI:(NSNumber *)rssi;
- (void)sensorTag:(SensorTag *)sensorTag didReadFirmwareRevision:(NSString *)firmware;

@end