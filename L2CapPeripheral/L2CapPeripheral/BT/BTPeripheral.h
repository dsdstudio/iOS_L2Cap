//
//  BTPeripheral.h
//  L2CapPeripheral
//
//  Created by hoehoe on 2017/10/08.
//  Copyright © 2017年 chocbanana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@protocol BTPeripheralDelegate<NSObject>
@optional

- (void)logDelegate:(NSString *)message;

@end


@interface BTPeripheral : NSObject<CBPeripheralManagerDelegate, NSStreamDelegate>
{
    NSString *kServiceUUID;
    NSString *kCharacteristicUUID;
    NSString* CBUUIDL2CAppSMCharacteristicString;
    CBL2CAPPSM psm;
}

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *characteristic;
@property (nonatomic, strong) CBMutableCharacteristic *L2CapSMCharacteristic;

@property (nonatomic, strong) CBMutableService *service;
@property (nonatomic, strong) CBL2CAPChannel *l2capChannel;
//@property (nonatomic, strong) NSInputStream* inputStream;
@property (nonatomic, strong) NSOutputStream* outputStream;

@property(nonatomic, assign) id <BTPeripheralDelegate> delegate;

// ------------------------------
// CBPeripheralManagerDelegate
// ------------------------------

// Monitoring Changes to the Peripheral Manager’s State

-(void)peripheralManager:(CBPeripheralManager *)peripheral didOpenL2CAPChannel:(CBL2CAPChannel *)channel error:(NSError *)error;

// peripheralManagerDidUpdateState:
// Invoked when the peripheral manager's state is updated. (required)
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral;

// peripheralManager:willRestoreState:
// Invoked when the peripheral manager is about to be restored by the system.
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict;

// Adding Services

// peripheralManager:didAddService:error:
// Invoked when you publish a service, and any of its associated characteristics and characteristic descriptors, to the local Generic Attribute Profile (GATT) database.
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error;

// Advertising Peripheral Data

// peripheralManagerDidStartAdvertising:error:
// Invoked when you start advertising the local peripheral device’s data.
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error;

// Monitoring Subscriptions to Characteristic Values

// peripheralManager:central:didSubscribeToCharacteristic:
// Invoked when a remote central device subscribes to a characteristic’s value.
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic;

// peripheralManager:central:didUnsubscribeFromCharacteristic:
// Invoked when a remote central device unsubscribes from a characteristic’s value.
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic;

// peripheralManagerIsReadyToUpdateSubscribers:
// Invoked when a local peripheral device is again ready to send characteristic value updates. (required)
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral;

// Receiving Read and Write Requests

// peripheralManager:didReceiveReadRequest:
// Invoked when a local peripheral device receives an Attribute Protocol (ATT) read request for a characteristic that has a dynamic value.
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request;

// peripheralManager:didReceiveWriteRequests:
// Invoked when a local peripheral device receives an Attribute Protocol (ATT) write request for a characteristic that has a dynamic value.
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests;

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices;

@end
