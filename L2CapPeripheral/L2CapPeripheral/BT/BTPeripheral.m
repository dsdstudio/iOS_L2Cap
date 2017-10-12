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
        // デフォルトの通知センターを取得する
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(didEnterBackground:) name:@"didEnterBackground" object:nil];
        
        //テキトーなサービスキャラクタリスティック
        kServiceUUID = @"312700E2-E798-4D5C-8DCF-49908332DF9F";
        kCharacteristicUUID = @"FFA28CDE-6525-4489-801C-1C060CAC9767";
        
        //L2Cap用のCharacteristic
        CBUUIDL2CAppSMCharacteristicString = @"ABDD3056-28FA-441D-A470-55A75A52553A";
        
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
       
    }
    return self;
}



- (void)setupService
{
    NSString* cmd = NSStringFromSelector(_cmd);
    NSLog(@"%@", cmd);
    [self.delegate logDelegate:cmd];
    
    // Creates the characteristic UUID
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    CBUUID *l2capCharacteisticUUID = [CBUUID UUIDWithString:CBUUIDL2CAppSMCharacteristicString];
    
    //NSLog(@"[characteristicUUID.description] %@", characteristicUUID.description);
    
    // Creates the characteristic
    //self.characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBMutableCharacteristic* characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBMutableCharacteristic* L2CapSMCharacteristic = [[CBMutableCharacteristic alloc] initWithType:l2capCharacteisticUUID properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];

    // Creates the service UUID
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    
    // Creates the service and adds the characteristic to it
    CBMutableService* service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    
    // Sets the characteristics for this service
    [service setCharacteristics:@[characteristic, L2CapSMCharacteristic]];
    
    // Publishes the service
    [self.peripheralManager addService:service];
    [self.peripheralManager publishL2CAPChannelWithEncryption:YES];
}

-(void)stop
{
    [outputStream close];
    //[_inputStream close];

    [self.peripheralManager unpublishL2CAPChannel:psm];
}

-(void)sendStreamData
{
    //NSString* cmd = NSStringFromSelector(_cmd);
    //NSLog(@"%@", cmd);
    //[self.delegate logDelegate:cmd];
    
    NSString* value = @"Hello L2Cap Stream data...";
    NSLog(@"%@\r\n", value);
    //[self.delegate logDelegate:value];
    
    NSData* data = [value dataUsingEncoding:NSUTF8StringEncoding];
    [outputStream write:[data bytes] maxLength:[data length]];
}


// ------------------------------
// NSStreamDelegate
// ------------------------------

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    //NSString* cmd = NSStringFromSelector(_cmd);
    //NSLog(@"%@", cmd);
    //[self.delegate logDelegate:cmd];
    
    //NSLog(@"%@", aStream);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasSpaceAvailable:
            [self sendStreamData];
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
// CBPeripheralManagerDelegate
// ------------------------------

-(void)peripheralManager:(CBPeripheralManager *)peripheral didOpenL2CAPChannel:(CBL2CAPChannel *)channel error:(NSError *)error
{
    NSString* cmd = NSStringFromSelector(_cmd);
    NSLog(@"%@", cmd);
    [self.delegate logDelegate:cmd];
    
    NSString* value = @"Open L2Cap channel...";
    NSLog(@"%@", value);
    [self.delegate logDelegate:value];
    
    _l2capChannel = channel;

    outputStream = _l2capChannel.outputStream;
    //inputStream = _l2capChannel.inputStream;
    
    outputStream.delegate = self;
    //inputStream.delegate = self;
    
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSDefaultRunLoopMode];
    [outputStream open];

    //[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
    //                         forMode:NSDefaultRunLoopMode];
    //[inputStream open];

}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didPublishL2CAPChannel:(CBL2CAPPSM)PSM error:(NSError *)error
{
    NSString* cmd = NSStringFromSelector(_cmd);
    NSLog(@"%@", cmd);
    [self.delegate logDelegate:cmd];
    
    psm = PSM;
    
    NSString* value = @"Listen L2Cap channel...";
    NSLog(@"%@", value);
    [self.delegate logDelegate:value];
    
    value = [NSString stringWithFormat:@"PSM: %d", psm];
    NSLog(@"%@", value);
    [self.delegate logDelegate:value];
    
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didUnpublishL2CAPChannel:(CBL2CAPPSM)PSM error:(NSError *)error
{
    NSString* cmd = NSStringFromSelector(_cmd);
    NSLog(@"%@", cmd);
    [self.delegate logDelegate:cmd];
}

// Monitoring Changes to the Peripheral Manager’s State

// CBPeripheralManager が初期化されたり状態が変化した際に呼ばれるデリゲートメソッド
// peripheralManagerDidUpdateState:
// Invoked when the peripheral manager's state is updated. (required)
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSString* cmd = NSStringFromSelector(_cmd);
    NSLog(@"%@", cmd);
    [self.delegate logDelegate:cmd];
    
    NSString* value;
    
    switch (peripheral.state) {
        case CBManagerStatePoweredOn:
        {
            [self setupService];
            value = [NSString stringWithFormat:@"%ld, CBManagerStatePoweredOn", (long)peripheral.state];
            [self.delegate logDelegate:value];
            NSLog(@"%@", value);
        }
            break;
        case CBManagerStatePoweredOff:
        {
            [self stop];
            value = [NSString stringWithFormat:@"%ld, CBManagerStatePoweredOff", (long)peripheral.state];
            [self.delegate logDelegate:value];
            NSLog(@"%@", value);
        }
            break;
        case CBManagerStateResetting:
        {
            value = [NSString stringWithFormat:@"%ld, CBManagerStateResetting", (long)peripheral.state];
            [self.delegate logDelegate:value];
            NSLog(@"%@", value);
        }
            break;
        case CBManagerStateUnauthorized:
        {
            value = [NSString stringWithFormat:@"%ld, CBManagerStateUnauthorized", (long)peripheral.state];
            [self.delegate logDelegate:value];
            NSLog(@"%@", value);
        }
            break;
        case CBManagerStateUnsupported:
        {
            value = [NSString stringWithFormat:@"%ld, CBManagerStateUnsupported", (long)peripheral.state];
            [self.delegate logDelegate:value];
            NSLog(@"%@", value);
        }
            break;
        case CBManagerStateUnknown:
        {
            value = [NSString stringWithFormat:@"%ld, CBManagerStateUnknown", (long)peripheral.state];
            [self.delegate logDelegate:value];
            NSLog(@"%@", value);
        }
            break;
        default:
            break;
    }
}

