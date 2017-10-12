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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)logDelegate:(NSString *)message
{
    //NSLog(@"message: %@", message);
    [logString appendFormat:@"%@%@", message, @"\r\n"];
    [self.txt_view setText:logString];
}
@end
