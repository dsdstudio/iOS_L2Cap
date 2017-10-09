//
//  BTPeripheral.m
//  L2CapPeripheral
//
//  Created by hoehoe on 2017/10/08.
//  Copyright © 2017年 chocbanana. All rights reserved.
//

#import "BTPeripheral.h"

@implementation BTPeripheral


-(id)init{
    // Do any additional setup after loading the view, typically from a nib.
    if(self = [super init]){
        kServiceUUID = @"312700E2-E798-4D5C-8DCF-49908332DF9F";
        kCharacteristicUUID = @"FFA28CDE-6525-4489-801C-1C060CAC9767";
        CBUUIDL2CAppSMCharacteristicString = @"ABDD3056-28FA-441D-A470-55A75A52553A";
        
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
       
    }
    return self;
}



- (void)setupService
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate logDelegate:NSStringFromSelector(_cmd)];
    
    // Creates the characteristic UUID
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    CBUUID *l2capCharacteisticUUID = [CBUUID UUIDWithString:CBUUIDL2CAppSMCharacteristicString];
    
    //NSLog(@"[characteristicUUID.description] %@", characteristicUUID.description);
    
    // Creates the characteristic
    //self.characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    self.characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    self.L2CapSMCharacteristic = [[CBMutableCharacteristic alloc] initWithType:l2capCharacteisticUUID properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];

    // Creates the service UUID
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    
    // Creates the service and adds the characteristic to it
    self.service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    
    // Sets the characteristics for this service
    [self.service setCharacteristics:@[self.characteristic, self.L2CapSMCharacteristic]];
    
    // Publishes the service
    [self.peripheralManager addService:self.service];
    [self.peripheralManager publishL2CAPChannelWithEncryption:YES];
}

-(void)stop
{
    [self.peripheralManager unpublishL2CAPChannel:psm];
    //self.peripheralManager.delegate = nil;
    //self.peripheralManager = nil;
}

// ------------------------------
// CBPeripheralManagerDelegate
// ------------------------------

-(void)peripheralManager:(CBPeripheralManager *)peripheral didOpenL2CAPChannel:(CBL2CAPChannel *)channel error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"Open L2Cap channel...");
    [self.delegate logDelegate:NSStringFromSelector(_cmd)];
    _l2capChannel = channel;
    //_l2capChannel.inputStream;
    
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didPublishL2CAPChannel:(CBL2CAPPSM)PSM error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate logDelegate:NSStringFromSelector(_cmd)];
    psm = PSM;
    NSLog(@"Listen L2Cap channel...");
    NSLog(@"PSM: %d", psm);
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didUnpublishL2CAPChannel:(CBL2CAPPSM)PSM error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate logDelegate:NSStringFromSelector(_cmd)];
}

// Monitoring Changes to the Peripheral Manager’s State

// CBPeripheralManager が初期化されたり状態が変化した際に呼ばれるデリゲートメソッド
// peripheralManagerDidUpdateState:
// Invoked when the peripheral manager's state is updated. (required)
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    //_manager = manager;
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate logDelegate:NSStringFromSelector(_cmd)];
    
    switch (peripheral.state) {
        case CBManagerStatePoweredOn:
            NSLog(@"%ld, CBManagerStatePoweredOn", (long)peripheral.state);
            // PowerOn なら，デバイスのセッティングを開始する．
             [self setupService];
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"%ld, CBManagerStatePoweredOff", (long)peripheral.state);
            [self stop];
            break;
        case CBManagerStateResetting:
            NSLog(@"%ld, CBManagerStateResetting", (long)peripheral.state);
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"%ld, CBManagerStateUnauthorized", (long)peripheral.state);
            break;
        case CBManagerStateUnsupported:
            NSLog(@"%ld, CBManagerStateUnsupported", (long)peripheral.state);
            break;
        case CBManagerStateUnknown:
            NSLog(@"%ld, CBManagerStateUnknown", (long)peripheral.state);
            break;
        default:
            break;
    }
}

// peripheralManager:willRestoreState:
// Invoked when the peripheral manager is about to be restored by the system.
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// Adding Services

// peripheralManager:didAddService:error:
// Invoked when you publish a service, and any of its associated characteristics and characteristic descriptors, to the local Generic Attribute Profile (GATT) database.
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate logDelegate:NSStringFromSelector(_cmd)];
    
    if(error){
        NSLog(@"[error] %@", [error localizedDescription]);
    }else{
        // Starts advertising the service
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey : @"mokyu", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:kServiceUUID]] }];
        NSLog(@"start advertising");
    }
}

// Advertising Peripheral Data

// peripheralManagerDidStartAdvertising:error:
// Invoked when you start advertising the local peripheral device’s data.
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate logDelegate:NSStringFromSelector(_cmd)];
    
    if(error){
        NSLog(@"[error] %@", [error localizedDescription]);
    }
}

// Monitoring Subscriptions to Characteristic Values

// peripheralManager:central:didSubscribeToCharacteristic:
// Invoked when a remote central device subscribes to a characteristic’s value.
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate logDelegate:NSStringFromSelector(_cmd)];
    if(characteristic.isNotifying ){
        if([characteristic.UUID.UUIDString isEqualToString:kCharacteristicUUID]){
            uint battery_level = 39;
            NSData *dataBatteryLevel = [NSData dataWithBytes:&battery_level length:sizeof(battery_level)];
            [peripheral updateValue:dataBatteryLevel forCharacteristic:self.characteristic onSubscribedCentrals:nil];
        }else if([characteristic.UUID.UUIDString isEqualToString:CBUUIDL2CAppSMCharacteristicString]){
            uint16_t value = psm;
            //uint8_t hoge;
            NSData* psmValue = [NSData dataWithBytes:&value length:sizeof(value)];
            //NSLog(@"%@", psmValue);
            [peripheral updateValue:psmValue forCharacteristic:self.L2CapSMCharacteristic
               onSubscribedCentrals:nil];
            
        }
    }
}

// peripheralManager:central:didUnsubscribeFromCharacteristic:
// Invoked when a remote central device unsubscribes from a characteristic’s value.
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate logDelegate:NSStringFromSelector(_cmd)];
}

// peripheralManagerIsReadyToUpdateSubscribers:
// Invoked when a local peripheral device is again ready to send characteristic value updates. (required)
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate logDelegate:NSStringFromSelector(_cmd)];
}

// Receiving Read and Write Requests

// peripheralManager:didReceiveReadRequest:
// Invoked when a local peripheral device receives an Attribute Protocol (ATT) read request for a characteristic that has a dynamic value.
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate logDelegate:NSStringFromSelector(_cmd)];
}

// peripheralManager:didReceiveWriteRequests:
// Invoked when a local peripheral device receives an Attribute Protocol (ATT) write request for a characteristic that has a dynamic value.
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate logDelegate:NSStringFromSelector(_cmd)];
}

// peripheral:didModifyServices:
// Invoked when a peripheral’s services have changed.
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
