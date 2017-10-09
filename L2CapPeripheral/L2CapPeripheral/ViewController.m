//
//  ViewController.m
//  L2CapPeripheral
//
//  Created by hoehoe on 2017/10/08.
//  Copyright © 2017年 chocbanana. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    logString = [NSMutableString string];
    self.p = [[BTPeripheral alloc] init];
    self.p.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)logDelegate:(NSString *)message
{
    //NSLog(@"%@", message);
    [logString stringByAppendingString:message];
    self.txt_view.text = logString;
}
@end
