//
//  ControlViewController.m
//  ControlDemo
//
//  Created by lawrence on 17/3/16.
//  Copyright © 2017年 李辉. All rights reserved.
//

#import "ControlViewController.h"
#import "ControlProtol.h"
#import "DicToData.h"

#import "Util.h"
@interface ControlViewController ()<RevDataDelegate>
{
    IBOutlet __weak UITextView *_senTextV;
    IBOutlet __weak UITextView *_revTextV;
}

@property(nonatomic,strong) NSString *deviceMac;
@property(nonatomic,strong) NSString *deviceIp;

@property(nonatomic,strong) NSTimer *beatTimer;

@end

@implementation ControlViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusChange:) name:Noti_StatusChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveData:) name:Noti_ReceiveData object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    _deviceMac = [NSString stringWithFormat:@"0x%@",_devDic[@"mac"]];
    _deviceIp = [NSString stringWithFormat:@"%@",_devDic[@"ip"]];
    
    
    
    [ControlProtol sharedInstance].delegate = self;
}

-(void)statusChange:(NSNotification*)noti{
    
    NSLog(@"statusChange:%@",noti.userInfo);
}

-(void)receiveData:(NSNotification*)noti{
    
    NSLog(@"receiveData:%@",noti.userInfo);
    
}

-(void)didReciveData:(NSData *)data fromAddress:(NSData *)address{
    
    _revTextV.text  = [NSString stringWithFormat:@"%@",data];
}

-(IBAction)backToSearch:(id)sender{

    [self dismissViewControllerAnimated:YES completion:nil];
}



-(IBAction)discoverDevice:(id)sender{
    
    NSDictionary *bodyDic = @{
                              @"cmd":@"0x0000",
                              @"discover":_deviceMac,
                              };
    NSData *sendata = [[DicToData sharedInstance] dataWithDic:bodyDic and:_deviceMac];
    NSString *host = [Util getBroadcastAddress];
    
    [[ControlProtol sharedInstance] sendProtocol:sendata host:host];
    
    _senTextV.text = [NSString stringWithFormat:@"%@",sendata];
    
}



-(IBAction)queryGPIO:(id)sender{

    NSDictionary *bodyDic = @{
                              @"cmd":@"0x0150",
                              @"Dev_GPIO":@"0x00",
                              };
    NSData *sendata = [[DicToData sharedInstance] dataWithDic:bodyDic and:_deviceMac];
    NSString *host = _deviceIp;
    
    [[ControlProtol sharedInstance] sendProtocol:sendata host:host];
    
    _senTextV.text = [NSString stringWithFormat:@"%@",sendata];
    
}


-(IBAction)openGPIO:(id)sender{
    
    
    NSDictionary *bodyDic = @{
                              @"cmd":@"0x0140",
                              @"Dev_GPIO":@"0x0000ffff",
                              };
    NSData *sendata = [[DicToData sharedInstance] dataWithDic:bodyDic and:_deviceMac];
    NSString *host = _deviceIp;
    
    [[ControlProtol sharedInstance] sendProtocol:sendata host:host];
    
    _senTextV.text = [NSString stringWithFormat:@"%@",sendata];
}

-(IBAction)closeGPIO:(id)sender{
    
    NSDictionary *bodyDic = @{
                              @"cmd":@"0x0140",
                              @"Dev_GPIO":@"0x000000ff",
                              };
    NSData *sendata = [[DicToData sharedInstance] dataWithDic:bodyDic and:_deviceMac];
    NSString *host = _deviceIp;
    
    [[ControlProtol sharedInstance] sendProtocol:sendata host:host];
    
    _senTextV.text = [NSString stringWithFormat:@"%@",sendata];
}


-(IBAction)startHeartBeat:(id)sender{
    
    NSTimeInterval time = NSTimeIntervalSince1970;
    
    NSDictionary *bodyDic = @{
                              @"cmd":@"0x0030",
                              @"heartBeat":[NSString stringWithFormat:@"%f",time],
                              };
    NSData *sendata = [[DicToData sharedInstance] dataWithDic:bodyDic and:_deviceMac];
    NSString *host = _deviceIp;
    
    [[ControlProtol sharedInstance] sendProtocol:sendata host:host];
    
    _senTextV.text = [NSString stringWithFormat:@"%@",sendata];
    
    
   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
       
       [self startHeartBeat:sender];
   }];
    
    _beatTimer = timer;
    
}

-(IBAction)stopHeartBeat:(id)sender{
    
    
    [_beatTimer invalidate];
    _beatTimer = nil;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
