//
//  ViewController.m
//  L2CapManager
//
//  Created by hoehoe on 2017/10/06.
//  Copyright © 2017年 chocbanana. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    log = [NSMutableString string];
    self.m = [BTManager sharedInstance];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(connectedPeripheral:) name:@"connectedPeripheral" object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)connectedPeripheral:(NSNotification *)notification
{
    self.m.p.delegate = self;
}


-(void)logDelegate:(NSString *)message
{
    [log appendFormat:@"%@%@", message, @"\r\n"];
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        [self.txt_view setText:log];
    //});
}

@end
