//
//  SensorTagManager.h
//  SensorTagTest
//
//  Created by Shing Trinh on 2015-05-27.
//  Copyright (c) 2015 SAP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SensorTagManagerDelegate.h"

@interface SensorTagManager : NSObject<CBCentralManagerDelegate>

@property (weak, nonatomic) NSObject<SensorTagManagerDelegate> *delegate;

- (instancetype)initWithDelegate:(NSObject<SensorTagManagerDelegate> *)delegate;
- (void)startScan;
- (void)stopScan;
- (void)connectSensorTag:(SensorTag *)sensorTag;
- (void)close;

@end
