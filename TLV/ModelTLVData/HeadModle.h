//
//  TLVModle.h
//  TLV
//
//  Created by lawrence on 16/12/14.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeadModle : NSObject

@property (nonatomic,strong) NSString * seq;
@property (nonatomic,strong) NSString * idName;
@property (nonatomic,assign) NSString * len;
@property (nonatomic,strong) NSString * desc;
@property (nonatomic,strong) NSString * type;
@property (nonatomic,strong) NSString * defaultvalue;

@end
