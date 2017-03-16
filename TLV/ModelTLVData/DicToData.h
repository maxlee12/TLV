//
//  DicToData.h
//  TLV
//
//  Created by lawrence on 17/3/16.
//  Copyright © 2017年 李辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DicToData : NSObject
+ (DicToData *)sharedInstance;


-(NSData*)dataWithDic:(NSDictionary*)dic and:(NSString*)mac;

-(NSArray*)dicWithNsdata:(NSData*)data;

@end
