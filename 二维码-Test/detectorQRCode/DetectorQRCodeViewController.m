//
//  DetectorQRCodeViewController.m
//  二维码-Test
//
//  Created by lizhongfei on 18/12/17.
//  Copyright © 2017年 lizhongfei. All rights reserved.
//

#import "DetectorQRCodeViewController.h"

@interface DetectorQRCodeViewController ()
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImageView;

- (IBAction)detectorQRCodeImage:(id)sender;
@end

@implementation DetectorQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


/**
     开始识别
 */
- (IBAction)detectorQRCodeImage:(id)sender {
    UIImage * image = self.QRCodeImageView.image;
    
    CIImage * imageCI = [[CIImage alloc] initWithImage:image];
    
    //创建二维码探测器
    CIDetector * detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    
    //直接探测二维码特征
   NSArray * featuresArray = [detector featuresInImage:imageCI];
    NSMutableString * resultStr = [NSMutableString string];
    for (CIFeature * feature in featuresArray) {
        CIQRCodeFeature * qrcodeFeature = (CIQRCodeFeature *)feature;
        NSLog(@"%@",qrcodeFeature.messageString);
        [resultStr appendString:qrcodeFeature.messageString];
    }
    
    //设置到结果textView
    self.resultTextView.text = resultStr;
}
@end
