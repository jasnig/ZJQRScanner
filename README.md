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

> 这是我写的<iOS_CUSTOMIZE_ANALYSIS>这本书籍中的一个demo, 如果你希望知道具体的实现过程和其他的一些常用效果的实现, 那么你应该能轻易在网上下载到免费的盗版书籍. 

> 当然作为本书的写作者, 还是希望有人能支持正版书籍. 如果你有意购买书籍, 在[这篇文章中](http://www.jianshu.com/p/510500f3aebd), 介绍了书籍中所有的内容和书籍适合阅读的人群, 和一些试读章节, 以及购买链接. 在你准备购买之前, 请一定读一读里面的说明. 否则, 如果不适合你阅读, 虽然书籍售价35不是很贵, 但是也是一笔损失.


> 如果你希望联系到我, 你可以联系QQ:597769272
> 或者通过[简书](http://www.jianshu.com/users/fb31a3d1ec30/latest_articles)联系到我