//
//  SensorTag.m
//  SensorTagTest
//
//  Created by Shing Trinh on 2015-05-27.
//  Copyright (c) 2015 SAP. All rights reserved.
//

#import "SensorTag.h"
#import "SensorTagManager.h"
#import "SensorTagGATT.h"
#import "NSData+Convert.h"

// Time interval between requesting RSSI (in seconds)
#define RSSI_UPDATE_INTERVAL 1.0

// Comment out this line to not log the reading
//#define LOG_READINGS


Point3D Point3DMake(float x, float y, float z){
    Point3D p;
    p.x = x; p.y = y; p.z = z;
    return p;
}

// TODO - Kill the RSSI timer when device disconnects

@interface SensorTag ()
@property (weak, nonatomic) SensorTagManager *manager;
@property (strong, nonatomic) NSTimer *rssiTimer;
@end

@implementation SensorTag

- (id)initWithPeripheral:(CBPeripheral *)peripheral sensorTagManager:(SensorTagManager *)manager {
    self = [super init];
    if (self) {
        self.peripheral = peripheral;
        self.manager = manager;
        self.peripheral.delegate = self;
        self.rssiTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:peripheral selector:@selector(readRSSI) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark - Public Methods

- (NSString *)name {
    return _peripheral.name;
}

- (void)setAllEnabled:(BOOL)enabled
{
    [self setTemperatureEnabled:enabled];
    [self setHumidityEnabled:enabled];
    [self setBarometerEnabled:enabled];
    [self setLuxometerEnabled:enabled];
    [self setMovementEnabled:enabled];
}

- (void)setAllPeriod:(int)period
{
    [self setTemperaturePeriod:period];
    [self setHumidityPeriod:period];
    [self setBarometerPeriod:period];
    [self setLuxometerPeriod:period];
    [self setMovementPeriod:period];
}

- (void)setAllNotify:(BOOL)notify
{
    [self setTemperatureNotify:notify];
    [self setHumidityNotify:notify];
    [self setBarometerNotify:notify];
    [self setLuxometerNotify:notify];
    [self setMovementNotify:notify];
    [self setSimpleKeyNotify:notify];
}

- (void)setTemperatureEnabled:(BOOL)enabled {
    unsigned char enableCode = enabled ? 1 : 0;
    [self writeCharacteristic:TEMPERATURE_CONFIG_CHARACTERISTIC service:TEMPERATURE_SERVICE byte:enableCode];
}

- (void)setTemperaturePeriod:(int)period {
    [self setPeriod:period characteristic:TEMPERATURE_PERIOD_CHARACTERISTIC service:TEMPERATURE_SERVICE];
}

- (void)setTemperatureNotify:(BOOL)notify
{
    [self setNotify:(BOOL)notify characteristic:TEMPERATURE_DATA_CHARACTERISTIC service:TEMPERATURE_SERVICE];
}

- (void)setHumidityEnabled:(BOOL)enabled {
    unsigned char enableCode = enabled ? 1 : 0;
    [self writeCharacteristic:HUMIDITY_CONFIG_CHARACTERISTIC service:HUMIDITY_SERVICE byte:enableCode];
}

- (void)setHumidityPeriod:(int)period {
    [self setPeriod:period characteristic:HUMIDITY_PERIOD_CHARACTERISTIC service:HUMIDITY_SERVICE];
}

- (void)setHumidityNotify:(BOOL)notify
{
    [self setNotify:(BOOL)notify characteristic:HUMIDITY_DATA_CHARACTERISTIC service:HUMIDITY_SERVICE];
}

- (void)setBarometerEnabled:(BOOL)enabled {
    unsigned char enableCode = enabled ? 1 : 0;
    [self writeCharacteristic:BAROMETER_CONFIG_CHARACTERISTIC service:BAROMETER_SERVICE byte:enableCode];
}

- (void)setBarometerPeriod:(int)period {
    [self setPeriod:period characteristic:BAROMETER_PERIOD_CHARACTERISTIC service:BAROMETER_SERVICE];
}

- (void)setBarometerNotify:(BOOL)notify
{
    [self setNotify:(BOOL)notify characteristic:BAROMETER_DATA_CHARACTERISTIC service:BAROMETER_SERVICE];
}

- (void)setLuxometerEnabled:(BOOL)enabled {
    unsigned char enableCode = enabled ? 1 : 0;
    [self writeCharacteristic:LUXOMETER_CONFIG_CHARACTERISTIC service:LUXOMETER_SERVICE byte:enableCode];
}

- (void)setLuxometerPeriod:(int)period {
    [self setPeriod:period characteristic:LUXOMETER_PERIOD_CHARACTERISTIC service:LUXOMETER_SERVICE];
}

- (void)setLuxometerNotify:(BOOL)notify
{
    [self setNotify:(BOOL)notify characteristic:LUXOMETER_DATA_CHARACTERISTIC service:LUXOMETER_SERVICE];
}

- (void)setMovementEnabled:(BOOL)enabled {
    // Set accelerometer configuration to ON.
    // magnetometer on: 64 (1000000) (seems to not work in ST2 FW 0.89)
    // 3-axis acc. on: 56 (0111000)
    // 3-axis gyro on: 7 (0000111)
    // 3-axis acc. + 3-axis gyro on: 63 (0111111)
    // 3-axis acc. + 3-axis gyro + magnetometer on: 127 (1111111)
    unsigned char enableCode = enabled ? 56 : 0;
    unsigned char data[2];
    data[0] = enableCode;
    data[1] = 0;
    [self writeCharacteristic:MOVEMENT_CONFIG_CHARACTERISTIC service:MOVEMENT_SERVICE bytes:data length:2];
}

- (void)setMovementPeriod:(int)period {
    [self setPeriod:period characteristic:MOVEMENT_PERIOD_CHARACTERISTIC service:MOVEMENT_SERVICE];
}

- (void)setMovementNotify:(BOOL)notify
{
    [self setNotify:(BOOL)notify characteristic:MOVEMENT_DATA_CHARACTERISTIC service:MOVEMENT_SERVICE];
}

- (void)setSimpleKeyNotify:(BOOL)notify
{
    [self setNotify:(BOOL)notify characteristic:SIMPLE_KEY_DATA_CHARACTERISTIC service:SIMPLE_KEY_SERVICE];
}

- (void)setBuzzer:(BOOL)buzzer redLED:(BOOL)led1 greenLED:(BOOL)led2 {
    unsigned char data = 0;
    if (buzzer)
        data |= IO_DATA_BUZZER;
    if (led1)
        data |= IO_DATA_LED1;
    if (led2)
        data |= IO_DATA_LED2;
    
    // TODO - The mode only needs to be set once
    [self writeCharacteristic:IO_CONFIG_CHARACTERISTIC service:IO_SERVICE byte:IO_MODE_REMOTE];
    [self writeCharacteristic:IO_DATA_CHARACTERISTIC service:IO_SERVICE byte:data];
}

#pragma mark - CBPeripheralDelegate Methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (peripheral != self.peripheral) {
        NSLog(@"Wrong peripheral");
        return;
    }
    
    if (error != nil) {
        NSLog(@"Error discovering peripheral services: %@", error);
        return;
    }
    
    if (peripheral.services == nil || peripheral.services.count == 0) {
        NSLog(@"No services found for peripheral");
        return;
    }
    
    NSLog(@"Discovered services for peripheral %@:", peripheral.name);
        for (CBService *service in peripheral.services) {
            NSLog(@"  %@", service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
    }

    // Send the didConnect event to listeners after we've connected and discovered all services and characteristics
    if (self.manager.delegate != nil) {
        [self waitForDiscoverCharacteristics:^{
            [self.manager.delegate didConnectSensorTag:self];
        }];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (peripheral != self.peripheral) {
        NSLog(@"Wrong peripheral");
        return;
    }
    
    if (error != nil) {
        NSLog(@"Error discovering peripheral service characteristics: %@", error);
        return;
    }

    NSLog(@"Discovered characteristics for service %@:", service.UUID);
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"  %@", characteristic.UUID);
        //[self.peripheral discoverDescriptorsForCharacteristic:characteristic];
        if ([service.UUID isEqual:DEVICE_INFO_SERVICE]) {
            [self.peripheral readValueForCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error != nil) {
        NSLog(@"Error discovering descriptors for characteristic %@: %@", characteristic.UUID, error);
        return;
    }
    
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        [self.peripheral readValueForDescriptor:descriptor];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if (error != nil) {
        NSLog(@"Error reading value for descriptor %@: %@", descriptor.UUID, error);
        return;
    }

    NSLog(@"Characteristic %@: %@ = %@", descriptor.characteristic.UUID, descriptor.UUID, descriptor.value);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error != nil) {
        NSLog(@"Failed to write value for characteristic %@: %@", characteristic.UUID, error);
    }
    else {
        NSLog(@"Successfully wrote value for characteristic %@", characteristic.UUID);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error == nil)
        NSLog(@"Successfully set notify to %@ for characteristic %@", characteristic.isNotifying ? @"on" : @"off", characteristic.UUID);
    else
        NSLog(@"Failed to set notify for characteristic %@: %@", characteristic.UUID, error);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error getting update for characteristic %@: %@", characteristic.UUID, error);
        return;
    }
    
    if (characteristic.value == nil) {
        NSLog(@"Characteristic %@ value is nil", characteristic.UUID);
        return;
    }

    [self processCharacteristicValue:characteristic];
}

