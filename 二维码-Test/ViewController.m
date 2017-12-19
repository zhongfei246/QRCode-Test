//
//  ViewController.m
//  二维码-Test
//
//  Created by lizhongfei on 18/12/17.
//  Copyright © 2017年 lizhongfei. All rights reserved.
//

#import "ViewController.h"

#import "CreateQRCodeViewController.h"
#import "DetectorQRCodeViewController.h"
#import "ScanQRCodeViewController.h"

@interface ViewController ()
- (IBAction)createQRCode:(id)sender;
- (IBAction)detectorQRCodeImage:(id)sender;
- (IBAction)scanQRCode:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"二维码-demo";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -生成二维码功能
/*
    生成二维码
 */
- (IBAction)createQRCode:(id)sender {
    [self.navigationController pushViewController:[[CreateQRCodeViewController alloc] init] animated:YES];
}

#pragma mark - 识别图片二维码
/*
 识别图片二维码
 */
- (IBAction)detectorQRCodeImage:(id)sender {
    [self.navigationController pushViewController:[[DetectorQRCodeViewController alloc] init] animated:YES];
}

#pragma mark - 扫描二维码
/*
  扫描二维码
 */
- (IBAction)scanQRCode:(id)sender {
    [self.navigationController pushViewController:[[ScanQRCodeViewController alloc] init] animated:YES];
}
@end
