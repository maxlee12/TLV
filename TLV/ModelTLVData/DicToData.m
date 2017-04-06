//
//  DicToData.m
//  TLV
//
//  Created by lawrence on 17/3/16.
//  Copyright © 2017年 李辉. All rights reserved.
//

#import "DicToData.h"
#import "CocoaSecurity.h"
#import "HeadModle.h"
#import "TLVModle.h"

#import "Util.h"
#import "TranslateTool.h"
#import "GDataXMLNode.h"
#import "DataResult.h"
//
#import "GCDAsyncUdpSocket.h"
//
#import <ifaddrs.h>
#include <sys/socket.h>
#import <arpa/inet.h>

#import "ControlProtol.h"
@interface DicToData()

@property (nonatomic ,strong) NSMutableArray *headBaseArr;
@property (nonatomic ,strong) NSMutableArray *bodyBaseArr;
@property (nonatomic ,strong) NSData *requestData;

@end
static DicToData *dicToData = nil;
@implementation DicToData


+ (DicToData *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dicToData = [[DicToData alloc] init];
    });
    return dicToData;
}

-(id)init{
    
    if (self = [super init]) {
      
        _headBaseArr = [[NSMutableArray alloc] init];
        _bodyBaseArr = [[NSMutableArray alloc] init];
        
        [self loadXml];
    }
    
    return self;
}

#pragma mark modle转data

-(NSData*)dataWithDic:(NSDictionary*)bodyDic and:(NSString*)mac{
    
    NSMutableData *sendData = [NSMutableData data];
    
    /*
     BODY
     */
    NSData *bodyData = [self setBodyModlewith:bodyDic];
    //加密
    
    NSData *enBodyData = [CocoaSecurity encryptAes128Data:bodyData andkey:@"BPEj4idhF4wlqe20"];
    
//#warning mark debug-todelete
//    enBodyData = bodyData;
    
    NSUInteger len = enBodyData.length;
    NSInteger sum = [Util uintDataCheckSum:enBodyData];
    /*
     HEADER
     */
    NSDictionary *headDic = @{
                              @"Flag":@"01000000", //bit
                              @"Code":@"00000010", //bit
                              @"Message_ID":@"256",
                              @"Delimiter":@"11111111", //bit
                              @"Service_Code":@"0x05",
                              @"Group_ID":@"0x05000001",
                              @"Data_Len":[NSString stringWithFormat:@"%lu",(unsigned long)len],
                              @"Command":@"0x00",
                              @"Device_Id":mac,
                              @"Reserved":@"0xc000",
                              @"Checksum":[NSString stringWithFormat:@"%lu",sum%256],
                              };
    
    NSData *headData = [self setHeadModlewith:headDic];
    
    //组装header和body
    [sendData appendData:headData];
    [sendData appendData:enBodyData];
    
    //
    
    return sendData;

}

#pragma mark ------ data转modle

-(NSArray*)dicWithNsdata:(NSData*)data{

    NSMutableArray *bodyTlvArr = [[NSMutableArray alloc] init];
    
    while (data.length) {
        
        NSData *Tdata = [data subdataWithRange:NSMakeRange(0, 2)];
        NSData *Ldata = [data subdataWithRange:NSMakeRange(2, 2)];
        NSInteger length = [TranslateTool uint16FromNetData:Ldata];
        NSData *Vdata = [data subdataWithRange:NSMakeRange(4, length)];
        
        NSInteger totalLen = 4+length;
        data = [data subdataWithRange:NSMakeRange(totalLen, data.length - totalLen)];
        
        TLVModle *modle = [self setModleWithT:Tdata andL:length andV:Vdata];
        
        [bodyTlvArr addObject:modle];
        
    }
    
    NSLog(@"%@",bodyTlvArr);
    
    return bodyTlvArr;
}



#pragma mark xml转modle
-(void)loadXml{
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"resource" ofType:@"xml"];
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *data = [file readDataToEndOfFile];
    
    [file closeFile];
    
    //header
    GDataXMLDocument * document = [[GDataXMLDocument alloc] initWithData:data error:nil];
    GDataXMLElement* headElement = [[document.rootElement elementsForName:@"Head"] firstObject];
    
    
    for(GDataXMLElement * chunkElement in [headElement elementsForName:@"chunk"]){
        
        HeadModle *head = [[HeadModle alloc] init];
        for (GDataXMLNode* nod in chunkElement.attributes) {
            [head setValue:nod.stringValue forKey:nod.name];
        }
        [_headBaseArr addObject:head];
        
    }
    
    //body
    GDataXMLElement* bodyElement = [[document.rootElement elementsForName:@"Body"] firstObject];
    for(GDataXMLElement * chunkElement in [bodyElement elementsForName:@"chunk"]){
        
        TLVModle *tlv = [[TLVModle alloc] init];
        for (GDataXMLNode* nod in chunkElement.attributes) {
            [tlv setValue:nod.stringValue forKey:nod.name];
        }
        [_bodyBaseArr addObject:tlv];
        
    }
    
    //    NSLog(@"headBaseArr: %@",_headBaseArr);
    //    NSLog(@"bodyBaseArr: %@",_bodyBaseArr);
    
    
}



