//
//  ZJQRScanerHelper.h
//  ZJQRCodeScaner
//
//  Created by ZeroJ on 16/9/26.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJQRScanerHelper : NSObject

/**
 *  生成一个二维码图片 默认图片边长为 300
 *
 *  @param string 二维码内容
 *
 *  @return 生成的二维码图片
 */
+ (UIImage *)createQRCodeWithString:(NSString *)string;

/**
 *  生成一个二维码图片 需指定图片的边长
 *
 *  @param string     二维码内容
 *  @param sideLength 图片的边长
 *
 *  @return 生成的二维码图片
 */
+ (UIImage *)createQRCodeWithString:(NSString *)string withSideLength:(CGFloat)sideLength;


/**
 *  从图片中识别二维码
 *
 *  @param image 二维码图片
 *
 *  @return 返回识别出的字符串
 */
+ (NSString *)recognizeQRCodeFromImage:(UIImage *)image;

/**
 *  添加一张图片到二维码上(头像)
 *
 *  @param codeImage 二维码图片
 *  @param image     要添加的图片
 *  @param sideLength     要添加的图片的边长尺寸
 *
 *  @return 返回合成的图片
 */
+ (UIImage *)composeQRCodeImage:(UIImage *)codeImage withImage:(UIImage *)image withImageSideLength:(CGFloat)sideLength;
@end
