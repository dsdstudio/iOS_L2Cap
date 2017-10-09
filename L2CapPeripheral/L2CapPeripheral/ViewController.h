//
//  ViewController.h
//  L2CapPeripheral
//
//  Created by hoehoe on 2017/10/08.
//  Copyright © 2017年 chocbanana. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTPeripheral.h"

@interface ViewController : UIViewController<BTPeripheralDelegate>
{
    NSMutableString* logString;
}
@property(nonatomic, strong)BTPeripheral* p;

@property (weak, nonatomic) IBOutlet UITextView *txt_view;

@end

