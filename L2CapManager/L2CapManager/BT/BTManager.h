//
//  BleManager.h
//  L2CapManager
//
//  Created by hoehoe on 2017/10/06.
//  Copyright © 2017年 chocbanana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTPeripheral.h"

@interface BTManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    NSString *kServiceUUID;
}

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) BTPeripheral* p;


+(id)sharedInstance;
- (id)init __attribute__((unavailable("init is not available")));

// ------------------------------
// CBCentralManagerDelegate
// ------------------------------

// Monitoring Connections with Peripherals

// centralManager:didConnectPeripheral:
// Invoked when a connection is successfully created with a peripheral.
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;

// centralManager:didDisconnectPeripheral:error:
// Invoked when an existing connection with a peripheral is torn down.
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

// centralManager:didFailToConnectPeripheral:error:
// Invoked when the central manager fails to create a connection with a peripheral.
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

// Discovering and Retrieving Peripherals

// centralManager:didDiscoverPeripheral:advertisementData:RSSI:
// Invoked when the central manager discovers a peripheral while scanning.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

// centralManager:didRetrieveConnectedPeripherals:
// Invoked when the central manager retrieves a list of peripherals currently connected to the system.
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals;

// centralManager:didRetrievePeripherals:
// Invoked when the central manager retrieves a list of known peripherals.
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals;

// Monitoring Changes to the Central Manager’s State

// centralManagerDidUpdateState:
// Invoked when the central manager’s state is updated. (required)
- (void)centralManagerDidUpdateState:(CBCentralManager *)central;

// centralManager:willRestoreState:
// Invoked when the central manager is about to be restored by the system.
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict;

// ------------------------------
// CBPeripheralDelegate
// ------------------------------

// Discovering Services

// peripheral:didDiscoverServices:
// Invoked when you discover the peripheral’s available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;


@end
