//
//  NSData+Convert.m
//  MiningSensorTag
//
//  Created by Shing Trinh on 2015-06-05.
//  Copyright (c) 2015 SAP. All rights reserved.
//

#import "NSData+Convert.h"

@implementation NSData(Convert)

- (NSString *)hexString {
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    if (!dataBuffer)
        return [NSString string];

    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

@end