// Note: There is currently a bug in iOS where in some cases this callback is never called. You need to Bluetooth off and on.
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    if (error != nil) {
        NSLog(@"Failed to get RSSI value for peripheral %@: %@", peripheral.name, error);
        return;
    }

#ifdef LOG_READINGS
    NSLog(@"Peripheral %@ RSSI is %@ dB", peripheral.name, RSSI);
#endif
    
    NSObject<SensorTagManagerDelegate> *delegate = self.manager.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(sensorTag:didUpdateRSSI:)]) {
        [delegate sensorTag:self didUpdateRSSI:RSSI];
    }
}

#pragma mark - Sensor Read Methods

- (void)processCharacteristicValue:(CBCharacteristic *)characteristic
{
    if ([characteristic.UUID isEqual:TEMPERATURE_DATA_CHARACTERISTIC]) {
        [self processTemperatureValue:characteristic.value];
    }
    else if ([characteristic.UUID isEqual:HUMIDITY_DATA_CHARACTERISTIC]) {
        [self processHumidityValue:characteristic.value];
    }
    else if ([characteristic.UUID isEqual:BAROMETER_DATA_CHARACTERISTIC]) {
        [self processBarometerValue:characteristic.value];
    }
    else if ([characteristic.UUID isEqual:LUXOMETER_DATA_CHARACTERISTIC]) {
        [self processLuxometerValue:characteristic.value];
    }
    else if ([characteristic.UUID isEqual:MOVEMENT_DATA_CHARACTERISTIC]) {
        [self processMovementValue:characteristic.value];
    }
    else if ([characteristic.UUID isEqual:SIMPLE_KEY_DATA_CHARACTERISTIC]) {
        [self processSimpleKeyValue:characteristic.value];
    }
    else if ([characteristic.UUID isEqual:FIRMWARE_REVISION_CHARACTERISTIC]) {
        NSString *firmware = [NSString stringWithUTF8String:characteristic.value.bytes];
        NSObject<SensorTagManagerDelegate> *delegate = self.manager.delegate;
        if (delegate != nil && [delegate respondsToSelector:@selector(sensorTag:didReadFirmwareRevision:)]) {
            [delegate sensorTag:self didReadFirmwareRevision:firmware];
        }
    }
    else {
        if ([characteristic.UUID.description hasSuffix:@" String"])
            NSLog(@"%@: %@", characteristic.UUID, [NSString stringWithUTF8String:characteristic.value.bytes]);
        else
            NSLog(@"%@: %@", characteristic.UUID, characteristic.value.hexString);
        //NSLog(@"No supported sensor for service %@", characteristic.service.UUID);
    }
}

