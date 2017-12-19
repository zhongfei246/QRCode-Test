## iOS QRCode 二维码生成、识别、扫描demo

这是一个iOS二维码生成、识别。扫描的demo。以下是简要介绍，具体还请看demo源码。如有不对的地方欢迎指正，如有帮助欢迎给star，谢谢！


先看几张效果图：

<figure>
    <img src="https://github.com/zhongfei246/QRCode-Test/blob/master/%E4%BA%8C%E7%BB%B4%E7%A0%81-Test/screenshots/1.jpg" width="300" align="center"/>
    <img src="https://github.com/zhongfei246/QRCode-Test/blob/master/%E4%BA%8C%E7%BB%B4%E7%A0%81-Test/screenshots/2.jpg" width="300" align="center"/>
     <img src="https://github.com/zhongfei246/QRCode-Test/blob/master/%E4%BA%8C%E7%BB%B4%E7%A0%81-Test/screenshots/3.jpg" width="300" align="center"/>
     <img src="https://github.com/zhongfei246/QRCode-Test/blob/master/%E4%BA%8C%E7%BB%B4%E7%A0%81-Test/screenshots/4.jpg" width="300" align="center"/>
</figure>

## 主要功能模块（Contents）

* 生成二维码，生成自定义的二维码
* 识别图片二维码
* 扫描兴趣区域内的二维码

## 使用注意
* 直接下载即可
* 运行需用真机，否则点击扫描二维码时没有反应。

## 功能介绍
### 生成普通二维码，生成自定义的二维码
```objc
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
```

### 生成自定义二维码
```objc
#pragma mark - 生成自定义二维码
/**
  生成自定义二维码：其实是在上一步的基础上拿到二维码图片后利用Quartz2d在上面绘制一个小的logo图片，然后合成一张二维码图片
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

```
### 识别图片二维码
```objc
#pragma mark - 识别图片二维码（这里只做图片二维码识别，使用者进行扩展，比如可以添加图库中的二维码图片进行识别）
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
```

### 扫描兴趣区域内的二维码
```objc

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

#pragma mark -扫描动画
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

#pragma mark -AVCaptureMetadataOutputObjectsDelegate：扫描结果代理方法
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
```

## 有问题反馈
在使用中有任何问题，欢迎反馈给我，可以用以下联系方式跟我交流

* 邮件(1440182323@qq.com)
* QQ: 1440182323

