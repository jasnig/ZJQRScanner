//
//  ZJCameraView.m
//  ZJQRCodeScaner
//
//  Created by ZeroJ on 16/9/25.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import "ZJQRScannerView.h"
#import <AVFoundation/AVFoundation.h>

@interface ZJQRScannerView ()<AVCaptureMetadataOutputObjectsDelegate> {
    // 用来作为上下左右的"背景"
    UIView *_topView;
    UIView *_downView;
    UIView *_leftView;
    UIView *_rightView;
}
// 采集设备
@property (strong, nonatomic) AVCaptureDevice *device;
// 输入设备
@property (strong, nonatomic) AVCaptureDeviceInput *deviceInput;
// 输出数据
@property (strong, nonatomic) AVCaptureMetadataOutput *metadataOutput;
// 会话
@property (strong, nonatomic) AVCaptureSession *session;
// 摄像头采集到的画面展示
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
// 我们自定义线程 来处理耗时操作-- 开始采集
@property (strong, nonatomic) dispatch_queue_t sessionQueue;

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImageView *scrollImageView;
@property (copy, nonatomic) QRScannerFinishHandler handler;
// 中间扫描区域的边长
@property (assign, nonatomic) CGFloat slideLength;

@end

@implementation ZJQRScannerView


- (instancetype)initWithDelegate:(id<ZJQRScannerDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _slideLength = 200;
    _scrollImageAnimateDuration = 2.f;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fitOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    // 使用SERIAL 保证FIFO
    self.sessionQueue = dispatch_queue_create("ZJCameraViewSession", DISPATCH_QUEUE_SERIAL);
    // 开始编辑输入和输出设备
    [self.session beginConfiguration];
    // 添加前一定要判断是否能够添加这种类型的设备, 否则不支持会crash
    if ([self.session canAddInput:self.deviceInput]) {
        // 添加输入设备
        [self.session addInput:self.deviceInput];
    }
    if ([self.session canAddOutput:self.metadataOutput]) {
        // 添加输出设备
        [self.session addOutput:self.metadataOutput];
    }
    // 设备添加和删除完成, 提交
    [self.session commitConfiguration];
    // 要先添加了设备, 才能设置MetadataObjectTypes
    // 设置支持识别的码类型, 系统是支持很多种的, 我们这里设置QR, 你可以设置为需要的类型
    NSArray *suportedType = [_metadataOutput availableMetadataObjectTypes];
    if ([suportedType containsObject:AVMetadataObjectTypeQRCode]) {
        [_metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    }
    // 设置子控件
    [self setupSubviews];
}


- (void)setupSubviews {
    
    // 初始化四周的view
    UIColor *bgColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    _topView = [UIView new];
    _topView.backgroundColor = bgColor;
    _rightView = [UIView new];
    _rightView.backgroundColor = bgColor;
    _leftView = [UIView new];
    _leftView.backgroundColor = bgColor;
    _downView = [UIView new];
    _downView.backgroundColor = bgColor;
    // 添加四周的view
    [self addSubview:_topView];
    [self addSubview:_rightView];
    [self addSubview:_downView];
    [self addSubview:_leftView];
    // 添加滚动线和扫描区域的背景ImageView
    [self addSubview:self.scrollImageView];
    [self addSubview:self.backgroundImageView];
    // 默认的图片
    self.backgroundImage = [UIImage imageNamed:@"scanBackground"];
    self.scrollImage = [UIImage imageNamed:@"scanLine"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.backgroundImage) {
        _slideLength = self.backgroundImage.size.width;
    }
    self.previewLayer.frame = self.bounds;
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    CGFloat bgImageViewX = (selfWidth - _slideLength)/2;
    CGFloat bgImageViewY = (selfHeight - _slideLength)/2;
    
    // 这里的frame设置稍微思考一下就清楚了
    self.backgroundImageView.frame = CGRectMake(bgImageViewX, bgImageViewY, _slideLength, _slideLength);
    _topView.frame = CGRectMake(0.f, 0.f, selfWidth, bgImageViewY);
    _leftView.frame = CGRectMake(0.f, bgImageViewY, bgImageViewX, _slideLength);
    _rightView.frame = CGRectMake(CGRectGetMaxX(self.backgroundImageView.frame), bgImageViewY, bgImageViewX, _slideLength);
    _downView.frame = CGRectMake(0.f, CGRectGetMaxY(self.backgroundImageView.frame), selfWidth, bgImageViewY);
    
    CGFloat scrollImageHeight = 1.0f;
    if (self.scrollImage) {
        scrollImageHeight = self.scrollImage.size.height;
    }
    self.scrollImageView.frame = CGRectMake(bgImageViewX, bgImageViewY, _slideLength, scrollImageHeight);
    /**
     *  设置扫描的有效区域
     *  这里需要注意 , rectOfInterest的 x, y, width, height的范围都是 0---1
     *  默认为(0,0,1,1) 代表 x和y都为0, 宽高都为previewLayer的宽高
     *  如果设置为 (0.5,0.5,0.5,0.5) 则表示居中显示, 宽高均为previewLayer的一半
     *  所以设置的时候, 需要和相应的 宽高求比例
     *  另外注意的是, 可以理解为系统处理图片的时候都是横着的, 当iPhone的屏幕确是竖着的
     *  时候应该 x = y/height;  y = x/height ...
     */
    if (self.bounds.size.width < self.bounds.size.height) { // 竖屏的时候
        self.metadataOutput.rectOfInterest = CGRectMake(bgImageViewY/selfHeight, bgImageViewX/selfWidth, _slideLength/selfHeight, _slideLength/selfWidth);
    }
    else {
        self.metadataOutput.rectOfInterest = CGRectMake(bgImageViewX/selfWidth, bgImageViewY/selfHeight, _slideLength/selfWidth, _slideLength/selfHeight);
    }
    if (self.bounds.size.width != 0) {// 有frame的时候添加动画和适应屏幕方向
        
        [self addAnimation];
        // 处理旋转 --- 也可以通过添加通知监听状态栏的方向来处理
//        [self fitOrientation];
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)fitOrientation {
    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationPortrait: {
            self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
            break;
        case UIInterfaceOrientationPortraitUpsideDown: {
            self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
        }
            break;
        case UIInterfaceOrientationLandscapeLeft: {
            self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
            break;
        case UIInterfaceOrientationLandscapeRight: {
            self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
            break;
        default:
            break;
    }
}


- (void)addAnimation {
    static NSString *const kPositionYKey = @"positionY";
    
    if ([self.scrollImageView.layer animationForKey:kPositionYKey]) {
        // 移除之前的, 可以适配旋转
        [self.scrollImageView.layer removeAnimationForKey:kPositionYKey];
    }
    // 改变Y值
    CABasicAnimation *scrollAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
//    scrollAnimation.fromValue = [NSNumber numberWithFloat:CGRectGetMinY(self.backgroundImageView.frame)] ;

    scrollAnimation.toValue = [NSNumber numberWithFloat:CGRectGetMaxY(self.backgroundImageView.frame) - self.scrollImageView.bounds.size.height];
    // 时间函数
    [scrollAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    // 自动反向
    scrollAnimation.autoreverses = YES;
    // 无限
    scrollAnimation.repeatCount = MAXFLOAT;
    scrollAnimation.duration = _scrollImageAnimateDuration;
    [self.scrollImageView.layer addAnimation:scrollAnimation forKey:kPositionYKey];
    
}

- (void)startScanning {
    // 耗时操作 另开线程
    dispatch_async(self.sessionQueue, ^{
        // 获取授权
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
            if (granted) {
                [self.session startRunning];
            }
            else {
                NSLog(@"用户未授权访问摄像头");
            }
        }];
    });
}

- (void)stopScanning {
    [self.session stopRunning];
}



- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        // 停止继续扫描, 否则会一直扫描
        [self stopScanning];

        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        // 调用handler
        if (_handler) {
            self.handler(self, metadataObject.stringValue);
        }
        // 调用代理
        if (_delegate && [_delegate respondsToSelector:@selector(qrScanner:didFinishScanningWithResult:)]) {
            [_delegate qrScanner:self didFinishScanningWithResult:metadataObject.stringValue];
        }
    }
}

- (void)setScannerFinishHandler:(QRScannerFinishHandler)handler {
    _handler = [handler copy];
}

- (void)changeTouchMode {
    if ([self.device hasTorch]) {// 如果有手电筒
        // 加锁操作
        [self.device lockForConfiguration:nil];
        if (self.device.torchMode != AVCaptureTorchModeOn) {// 未打开就打开
            self.device.torchMode = AVCaptureTorchModeOn;
        }
        else {// 否则关闭
            self.device.torchMode = AVCaptureTorchModeOff;
        }
        // 操作完成, 解锁
        [self.device unlockForConfiguration];
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    _backgroundImageView.image = backgroundImage;
    [self setNeedsLayout];
}

- (void)setScrollImage:(UIImage *)scrollImage {
    _scrollImage = scrollImage;
    _scrollImageView.image = scrollImage;
    [self setNeedsLayout];
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [UIImageView new];
        _backgroundImageView.contentMode = UIViewContentModeCenter;
    }
    return _backgroundImageView;
}


- (UIImageView *)scrollImageView {
    if (!_scrollImageView) {
        _scrollImageView = [UIImageView new];
        _scrollImageView.contentMode = UIViewContentModeCenter;
    }
    return _scrollImageView;
}
- (AVCaptureMetadataOutput *)metadataOutput {
    if (!_metadataOutput) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        // 设置代理, 通过代理方法可以获取到扫描的数据
        [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
    }
    return _metadataOutput;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        // 缩放方式
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        // 添加到self.layer
        [self.layer insertSublayer:_previewLayer atIndex:0];
        
    }
    return _previewLayer;
}

- (AVCaptureDeviceInput *)deviceInput {
    if (!_deviceInput) {
        NSError *error;
        _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
        if (error) {
            return nil;
        }
    }
    return _deviceInput;
}

- (AVCaptureDevice *)device {
    if (!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureSession *)session {
    if (!_session) {
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            // 设置为这个模式, 可以快速精确的扫描到较小的二维码
//            session.sessionPreset = AVCaptureSessionPreset1920x1080;
        }
        _session = session;
    }
    return _session;
}

@end
