//
// Created by develop on 2023/2/9.
//

#import "RsaUtils.h"


static NSString *base64_encode_data(NSData *data) {
    data = [data base64EncodedDataWithOptions:0];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

@implementation RsaUtils
+ (NSString *)encrypt:(NSString *)plainText publicKey:(NSString *)publicKey {
    if (plainText.length == 0 || publicKey.length == 0) {
        return nil;
    }
    NSData *data = [self encryptData:[plainText dataUsingEncoding:NSUTF8StringEncoding] publicKey:publicKey];
    NSString *ret = base64_encode_data(data);
    return ret;
}

+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey{
    if(!data || !pubKey){
        return nil;
    }
    SecKeyRef keyRef = [self addPublicKey:pubKey];
    NSData *enData = [self encryptData:data withKeyRef:keyRef];
    if (keyRef) CFRelease(keyRef);

    return enData;
}

+ (NSString *)decrypt:(NSString *)ciphertext privateKey:(NSString *)privateKey {
    if (ciphertext.length == 0 || privateKey.length == 0) {
        return nil;
    }

    NSData *data = [[NSData alloc] initWithBase64EncodedString:ciphertext options:NSDataBase64DecodingIgnoreUnknownCharacters];
    data = [self decryptData:data privateKey:privateKey];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    return ret;
}

+ (NSData *)decryptData:(NSData *)data privateKey:(NSString *)privKey{
    if(!data || !privKey){
        return nil;
    }
    SecKeyRef keyRef = [self addPrivateKey:privKey];
    NSData *deData = [self decryptData:data withKeyRef:keyRef];
    if (keyRef) CFRelease(keyRef);

    return deData;
}

+ (NSData *)decryptData:(NSData *)data withKeyRef:(SecKeyRef)keyRef{
    if(!keyRef){
        return nil;
    }
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;

    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    size_t src_block_size = block_size;

    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx=0; idx<srclen; idx+=src_block_size){
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }

        size_t outlen = block_size;

        NSData* clearText = nil;
        CFErrorRef error = NULL;
        NSData *tmpData = [[NSData alloc] initWithBytes:srcbuf + idx length:data_len];
        clearText = (NSData*)CFBridgingRelease(       // ARC takes ownership
                SecKeyCreateDecryptedData(keyRef,
                        kSecKeyAlgorithmRSAEncryptionPKCS1,
                        (__bridge CFDataRef)tmpData,
                        &error));
        if (!clearText) {
            NSError *err = CFBridgingRelease(error);  // ARC takes ownership
            NSLog(@"SecKeyDecrypt fail. Error : %@", err.localizedDescription);
            ret = nil;
            break;
        } else {
            UInt8 *tmpbuf = clearText.bytes;
            int idxFirstZero = -1;
            int idxNextZero = (int)outlen;
            for ( int i = 0; i < outlen; i++ ) {
                if ( tmpbuf[i] == 0 ) {
                    if ( idxFirstZero < 0 ) {
                        idxFirstZero = i;
                    } else {
                        idxNextZero = i;
                        break;
                    }
                }
            }

            [ret appendBytes:&tmpbuf[idxFirstZero+1] length:idxNextZero-idxFirstZero-1];
//            free(tmpbuf);
        }

//        OSStatus status = noErr;
//        status = SecKeyDecrypt(keyRef,
//                kSecPaddingNone,
//                srcbuf + idx,
//                data_len,
//                outbuf,
//                &outlen
//        );
//        if (status != 0) {
//            NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
//            ret = nil;
//            break;
//        }else{
//            //the actual decrypted data is in the middle, locate it!
//            int idxFirstZero = -1;
//            int idxNextZero = (int)outlen;
//            for ( int i = 0; i < outlen; i++ ) {
//                if ( outbuf[i] == 0 ) {
//                    if ( idxFirstZero < 0 ) {
//                        idxFirstZero = i;
//                    } else {
//                        idxNextZero = i;
//                        break;
//                    }
//                }
//            }
//
//            [ret appendBytes:&outbuf[idxFirstZero+1] length:idxNextZero-idxFirstZero-1];
//        }
    }
    return ret;
}

+ (SecKeyRef)addPrivateKey:(NSString *)key{
    NSRange spos = [key rangeOfString:@"-----BEGIN RSA PRIVATE KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END RSA PRIVATE KEY-----"];
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];

    // This will be base64 encoded, decode it.
    NSData *data = base64_decode(key);
    data = [self stripPrivateKeyHeader:data];
    if(!data){
        return NULL;
    }

    //a tag to read/write keychain storage
    NSString *tag = @"RSAUtil_PrivKey";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];

    // Delete any old lingering key with the same tag
    NSMutableDictionary *privateKey = [[NSMutableDictionary alloc] init];
    privateKey[(__bridge id) kSecClass] = (__bridge id) kSecClassKey;
    privateKey[(__bridge id) kSecAttrKeyType] = (__bridge id) kSecAttrKeyTypeRSA;
    privateKey[(__bridge id) kSecAttrApplicationTag] = d_tag;
    SecItemDelete((__bridge CFDictionaryRef)privateKey);

    // Add persistent version of the key to system keychain
    privateKey[(__bridge id) kSecValueData] = data;
    privateKey[(__bridge id)
            kSecAttrKeyClass] = (__bridge id) kSecAttrKeyClassPrivate;
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
            kSecReturnPersistentRef];

    CFTypeRef persistKey = NULL;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)privateKey, &persistKey);
    if (persistKey) CFRelease(persistKey);

    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return NULL;
    }

    [privateKey removeObjectForKey:(__bridge id)kSecValueData];
    [privateKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [privateKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];

    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)privateKey, (CFTypeRef *)&keyRef);
    if(status != noErr){
        return NULL;
    }
    return keyRef;
}

