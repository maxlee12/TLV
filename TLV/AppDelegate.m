//
//  AppDelegate.m
//  TLV
//
//  Created by lawrence on 16/12/14.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import "AppDelegate.h"

char g_mac[20] = {0};
int  g_smartConfig = 0;
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setXlwDevice];
    
    return YES;
}

-(void)setXlwDevice{
    
    _xlwDevice = [[XlwDevice alloc] init];
    _xlwDevice.delegate = self;
    NSLog(@"init device(%s)...", [_xlwDevice GetLibraryVersion]);
    [_xlwDevice SetStatucCheck:3000];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [_xlwDevice LibraryResume];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(bool)onSmartFound:(char *)mac MODULE_IP:(char *)ip MODULE_VER:(char *)ver MODULE_CAP:(char *)cap MODULE_EXT:(char*)ext
{
    NSNotification * notice = [NSNotification notificationWithName:Noti_SmartFound object:nil userInfo:@{@"mac":[NSString stringWithUTF8String:mac],@"ip":[NSString stringWithUTF8String:ip]}];
    [[NSNotificationCenter defaultCenter]postNotification:notice];
    NSLog(@"onSmartFound(), mac=%s, ip=%s, ver=%s, cap=%s, ext=%s", mac, ip, ver, cap, ext);
    [_xlwDevice SmartConfigStop];
    strcpy(g_mac, mac);
    return true;
}

-(bool)onSearchFound:(char*)mac  MODULE_IP:(char*)ip MODULE_VER:(char*)ver MODULE_CAP:(char*)cap MODULE_EXT:(char*)ext
{
    NSLog(@"onSearchFound(), mac=%s, ip=%s, ver=%s, cap=%s, ext=%s", mac, ip, ver, cap, ext);
    strcpy(g_mac, mac);
    NSLog(@"find it");
    
    NSString *isCoonected ;
    
    if([_xlwDevice DeviceIsConnected:mac] != 1){
        if([_xlwDevice DeviceConnect:mac] == 1){
            isCoonected = @"YES";
        }else{
            isCoonected = @"NO";
        }
        
        NSNotification * notice = [NSNotification notificationWithName:Noti_SearchFound object:nil userInfo:@{@"mac":[NSString stringWithUTF8String:mac],@"coon":isCoonected,@"ip":[NSString stringWithUTF8String:ip]}];
        [[NSNotificationCenter defaultCenter]postNotification:notice];
    }
    
    
    return true;
}
-(void)onStatusChange:(char *)mac MODULE_STATUS:(int)status
{
    NSNotification * notice = [NSNotification notificationWithName:Noti_StatusChange object:nil userInfo:@{@"mac":[NSString stringWithFormat:@"%s",mac],@"status":[NSString stringWithFormat:@"%d", status]}];
    [[NSNotificationCenter defaultCenter]postNotification:notice];
    NSLog(@"onStatusChange(), mac=%s, status=%d", mac, status);
}
-(void)onReceive:(char*)mac RECEIVE_DATA:(char*)data RECEIVE_LEN:(int)len;
{
    NSLog(@"OnReceive %@, ",[NSData dataWithBytes:data length:len]);
    NSData *newData = [NSData dataWithBytes:data length:len];
    NSString *newStr = [self convertDataToHexStr:newData];
    NSNotification * notice = [NSNotification notificationWithName:Noti_ReceiveData object:nil userInfo:@{@"mac":[NSString stringWithFormat:@"%s",mac],@"data":newStr}];
    [[NSNotificationCenter defaultCenter]postNotification:notice];
}
-(void)onSendError:(char*)mac SEND_SN:(int)sn SEND_ERR:(int)err;
{
    NSLog(@"recv send error %s, sn=%d, err=%d", mac, sn, err);
    
}

- (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}


@end
