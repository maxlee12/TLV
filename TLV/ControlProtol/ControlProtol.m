//
//  ControlProtol.m
//  ControlDemo
//
//  Created by lawrence on 17/3/16.
//  Copyright © 2017年 李辉. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "ControlProtol.h"
#import "GCDAsyncUdpSocket.h"

#import "Util.h"


//
//L口
#define DevicePort 8530
#define iOS_Version [[[UIDevice currentDevice]systemVersion] floatValue]



static ControlProtol *protolService = nil;
@interface ControlProtol()<GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket * _udpSocket;
    BOOL _connected;  //udp是否连接
    
}


@end

@implementation ControlProtol

+ (ControlProtol *)sharedInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protolService = [[ControlProtol alloc] init];
    });
    return  protolService;
}

#pragma mark 发送 sendProtocol

//host
- (void)sendProtocol:(NSData *)protocol host:(NSString *)host
{
    
    //app从后台进入的情况下 有可能wifi还未连接成功 不能进行udp连接
    if (!_udpSocket) {
        [self connect];
    }
    
    if (!protocol) {
        NSLog(@"local request = %@ 为空,跳出",protocol);
        return ;
    }
    
    if (!host) {
        NSLog(@"host = %@ 为空,跳出",host);
        return ;
    }
    
    int sendTimes = [host isEqualToString:[Util getBroadcastAddress]] ? 3: 1;
    
    
    for (int i = 0; i < sendTimes; i++)
    {
        [_udpSocket sendData:protocol toHost:host port:DevicePort withTimeout:-1 tag:0];
    }
}


#pragma mark 开启udpScoket
- (void)connect
{
    
    _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError * error = nil;
    if (iOS_Version >6.0f) {
        [_udpSocket enableBroadcast:YES error:&error];
        
    }
    if (![_udpSocket bindToPort:DevicePort error:&error])
    {
  
        NSLog(@"%@",[NSString stringWithFormat:@"LocalSocket Error binding: %@", [error localizedDescription]]);

    }
    else if (![_udpSocket enableBroadcast:YES error:&error])
    {
        
        NSLog(@"%@",[NSString stringWithFormat:@"LocalSocket Error enableBroadcast: %@", [error localizedDescription]]);

    }
    else if (![_udpSocket beginReceiving:&error])
    {
        NSLog(@"%@",[NSString stringWithFormat:@"LocalSocket Error receiving: %@", [error localizedDescription]]);
    }
    else
    {
        _connected = YES;
        NSLog(@"--------connect success");
        
    }
    
}

- (void)disconnect
{
    _connected = NO;
    _udpSocket.delegate = nil;
    [_udpSocket close];
    _udpSocket = nil;
}

#pragma mark -- LSDGCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.delegate &&[self.delegate respondsToSelector:@selector(didReciveData:fromAddress:)]) {
            
            [self.delegate didReciveData:data fromAddress:address];
        }
    });

}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    [self disconnect];
}


@end
