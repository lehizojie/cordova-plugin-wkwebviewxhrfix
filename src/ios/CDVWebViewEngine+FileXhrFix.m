//
//  CDVWebViewEngine+FileXhrFix.m
//  HelloCordova
//
//  Created by Connor Pearson on 2/9/17.
//
//

#import "CDVWebViewEngine+FileXhrFix.h"
#import <objc/runtime.h>

@implementation CDVWebViewEngine (FileXhrFix)
+ (void)load {
    SEL selector = NSSelectorFromString(@"createConfigurationFromSettings:");
    Method originalMethod = class_getInstanceMethod([CDVWebViewEngine class], selector);
    IMP originalImp = method_getImplementation(originalMethod);
    typedef WebViewConfiguration* (*send_type)(id, SEL , NSDictionary*);
    send_type originalImpSend = (send_type)originalImp;
    
    IMP newImp = imp_implementationWithBlock(^(id _self, NSDictionary* settings){
        // Get the original configuration
        WebViewConfiguration* configuration = originalImpSend(_self, selector, settings);

        // allow access to file api
        @try {
            [configuration.preferences setValue:@TRUE forKey:@"allowFileAccessFromFileURLs"];
        }
        @catch (NSException *exception) {}
        
        @try {
            [configuration setValue:@TRUE forKey:@"allowUniversalAccessFromFileURLs"];
        }
        @catch (NSException *exception) {}
        
        return configuration;
    });
    
    method_setImplementation(originalMethod, newImp);
}
@end