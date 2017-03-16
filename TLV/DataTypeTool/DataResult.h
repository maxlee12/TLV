//
//  DataResultSet.h
//  TLV
//
//  Created by lawrence on 16/12/15.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataResultSet : NSObject


@property (strong, nonatomic, readonly) NSData *data;
@property (strong, nonatomic, readonly) NSString *utf8String;
@property (strong, nonatomic, readonly) NSString *hex;
@property (strong, nonatomic, readonly) NSString *hexLower;
@property (strong, nonatomic, readonly) NSString *base64;

- (id)initWithBytes:(unsigned char[])initData length:(NSUInteger)length;

@end

@interface DataResult : NSObject

#pragma mark - AES Encrypt
+ (DataResultSet *)encryptControlData:(NSData *)data andkey:(NSString *)key;

#pragma mark AES Decrypt
+ (DataResultSet *)aesDecryptWithData:(NSData *)data andkey:(NSString *)key;
@end


#pragma mark - DataResultEncoder
@interface DataResultEncoder : NSObject
- (NSString *)base64:(NSData *)data;
- (NSString *)hex:(NSData *)data useLower:(BOOL)isOutputLower;
@end


#pragma mark - DataResultDecoder
@interface DataResultDecoder : NSObject
- (NSData *)base64:(NSString *)data;
- (NSData *)hex:(NSString *)data;
@end
