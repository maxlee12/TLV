//
//  Util.m
//  TLV
//
//  Created by lawrence on 16/12/15.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import "Util.h"
#import "DataResult.h"

#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation Util
#pragma mark - 获取路由器地址 子网掩码 广播地址等信息
+ (NSString *) getBroadcastAddress {
    
    NSString *broadcastAddress = nil;
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        //*/
        while(temp_addr != NULL)
        /*/
         int i=255;
         while((i--)>0)
         //*/
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String //ifa_addr
                    //ifa->ifa_dstaddr is the broadcast address, which explains the "255's"
                    //                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                    //--192.168.1.255 广播地址
                    //                    NSLog(@"broadcast address--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);
                    //--192.168.1.106 本机地址
                    //                    NSLog(@"local device ip--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]);
                    //--255.255.255.0 子网掩码地址
                    //                    NSLog(@"netmask--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
                    //--en0 端口地址
                    //                    NSLog(@"interface--%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
                    
                    broadcastAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    //    // Free memory
    //    freeifaddrs(interfaces);
    //
    //    in_addr_t i =inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
    //    in_addr_t* x =&i;
    //
    //    unsigned char *s=getdefaultgateway(x);
    //    // --路由器Ip
    //    NSString *ip=[NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];
    //    free(s);
    
    return broadcastAddress;
}




#pragma mark-scoket的数据转化

+ (UInt8)getuint8FromHexStr:(NSString *)hexStr;
{
    NSData *typeData = [[[DataResultDecoder alloc] init] hex:hexStr];
    UInt8 type[1];
    memcpy(type + 0, [typeData bytes], 1);
    return type[0];
    
}

+ (UInt16)uint16FromNetData:(NSData *)data
{
    return ntohs(*((UInt16 *)[data bytes]));
}

+ (UInt32)uint32FromNetData:(NSData *)data
{
    return ntohl(*((UInt32 *)[data bytes]));
}

//
+ (NSData *)netDataFromUint16:(UInt16)number
{
    UInt16 netNumber = htons(number);
    NSData * data = [NSData dataWithBytes:(Byte *)&netNumber length:2];
    return data;
}


//16进制字符串转byte
+(Byte)uint8From16Str:(NSString*)str_16{
    
    Byte byt = 0;
    if(str_16.length)
    {
        byt =  strtoul([str_16 UTF8String], 0, 16);
    }
    return byt;
}

/*

//   转换Int数据到字节数组
-(Byte)intToByte{
    unsigned int intVariable,i;
    unsigned char charArray[2];
//    (unsigned char) * pdata = ((unsigned char)*)&intVariable;  //进行指针的强制转换
    (unsigned char) *pdata = ((unsigned char) *)&intVariable;
    for(i=0;i<2;i++)
    {
        charArray[i] = *pdata++;
    }
}

//   转换float数据到字节数组
-(Byte)floatToByte{
    unsigned int i;
    float floatVariable;
    unsigned char charArray[4];
    (unsigned char) * pdata = ((unsigned char)*)&floatVariable;  //进行指针的强制转换
    for(i=0;i<4;i++)
    {
        charArray[i] = *pdata++;
    }
}
//   转换字节数组到int数据

-(int)byteToInt{
    unsigned int   intVariable="0";
    unsigned char  i;
    void   *pf;
    pf   =&intVariable;
    (unsigned char) * px = charArray;
    for(i=0;i<2;i++)
    {
        *(((unsigned char)*)pf+i)=*(px+i);
    }
}

//   转换字节数组到float数据
-(float)byteToFloat{
    float   floatVariable="0";
    unsigned char  i;
    void   *pf;
    pf   =&floatVariable;
    (unsigned char) * px = charArray;
    for(i=0;i<4;i++)
    {
        *(((unsigned char)*)pf+i)=*(px+i);
    }
}
//使用结构和联合 定义结构和联合如下
typedef union {
    
    struct {
    unsigned char low_byte;
    unsigned char mlow_byte;
    unsigned char mhigh_byte;
    unsigned char high_byte;
    }float_byte;
    
    struct {
        unsigned int low_word;
        unsigned int high_word;
    }float_word;
    
    float  value;
}FLOAT;

typedef union   {
    struct {
        unsigned char low_byte;
        unsigned char high_byte;
    } d1;
    unsigned int value;
} INT;


//使用方法： 对于浮点数：
//FLOAT floatVariable；在程序中直接使用floatVariable.float_byte.high_byte,floatVariable.float_byte.mhigh_byte,
//floatVariable.float_byte.mlow_byte,floatVariable.float_byte.low_byte这四个字节就可以方便的进行转换了。
//例子：
-(void)main
{
    unsigned char c[]={0x80,0xDA,0xCC,0x41};//四个字节顺序颠倒一下赋值
    FLOAT x;
    x.float_byte.high_byte=0x41;
    x.float_byte.mhigh_byte=0xCC;
    x.float_byte.mlow_byte=0xDA;
    x.float_byte.low_byte=0x80;
    
    printf("%f/n",x.value);//25.607
}
//对于整数：
//INT intVariable;在程序中直接使用intVariable.value.high_byte,intVariable.value.low_byte就OK了。
//三、对整型数可以用数学运算的方法进行转换
-(void)intToChar{
    unsigned int intVariable;
    unsigned char low_byte = intVariable%256;
    unsigned char high_byte = intVariable/256;
}
 
 */
 
@end
