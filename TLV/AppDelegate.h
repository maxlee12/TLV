//
//  AppDelegate.h
//  TLV
//
//  Created by lawrence on 16/12/14.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <UIKit/UIKit.h>
//
#import "XlwDevice.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,XlwDeviceDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) XlwDevice *xlwDevice;


-(bool)onSmartFound:(char *)mac MODULE_IP:(char *)ip MODULE_VER:(char *)ver MODULE_CAP:(char *)cap;

-(bool)onSearchFound:(char*)mac  MODULE_IP:(char*)ip MODULE_VER:(char*)ver MODULE_CAP:(char*)cap MODULE_EXT:(char*)ext;

-(void)onStatusChange:(char *)mac MODULE_STATUS:(int)status;

-(void)onReceive:(char*)mac RECEIVE_DATA:(char*)data RECEIVE_LEN:(int)len;  //收到的数据

-(void)onSendError:(char*)mac SEND_SN:(int)sn SEND_ERR:(int)err;
@end

