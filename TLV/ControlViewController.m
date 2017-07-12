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
#import "CocoaSecurity.h"
#import "SubViewController.h"
@interface ControlViewController ()<RevDataDelegate>
{
    IBOutlet __weak UITextView *_senTextV;
    IBOutlet __weak UITextView *_revTextV;
    
    IBOutlet __weak UILabel *macLab;
    IBOutlet __weak UILabel *ipLab;
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
    
    [ControlProtol sharedInstance].delegate = self;
    
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
    
    macLab.text = _deviceMac;
    ipLab.text = _deviceIp;
    //
    
    //
    [[ControlProtol sharedInstance] connect];
    [ControlProtol sharedInstance].delegate = self;
}

-(void)statusChange:(NSNotification*)noti{
    
    NSLog(@"statusChange:%@",noti.userInfo);
}

-(void)receiveData:(NSNotification*)noti{
    
    NSLog(@"receiveData:%@",noti.userInfo);
    
}

-(void)didReciveData:(NSData *)data fromAddress:(NSData *)address{
    
    //
    //host
    NSMutableString * host = [[NSMutableString alloc] init];
    for (int i = 0; i < address.length; i++){
        UInt8 no = ((UInt8 *)address.bytes)[i];
        [host appendFormat:@"%d.",no];
    }
    NSString *tempHost = [host substringWithRange:NSMakeRange(0, host.length-1)];
    //
    
    UInt8 flag = ((UInt8 *)[data bytes])[1];
    //
    if (flag == 0x02 ) {
        return;
    }
    
    //
    NSData *bodyData = [data subdataWithRange:NSMakeRange(24, data.length - 24)];
    NSData *enBodyData = [CocoaSecurity decryptAes128Data:bodyData andkey:@"BPEj4idhF4wlqe20"];
    NSArray *arr = [[DicToData sharedInstance] dicWithNsdata:enBodyData];
    
    NSLog(@"enBodyData:%@",enBodyData);
    NSLog(@"responseArr:%@",arr);
    
    _revTextV.text  = [NSString stringWithFormat:@"%@",data];
}

-(IBAction)backToSearch:(id)sender{

    [self dismissViewControllerAnimated:YES completion:nil];
}



-(IBAction)discoverDevice:(id)sender{
    
    NSString *mac = @"0xFFFFFFFFFFFF";
    NSDictionary *bodyDic = @{
                              @"cmd":@"0x0000",
                              @"devMac":mac,
                              };
    NSData *sendata = [[DicToData sharedInstance] dataWithDic:bodyDic and:mac];
//    NSString *host = [Util getBroadcastAddress];
    
    [[ControlProtol sharedInstance] sendProtocol:sendata host:@"255.255.255.255"];
    
    _senTextV.text = [NSString stringWithFormat:@"%@",sendata];
    
}



-(IBAction)queryGPIO:(id)sender{

    NSInteger index = 13;
    
    NSDictionary *bodyDic = @{
                              @"cmd":@"0x0150",
                              @"Dev_GPIO":[NSString stringWithFormat:@"0x%.2lu%@",index,@"0000"],
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
    
    NSInteger time = [[NSDate date] timeIntervalSince1970];
    
    NSDictionary *bodyDic = @{
                              @"cmd":@"0x0030",
                              @"heartBeat":[NSString stringWithFormat:@"%ld",(long)time],
                              };
    NSData *sendata = [[DicToData sharedInstance] dataWithDic:bodyDic and:_deviceMac];
    NSString *host = _deviceIp;
    
    [[ControlProtol sharedInstance] sendProtocol:sendata host:host];
    
    _senTextV.text = [NSString stringWithFormat:@"%@",sendata];
    
    if (!_beatTimer) {
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 repeats:YES block:^(NSTimer * _Nonnull timer) {
            
            [self startHeartBeat:sender];
            
        }];
        _beatTimer = timer;
    }

    
    
    
}

-(IBAction)stopHeartBeat:(id)sender{
    
    
    [_beatTimer invalidate];
    _beatTimer = nil;
    
}

- (IBAction)pushToSubDevice:(id)sender{
    
    SubViewController *subVc = [[SubViewController alloc] init];
    subVc.deviceMac = self.deviceMac;
    subVc.deviceIp = self.deviceIp;
    
    [self presentViewController:subVc animated:YES completion:nil];
    
    
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
