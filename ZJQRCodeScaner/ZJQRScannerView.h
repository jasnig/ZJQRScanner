//
//  ZJCameraView.h
//  ZJQRCodeScaner
//
//  Created by ZeroJ on 16/9/25.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZJQRScannerView;

@protocol ZJQRScannerDelegate <NSObject>
/**
 *  扫描成功的代理回调方法 ---- 可以直接使用提供的设置block方法替代 代理
 *
 *  @param scanner      scanner
 *  @param resultString 扫描结果 -- 字符串
 */
- (void)qrScanner:(ZJQRScannerView *)scanner didFinishScanningWithResult:(NSString *)resultString;

@end

typedef void(^QRScannerFinishHandler)(ZJQRScannerView *scanner, NSString *resultString);

@interface ZJQRScannerView : UIView

/** 扫描框的背景图片 */
@property (strong, nonatomic) UIImage *backgroundImage;
/** 扫描线- 图片 */
@property (strong, nonatomic) UIImage *scrollImage;
/** 扫描线扫描一次的时间 可以设置扫描线滚动的速度 默认是2s */
@property (assign, nonatomic) CGFloat scrollImageAnimateDuration;

/** 代理 --- 也可直接使用block*/
@property (weak, nonatomic) id<ZJQRScannerDelegate> delegate;
/**
 *  设置扫描成功的回调 --- 当然你也可以使用代理来实现
 *  @param handler handler
 */
- (void)setScannerFinishHandler:(QRScannerFinishHandler)handler;
/** 开始扫描 */
- (void)startScanning;
/** 停止扫描 */
- (void)stopScanning;
@end