- (void)processTemperatureValue:(NSData *)value
{
    if (value.length != 4) {
        NSLog(@"Invalid length for temperature reading: %lu", (unsigned long)value.length);
        return;
    }
    
    float ambientTemperature = [self extractUnsignedShort:value offset:2] / 128.0;
    float targetTemperature = [self extractSignedShort:value offset:0] / 128.0;
    
#ifdef LOG_READINGS
    NSLog(@"Temperature: %.1f °C (ambient), %.1f °C (target)", ambientTemperature, targetTemperature);
#endif
    
    NSObject<SensorTagManagerDelegate> *delegate = self.manager.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(sensorTag:didUpdateAmbientTemperature:targetTemperature:)]) {
        [delegate sensorTag:self didUpdateAmbientTemperature:ambientTemperature targetTemperature:targetTemperature];
    }
}

- (void)processHumidityValue:(NSData *)value
{
    if (value.length != 4) {
        NSLog(@"Invalid length for humidity reading: %lu", (unsigned long)value.length);
        return;
    }

    // Calculate the humidity temperature (Celsius).
    int rawTemperature = [self extractUnsignedShort:value offset:0];
    float temperature = -40 + ((165 * rawTemperature) / 65536.0);

    // Calculate the relative humidity
    float relativeHumidity = [self extractUnsignedShort:value offset:2] * 100.0 / 65536.0;
    
#ifdef LOG_READINGS
    NSLog(@"Humidity: %.1f%% (%.1f °C)", relativeHumidity, temperature);
#endif
    
    NSObject<SensorTagManagerDelegate> *delegate = self.manager.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(sensorTag:didUpdateHumidity:temperature:)]) {
        [delegate sensorTag:self didUpdateHumidity:relativeHumidity temperature:temperature];
    }
}

