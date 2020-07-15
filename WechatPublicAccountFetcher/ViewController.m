//
//  ViewController.m
//  WechatPublicAccountFetcher
//
//  Created by 马岩 on 2019/11/24.
//  Copyright © 2019 马岩. All rights reserved.
//

#import "ViewController.h"
#import "Fetcher.h"
#import "Arranger.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSLog(@"documentsPath: %@", documentsPath);
}

- (IBAction)fetchButtonClick:(UIButton *)sender {
    [[Fetcher shareInstance] fetchGeneralMsgListWithOffset:@0];
}

- (IBAction)arrangeButtonClick:(id)sender {
    [[Arranger shareInstance] arrangeGeneralMsgList];
}


@end