+ (NSData *)stripPrivateKeyHeader:(NSData *)d_key{
    // Skip ASN.1 private key header
    if (d_key == nil) return(nil);

    unsigned long len = [d_key length];
    if (!len) return(nil);

    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx     = 22; //magic byte at offset 22

    if (0x04 != c_key[idx++]) return nil;

    //calculate length of the key
    unsigned int c_len = c_key[idx++];
    int det = c_len & 0x80;
    if (!det) {
        c_len = c_len & 0x7f;
    } else {
        int byteCount = c_len & 0x7f;
        if (byteCount + idx > len) {
            //rsa length field longer than buffer
            return nil;
        }
        unsigned int accum = 0;
        unsigned char *ptr = &c_key[idx];
        idx += byteCount;
        while (byteCount) {
            accum = (accum << 8) + *ptr;
            ptr++;
            byteCount--;
        }
        c_len = accum;
    }

    return [d_key subdataWithRange:NSMakeRange(idx, c_len)];
}

static NSData *base64_decode(NSString *str){
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

+ (SecKeyRef)addPublicKey:(NSString *)key{
    NSRange spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];

    // This will be base64 encoded, decode it.
    NSData *data = base64_decode(key);
    data = [self stripPublicKeyHeader:data];
    if(!data){
        return nil;
    }

    //a tag to read/write keychain storage
    NSString *tag = @"RSAUtil_PubKey";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];

    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    publicKey[(__bridge id) kSecClass] = (__bridge id) kSecClassKey;
    publicKey[(__bridge id) kSecAttrKeyType] = (__bridge id) kSecAttrKeyTypeRSA;
    publicKey[(__bridge id) kSecAttrApplicationTag] = d_tag;
    SecItemDelete((__bridge CFDictionaryRef)publicKey);

    // Add persistent version of the key to system keychain
    publicKey[(__bridge id) kSecValueData] = data;
    publicKey[(__bridge id)
            kSecAttrKeyClass] = (__bridge id) kSecAttrKeyClassPublic;
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
            kSecReturnPersistentRef];

    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil){
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }

    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    publicKey[(__bridge id) kSecAttrKeyType] = (__bridge id) kSecAttrKeyTypeRSA;

    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    if(status != noErr){
        return nil;
    }
    return keyRef;
}

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key{
    // Skip ASN.1 public key header
    if (d_key == nil) return(nil);

    unsigned long len = [d_key length];
    if (!len) return(nil);

    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx     = 0;

    if (c_key[idx++] != 0x30) return(nil);

    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;

    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
            { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
                    0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);

    idx += 15;

    if (c_key[idx++] != 0x03) return(nil);

    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;

    if (c_key[idx++] != '\0') return(nil);

    return ([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

+ (NSData *)encryptData:(NSData *)data withKeyRef:(SecKeyRef)keyRef{
    if(!keyRef){
        return nil;
    }

    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;

    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    void *outbuf = malloc(block_size);
    size_t src_block_size = block_size - 11;
    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx=0; idx<srclen; idx+=src_block_size){
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }

        size_t outlen = block_size;

        CFErrorRef error = NULL;
        NSData* cipherText = nil;
        NSData *tmpData = [[NSData alloc] initWithBytes:srcbuf + idx length:data_len];
        cipherText = (NSData*)CFBridgingRelease(      // ARC takes ownership
                SecKeyCreateEncryptedData(keyRef,
                        kSecKeyAlgorithmRSAEncryptionPKCS1,
                        (__bridge CFDataRef)tmpData,
                        &error));
        if (!cipherText) {
            NSError *err = CFBridgingRelease(error);
            NSLog(@"SecKeyEncrypt fail. Error : %@", err.localizedDescription);
            ret = nil;
        } else {
            [ret appendBytes:cipherText.bytes length:outlen];
        }

//        OSStatus status = noErr;
//        status = SecKeyEncrypt(keyRef,
//                kSecPaddingPKCS1,
//                srcbuf + idx,
//                data_len,
//                outbuf,
//                &outlen
//        );
//        if (status != 0) {
//            NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
//            ret = nil;
//            break;
//        }else{
//            [ret appendBytes:outbuf length:outlen];
//        }
    }

    free(outbuf);
    return ret;


//    CFErrorRef error = NULL;
//    NSData* cipherText = nil;
//    cipherText = (NSData*)CFBridgingRelease(      // ARC takes ownership
//            SecKeyCreateEncryptedData(keyRef,
//                    kSecKeyAlgorithmRSAEncryptionPKCS1,
//                    (__bridge CFDataRef)data,
//                    &error));
//    if (!cipherText) {
//        NSError *err = CFBridgingRelease(error);
//        NSLog(@"SecKeyEncrypt fail. Error : %@", err.localizedDescription);
//        return nil;
//    } else {
//        return cipherText;
//    }



//    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
//    size_t srclen = (size_t)data.length;
//
//    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
//    void *outbuf = malloc(block_size);
//    size_t src_block_size = block_size - 11;
//
//    NSMutableData *ret = [[NSMutableData alloc] init];
//    for(int idx=0; idx<srclen; idx+=src_block_size){
//        //NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
//        size_t data_len = srclen - idx;
//        if(data_len > src_block_size){
//            data_len = src_block_size;
//        }
//
//        size_t outlen = block_size;
//        OSStatus status = noErr;
//        status = SecKeyEncrypt(keyRef,
//                kSecPaddingPKCS1,
//                srcbuf + idx,
//                data_len,
//                outbuf,
//                &outlen
//        );
//        if (status != 0) {
//            NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
//            ret = nil;
//            break;
//        }else{
//            [ret appendBytes:outbuf length:outlen];
//        }
//    }
//
//    free(outbuf);
//    return ret;
}

@end