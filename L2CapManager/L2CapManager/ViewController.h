//
//  ViewController.h
//  L2CapManager
//
//  Created by hoehoe on 2017/10/06.
//  Copyright © 2017年 chocbanana. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTManager.h"

@interface ViewController : UIViewController<BTPeripheralDelegate>
{
    NSMutableString* log;
}

@property(nonatomic, strong)BTManager *m;

@property (weak, nonatomic) IBOutlet UITextView *txt_view;

@end

