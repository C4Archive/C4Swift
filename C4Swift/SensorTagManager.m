//
//  SensorTagManager.m
//  SensorTagTest
//
//  Created by Shing Trinh on 2015-05-27.
//  Copyright (c) 2015 SAP. All rights reserved.
//

#import "SensorTagManager.h"

@interface SensorTagManager ()

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableArray *sensorTags;

@end

@implementation SensorTagManager

#pragma mark - Lifecycle

- (instancetype)initWithDelegate:(NSObject<SensorTagManagerDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        self.sensorTags = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)startScan {
    NSLog(@"Scanning for peripherals ...");
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopScan {
    NSLog(@"Stopped scanning for peripherals");
    [self.centralManager stopScan];
}

- (void)connectSensorTag:(SensorTag *)sensorTag {
    NSLog(@"Connecting peripheral %@ ...", sensorTag.name);
    [self.centralManager connectPeripheral:sensorTag.peripheral options:nil];
}

- (void)close {
    if (self.sensorTags != nil) {
        NSLog(@"Disconnecting all peripherals");
        for (SensorTag *sensorTag in self.sensorTags) {
            sensorTag.peripheral.delegate = nil;
            if (sensorTag.peripheral.state != CBPeripheralStateDisconnected) {
                [self.centralManager cancelPeripheralConnection:sensorTag.peripheral];
                NSLog(@"Disconnecting peripheral %@", sensorTag.peripheral.name);
            }
        }
        [self.sensorTags removeAllObjects];
        self.sensorTags = nil;
    }

    if (self.centralManager != nil) {
        NSLog(@"Destroying Core Bluetooth Central Manager");
        [self.centralManager stopScan];
        self.centralManager.delegate = nil;
        self.centralManager = nil;
    }
    
    NSLog(@"SensorTagManager closed");
}

#pragma mark - CBCentralManagerDelegate Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (self.centralManager.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"Bluetooth is powered off");
            [self.sensorTags removeAllObjects];
            if (self.delegate != nil)
                [self.delegate bluetoothStateChanged:NO];
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"Bluetooth not supported on this device");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"Bluetooth is powered on");
            if (self.delegate != nil)
                [self.delegate bluetoothStateChanged:YES];
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"Bluetooth is resetting");
            [self.sensorTags removeAllObjects];
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"Bluetooth is unsupported on this device");
            break;
        case CBCentralManagerStateUnknown:
        default:
            NSLog(@"Bluetooth is unknown");
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)rssi {

    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];

    NSLog(@"Found peripheral %@ (Name: %@, RSSI: %@dB)", peripheral.name, localName, rssi);

    // Validate peripheral information
    if (!peripheral.name || ([peripheral.name isEqualToString:@""])) {
        return;
    }
    
    if (![peripheral.name containsString:@"SensorTag"]) {
        return;
    }

    if (self.delegate != nil) {
        SensorTag *sensorTag = [self findSensorTagByPeripheral:peripheral];
        if (sensorTag == nil) {
            sensorTag = [[SensorTag alloc] initWithPeripheral:peripheral sensorTagManager:self];
            sensorTag.localName = localName;
            [self.sensorTags addObject:sensorTag];
        }
        [self.delegate didDiscoverSensorTag:sensorTag];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if (!peripheral) {
        return;
    }

    NSLog(@"Connected peripheral %@", peripheral.name);

    SensorTag *sensorTag = [self findSensorTagByPeripheral:peripheral];
    if (sensorTag != nil) {
        // Discover all the services and characteristics of those services before making callback
        NSLog(@"Discovering services for peripheral %@ ...", peripheral.name);
        [peripheral discoverServices:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect peripheral %@: %@", peripheral.name, error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (!peripheral) {
        return;
    }

    NSLog(@"Disconnected peripheral %@", peripheral.name);
    
    if (self.delegate != nil) {
        SensorTag *sensorTag = [self findSensorTagByPeripheral:peripheral];
        if (sensorTag != nil) {
            [self.delegate didDisconnectSensorTag:sensorTag];
            [self.sensorTags removeObject:sensorTag];
        }
    }
}


#pragma mark - Private Methods

- (SensorTag *)findSensorTagByPeripheral:(CBPeripheral *)peripheral {
    for (SensorTag *sensorTag in self.sensorTags) {
        if (sensorTag.peripheral == peripheral)
            return sensorTag;
    }
    return nil;
}

@end