- (void)processBarometerValue:(NSData *)value
{
    if (value.length != 6) {
        NSLog(@"Invalid length for barometer reading: %lu", (unsigned long)value.length);
        return;
    }
    
    float temperature = [self extractUnsignedInt:value offset:0 length:3] / 100.0;
    
    float barometer = [self extractUnsignedInt:value offset:3 length:3];
    
#ifdef LOG_READINGS
    NSLog(@"Barometer: %.0f Pa (%.1f °C)", barometer, temperature);
#endif
    
    NSObject<SensorTagManagerDelegate> *delegate = self.manager.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(sensorTag:didUpdateBarometer:temperature:)]) {
        [delegate sensorTag:self didUpdateBarometer:barometer temperature:temperature];
    }
}

- (void)processLuxometerValue:(NSData *)value
{
    if (value.length != 2) {
        NSLog(@"Invalid length for luxometer reading: %lu", (unsigned long)value.length);
        return;
    }
    
    float lux = [self extractFloat:value offset:0] / 100.0;
    
#ifdef LOG_READINGS
    NSLog(@"Light: %.0f Lux", lux);
#endif
    
    NSObject<SensorTagManagerDelegate> *delegate = self.manager.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(sensorTag:didUpdateLuxometer:)]) {
        [delegate sensorTag:self didUpdateLuxometer:lux];
    }
}

- (void)processMovementValue:(NSData *)value
{
    if (value.length != 18) {
        NSLog(@"Invalid length for movement reading: %lu", (unsigned long)value.length);
        return;
    }
    
    // Gyroscope values
    int dps = 250; // 250 degrees per second by default (250, 500, 1000, 2000 dps)
    float gx = [self extractSignedShort:value offset:0] * dps / 32768.0;
    float gy = [self extractSignedShort:value offset:2] * dps / 32768.0;
    float gz =  [self extractSignedShort:value offset:4] * dps / 32768.0;
    
    // Accelerometer values
    float range = 2.0; // 2G range by default (+/- 2, 4, 8, 16g)
    float ax = [self extractSignedShort:value offset:6]  * range / 32768.0;
    float ay = [self extractSignedShort:value offset:8]  * range / 32768.0;
    float az = [self extractSignedShort:value offset:10] * range / 32768.0;

    // Magnetometer values (Micro Tesla)
    // See page 52: http://www.invensense.com/wp-content/uploads/2015/02/MPU-9250-Register-Map.pdf
    float mx = [self extractSignedShort:value offset:12] * (4912.0 / 32768.0);
    float my = [self extractSignedShort:value offset:14] * (4912.0 / 32768.0);
    float mz = [self extractSignedShort:value offset:16] * (4912.0 / 32768.0);

#ifdef LOG_READINGS
    NSLog(@"Movement: accelerometer=(%f, %f, %f) gyroscope=(%f, %f, %f) magnetometer=(%f, %f, %f)", ax, ay, az, gx, gy, gz, mx, my, mz);
#endif

    NSObject<SensorTagManagerDelegate> *delegate = self.manager.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(sensorTag:didUpdateLuxometer:)]) {
        [delegate sensorTag:self didUpdateAccelerometer:Point3DMake(ax, ay, az) gyroscope:Point3DMake(gx, gy, gz) magnetometer:Point3DMake(mx, my, mz)];
    }
}

