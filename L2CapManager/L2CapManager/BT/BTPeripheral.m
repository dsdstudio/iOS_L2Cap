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

        NSLog(@"peripheral start...");
        
        self.peripheral = peripheral;
        self.peripheral.delegate = self;
        self.service = service;

        NSArray* characteristics = @[
                                     [CBUUID UUIDWithString:kCharacteristicUUID],
                                     [CBUUID UUIDWithString:CBUUIDL2CAppSMCharacteristicString],
                                     ];
        [self.peripheral discoverCharacteristics:characteristics forService:service];

    }
    return self;
}


// ------------------------------
// NSStreamDelegate
// ------------------------------

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"%@", aStream);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasSpaceAvailable:
            break;
        case NSStreamEventHasBytesAvailable:
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
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if(error){
        NSLog(@"%@", error);
    }
    _l2cap = channel;
    _stream = _l2cap.outputStream;
    _stream.delegate = self;
}


// Discovering Services

// peripheral:didDiscoverServices:
// Invoked when you discover the peripheral’s available services.

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));;;
}

//Discovering Characteristics and Characteristic Descriptors

// peripheral:didDiscoverCharacteristicsForService:error:
// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if(error){
        NSLog(@"[error] %@", [error localizedDescription]);
    }else{
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:kCharacteristicUUID]) {
                NSLog(@"characteristics is found!");
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
    NSLog(@"%@", NSStringFromSelector(_cmd));
}



// peripheral:didDiscoverDescriptorsForCharacteristic:error:
// Invoked when you discover the descriptors of a specified characteristic.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}



// Retrieving Characteristic and Characteristic Descriptor Values

// peripheral:didUpdateValueForCharacteristic:error:
// Invoked when you retrieve a specified characteristic’s value, or when the peripheral device notifies your app that the characteristic’s value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if(error){
        NSLog(@"[error] %@", [error localizedDescription]);
    }//else{
        if([characteristic.UUID.UUIDString isEqualToString:kCharacteristicUUID]){
            uint value;
            NSData* data = characteristic.value;
            [data getBytes:&value length:sizeof(uint)];
            
            NSLog(@"data: %d", value);
        }else if([characteristic.UUID.UUIDString isEqualToString:CBUUIDL2CAppSMCharacteristicString]){
//            uint16_t value;
//            NSData* data = characteristic.value;
//            [data getBytes:&value length:sizeof(uint16_t)];
//            psm = value;
//
//            NSLog(@"PSM: %d", value);
//            [peripheral openL2CAPChannel:psm];
        }
        
    //}
}

// peripheral:didUpdateValueForDescriptor:error:
// Invoked when you retrieve a specified characteristic descriptor’s value.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// Writing Characteristic and Characteristic Descriptor Values

// peripheral:didWriteValueForCharacteristic:error:
// Invoked when you write data to a characteristic’s value.
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //NSLog(@"write characteristic");
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
}

// peripheral:didWriteValueForDescriptor:error:
// Invoked when you write data to a characteristic descriptor’s value.
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// Managing Notifications for a Characteristic’s Value

// peripheral:didUpdateNotificationStateForCharacteristic:error:
// Invoked when the peripheral receives a request to start or stop providing notifications for a specified characteristic’s value.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if(error){
        NSLog(@"[error] %@", [error localizedDescription]);
    }else{
        // Exits if it's not the transfer characteristic
        //if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]]) {
        //    return;
        //}
        
        // Notification has started
        if (characteristic.isNotifying) {
            if([characteristic.UUID.UUIDString isEqualToString:kCharacteristicUUID]){
                
                //[peripheral readValueForCharacteristic:characteristic];
            }else if([characteristic.UUID.UUIDString isEqualToString:CBUUIDL2CAppSMCharacteristicString]){
                NSLog(@"Notification began on %@", characteristic);
                uint16_t value;
                NSData* data = characteristic.value;
                [data getBytes:&value length:sizeof(uint16_t)];
                NSLog(@"data: %d", value);
                [peripheral openL2CAPChannel:192];
                //[peripheral readValueForCharacteristic:characteristic];
            }
        }
    }
    
}

// Retrieving a Peripheral’s Received Signal Strength Indicator (RSSI) Data

// peripheralDidUpdateRSSI:error:
// Invoked when you retrieve the value of the peripheral’s current RSSI while it is connected to the central manager.
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// Monitoring Changes to a Peripheral’s Name or Services

// peripheralDidUpdateName:
// Invoked when a peripheral’s name changes.
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// peripheral:didModifyServices:
// Invoked when a peripheral’s services have changed.
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
