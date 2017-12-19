//
//  CreateQRCodeViewController.m
//  二维码-Test
//
//  Created by lizhongfei on 18/12/17.
//  Copyright © 2017年 lizhongfei. All rights reserved.
//

#import "CreateQRCodeViewController.h"

@interface CreateQRCodeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImageView;
- (IBAction)generatorQRCode:(id)sender;
- (IBAction)generatorCustomQRCode:(id)sender;

@end

@implementation CreateQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

/**
 生成普通二维码
 */
- (IBAction)generatorQRCode:(id)sender {
    [self generatorQRCode];
}
/**
 生成自定义二维码
 */
- (IBAction)generatorCustomQRCode:(id)sender {
    [self generatorCustomerQRCode];
}

#pragma mark - 生成普通二维码
/**
     生成普通二维码
 */
-(void)generatorQRCode{
    //创建二维码滤镜
    CIFilter * filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //回复滤镜默认设置
    [filter setDefaults];
    
    //设置滤镜输入数据
    [filter setValue:[@"lizhongfei" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
    
    //从二维码滤镜里面, 获取结果图片
    CIImage * image = filter.outputImage;
    
    //因为生成的图片默认大小是23*23的，所以显示到我们的控件上会变形，这里处理一下，就是放大一下
    image = [image imageByApplyingTransform:CGAffineTransformMakeScale(20, 20)];
    
    //转成UIImage
    UIImage * resultImage = [UIImage imageWithCIImage:image];
    
    self.QRCodeImageView.image = resultImage;
}

#pragma mark - 生成自定义二维码
/**
  生成自定义二维码
 */
-(void)generatorCustomerQRCode{
    //创建二维码滤镜
    CIFilter * filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //回复滤镜默认设置
    [filter setDefaults];
    
    //设置滤镜输入数据
    [filter setValue:[@"lizhongfei" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
    
    //从二维码滤镜里面, 获取结果图片
    CIImage * image = filter.outputImage;
    
    //因为生成的图片默认大小是23*23的，所以显示到我们的控件上会变形，这里处理一下，就是放大一下
    image = [image imageByApplyingTransform:CGAffineTransformMakeScale(20, 20)];
    
    //转成UIImage
    UIImage * resultImage = [UIImage imageWithCIImage:image];
    
    self.QRCodeImageView.image = [self drawCustomerQRCodeImage:resultImage withLogo:[UIImage imageNamed:@"logo"]];
}
/**
     绘制自定义二维码图片
 */
-(UIImage *)drawCustomerQRCodeImage:(UIImage *)soureImage withLogo:(UIImage *)logoImage{
    CGSize size = soureImage.size;
    
    //开启图形上下文
    UIGraphicsBeginImageContext(size);
    
    //把生成的二维码绘制上去
    [soureImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    //然后绘制logo
    CGFloat frameW = 60;
    CGFloat frameH = 60;
    CGFloat frameX = 0.5*(size.width - frameW);
    CGFloat frameY = 0.5*(size.height - frameH);
    [logoImage drawInRect:CGRectMake(frameX, frameY, frameW, frameH)];
    
    //从上下文中取出图片
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return resultImage;
    
}


@end
