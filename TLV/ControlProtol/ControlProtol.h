//
//  ControlProtol.h
//  ControlDemo
//
//  Created by lawrence on 17/3/16.
//  Copyright © 2017年 李辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RevDataDelegate <NSObject>
- (void)didReciveData:(NSData*)data fromAddress:(NSData *)address;
@end

@interface ControlProtol : NSObject

+ (ControlProtol *)sharedInstance;

@property(nonatomic,assign) id<RevDataDelegate> delegate;

- (void)sendProtocol:(NSData *)protocol host:(NSString *)host;


@end
