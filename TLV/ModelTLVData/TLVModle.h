//
//  TLVModle.h
//  TLV
//
//  Created by lawrence on 16/12/14.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLVModle : NSObject
@property (nonatomic,copy) NSString * idName;
@property (nonatomic,copy) NSString * key;
@property (nonatomic,copy) NSString * explain;
@property (nonatomic,copy) NSString * encoding;
@property (nonatomic,copy) NSString * type;

@property (nonatomic,assign) NSString* dataValue;
@property (nonatomic,assign) NSString* len;


@property (nonatomic,copy) NSString* lock_unLock;
@property (nonatomic,copy) NSString* Dev_MAC;

-(TLVModle*)initWithTlV:(TLVModle*)oldModle;
@end
