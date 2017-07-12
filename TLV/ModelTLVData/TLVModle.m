//
//  TLVModle.m
//  TLV
//
//  Created by lawrence on 16/12/14.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import "TLVModle.h"

@implementation TLVModle

-(TLVModle*)initWithTlV:(TLVModle*)oldModle{

    if (self = [super init]) {
        
        self.idName = oldModle.idName;
        self.key = oldModle.key;
        self.explain = oldModle.explain;
        self.encoding = oldModle.encoding;
        self.type = oldModle.type;
        self.dataValue = oldModle.dataValue;
    }
    return self;
    
    
}

-(void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key{
    

    if ([key isEqualToString:@"id"]) {
        
        [self setValue:value forKey:@"idName"];
    }
}

-(NSString*)description{
    
    NSString *des = [NSString stringWithFormat:@"id = %@,key = %@,explain = %@,type = %@,value = %@ ,length = %@",_idName,_key,_explain,_type,_dataValue,_len];
    
    return des;
    
}

@end
