//
// Created by develop on 2023/2/9.
//

#import <Foundation/Foundation.h>


@interface RsaUtils : NSObject

+ (NSString *)encrypt:(NSString *)plainText publicKey:(NSString *)publicKey;

+ (NSString *)decrypt:(NSString *)cipherText privateKey:(NSString *)privateKey;

@end