// peripheralManager:willRestoreState:
// Invoked when the peripheral manager is about to be restored by the system.
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict
{
    NSString* cmd = NSStringFromSelector(_cmd);
    NSLog(@"%@", cmd);
    [self.delegate logDelegate:cmd];
}

// Adding Services

// peripheralManager:didAddService:error:
// Invoked when you publish a service, and any of its associated characteristics and characteristic descriptors, to the local Generic Attribute Profile (GATT) database.
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    NSString* cmd = NSStringFromSelector(_cmd);
    NSLog(@"%@", cmd);
    [self.delegate logDelegate:cmd];
    
    if(error){
        NSLog(@"[error] %@", [error localizedDescription]);
    }else{
        // Starts advertising the service
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey : @"mokyu", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:kServiceUUID]] }];
        NSString* value = @"start advertising";
        NSLog(@"%@", value);
        [self.delegate logDelegate:value];
    }
}

// Advertising Peripheral Data

// peripheralManagerDidStartAdvertising:error:
// Invoked when you start advertising the local peripheral device’s data.
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSString* cmd = NSStringFromSelector(_cmd);
    NSLog(@"%@", cmd);
    [self.delegate logDelegate:cmd];
    
    if(error){
        NSLog(@"[error] %@", [error localizedDescription]);
    }
}

// Monitoring Subscriptions to Characteristic Values

// peripheralManager:central:didSubscribeToCharacteristic:
// Invoked when a remote central device subscribes to a characteristic’s value.
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSString* cmd = NSStringFromSelector(_cmd);
    NSLog(@"%@", cmd);
    [self.delegate logDelegate:cmd];
}

// peripheralManager:central:didUnsubscribeFromCharacteristic:
// Invoked when a remote central device unsubscribes from a characteristic’s value.
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSString* cmd = NSStringFromSelector(_cmd);
    NSLog(@"%@", cmd);
    [self.delegate logDelegate:cmd];
}

// peripheralManagerIsReadyToUpdateSubscribers:
// Invoked when a local peripheral device is again ready to send characteristic value updates. (required)
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    NSString* cmd = NSStringFromSelector(_cmd);
    NSLog(@"%@", cmd);
    [self.delegate logDelegate:cmd];
}

// Receiving Read and Write Requests

// peripheralManager:didReceiveReadRequest:
// Invoked when a local peripheral device receives an Attribute Protocol (ATT) read request for a characteristic that has a dynamic value.
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSString* cmd = NSStringFromSelector(_cmd);
    NSLog(@"%@", cmd);
    [self.delegate logDelegate:cmd];
    
    CBCharacteristic* characteristic = request.characteristic;
    
    if([characteristic.UUID.UUIDString isEqualToString:kCharacteristicUUID]){
        uint battery_level = 39;
        NSData *dataBatteryLevel = [NSData dataWithBytes:&battery_level length:sizeof(battery_level)];
        request.value = dataBatteryLevel;
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }else if([characteristic.UUID.UUIDString isEqualToString:CBUUIDL2CAppSMCharacteristicString]){
        uint16_t value = psm;
        NSData* psmValue = [NSData dataWithBytes:&value length:sizeof(value)];
        request.value = psmValue;
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

// peripheralManager:didReceiveWriteRequests:
// Invoked when a local peripheral device receives an Attribute Protocol (ATT) write request for a characteristic that has a dynamic value.
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    NSString* cmd = NSStringFromSelector(_cmd);
    NSLog(@"%@", cmd);
    [self.delegate logDelegate:cmd];
}

// peripheral:didModifyServices:
// Invoked when a peripheral’s services have changed.
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

-(void)didEnterBackground:(NSNotification *)notification
{
    [self stop];
}

@end
