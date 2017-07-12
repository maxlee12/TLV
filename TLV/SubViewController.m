//
//  SubViewController.m
//  TLV
//
//  Created by lawrence on 17/7/12.
//  Copyright © 2017年 李辉. All rights reserved.
//

#import "SubViewController.h"
#import "ControlProtol.h"
#import "DicToData.h"
#import "Util.h"
#import "CocoaSecurity.h"
#import "TLVModle.h"
@interface SubViewController ()<RevDataDelegate>{
    
    IBOutlet __weak UITextView *_senTextV;
    IBOutlet __weak UITextView *_revTextV;
    
    IBOutlet __weak UILabel *adressLab;
    IBOutlet __weak UILabel *typeLab;
    IBOutlet __weak UILabel *stauesLab;
}

@property(nonatomic,strong) NSString *subAdress;
@property(nonatomic,strong) NSString *subDevType;

@end

@implementation SubViewController

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [ControlProtol sharedInstance].delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //
    [[ControlProtol sharedInstance] connect];

}

-(IBAction)addSubDevice:(id)sender{
    
    NSString *Addr = @"0x00000011";
    NSString *Dev_type = @"0x011";
    
    if (_subAdress.length && _subDevType.length) {
        Addr = _subAdress;
        Dev_type = _subDevType;
    }
    
    NSDictionary *bodyDic = @{
                              @"cmd":@"0x01c0",
                              @"Num":@"0x01",
                              @"Addr":Addr,
                              @"Dev_type":Dev_type,
                              };
    if ([Dev_type integerValue] > 5) {
        bodyDic = @{
                    @"cmd":@"0x01c0",
                    @"Dev_type":Dev_type,
                    };
        
    }
    

    NSData *sendata = [[DicToData sharedInstance] dataWithDic:bodyDic and:_deviceMac];
    NSString *host = _deviceIp;
    
    [[ControlProtol sharedInstance] sendProtocol:sendata host:host];
    
    _senTextV.text = [NSString stringWithFormat:@"%@",sendata];
}

-(IBAction)openGPIO:(id)sender{
    
    NSString *Addr = @"0x00000011";
    NSString *Dev_type = @"0x11";
    
    if (_subAdress.length && _subDevType.length) {
        Addr = _subAdress;
        Dev_type = _subDevType;
    }
    
    NSDictionary *bodyDic = @{
                              @"cmd":@"0x01d0",
                              @"Addr":Addr,
                              @"Dev_type":Dev_type,
                              @"Num":@"0x00",
                              @"Dev_value":@"0xFF",
                              };
    NSData *sendata = [[DicToData sharedInstance] dataWithDic:bodyDic and:_deviceMac];
    NSString *host = _deviceIp;
    
    [[ControlProtol sharedInstance] sendProtocol:sendata host:host];
    
    _senTextV.text = [NSString stringWithFormat:@"%@",sendata];
}


-(IBAction)closeGPIO:(id)sender{
    
    
    NSString *Addr = @"0x00000011";
    NSString *Dev_type = @"0x11";
    
    if (_subAdress.length && _subDevType.length) {
        Addr = _subAdress;
        Dev_type = _subDevType;
    }
    
    NSDictionary *bodyDic = @{
                              @"cmd":@"0x01d0",
                              @"Addr":Addr,
                              @"Dev_type":Dev_type,
                              @"Num":@"0x00",
                              @"Dev_value":@"0x00",
                              };
    NSData *sendata = [[DicToData sharedInstance] dataWithDic:bodyDic and:_deviceMac];
    NSString *host = _deviceIp;
    
    [[ControlProtol sharedInstance] sendProtocol:sendata host:host];
    
    _senTextV.text = [NSString stringWithFormat:@"%@",sendata];
}

-(IBAction)queryGPIO:(id)sender{
    
    
    NSString *Addr = @"0x00000011";
    NSString *Dev_type = @"0x11";
    
    if (_subAdress.length && _subDevType.length) {
        Addr = _subAdress;
        Dev_type = _subDevType;
    }
    
    NSDictionary *bodyDic = @{
                              @"cmd":@"0x01e0",
                              @"Addr":Addr,
                              @"Dev_type":Dev_type,
                              @"Num":@"0x00",
                              };
    NSData *sendata = [[DicToData sharedInstance] dataWithDic:bodyDic and:_deviceMac];
    NSString *host = _deviceIp;
    
    [[ControlProtol sharedInstance] sendProtocol:sendata host:host];
    
    _senTextV.text = [NSString stringWithFormat:@"%@",sendata];
}

-(IBAction)backToSearch:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didReciveData:(NSData *)data fromAddress:(NSData *)address{
    
    //
    //host
    NSMutableString * host = [[NSMutableString alloc] init];
    for (int i = 0; i < address.length; i++){
        UInt8 no = ((UInt8 *)address.bytes)[i];
        [host appendFormat:@"%d.",no];
    }
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
    
    _revTextV.text  = [NSString stringWithFormat:@"%@",arr];
    
    for (TLVModle*modle in arr) {
        
        if ([modle.key isEqualToString:@"Addr"]) {
            
            _subAdress =[NSString stringWithFormat:@"0x%@",modle.dataValue];
            
            adressLab.text = _subAdress;
        }
        
        
        if ([modle.key isEqualToString:@"Dev_type"]) {
            
            _subDevType =[NSString stringWithFormat:@"0x%@",modle.dataValue];
            
            typeLab.text = _subDevType;
        }
        
        
        if ([modle.key isEqualToString:@"Dev_value"]) {
            
            stauesLab.text =[NSString stringWithFormat:@"0x%@",modle.dataValue];
        }
        
    }
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
