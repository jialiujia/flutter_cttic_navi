#import "FlutterCtticNaviPlugin.h"
#import "RsaUtils.h"

@implementation FlutterCtticNaviPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
            methodChannelWithName:@"flutter_cttic_navi"
                  binaryMessenger:[registrar messenger]];
    FlutterCtticNaviPlugin* instance = [[FlutterCtticNaviPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"isMsdAppInstalled" isEqualToString:call.method]) {
        NSURL *url = [NSURL URLWithString:@"msd://"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            result(@(YES));
        } else {
            result(@(NO));
        }
    } else if ([@"startAmapNavigation" isEqualToString:call.method] || [@"startDockNavigation" isEqualToString:call.method]) {
        NSString *enity = call.arguments[@"enity"];
        NSString *cipherText = [RsaUtils encrypt:enity publicKey:PUBLIC_KEY];
        NSString *str = [@"msd://app?content=" stringByAppendingString:cipherText];
        NSURL *url = [NSURL URLWithString:str];
        UIApplication *application = [UIApplication sharedApplication];
        if ([application respondsToSelector:@selector(open:options:completionHandler:)]) {
            if ([application respondsToSelector:@selector(open:options:completionHandler:)]) {
                [application openURL:url options:@{} completionHandler:^(BOOL success){
                    if (success) {
                        result(@(YES));
                    } else {
                        result(@(NO));
                    }
                }];
            }
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
