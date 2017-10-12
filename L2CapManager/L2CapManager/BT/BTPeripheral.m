//
//  BTPeripheral.m
//  L2CapManager
//
//  Created by hoehoe on 2017/10/08.
//  Copyright © 2017年 chocbanana. All rights reserved.
//

#import "BTPeripheral.h"

@implementation BTPeripheral

- (id)init
{
    [NSException raise:NSGenericException
                format:@"Disabled. Use +[[%@ alloc] %@] instead",
     NSStringFromClass([self class]),
     NSStringFromSelector(@selector(initWithServicePeripheral:service:))];
    return nil;
}


- (id)initWithServicePeripheral:(CBPeripheral *)peripheral service:(CBService *)service
{
    if(self = [super init]){
        kCharacteristicUUID = @"FFA28CDE-6525-4489-801C-1C060CAC9767";
        CBUUIDL2CAppSMCharacteristicString = @"ABDD3056-28FA-441D-A470-55A75A52553A";
        
        //NSLog(@"peripheral init...");
        
        self.peripheral = peripheral;
        self.peripheral.delegate = self;
        
        NSArray* characteristics = @[
                                     [CBUUID UUIDWithString:kCharacteristicUUID],
                                     [CBUUID UUIDWithString:CBUUIDL2CAppSMCharacteristicString],
                                     ];
        [self.peripheral discoverCharacteristics:characteristics forService:service];
        
    }
    return self;
}

-(void)log:(NSString *)message
{
    NSLog(@"%@", message);
    [self.delegate logDelegate:message];
}


-(void)receiveStreamData
{
    NSMutableData* data = [NSMutableData data];
    static uint8_t buf[1024];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Background Thread.
        [inputStream read:buf maxLength:1024];

        dispatch_async(dispatch_get_main_queue(), ^{
            //Main Thread.
            [data appendBytes:buf length:sizeof(buf)];
            
            NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self log:str];
        });
    });
}


// ------------------------------
// NSStreamDelegate
// ------------------------------

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    //NSLog(@"%@", aStream);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            
            break;
        case NSStreamEventHasSpaceAvailable:
            break;
        case NSStreamEventHasBytesAvailable:
            [self receiveStreamData];
            break;
        case NSStreamEventErrorOccurred:
            break;
        case NSStreamEventEndEncountered:
            break;
        case NSStreamEventNone:
            break;
        default:
            break;
    }
}


// ------------------------------
// CBPeripheralDelegate
// ------------------------------

-(void)peripheral:(CBPeripheral *)peripheral didOpenL2CAPChannel:(CBL2CAPChannel *)channel error:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];
    
    if(error){
        NSLog(@"%@", error);
    }
    
    _l2cap = channel;
    
    //outputStream = _l2cap.outputStream;
    inputStream = _l2cap.inputStream;
    //outputStream.delegate = self;
    inputStream.delegate = self;
    
    //[outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
    //                        forMode:NSDefaultRunLoopMode];
    //[outputStream open];

    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
    [inputStream open];
    
}


// Discovering Services

// peripheral:didDiscoverServices:
// Invoked when you discover the peripheral’s available services.

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];
}

//Discovering Characteristics and Characteristic Descriptors

// peripheral:didDiscoverCharacteristicsForService:error:
// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];
    
    if(error){
        NSLog(@"[error] %@", [error localizedDescription]);
    }else{
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:kCharacteristicUUID]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }else if([characteristic.UUID.UUIDString isEqualToString:CBUUIDL2CAppSMCharacteristicString]){
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
}
// peripheral:didDiscoverIncludedServicesForService:error:
// Invoked when you discover the included services of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];
}



// peripheral:didDiscoverDescriptorsForCharacteristic:error:
// Invoked when you discover the descriptors of a specified characteristic.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];
}



// Retrieving Characteristic and Characteristic Descriptor Values

// peripheral:didUpdateValueForCharacteristic:error:
// Invoked when you retrieve a specified characteristic’s value, or when the peripheral device notifies your app that the characteristic’s value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];
    
    if(error){
        NSLog(@"[error] %@", [error localizedDescription]);
        return;
    }
    
    if([characteristic.UUID.UUIDString isEqualToString:kCharacteristicUUID]){
        uint value;
        NSData* data = characteristic.value;
        [data getBytes:&value length:sizeof(uint)];
        
        [self log:[NSString stringWithFormat:@"%d", value]];
    }else if([characteristic.UUID.UUIDString isEqualToString:CBUUIDL2CAppSMCharacteristicString]){
        uint16_t value;
        NSData* data = characteristic.value;
        [data getBytes:&value length:sizeof(uint16_t)];
        psm = value;
        
        [self log:[NSString stringWithFormat:@"PSM: %d", value]];
        [peripheral openL2CAPChannel:psm];
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
    }
}

// peripheral:didUpdateValueForDescriptor:error:
// Invoked when you retrieve a specified characteristic descriptor’s value.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];
}

// Writing Characteristic and Characteristic Descriptor Values

// peripheral:didWriteValueForCharacteristic:error:
// Invoked when you write data to a characteristic’s value.
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //NSLog(@"write characteristic");
    [self log:NSStringFromSelector(_cmd)];
    
}

// peripheral:didWriteValueForDescriptor:error:
// Invoked when you write data to a characteristic descriptor’s value.
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];
}

// Managing Notifications for a Characteristic’s Value

// peripheral:didUpdateNotificationStateForCharacteristic:error:
// Invoked when the peripheral receives a request to start or stop providing notifications for a specified characteristic’s value.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];
    
    if(error){
        NSLog(@"[error] %@", [error localizedDescription]);
    }else{
        // Notification has started
        if (characteristic.isNotifying) {
            if([characteristic.UUID.UUIDString isEqualToString:kCharacteristicUUID]){
                [peripheral readValueForCharacteristic:characteristic];
            }else if([characteristic.UUID.UUIDString isEqualToString:CBUUIDL2CAppSMCharacteristicString]){
                [peripheral readValueForCharacteristic:characteristic];
            }
        }
    }
    
}

// Retrieving a Peripheral’s Received Signal Strength Indicator (RSSI) Data

// peripheralDidUpdateRSSI:error:
// Invoked when you retrieve the value of the peripheral’s current RSSI while it is connected to the central manager.
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];
}

// Monitoring Changes to a Peripheral’s Name or Services

// peripheralDidUpdateName:
// Invoked when a peripheral’s name changes.
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    [self log:NSStringFromSelector(_cmd)];
}

// peripheral:didModifyServices:
// Invoked when a peripheral’s services have changed.
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    [self log:NSStringFromSelector(_cmd)];
}

@end

