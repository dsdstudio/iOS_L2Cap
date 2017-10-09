//
//  BTPeripheral.h
//  L2CapManager
//
//  Created by hoehoe on 2017/10/08.
//  Copyright © 2017年 chocbanana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


#define CBUUIDL2CAPPSMCharacteristicString @"ABDD3056-28FA-441D-A470-55A75A52553A"

@interface BTPeripheral : NSObject<CBPeripheralDelegate, NSStreamDelegate>
{
    NSString *kCharacteristicUUID;
    NSString* CBUUIDL2CAppSMCharacteristicString;
    CBL2CAPPSM psm;
}

@property(nonatomic, strong)CBPeripheral* peripheral;
@property(nonatomic, strong) CBService* service;
@property(nonatomic, strong)NSStream* stream;
@property(nonatomic, strong)CBL2CAPChannel* l2cap;

- (id)init __attribute__((unavailable("init is not available")));
- (id)initWithServicePeripheral:(CBPeripheral *)peripheral service:(CBService *)service;
//-(void)start:(CBPeripheral *)peripheral service:(CBService *)service;

// ------------------------------
// CBPeripheralDelegate
// ------------------------------

-(void)peripheral:(CBPeripheral *)peripheral didOpenL2CAPChannel:(CBL2CAPChannel *)channel error:(NSError *)error;

// Discovering Services

// peripheral:didDiscoverServices:
// Invoked when you discover the peripheral’s available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;

// peripheral:didDiscoverIncludedServicesForService:error:
// Invoked when you discover the included services of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error;

//Discovering Characteristics and Characteristic Descriptors

// peripheral:didDiscoverCharacteristicsForService:error:
// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;

// peripheral:didDiscoverDescriptorsForCharacteristic:error:
// Invoked when you discover the descriptors of a specified characteristic.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

// Retrieving Characteristic and Characteristic Descriptor Values

// peripheral:didUpdateValueForCharacteristic:error:
// Invoked when you retrieve a specified characteristic’s value, or when the peripheral device notifies your app that the characteristic’s value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

// peripheral:didUpdateValueForDescriptor:error:
// Invoked when you retrieve a specified characteristic descriptor’s value.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error;

// Writing Characteristic and Characteristic Descriptor Values

// peripheral:didWriteValueForCharacteristic:error:
// Invoked when you write data to a characteristic’s value.
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

// peripheral:didWriteValueForDescriptor:error:
// Invoked when you write data to a characteristic descriptor’s value.
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error;

// Managing Notifications for a Characteristic’s Value

// peripheral:didUpdateNotificationStateForCharacteristic:error:
// Invoked when the peripheral receives a request to start or stop providing notifications for a specified characteristic’s value.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

// Retrieving a Peripheral’s Received Signal Strength Indicator (RSSI) Data

// peripheralDidUpdateRSSI:error:
// Invoked when you retrieve the value of the peripheral’s current RSSI while it is connected to the central manager.
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error;

// Monitoring Changes to a Peripheral’s Name or Services

// peripheralDidUpdateName:
// Invoked when a peripheral’s name changes.
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral;

// peripheral:didModifyServices:
// Invoked when a peripheral’s services have changed.
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices;


@end
