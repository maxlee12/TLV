//
//  ViewController.m
//  ControlDemo
//
//  Created by lawrence on 17/3/16.
//  Copyright © 2017年 李辉. All rights reserved.
//

#import "ViewController.h"
#import "ControlViewController.h"
#import "AppDelegate.h"
//
#import <SystemConfiguration/CaptiveNetwork.h>
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{

    IBOutlet __weak UITextField *_wifiNameT;
    IBOutlet __weak UITextField *_wifiSecretT;
    IBOutlet __weak UITableView *_table;
}

@property (nonatomic,strong) NSMutableArray *deviceArr;
@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusChange:) name:Noti_StatusChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceFound:) name:Noti_SearchFound object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceFound:) name:Noti_SmartFound object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveData:) name:Noti_ReceiveData object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self layoutUI];
    
    [self setUIData];
}

#pragma mark NOtiMethod

-(void)deviceFound:(NSNotification*)noti{
    
    NSDictionary *dic = noti.userInfo;
    
    NSMutableArray *newArr = [NSMutableArray array];
    for (NSDictionary *divDic in _deviceArr) {
        [newArr addObject:divDic[@"mac"]];
    }
    
    if (![newArr containsObject:dic[@"mac"]]) {
        [_deviceArr addObject:dic];
        [self reloadOnMainthread];
    }
    
    
}

-(void)statusChange:(NSNotification*)noti{
  
}

-(void)receiveData:(NSNotification*)noti{
    
    
}



-(void)layoutUI{
    
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];

    _wifiNameT.returnKeyType = UIReturnKeyDone;
    _wifiSecretT.returnKeyType = UIReturnKeyDone;
}

-(void)setUIData{
    
    NSString *wifiName = [self getDeviceWiFiName];
    _wifiNameT.text = wifiName;
    _wifiSecretT.text = @"xiaoQuan_137";
    
    _deviceArr = [[NSMutableArray alloc] init];
}

-(void)reloadOnMainthread{
    
    [_table performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:nil];
}

-(IBAction)smartConfig:(id)sender{
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([app.xlwDevice SmartConfigV3_Start:(char*)[_wifiNameT.text UTF8String] PASSWORD:(char*)[_wifiSecretT.text UTF8String] TIMEOUT:60000] == false){
        NSLog(@"start smartconfig failed");
    }else{
        //开始配置蒸锅
        [app.xlwDevice DeviceSearch];
    }
}


-(IBAction)searchDevice:(id)sender{
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.xlwDevice DeviceSearch];
    
}

-(IBAction)reSearch:(id)sender{
    
    [_deviceArr removeAllObjects];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.xlwDevice DeviceClear];
    
    [self reloadOnMainthread];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _deviceArr.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    NSDictionary *dic = [_deviceArr objectAtIndex:indexPath.row];
    cell.textLabel.text =dic[@"mac"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ControlViewController *vc = [[ControlViewController alloc] init];
    NSDictionary *dic = [_deviceArr objectAtIndex:indexPath.row];
    vc.devDic = dic;
    [self presentViewController:vc animated:YES completion:nil];
    
//    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    app.xlwDevice.delegate = nil;
//    [app.xlwDevice DeviceClear];
//    [app.xlwDevice LibraryRelease];
//    [app.xlwDevice SetStatucCheck:0];
//    [app.xlwDevice SmartConfigStop];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    [textField resignFirstResponder];
    return YES;
}

#pragma mark getWifiName
-(NSString *)getDeviceWiFiName
{

    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        if (info && [info count]) { break; }
    }
    
    NSString *BSSID = info[@"SSID"];
    return BSSID.length?BSSID:@"";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
