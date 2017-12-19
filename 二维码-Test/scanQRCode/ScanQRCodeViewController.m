//
//  ScanQRCodeViewController.m
//  二维码-Test
//
//  Created by lizhongfei on 18/12/17.
//  Copyright © 2017年 lizhongfei. All rights reserved.
//

#import "ScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *QRCode_imageline_tobuttom_qrcodeimage;
@property (weak, nonatomic) IBOutlet UIView *QRCodeBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeLineImageView;

/** 会话 */
@property (nonatomic, strong) AVCaptureSession *QRCodeSession;

/** 预览图层 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * layer;

@end

@implementation ScanQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"单击屏幕开始扫描";
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self startScanAnimation];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self startScan];
}

#pragma mark -开始扫描
/**
     开始扫描
 */
-(void)startScan{
    //输入
    //获取摄像头
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //设置摄像头为输入设备
    NSError * error = nil;
   AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error != nil) {
        return;
    }
    
    //输出
    AVCaptureMetadataOutput * outPut = [[AVCaptureMetadataOutput alloc] init];
    
    //设置输出代理
    [outPut setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //创建会话，链接输入和输出
    self.QRCodeSession = [[AVCaptureSession alloc] init];
    if ([self.QRCodeSession canAddInput:input] && [self.QRCodeSession canAddOutput:outPut]) {
        [self.QRCodeSession addInput:input];
        [self.QRCodeSession addOutput:outPut];
    } else {
        return;
    }
    
    //设置识别的码制
    outPut.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    //设置兴趣区：即扫描的有效范围区域，那个框所在的区域，二维码不进入那个区域无法识别扫描。特别说明：这个设置兴趣区就是设置比例（0到1）而不是设置frame，并且原点在右上角
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat proportionX = self.QRCodeBgImageView.frame.origin.x / bounds.size.width;
    CGFloat proportionY = self.QRCodeBgImageView.frame.origin.y / bounds.size.height;
    CGFloat proportionW = self.QRCodeBgImageView.frame.size.width / bounds.size.width;
    CGFloat proportionH = self.QRCodeBgImageView.frame.size.height / bounds.size.height;
    //由于右上角是原点，所以需要翻转。右上角是原点就相当于横屏的左上角原点一样
    outPut.rectOfInterest = CGRectMake(proportionY, proportionX, proportionH, proportionW);
    
    //添加预览图层（用户可以看到界面，非必须）
    self.layer = [AVCaptureVideoPreviewLayer layerWithSession:self.QRCodeSession];
    self.layer.frame = self.view.bounds;
    //放到最下面
    [self.view.layer insertSublayer:self.layer atIndex:0];
    
    //启动会话
    [self.QRCodeSession startRunning];
}

#pragma mark -开始扫描
/**
     开始扫描
 */
-(void)startScanAnimation{
    self.QRCode_imageline_tobuttom_qrcodeimage.constant =  self.QRCodeBgImageView.frame.size.height - 2;//2是那个动画线条高度
    [self.view layoutIfNeeded];
    
    self.QRCode_imageline_tobuttom_qrcodeimage.constant = 0;
    [UIView animateWithDuration:2.0 animations:^{
        [UIView setAnimationRepeatCount:MAXFLOAT];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark -取消扫描动画
/**
     取消扫描动画
 */
-(void)cancelQRCodeScanAnimations{
    //点击屏幕可取消动画
    [self.QRCodeLineImageView.layer removeAllAnimations];
}

#pragma mark -AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    //移除之前绘制的层
    [self removeLastQRCodeBorderFrameLayer];
    
    for (id obj in metadataObjects) {
        if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            // 转换成为, 二维码, 在预览图层上的真正坐标
            // Obj.corners 代表二维码的四个角, 但是, 需要借助视频预览 图层,转换成为,我们需要的可以用的坐标
            AVMetadataObject * dataObject = (AVMetadataObject *)obj;
           AVMetadataMachineReadableCodeObject * resultObjAfterTransform =  (AVMetadataMachineReadableCodeObject *)[self.layer transformedMetadataObjectForMetadataObject:dataObject];
            
            NSLog(@"扫描结果：%@",resultObjAfterTransform.stringValue);
            
            //绘制二维码边框
            [self drawQRCodeBorder:resultObjAfterTransform];
        }
    }
    
}
/**
     移除上一次扫描绘制的边框图层
 */
-(void)removeLastQRCodeBorderFrameLayer{
    if (self.layer.sublayers != nil && self.layer.sublayers.count > 0) {
        NSArray * layerArray = [NSArray arrayWithArray:self.layer.sublayers];
        for (CALayer * subLayer in layerArray) {
            if ([subLayer isKindOfClass:[CAShapeLayer class]]) {
                [subLayer removeFromSuperlayer];
            }
        }
    } else {
        return;
    }
}
/**
     绘制二维码边框
 */
-(void)drawQRCodeBorder:(AVMetadataMachineReadableCodeObject *)resultObject{
    //里面的元素是字典：存放坐标的字典
    NSArray * cornersArray = resultObject.corners;
    
    //添加绘制的边框图层
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = UIColor.clearColor.CGColor;
    shapeLayer.strokeColor = UIColor.redColor.CGColor;
    shapeLayer.lineWidth = 4;
    
    //创建路径
    UIBezierPath * path = [UIBezierPath bezierPath];
    NSInteger index = 0;
    for (NSDictionary * cornerDict in cornersArray) {
        CGPoint point = CGPointZero;
        //从字典中取出坐标
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)cornerDict, &point);
        
        if (index == 0) {//第一个点
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
        
        index += 1;
        
    }
    [path closePath];
    
    //给图形图层的路径赋值, 代表, 图层展示怎样的形状
    shapeLayer.path = path.CGPath;
    
    //直接添加图形图层到需要展示的图层
    [self.layer addSublayer:shapeLayer];
}

@end
