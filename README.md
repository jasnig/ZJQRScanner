# ZJQRScanner
一个扫描二维码, 生成二维码, 识别图片中的二维码的demo, 可以直接使用

![qrScanner.gif](http://upload-images.jianshu.io/upload_images/1271831-abac79315cd5e171.gif?imageMogr2/auto-orient/strip)

```
    ZJQRScannerView *scanner = [ZJQRScannerView new];
    scanner.frame = self.view.bounds;
    [self.view addSubview:scanner];
    // 开始扫描
    [scanner startScanning];
    // 扫描完成
    [scanner setScannerFinishHandler:^(ZJQRScannerView *scanner, NSString *resultString) {
        // 扫描结束
        NSLog(@"内容是%@", resultString);
    }];
```