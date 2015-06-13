//
//  SensorTag.h
//  SensorTagTest
//
//  Created by Shing Trinh on 2015-05-27.
//  Copyright (c) 2015 SAP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// Forward declare SensorTagManager to avoid circular reference compile errors
@class SensorTagManager;

typedef struct Point3D_ {
    float x, y, z;
} Point3D;

Point3D Point3DMake(float x, float y, float z);

@interface SensorTag : NSObject<CBPeripheralDelegate>

@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) NSString *localName;

- (id)initWithPeripheral:(CBPeripheral *)peripheral sensorTagManager:(SensorTagManager *)manager;
- (NSString *)name;

- (void)setAllEnabled:(BOOL)enabled;
- (void)setAllPeriod:(int)period;
- (void)setAllNotify:(BOOL)notify;

- (void)setTemperatureEnabled:(BOOL)enabled;
- (void)setTemperaturePeriod:(int)period;
- (void)setTemperatureNotify:(BOOL)notify;

- (void)setHumidityEnabled:(BOOL)enabled;
- (void)setHumidityPeriod:(int)period;
- (void)setHumidityNotify:(BOOL)notify;

- (void)setBarometerEnabled:(BOOL)enabled;
- (void)setBarometerPeriod:(int)period;
- (void)setBarometerNotify:(BOOL)notify;

- (void)setLuxometerEnabled:(BOOL)enabled;
- (void)setLuxometerPeriod:(int)period;
- (void)setLuxometerNotify:(BOOL)notify;

- (void)setMovementEnabled:(BOOL)enabled;
- (void)setMovementPeriod:(int)period;
- (void)setMovementNotify:(BOOL)notify;

- (void)setSimpleKeyNotify:(BOOL)notify;

- (void)setBuzzer:(BOOL)buzzer redLED:(BOOL)led1 greenLED:(BOOL)led2;

@end