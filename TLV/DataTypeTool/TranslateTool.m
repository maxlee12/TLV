//
//  TranslateTool.m
//  TelinkBlueDemo
//
//  Created by telink on 15/12/9.
//  Copyright © 2015年 Green. All rights reserved.
//

#import "TranslateTool.h"

@implementation TranslateTool

+(NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"a";break;
            case 11:
                nLetterValue =@"b";break;
            case 12:
                nLetterValue =@"c";break;
            case 13:
                nLetterValue =@"d";break;
            case 14:
                nLetterValue =@"e";break;
            case 15:
                nLetterValue =@"f";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;  
        }  
        
    }  
    return str;  
}



//普通字符串转换为十六进制的。
+ (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr]; 
    } 
    return hexStr; 
} 


// 十六进制转换为普通字符串的。
+ (NSString *)stringFromHexString:(NSString *)hexString { //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    return unicodeString;
    
    
}

//十进制转换成二进制字符串
+ (NSString *)binaryStringFromDecimalString:(NSString *)decimalString
{
    NSInteger num = [decimalString integerValue];
    NSInteger remainder = 0;      //余数
    NSInteger divisor = 0;        //除数
    
    NSString * prepare = @"";
    
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%ld",remainder];
        
        if (divisor == 0)
        {
            break;
        }
    }
    
    NSString * result = @"";
    for (NSInteger i = prepare.length - 1; i >= 0; i --)
    {
        result = [result stringByAppendingFormat:@"%@",
                  [prepare substringWithRange:NSMakeRange(i , 1)]];
    }
    
    return result;
}

//二进制转十进制
+ (NSString *)toDecimalSystemWithBinaryString:(NSString *)binary
{
    int ll = 0 ;
    int  temp = 0 ;
    for (int i = 0; i < binary.length; i ++)
    {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        ll += temp;
    }
    
    NSString * result = [NSString stringWithFormat:@"%d",ll];
    
    return result;
}

+ (NSString *)hanleNums:(NSString *)numbers
{
    NSString * str = [numbers substringWithRange:NSMakeRange(numbers.length%1, numbers.length-numbers.length%1)];
    NSString * strs = [numbers substringWithRange:NSMakeRange(0, numbers.length%1)];
    for (int  i =0; i < str.length; i =i+1) {
        NSString * sss = [str substringWithRange:NSMakeRange(i, 1)];
        strs = [strs stringByAppendingString:[NSString stringWithFormat:@",%@",sss]];
    }
    if ([[strs substringWithRange:NSMakeRange(0, 1)] isEqualToString:@","]) {
        strs = [strs substringWithRange:NSMakeRange(1, strs.length-1)];
    }
    return strs;
}




/**
 *  2进制转10进制
 */
+ (NSString *)toDecimalWithBinary:(NSString *)binary{

    int ll = 0 ;
    int  temp = 0 ;
    for (int i = 0; i < binary.length; i ++)
    {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        ll += temp;
    }
    
    NSString * result = [NSString stringWithFormat:@"%d",ll];
    
    return result;
}

/**
 *  bitToData
 */
+ (NSData *)bitToData:(NSString *)bits{
    if (bits.length%8) {
        
        return [[NSData alloc] init];
    }
    NSUInteger value = strtoul([bits UTF8String], NULL, 2);
    NSUInteger len = bits.length/8;
    NSData *data = [NSData dataWithBytes:&value length:len];
    return data;
}

/**
 *  16进制字符串转NSData
 */
+ (NSData *)transStrHexToData:(NSString *)strHex andLen:(NSInteger)len
{
    NSInteger exLen = 2*len;
    
    while (exLen != strHex.length) {
        
        if (exLen < strHex.length) {
           strHex = [strHex substringToIndex:exLen-1];
        }else{
            strHex = [NSString stringWithFormat:@"0%@",strHex];
        }
    }
    /// bytes索引
    NSUInteger j = 0;
    Byte *bytes = (Byte *)malloc((len / 2 + 1) * sizeof(Byte));
    
    /// 初始化内存 其中memset的作用是在一段内存块中填充某个给定的值，它是对较大的结构体或数组进行清零操作的一种最快方法
    memset(bytes, '\0', (len / 2 + 1) * sizeof(Byte));
    
    /// for循环里面其实就是把16进制的字符串转化为字节数组的过程
    for (NSUInteger i = 0; i < strHex.length; i += 2) {
        
        /// 一字节byte是8位(比特)bit 一位就代表一个0或者1(即二进制) 每8位(bit)组成一个字节(Byte) 所以每一次取2为字符组合成一个字节 其实就是2个16进制的字符其实就是8位(bit)即一个字节byte
        NSString *str = [strHex substringWithRange:NSMakeRange(i, 2)];
        /// 将16进制字符串转化为十进制
        unsigned long uint_ch = strtoul([str UTF8String], 0, 16);
        
        bytes[j] = uint_ch;
        
        /// 自增
        j ++;
    }
    /// 将字节数组转化为NSData
    NSData *data = [[NSData alloc] initWithBytes:bytes length:len];
    
    /// 释放内存
    free(bytes);
    
    return data;
}



+ (NSInteger)uint16FromNetData:(NSData *)data;
{
    return ntohs(*((UInt16 *)[data bytes]));
}










@end
