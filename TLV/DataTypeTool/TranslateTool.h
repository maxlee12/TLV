//
//  TranslateTool.h
//  TelinkBlueDemo
//
//  Created by telink on 15/12/9.
//  Copyright © 2015年 Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TranslateTool : NSObject

/**
 *  十进制整数十六进制字符串（例子：110-->6e）
 */
+ (NSString *)ToHex:(long long int)tmpid;
/**
 *  普通字符串转十六进制字符串（例子：lihui-->6c69687569）
 */
+ (NSString *)hexStringFromString:(NSString *)string;

/**
 *  十六进制字符串转普通字符串（例子：6c69687569-->lihui）
 */
+ (NSString *)stringFromHexString:(NSString *)hexString;

/**
 *  十进制转换成二进制字符串（例子：10 --> 1010）
 */
+ (NSString *)binaryStringFromDecimalString:(NSString *)decimalString;

/**
 *  二进制字符串转十进制字符串
 */
+ (NSString *)toDecimalWithBinary:(NSString *)binary;

/**
 *  二进制字符串转NSData
 */
+ (NSData *)bitToData:(NSString *)bits;

/**
 *  十六进制字符串转NSData
 */
+ (NSData *)transStrHexToData:(NSString *)strHex andLen:(NSInteger)len;

/**
 *  NSData转十进制字符串
 */
+ (NSInteger)uint16FromNetData:(NSData *)data;



@end
