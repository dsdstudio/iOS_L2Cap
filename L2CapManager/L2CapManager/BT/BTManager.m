//
//  BleManager.m
//  L2CapManager
//
//  Created by hoehoe on 2017/10/06.
//  Copyright © 2017年 chocbanana. All rights reserved.
//

#import "BTManager.h"
#import "BTPeripheral.h"

@implementation BTManager

static BTManager* me;


+(id)sharedInstance
{
    
    @synchronized(self) {
        if(!me){
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                me = [[self alloc] initWithSelf];
            });
        }
    }
    return me;
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)init
{
    [NSException raise:NSGenericException
                format:@"Disabled. Use +[[%@ alloc] %@] instead",
     NSStringFromClass([self class]),
     NSStringFromSelector(@selector(initWithSelf))];
    return nil;
}

-(id)initWithSelf
{
    if(self){
        self = [super init];
    }
    kServiceUUID = @"312700E2-E798-4D5C-8DCF-49908332DF9F";
    
    //    NSDictionary *options = @{
    //                              CBCentralManagerOptionRestoreIdentifierKey:@"EA.ble.identifier",
    //                              CBCentralManagerOptionShowPowerAlertKey:@YES
    //                              };
    //dispatch_queue_t que = dispatch_queue_create("com.chocbanana.ios.eeg-acceleration-logger", DISPATCH_QUEUE_SERIAL);
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    return self;
    
}

-(void)start
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // 単一デバイスの発見イベントを重複して発行させるか？
    CBUUID* uuid = [CBUUID UUIDWithString:kServiceUUID];
    [self.centralManager scanForPeripheralsWithServices: @[uuid]
                                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}


-(void)stop
{
    if(_peripheral != nil){
        _peripheral.delegate = nil;
        [self.centralManager cancelPeripheralConnection:_peripheral];
    }
}

// ------------------------------
// CBCentralManagerDelegate
// ------------------------------

// Monitoring Connections with Peripherals

// centralManager:didConnectPeripheral:
// Invoked when a connection is successfully created with a peripheral.
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    //NSLog(@"%@", peripheral.description);
    
    // Clears the data that we may already have
    // Sets the peripheral delegate
    [peripheral setDelegate:self];
    
    // Asks the peripheral to discover the service
    [peripheral discoverServices:@[ [CBUUID UUIDWithString:kServiceUUID] ]];
}

// centralManager:didDisconnectPeripheral:error:
// Invoked when an existing connection with a peripheral is torn down.
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    //if(error){
    //        NSLog(@"[error] %@", [error localizedDescription]);
    //        NSLog(@"[error] %@", [error localizedFailureReason]);
    //        NSLog(@"[error] %@", [error localizedRecoverySuggestion]);
    //}else{
    //NSLog(@"disconnect");
    
    if([self.peripheral isEqual:peripheral]){
        self.peripheral.delegate = nil;
        self.peripheral = nil;
    }
    //}
}

// centralManager:didFailToConnectPeripheral:error:
// Invoked when the central manager fails to create a connection with a peripheral.
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// Discovering and Retrieving Peripherals

// デバイス発見時
// centralManager:didDiscoverPeripheral:advertisementData:RSSI:
// Invoked when the central manager discovers a peripheral while scanning.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    //[self.centralManager stopScan];
    //NSLog(@"[RSSI] %@", RSSI);
    
    
    self.peripheral = peripheral;
    //NSLog(@"Connecting to pripheral %@", peripheral);
    // 発見されたデバイスに接続
    [self.centralManager connectPeripheral:peripheral options:nil];
    [self.centralManager stopScan];
}


// centralManager:didRetrieveConnectedPeripherals:
// Invoked when the central manager retrieves a list of peripherals currently connected to the system.
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// centralManager:didRetrievePeripherals:
// Invoked when the central manager retrieves a list of known peripherals.
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// Monitoring Changes to the Central Manager’s State

// CBCentralManager が初期化されたり状態が変化した際に呼ばれるデリゲートメソッド
// centralManagerDidUpdateState:
// Invoked when the central manager’s state is updated. (required)
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    switch (central.state) {
        case CBManagerStatePoweredOn:
            //NSLog(@"CBCentralManagerStatePoweredOn");
            [self start];
            break;
        case CBManagerStatePoweredOff:
            //NSLog(@"CBCentralManagerStatePoweredOff");
            [self stop];
            break;
        case CBManagerStateResetting:
            //NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBManagerStateUnauthorized:
            //NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBManagerStateUnsupported:
            //NSLog(@"CBCentralManagerStatePoweredOn");
            break;
        case CBManagerStateUnknown:
            //NSLog(@"CBCentralManagerStateUnknown");
            break;
        default:
            break;
    }
}

// centralManager:willRestoreState:
// Invoked when the central manager is about to be restored by the system.
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


// ------------------------------
// CBPeripheralDelegate
// ------------------------------

// Discovering Services

// peripheral:didDiscoverServices:
// Invoked when you discover the peripheral’s available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    if(error){
        NSLog(@"[error] %@", [error localizedDescription]);
    }else{
        
        for(CBService *service in peripheral.services) {
            if([service.UUID.UUIDString isEqualToString:kServiceUUID]){
                //NSLog(@"hoge");
                _p = [[BTPeripheral alloc] initWithServicePeripheral:peripheral service:service];
            }
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    ;;
}
@end

