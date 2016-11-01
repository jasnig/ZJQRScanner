//
//  ViewController.m
//  ZJQRCodeScaner
//
//  Created by ZeroJ on 16/9/25.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import "ViewController.h"
#import "ZJQRScanerHelper.h"
#import "ZJTestViewController.h"
@interface ViewController ()
<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<NSString *> *titlesArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titlesArray = @[@"扫描二维码", @"识别图片中的二维码",  @"生成二维码", @"生成带有头像的二维码"];
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titlesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kCellID = @"kCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
    }
    cell.textLabel.text = self.titlesArray[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0: {
            
            // 真机测试
            ZJTestViewController *testVc = [ZJTestViewController new];
            [testVc startScanner];
            [self.navigationController showViewController:testVc sender:nil];
        }
            break;
        case 1: {
            // 模拟相册选择了一张图片
            UIImage *qrImage = [ZJQRScanerHelper createQRCodeWithString:@"这是二维码" withSideLength:200.f];
            
            ZJTestViewController *testVc = [ZJTestViewController new];
            
            [testVc createCodeWithQRString:@"这是二维码" andLogoImage:nil];
            
            [testVc recognizedQRImage:qrImage];
            [self.navigationController showViewController:testVc sender:nil];

        }
            
            
            break;
        case 2: {
            ZJTestViewController *testVc = [ZJTestViewController new];
            [testVc createCodeWithQRString:@"这是没有logo的二维码" andLogoImage:nil];
            [self.navigationController showViewController:testVc sender:nil];

        }
            
            break;
        case 3: {
            ZJTestViewController *testVc = [ZJTestViewController new];
            [testVc createCodeWithQRString:@"这是带有logo的二维码" andLogoImage:[UIImage imageNamed:@"1-开心"]];
            [self.navigationController showViewController:testVc sender:nil];

        }
            break;
    }
}



- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
