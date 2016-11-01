//
//  ZJTestViewController.h
//  ZJQRCodeScaner
//
//  Created by ZeroJ on 16/11/1.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJTestViewController : UIViewController

- (void)startScanner;

- (void)createCodeWithQRString:(NSString *)qrString andLogoImage:(UIImage *)logo;


- (void)recognizedQRImage:(UIImage *)qrImage;
@end