-(TLVModle*)setModleWithT:(NSData*)Tdata andL:(NSInteger)length andV:(NSData*)Vdata{
    
    
    NSInteger Tid = [TranslateTool uint16FromNetData:Tdata];
    NSArray *tempBodyBaseArr = [[NSArray alloc] initWithArray:_bodyBaseArr];
    for (TLVModle *tlvModle in tempBodyBaseArr) {
        
        TLVModle *temModle = [[TLVModle new] initWithTlV:tlvModle];
        temModle.len = [NSString stringWithFormat:@"%ld",(long)length];
        NSInteger  modleId;
        if ([temModle.idName hasPrefix:@"0x"]) {
            NSString* strId = [temModle.idName stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
            modleId = [[NSString stringWithFormat:@"%ld", strtoul([strId UTF8String],0,16)] integerValue];
        }
        
        if (modleId == Tid) {
            
            NSInteger type = [tlvModle.type integerValue];
            NSInteger value = 0;
            if (type == 0 || type == 1 || type == 2 || type == 3 || type == 4) {
                
                value = [TranslateTool uint16FromNetData:Vdata];
                temModle.dataValue = [NSString stringWithFormat:@"%ld",(long)value];
                return temModle;
            }
            
            if (type == 5) {
                //bye
                NSString *hexstr = [[[CocoaSecurityEncoder alloc] init] hex:Vdata useLower:YES];
                temModle.dataValue = [NSString stringWithFormat:@"%@",hexstr];
                return temModle;
            }
            if (type == 6) {
                //string
                NSString *value = [[NSString alloc] initWithData:Vdata encoding:NSUTF8StringEncoding];
                temModle.dataValue = [NSString stringWithFormat:@"%@",value];
                return temModle;
            }
            if (type == 7) {
                
                NSString *str = [[[DataResultEncoder alloc] init] hex:Vdata useLower:YES];
                
                if ([temModle.idName isEqualToString:@"0x0001"]) {
                    if ([str isEqualToString:@"0001"]) {
                        temModle.dataValue = @"turn off";
                    }
                    if ([str isEqualToString:@"0002"]) {
                        temModle.dataValue = @"turn on";
                    }
                }
                
                if ([temModle.idName isEqualToString:@"0x0F00"]) {
                    if ([str isEqualToString:@"0010"]) {
                        temModle.dataValue = @"lock";
                    }
                    if ([str isEqualToString:@"0020"]) {
                        temModle.dataValue = @"unLock";
                    }
                }
                
                return temModle;
            }
            
            
            temModle.dataValue =  [NSString stringWithFormat:@"%ld",(long)value];
            return temModle;
            
        }
        
    }
    
    @throw [NSException exceptionWithName:@"dataToModle"
                                   reason:[NSString stringWithFormat:@"%ld没有找到匹配值",(long)Tid]
                                 userInfo:nil];
    return nil;
}



#pragma mark ------ userDic
-(NSData*)setHeadModlewith:(NSDictionary *)dic{
    
    NSMutableData *sendData = [NSMutableData data];
    for (HeadModle *headModle in _headBaseArr) {
        
        for (NSString *key in dic.allKeys) {
            
            if ([headModle.idName isEqualToString:key]) {
                
                if (!headModle.defaultvalue.length && ![dic[key] length] ) {
                    
                    @throw [NSException exceptionWithName:@"modleTodata"
                                                   reason:[NSString stringWithFormat:@"%@没有默认值，不能为空",key]
                                                 userInfo:nil];
                }
                
                else{
                    
                    NSString *value = ((NSString*)dic[key]).length?dic[key]:headModle.defaultvalue;
                    NSData *v = [self headerStrToData:value type:headModle.type len:[headModle.len integerValue]];
                    [sendData appendData:v];
                    
                }
                
                
            }
            
        }
        
        
    }
    
    return sendData;
}


#pragma mark ------ body dic->NSData

-(NSData*)setBodyModlewith:(NSDictionary *)dic{
    
    NSMutableData *sendData = [NSMutableData data];
    
    for (NSString *key in dic.allKeys) {
        
        for (TLVModle *tlvModle in _bodyBaseArr) {
            
            if ([tlvModle.key isEqualToString:key]) {
                
                
                if ( ![dic[key] length] ) {
                    
                    @throw [NSException exceptionWithName:@"modleTodata"
                                                   reason:[NSString stringWithFormat:@"%@不能为空",key]
                                                 userInfo:nil];
                }
                else{
                    
                    // t;
                    NSData *t  = [self str_oxToData:tlvModle.idName length:2];
                    
                    // v;
                    NSData *v = [self strToData:dic[key] type:[tlvModle.type integerValue] len:[tlvModle.len integerValue]];
                    
                    
                    // l;
                    NSData *l = [self str_oxToData:[NSString stringWithFormat:@"%lu",(unsigned long)v.length] length:2];
                    [sendData appendData:t];
                    [sendData appendData:l];
                    [sendData appendData:v];
                    
                    
                }
                
            }
            
        }
        
        
    }
    
    
    return sendData;
}


#pragma mark 转data

// TODO:T
-(NSData*)str_oxToData:(NSString*)str length:(NSInteger)len{
    
    NSData *data;
    //删除0x前缀
    if ([str hasPrefix:@"0x"]) {
        //十六进制字符串
        str = [str stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
        
        if (len <= 0) {
            len = str.length/2;
            if (str.length%2) {
              len = str.length/2 +1;
            }
            
        }
        data = [TranslateTool transStrHexToData:str andLen:len];
        
    }else{
        
        //十进制
        UInt16 t = [str integerValue];
        data = [TranslateTool transStrHexToData:[TranslateTool ToHex:t] andLen:len];
        
//        if (len <= 0) {
//            len = 2;
//        }
//        if (len > 1) {
//            UInt16 t = htons(t);
//        }
//        //
//        data = [NSData dataWithBytes:(Byte *)&t length:len];
    }
    
    return data;
}

// TODO:V
-(NSData*)strToData:(NSString*)str type:(NSInteger)type len:(NSInteger)len{
    
    //    type: 0:double;1:float;2:long;3:int;4:short;5:byte;6:String;7:自定义类型;
    
    NSData *data = [NSData data];
    
    if (type == 0 || type == 1 || type == 2 || type == 3 || type == 4) {
        
//        UInt16 t = [str integerValue];
//        data = [TranslateTool transStrHexToData:[TranslateTool ToHex:t] andLen:len];
        NSInteger number = [str  integerValue];
        if (len > 1) {
           UInt16 number = htons(number);
        }
        data = [NSData dataWithBytes:(Byte *)&number length:len];

    }
    if (type == 5) {
        //bye
        data = [self str_oxToData:str length:len];
    }
    if (type == 6) {
        //string
        data = [str dataUsingEncoding:NSUTF8StringEncoding];
    }
    if (type == 7) {
        
        //
        if ([str isEqualToString:@"turn on"]) {
            data = [self str_oxToData:@"0x0001" length:1];
        }
        if ([str isEqualToString:@"turn off"]) {
            data = [self str_oxToData:@"0x0002" length:1];
        }
        
        //
        if ([str isEqualToString:@"lock"]) {
            data = [self str_oxToData:@"0x0010" length:1];
        }
        if ([str isEqualToString:@"unLock"]) {
            data = [self str_oxToData:@"00x0020" length:1];
        }
    }
    
    
    return data;
}



#pragma mark header ->data

-(NSData*)headerStrToData:(NSString*)str type:(NSString*)type len:(NSInteger)len{
    
    NSData *data = [NSData data];
    if ([type caseInsensitiveCompare:@"bit"] == NSOrderedSame) {
        
        /** bit字符串转NSData */
        data = [TranslateTool bitToData:str];
        
    }
    
    if ([type caseInsensitiveCompare:@"byte"] == NSOrderedSame) {
        
        //删除0x前缀
        if ([str hasPrefix:@"0x"]) {
            
            str = [str stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
            data = [TranslateTool transStrHexToData:str andLen:len];
            
        }else{
            
            UInt16 t = [str integerValue];
            data = [TranslateTool transStrHexToData:[TranslateTool ToHex:t] andLen:len];
//            if (len > 1) {
//                UInt16 num = htons(num);
//            }
//            data = [NSData dataWithBytes:(Byte *)&num length:len];
        }
    }
    
    return data;
}

@end
