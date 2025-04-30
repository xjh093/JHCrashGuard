//
//  NSObject+JHCrashGuard.m
//  JHKit
//
//  Created by HaoCold on 2018/11/20.
//  Copyright © 2018 HaoCold. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2018 xjh093
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "NSObject+JHCrashGuard.h"
#import <objc/runtime.h>

#define JHCrashGuardSeparatorHeader @"========================JHCrashGuard Log=========================="
#define JHCrashGuardSeparatorFooter @"=================================================================="

#ifdef DEBUG
#define JHCrashGuardLog(...) NSLog(@"%@",[NSString stringWithFormat:__VA_ARGS__])
#else
#define JHCrashGuardLog(...)
#endif


@interface JHCrashGuard : NSObject
///
+ (NSMethodSignature *)crashGuardSignature;
///
+ (NSString *)currentTimeString;
///
+ (void)postUnrecognizedSelectorNotification:(Class)class instance:(NSString *)instance selector:(SEL)aSelector isClassMethod:(BOOL)isClassMethod;
///
- (void)crashGuard;
@end

@implementation JHCrashGuard
+ (NSMethodSignature *)crashGuardSignature {
    static NSMethodSignature *signature = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        signature = [self instanceMethodSignatureForSelector:@selector(crashGuard)];
    });
    return signature;
}

+ (NSString *)currentTimeString {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    });
    return [formatter stringFromDate:[NSDate date]];
}

+ (void)postUnrecognizedSelectorNotification:(Class)class instance:(NSString *)instance selector:(SEL)aSelector isClassMethod:(BOOL)isClassMethod {
    NSDictionary *userInfo = @{
        JHCrashGuardClassNameKey: NSStringFromClass(class),
        JHCrashGuardInstanceNameKey: instance,
        JHCrashGuardSelectorNameKey: NSStringFromSelector(aSelector),
        JHCrashGuardIsClassMethodKey: @(isClassMethod),
        JHCrashGuardTimestampKey: [JHCrashGuard currentTimeString]
    };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:JHCrashGuardUnrecognizedSelectorNotification
                                                      object:nil
                                                    userInfo:userInfo];
}

- (void)crashGuard{}
@end

@implementation NSObject (JHCrashGuard)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:aSelector];
    if (!signature) {
        IMP originIMP = class_getMethodImplementation([NSObject class], @selector(methodSignatureForSelector:));
        IMP currentIMP = class_getMethodImplementation([self class], @selector(methodSignatureForSelector:));
        
        if (originIMP != currentIMP){
            return nil;
        }
        
        signature = [JHCrashGuard crashGuardSignature];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    anInvocation.target = nil;
    [anInvocation invoke];
    
    NSString *info = [NSString stringWithFormat:@"instance: %@\nclass:    %@\nmethod:   %@", self, NSStringFromClass([self class]), NSStringFromSelector(anInvocation.selector)];
    NSString *logInfo = [NSString stringWithFormat:@"\n%@\n\n[%@] Unrecognized selector", JHCrashGuardSeparatorHeader, [JHCrashGuard currentTimeString]];
    logInfo = [NSString stringWithFormat:@"%@\n\n%@",logInfo, info];
    logInfo = [NSString stringWithFormat:@"%@\n\n%@\n\n",logInfo, JHCrashGuardSeparatorFooter];
    JHCrashGuardLog(@"%@",logInfo);
    
    //
    [JHCrashGuard postUnrecognizedSelectorNotification:[self class] instance:[NSString stringWithFormat:@"%@", self] selector:anInvocation.selector isClassMethod:NO];
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:aSelector];
    if (!signature) {
        signature = [JHCrashGuard crashGuardSignature];
    }
    return signature;
}

+ (void)forwardInvocation:(NSInvocation *)anInvocation {
    anInvocation.target = nil;
    [anInvocation invoke];
    
    NSString *info = [NSString stringWithFormat:@"class:  %@\nmethod: %@", self, NSStringFromSelector(anInvocation.selector)];
    NSString *logInfo = [NSString stringWithFormat:@"\n%@\n\n[%@] Unrecognized selector", JHCrashGuardSeparatorHeader, [JHCrashGuard currentTimeString]];
    logInfo = [NSString stringWithFormat:@"%@\n\n%@",logInfo, info];
    logInfo = [NSString stringWithFormat:@"%@\n\n%@\n\n",logInfo, JHCrashGuardSeparatorFooter];
    JHCrashGuardLog(@"%@",logInfo);
    
    //
    [JHCrashGuard postUnrecognizedSelectorNotification:self instance:@"None" selector:anInvocation.selector isClassMethod:YES];
}

#pragma clang diagnostic pop

@end
