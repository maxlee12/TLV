//
//  TLVModle.m
//  TLV
//
//  Created by lawrence on 16/12/14.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import "HeadModle.h"

@implementation HeadModle


-(void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key{
    
    if ([key isEqualToString:@"id"]) {
        
        [self setValue:value forKey:@"idName"];
    }
}

- (NSString*)description{
    
    return [NSString stringWithFormat:@"idName:%@ len:%@ des:%@ type%@",self.idName,self.len,self.desc,self.type];
}

@end
