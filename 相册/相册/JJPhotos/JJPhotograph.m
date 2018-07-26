//
//  JJPhotograph.m
//  JJPhotograph
//
//  Created by 16 on 2018/7/25.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJPhotograph.h"
#import <AVFoundation/AVFoundation.h>

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define sw [UIScreen mainScreen].bounds.size.width
#define sh [UIScreen mainScreen].bounds.size.height
@interface JJPhotograph ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

///捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;
///AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;
///当启动摄像头开始捕获输入
@property(nonatomic)AVCaptureMetadataOutput *output;
@property (nonatomic)AVCaptureStillImageOutput *ImageOutPut;
///session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;
///图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;
@end
@implementation JJPhotograph
{
    CGFloat head_h;
    CGFloat foot_h;
    CGRect nomalFrame;
    UIButton *back;
    UIButton *photoBtn;
    UIButton *sure;
    CGRect sureFrame;
    UIButton *cancel;
    CGRect cancelFrame;
    UIImage *current;
}
- (instancetype)initWithFrame:(CGRect)frame type:(JJ_PhotographType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        head_h = 64;
        foot_h = 149;
        if (iPhoneX) {
            head_h = 88;
            foot_h = 183;
        }
        [self creatCamera];
        if (type == JJ_PhotographTypeNomal) {
            // 添加控制界面
            [self creatSubViews];
        }
    }
    return self;
}
- (void)creatCamera
{
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //使用设备初始化输入
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    
    //生成输出对象
    self.output = [[AVCaptureMetadataOutput alloc]init];
    self.ImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
    //生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc]init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.ImageOutPut]) {
        [self.session addOutput:self.ImageOutPut];
    }
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = self.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:self.previewLayer];
    
    //开始启动
    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}
- (void)creatSubViews
{
    UIButton *exchange = [[UIButton alloc] initWithFrame:CGRectMake(sw-45, head_h-40, 30, 30)];
    [exchange setImage:[UIImage imageNamed:@"exchange"] forState:UIControlStateNormal];
    [exchange addTarget:self action:@selector(exchange) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:exchange];
    
    back = [[UIButton alloc] initWithFrame:CGRectMake(60, sh-foot_h+40, 40, 40)];
    [back setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:back];
    
    photoBtn = [[UIButton alloc] initWithFrame:CGRectMake((sw-60)/2, sh-foot_h+30, 60, 60)];
    [photoBtn addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [photoBtn setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
    [self addSubview:photoBtn];
    nomalFrame = photoBtn.frame;
    
    sure = [[UIButton alloc] initWithFrame:nomalFrame];
    [sure setImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
    [sure addTarget:self action:@selector(saveImg) forControlEvents:UIControlEventTouchUpInside];
    sure.hidden = YES;
    [self addSubview:sure];
    sureFrame = CGRectMake(sw/2+50, sh-foot_h+30, 60, 60);
    
    cancel = [[UIButton alloc] initWithFrame:nomalFrame];
    [cancel setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    cancel.hidden = YES;
    [self addSubview:cancel];
    cancelFrame = CGRectMake(sw/2-110, sh-foot_h+30, 60, 60);
}
- (void)takePhoto:(UIButton *)sender
{
    if (sender == photoBtn) {
        [UIView animateWithDuration:0.3 animations:^{
            photoBtn.hidden = back.hidden = YES;
            sure.hidden = cancel.hidden = NO;
            sure.frame = sureFrame;
            cancel.frame = cancelFrame;
        }];
        
        AVCaptureConnection * videoConnection = [self.ImageOutPut connectionWithMediaType:AVMediaTypeVideo];
        if (!videoConnection) return;
        
        [self.ImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            // 判断图片信息是否为空
            if (imageDataSampleBuffer == NULL) return;
            // 获取图片信息
            NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            // 保存图片
            current = [UIImage imageWithData:imageData];
            // 停止拍照
            [self.session stopRunning];
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            [self.session startRunning];
            sure.frame = cancel.frame = nomalFrame;
        } completion:^(BOOL finished) {
            photoBtn.hidden = back.hidden = NO;
            sure.hidden = cancel.hidden = YES;
        }];
    }
}
- (void)saveImg
{
    UIImageWriteToSavedPhotosAlbum(current, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    [self.session stopRunning];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"保存失败");
    }else {
        if ([self.delegate respondsToSelector:@selector(JJPhotographDisappear:save:)]) {
            [self.delegate JJPhotographDisappear:self save:YES];
        }
    }
}
- (void)exchange
{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        
        CATransition *animation = [CATransition animation];
        animation.duration = .5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }
        else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
            } else {
                [self.session addInput:self.input];
            }
            
            [self.session commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}
- (void)back
{
    [self.session stopRunning];
    if ([self.delegate respondsToSelector:@selector(JJPhotographDisappear:save:)]) {
        [self.delegate JJPhotographDisappear:self save:NO];
    }
}
@end