- (void)processSimpleKeyValue:(NSData *)value
{
    if (value.length != 1) {
        NSLog(@"Invalid length for simple keys reading: %lu", (unsigned long)value.length);
        return;
    }

    int rawValue = *((unsigned char*)value.bytes);
    BOOL button1 = rawValue & 0x1;
    BOOL button2 = rawValue & 0x2;

#ifdef LOG_READINGS
    NSLog(@"Simple Keys: button1 %@, button 2 %@", button1 ? @"on" : @"off", button2 ? @"on" : @"off");
#endif

    NSObject<SensorTagManagerDelegate> *delegate = self.manager.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(sensorTag:didUpdateButton1:button2:)]) {
        [delegate sensorTag:self didUpdateButton1:button1 button2:button2];
    }
}

- (float)extractFloat:(NSData *)data offset:(int)offset
{
    int rawValue = [self extractUnsignedShort:data offset:offset];
    int mantissa = rawValue & 0x0FFF;
    int exponent = (rawValue & 0xF000) >> 12;
    double magnitude = pow(2.0f, exponent);
    return mantissa * magnitude;
}

- (unsigned short)extractUnsignedShort:(NSData *)data offset:(int)offset
{
    return [self extractUnsignedInt:data offset:offset length:2];
}

- (short)extractSignedShort:(NSData *)data offset:(int)offset
{
    unsigned char *c = (unsigned char *)data.bytes;
    int lowerByte = (int) c[offset] & 0xFF;
    int upperByte = (int) c[offset+1];
    return (upperByte << 8) + lowerByte;
}

- (int)extractUnsignedInt:(NSData *)data offset:(int)offset length:(int)length {
    int result = 0;
    
    unsigned char *c = (unsigned char *)data.bytes;
    for (int i = 0; i < length; i++) {
        result += ((int)c[offset + i] & 0xFF) << (i * 8);
    }
    
    return result;
}

#pragma mark - Private Methods

- (void)waitForDiscoverCharacteristics:(void (^)())completion
{
    if ([self hasDiscoveredAllServiceCharacteristics]) {
        completion();
    }
    else {
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 100.0 * NSEC_PER_MSEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [self waitForDiscoverCharacteristics:completion];
        });
    }
}

- (BOOL)hasDiscoveredAllServiceCharacteristics
{
    for (CBService *service in self.peripheral.services) {
        if (service.characteristics == nil)
            return false;
    }
    return true;
}

- (void)setPeriod:(NSUInteger)period characteristic:(CBUUID *)characteristic service:(CBUUID *)service;
{
    unsigned char data[2];
    int length;
    
    // Period is in tens of milliseconds
    period = period / 10;

    if (period <= 255) {
        data[0] = period;
        length = 1;
    }
    else {
        // TODO - Figure out if this is even the right format for sending larger values for period
        data[0] = period & 0xFF;
        data[1] = (period & 0xFF00) >> 8;
        length = 2;
    }
    
    [self writeCharacteristic:characteristic service:service bytes:data length:length];
}

- (void)writeCharacteristic:(CBUUID *)uuid service:(CBUUID *)service byte:(unsigned char)value
{
    [self writeCharacteristic:uuid service:service bytes:&value length:1];
}

- (void)writeCharacteristic:(CBUUID *)uuid service:(CBUUID *)service bytes:(unsigned char *)value length:(int)length
{
    NSData *data = [NSData dataWithBytes:value length:length];
    [self writeCharacteristic:uuid service:service data:data];
}

- (void)writeCharacteristic:(CBUUID *)uuid service:(CBUUID *)service data:(NSData *)data
{
    CBCharacteristic *characteristic = [self characteristicForUUID:uuid service:service];
    if (characteristic == nil)
        return;

    [_peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)setNotify:(BOOL)notify characteristic:(CBUUID *)charUUID service:(CBUUID *)serviceUUID {
    CBCharacteristic *characteristic = [self characteristicForUUID:charUUID service:serviceUUID];
    if (characteristic == nil)
        return;
    
    [self.peripheral setNotifyValue:notify forCharacteristic:characteristic];
}

- (CBCharacteristic *)characteristicForUUID:(CBUUID *)charUUID service:(CBUUID *)serviceUUID
{
    CBService *service = [self serviceForUUID:serviceUUID];
    if (service == nil)
        return nil;

    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:charUUID])
            return characteristic;
    }

    NSLog(@"Characteristic %@ not found for service %@", charUUID, serviceUUID);

    return nil;
}

- (CBService *)serviceForUUID:(CBUUID *)uuid
{
    for (CBService *service in _peripheral.services) {
        if ([service.UUID isEqual:uuid])
            return service;
    }

    NSLog(@"Service %@ not found", uuid);
    
    return nil;
}

@end