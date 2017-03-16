//
//  Util.h
//  TLV
//
//  Created by lawrence on 16/12/15.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject
#pragma mark-scoket的数据转化

/*
 由器地址 子网掩码 广播地址等信息
 */
+ (NSString *) getBroadcastAddress;

/**
 *  十六进制字符串转十进制整数（例子：6e-->110）
 */
+ (UInt8)getuint8FromHexStr:(NSString *)hexStr;


+ (UInt16)uint16FromNetData:(NSData *)data;

+ (UInt32)uint32FromNetData:(NSData *)data;

//
+ (NSData *)netDataFromUint16:(UInt16)number;

/**
 *  十六进制字符串转byte (例子：6e-->'n'） ASCII
 */
+(Byte)uint8From16Str:(NSString*)str_16;

//shadow[13] =  *(Byte *)&index;
@end
