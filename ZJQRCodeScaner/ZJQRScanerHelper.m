//
//  ZJQRScanerHelper.m
//  ZJQRCodeScaner
//
//  Created by ZeroJ on 16/9/26.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import "ZJQRScanerHelper.h"

@implementation ZJQRScanerHelper

+ (UIImage *)createQRCodeWithString:(NSString *)string withSideLength:(CGFloat)sideLength {
    
    //滤镜 be set to default values
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];    
    //将字符串转换成NSData
    NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding];
    //设置输出数据
    [filter setValue:data forKey:@"inputMessage"];
    //设置纠错等级越高；即识别越容易，值可设置为L(Low) |  M(Medium) | Q | H(High)
    // 正因为有容错率 所以可以在中心添加图片, 仍然能够被识别
    [filter setValue:@"Q" forKey:@"inputCorrectionLevel"];
    
    //获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    
    // 如果直接缩放方法很模糊
//    UIImage *image = [UIImage imageWithCIImage:outputImage scale:2.0f orientation:UIImageOrientationUp];
    
    // 需要绘制高清图
    UIImage *image = [self scaleImage:outputImage withSideLength:sideLength];
    
    return image;

}

+ (UIImage *)createQRCodeWithString:(NSString *)string  {
    return [self createQRCodeWithString:string withSideLength:300.f];
}

//+ (UIImage *)createQRCodeWithString:(NSString *)string withSideLength:(CGFloat)sideLength withRGBColor:(UIColor *)color {
//    
//}

+ (UIImage *)scaleImage:(CIImage *)ciImage withSideLength:(CGFloat)sideLength {
    // 开启图形上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sideLength, sideLength), NO, 0.0f);
    UIImage *temp = [UIImage imageWithCIImage:ciImage];
    CGSize originalSize = temp.size;
    CGFloat scale = MIN(sideLength/originalSize.width, sideLength/originalSize.height);
    // 按比例计算缩放后的宽高
    size_t scaledWidth = originalSize.width * scale;
    size_t scaledHeight = originalSize.height * scale;
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    // 清晰
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    // 绘制缩放后的图片
    [temp drawInRect:CGRectMake(0, 0, scaledWidth, scaledHeight)];
    // 取得缩放后的图片
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束绘制
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (NSString *)recognizeQRCodeFromImage:(UIImage *)image {
    /* 这两种方式用来生成CIImage不是很好, 因为当传进来的image是基于CIImage的就会返回为nil
     * 同样的 可能返回的CGImage也为nil
    CIImage *ciImage = image.CIImage;
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
     */
    NSData *imageData = UIImagePNGRepresentation(image);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    if (!ciImage) return nil;
    // Apple提供的强大的识别功能, 可以支持多种类型的识别, 比如人脸识别
    CIDetector *qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                context:[CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}]
                                                options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    // CIFeature 返回的数组按照识别出的可信任度排序, 所以使用第一个是最精准的
    NSArray *resultArr = [qrDetector featuresInImage:ciImage];
    // 没有识别到
    if (resultArr.count == 0) return nil;
    // 第一个是最精准的
    CIQRCodeFeature *feature = resultArr[0];
    return feature.messageString;
}

+ (UIImage *)composeQRCodeImage:(UIImage *)codeImage withImage:(UIImage *)image withImageSideLength:(CGFloat)sideLength {
    
    UIGraphicsBeginImageContextWithOptions(codeImage.size, NO, 0.0f);
    
    CGFloat codeImageWidth = codeImage.size.width;
    CGFloat codeImageHeight = codeImage.size.height;
    // 绘制原来的codeImage
    [codeImage drawInRect:CGRectMake(0, 0, codeImageWidth, codeImageHeight)];
    // 绘制image到codeImage中心
    [image drawInRect:CGRectMake((codeImageWidth-sideLength)/2, (codeImageHeight-sideLength)/2,
                                sideLength, sideLength)];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;
}



@end
