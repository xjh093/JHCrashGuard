//
//  JHCrashGuard.m
//  JHCrashGuardDemo
//
//  Created by Haomissyou on 2025/5/7.
//  Copyright © 2025 HaoCold. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2025 xjh093
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

#import "JHCrashGuard.h"
#import <objc/runtime.h>

#define JHCrashGuardSeparatorHeader @"========================JHCrashGuard Log=========================="
#define JHCrashGuardSeparatorFooter @"=================================================================="

#ifdef DEBUG
#define JHCrashGuardLog(...) NSLog(@"%@",[NSString stringWithFormat:__VA_ARGS__])
#else
#define JHCrashGuardLog(...)
#endif

NSString *const JHCrashGuardUnrecognizedSelectorNotification = @"JHCrashGuardUnrecognizedSelectorNotification";
NSString *const JHCrashGuardClassNameKey = @"className";
NSString *const JHCrashGuardInstanceNameKey = @"instanceName";
NSString *const JHCrashGuardSelectorNameKey = @"selectorName";
NSString *const JHCrashGuardIsClassMethodKey = @"isClassMethod";
NSString *const JHCrashGuardTimestampKey = @"timestamp";
NSString *const JHCrashGuardErrorPlaceKey = @"errorPlace";
NSString *const JHCrashGuardCallStackSymbolsKey = @"callStackSymbols";
NSString *const JHCrashGuardExceptionNameKey = @"exceptionName";
NSString *const JHCrashGuardExceptionReasonKey = @"exceptionReason";


// 静态全局变量
static BOOL _isEnabled;  // 是否启用保护
static NSMutableSet *_protectedClasses;  // 忽略保护的类集合
static IMP _originalMethodSignatureIMP;  // 原始方法签名实现
static IMP _originalForwardInvocationIMP;  // 原始转发调用实现
static IMP _originalClassMethodSignatureIMP;  // 原始类方法签名实现
static IMP _originalClassForwardInvocationIMP;  // 原始类转发调用实现

// 持久化存储的Key
static NSString *const kPersistedProtectedClassesKey = @"JHCrashGuard_PersistedClasses";

@implementation JHCrashGuard

#pragma mark - public

+ (void)enableCrashGuard {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _isEnabled = YES;
        
        // 初始化
        _protectedClasses = [NSMutableSet new];
        
        // 启动时自动加载持久化的类
        [self loadPersistedProtectedClasses];
        
#if kReplaceImplementation
        // 实例方法防护
        [self replaceInstanceMethods];
        
        // 类方法防护
        [self replaceClassMethods];
#else
        // 交换实例方法
        [self swizzleInstanceMethods];
        
//        class_getMethodImplementation()
        
//        Class metaClass = object_getClass([NSObject class]);
//        _originalClassMethodSignatureIMP = class_getMethodImplementation(metaClass, @selector(methodSignatureForSelector:));
//        _originalClassForwardInvocationIMP = class_getMethodImplementation(metaClass, @selector(forwardInvocation:));
        
#endif
        
        //
        NSLog(@"%@", [NSString stringWithFormat:@"[%@] JHCrashGuard 防护已启用", [JHCrashGuard currentTimeString]]);
    });
}

+ (void)disableCrashGuard {
    _isEnabled = NO;
}

+ (void)addProtectedClass:(Class)aClass {
    if (_protectedClasses && aClass) {
        // 防止重复添加
        if (![_protectedClasses containsObject:aClass]) {
            [_protectedClasses addObject:aClass];
            [self persistProtectedClasses]; // 添加后立即持久化
            NSLog(@"添加并持久化防护类: %@", NSStringFromClass(aClass));
        }
    }
}

+ (void)registerProtectedClassFromException:(NSException *)exception
{
    // -[ClassA methodA]: unrecognized selector sent to instance 0x60000000c4f0
    NSString *reason = exception.reason;
    if (![reason containsString:@"unrecognized selector sent to"]) return;
    
    // 匹配两种格式：
    // 1. 实例方法: -[ClassName selector]
    // 2. 类方法:   +[ClassName selector]
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\+\\-]\\[(\\w+)\\s" options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:reason options:0 range:NSMakeRange(0, reason.length)];
    
    if (match && match.numberOfRanges >= 2) {
        NSString *className = [reason substringWithRange:[match rangeAtIndex:1]];
        Class cls = NSClassFromString(className);
        
        if (cls) {
            [self addProtectedClass:cls];
            NSLog(@"从崩溃信息注册防护类: %@ (%@)", className, [reason containsString:@"+["] ? @"类方法" : @"实例方法");
        }
    }
}

+ (void)resetPersistedProtectedClasses {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPersistedProtectedClassesKey];
    [_protectedClasses removeAllObjects];
    NSLog(@"已清空持久化防护类");
}


#pragma mark - private

#pragma mark --- 持久化相关方法
+ (void)persistProtectedClasses {
    NSArray *classNames = [_protectedClasses.allObjects valueForKey:@"description"];
    [[NSUserDefaults standardUserDefaults] setObject:classNames forKey:kPersistedProtectedClassesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)loadPersistedProtectedClasses {
    NSArray *classNames = [[NSUserDefaults standardUserDefaults] objectForKey:kPersistedProtectedClassesKey];
    
    [classNames enumerateObjectsUsingBlock:^(NSString *className, NSUInteger idx, BOOL *stop) {
        Class cls = NSClassFromString(className);
        if (cls) {
            [_protectedClasses addObject:cls];
        }
    }];
    
    if (classNames.count > 0) {
        NSLog(@"%@", [NSString stringWithFormat:@"[%@] 加载持久化防护类: %@", [JHCrashGuard currentTimeString], classNames]);
    }
}

#pragma mark --- Helper Methods

/// 默认返回 void 类型
+ (NSMethodSignature *)safeMethodSignature {
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

///
+ (void)postUnrecognizedSelectorNotification:(Class)class instance:(NSString *)instance selector:(SEL)aSelector isClassMethod:(BOOL)isClassMethod info:(NSString *)info {
    NSString *errorPlace = [JHCrashGuard getMainCallStackSymbolMessageFromCallStackSymbols:[NSThread callStackSymbols]];
    NSString *reason = @"null";
    if (![errorPlace hasPrefix:@"崩溃方法定位失败"]) {
        reason = [NSString stringWithFormat:@"%@[%@ %@]: unrecognized selector sent to %@ %@", isClassMethod ? @"+" : @"-", NSStringFromClass(class), NSStringFromSelector(aSelector), isClassMethod ? @"class" : @"instance", instance];
    }
    
    info = [NSString stringWithFormat:@"%@\nplace:    %@", info, errorPlace];
    NSString *logInfo = [NSString stringWithFormat:@"\n\n%@\n\n[%@] Unrecognized selector", JHCrashGuardSeparatorHeader, [JHCrashGuard currentTimeString]];
    logInfo = [NSString stringWithFormat:@"%@\n\n%@",logInfo, info];
    logInfo = [NSString stringWithFormat:@"%@\n\n%@\n\n",logInfo, JHCrashGuardSeparatorFooter];
    JHCrashGuardLog(@"%@",logInfo);
    
    NSDictionary *userInfo = @{
        JHCrashGuardClassNameKey: NSStringFromClass(class),
        JHCrashGuardInstanceNameKey: isClassMethod ? @"None" : instance,
        JHCrashGuardSelectorNameKey: NSStringFromSelector(aSelector),
        JHCrashGuardIsClassMethodKey: @(isClassMethod),
        JHCrashGuardTimestampKey: [JHCrashGuard currentTimeString],
        JHCrashGuardErrorPlaceKey: errorPlace,
        JHCrashGuardExceptionNameKey: @"NSInvalidArgumentException",
        JHCrashGuardExceptionReasonKey: reason,
        JHCrashGuardCallStackSymbolsKey: [NSThread callStackSymbols],
    };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:JHCrashGuardUnrecognizedSelectorNotification
                                                      object:nil
                                                    userInfo:userInfo];
}

///
+ (NSString *)getMainCallStackSymbolMessageFromCallStackSymbols:(NSArray<NSString *> *)callStackSymbols
{
    // mainCallStackSymbolMsg的格式为   +[类名 方法名]  或者 -[类名 方法名]
    __block NSString *mainCallStackSymbolMsg = nil;
    
    // 匹配出来的格式为 +[类名 方法名]  或者 -[类名 方法名]
    NSString *regularExpStr = @"[-\\+]\\[.+\\]";
    
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    for (int index = 2; index < callStackSymbols.count; index++) {
        NSString *callStackSymbol = callStackSymbols[index];
        
        [regularExp enumerateMatchesInString:callStackSymbol options:NSMatchingReportProgress range:NSMakeRange(0, callStackSymbol.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if (result) {
                NSString* tempCallStackSymbolMsg = [callStackSymbol substringWithRange:result.range];
                
                //get className
                NSString *className = [tempCallStackSymbolMsg componentsSeparatedByString:@" "].firstObject;
                className = [className componentsSeparatedByString:@"["].lastObject;
                
                NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(className)];
                
                //filter category and system class
                if (![className hasSuffix:@")"] && bundle == [NSBundle mainBundle]) {
                    mainCallStackSymbolMsg = tempCallStackSymbolMsg;
                }
                *stop = YES;
            }
        }];
        
        if (mainCallStackSymbolMsg.length) {
            break;
        }
    }
    
    if (mainCallStackSymbolMsg == nil) {
        mainCallStackSymbolMsg = @"崩溃方法定位失败，请查看函数调用栈来排查错误原因";
    }
    
    return mainCallStackSymbolMsg;
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



#if kReplaceImplementation

#pragma mark ======================== ReplaceImplementation ========================

#pragma mark --- 实例方法处理
+ (void)replaceInstanceMethods {
    Class targetClass = [NSObject class];
    
    // methodSignatureForSelector:
    Method originalMethod = class_getInstanceMethod(targetClass, @selector(methodSignatureForSelector:));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(guard_instanceMethodSignatureForSelector:));
    _originalMethodSignatureIMP = method_setImplementation(originalMethod, method_getImplementation(swizzledMethod));
    
    // forwardInvocation:
    Method originalForward = class_getInstanceMethod(targetClass, @selector(forwardInvocation:));
    Method swizzledForward = class_getInstanceMethod([self class], @selector(guard_instanceForwardInvocation:));
    _originalForwardInvocationIMP = method_setImplementation(originalForward, method_getImplementation(swizzledForward));
}

- (NSMethodSignature *)guard_instanceMethodSignatureForSelector:(SEL)aSelector {
    // 如果保护未启用或当前类在忽略列表中，调用原始实现
    if (!_isEnabled || ![_protectedClasses containsObject:[self class]]) {
        return ((id(*)(id, SEL, SEL))_originalMethodSignatureIMP)(self, _cmd, aSelector);
    }
    
    // 先尝试原始实现
    NSMethodSignature *signature = ((id(*)(id, SEL, SEL))_originalMethodSignatureIMP)(self, _cmd, aSelector);
    
    // 如果没有获取到签名，返回安全签名
    if (!signature) {
        signature = [JHCrashGuard safeMethodSignature];
    }
    return signature;
}

- (void)guard_instanceForwardInvocation:(NSInvocation *)anInvocation {
    // 调用原始实现
    if (!_isEnabled || ![_protectedClasses containsObject:[self class]]) {
        ((void(*)(id, SEL, NSInvocation *))_originalForwardInvocationIMP)(self, _cmd, anInvocation);
        return;
    }
    
    // 安全处理：将 target 置为 nil 后调用
    anInvocation.target = nil;
    [anInvocation invoke];
    
    // 日志
    NSString *info = [NSString stringWithFormat:@"instance: %@\nclass:    %@\nmethod:   %@", self, NSStringFromClass([self class]), NSStringFromSelector(anInvocation.selector)];
    
    // 发送未识别方法通知
    [JHCrashGuard postUnrecognizedSelectorNotification:[self class] instance:[NSString stringWithFormat:@"%@", self] selector:anInvocation.selector isClassMethod:NO info:info];
}

#pragma mark --- 类方法处理
+ (void)replaceClassMethods {
    Class metaClass = object_getClass([NSObject class]);
    
    // 类方法签名
    Method originalClassMethod = class_getClassMethod(metaClass, @selector(methodSignatureForSelector:));
    _originalClassMethodSignatureIMP = method_setImplementation(originalClassMethod, (IMP)guard_classMethodSignatureForSelector);
    
    // 类方法转发
    Method originalClassForward = class_getClassMethod(metaClass, @selector(forwardInvocation:));
    _originalClassForwardInvocationIMP = method_setImplementation(originalClassForward, (IMP)guard_classForwardInvocation);
}

// C函数实现（避免self问题）
static NSMethodSignature * guard_classMethodSignatureForSelector(Class self, SEL _cmd, SEL aSelector) {
    if (!_isEnabled || ![_protectedClasses containsObject:self]) {
        return ((id(*)(Class, SEL, SEL))_originalClassMethodSignatureIMP)(self, _cmd, aSelector);
    }
    
    NSMethodSignature *signature = ((id(*)(Class, SEL, SEL))_originalClassMethodSignatureIMP)(self, _cmd, aSelector);
    if (!signature) {
        signature = [JHCrashGuard safeMethodSignature];
    }
    return signature;
}

static void guard_classForwardInvocation(Class self, SEL _cmd, NSInvocation *anInvocation) {
    if (!_isEnabled || ![_protectedClasses containsObject:self]) {
        ((void(*)(Class, SEL, NSInvocation *))_originalClassForwardInvocationIMP)(self, _cmd, anInvocation);
        return;
    }
    
    anInvocation.target = nil;
    [anInvocation invoke];
    
    // 日志
    NSString *info = [NSString stringWithFormat:@"class:    %@\nmethod:   %@", self, NSStringFromSelector(anInvocation.selector)];
    
    // 发送未识别方法通知
    [JHCrashGuard postUnrecognizedSelectorNotification:[self class] instance:[NSString stringWithFormat:@"<%@: %p>", self, self] selector:anInvocation.selector isClassMethod:YES info:info];
}

#else


#pragma mark ======================== Method Swizzling ========================

+ (void)swizzleInstanceMethods
{
    [self swizzleMethodSignatureForSelector];
    [self swizzleForwardInvocation];
}

/**
 通用方法交换实现
 @param originalSelector 原始方法选择器
 @param swizzledSelector 替换方法选择器
 @param methodType 方法类型（实例/类方法）
 @param originalIMPStore 存储原始IMP的指针
 */
+ (void)swizzleWithOriginalSelector:(SEL)originalSelector
                  swizzledSelector:(SEL)swizzledSelector
                        methodType:(JHMethodType)methodType
                   originalIMPStore:(IMP *)originalIMPStore {
    // 确定目标类（类方法需要获取NSObject的元类）
    Class targetClass = (methodType == JHMethodTypeClass) ?
                        object_getClass([NSObject class]) :
                        [NSObject class];
    
    // 获取原始方法和替换方法
    Method originalMethod = (methodType == JHMethodTypeClass) ?
                           class_getClassMethod([NSObject class], originalSelector) :
                           class_getInstanceMethod(targetClass, originalSelector);
    
    Method swizzledMethod = (methodType == JHMethodTypeClass) ?
                           class_getClassMethod([self class], swizzledSelector) :
                           class_getInstanceMethod([self class], swizzledSelector);
    
    // 保存原始实现
    *originalIMPStore = method_getImplementation(originalMethod);
    
    // 尝试添加方法（防止原始方法未实现的情况）
    BOOL didAddMethod = class_addMethod(targetClass,
                                      originalSelector,
                                      method_getImplementation(swizzledMethod),
                                      method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        // 添加成功，替换新方法的实现为原始实现
        class_replaceMethod(targetClass,
                          swizzledSelector,
                          *originalIMPStore,
                          method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


+ (void)swizzleMethodSignatureForSelector {
    [self swizzleWithOriginalSelector:@selector(methodSignatureForSelector:)
                    swizzledSelector:@selector(guard_methodSignatureForSelector:)
                          methodType:JHMethodTypeInstance
                     originalIMPStore:&_originalMethodSignatureIMP];
}

+ (void)swizzleForwardInvocation {
    [self swizzleWithOriginalSelector:@selector(forwardInvocation:)
                    swizzledSelector:@selector(guard_forwardInvocation:)
                          methodType:JHMethodTypeInstance
                     originalIMPStore:&_originalForwardInvocationIMP];
}

#pragma mark --- Guard Methods

- (NSMethodSignature *)guard_methodSignatureForSelector:(SEL)aSelector {
    // 如果保护未启用或当前类在忽略列表中，调用原始实现
    if (!_isEnabled || ![_protectedClasses containsObject:[self class]]) {
        return ((id(*)(id, SEL, SEL))_originalMethodSignatureIMP)(self, _cmd, aSelector);
    }
    
    // 先尝试原始实现
    NSMethodSignature *signature = ((id(*)(id, SEL, SEL))_originalMethodSignatureIMP)(self, _cmd, aSelector);
    
    // 如果没有获取到签名，返回安全签名
    if (!signature) {
        signature = [JHCrashGuard safeMethodSignature];
    }
    return signature;
}

- (void)guard_forwardInvocation:(NSInvocation *)anInvocation {
    // 调用原始实现
    if (!_isEnabled || ![_protectedClasses containsObject:[self class]]) {
        ((void(*)(id, SEL, NSInvocation *))_originalForwardInvocationIMP)(self, _cmd, anInvocation);
        return;
    }
    
    // 安全处理：将 target 置为 nil 后调用
    anInvocation.target = nil;
    [anInvocation invoke];
    
    // 日志
    NSString *info = [NSString stringWithFormat:@"instance: %@\nclass:    %@\nmethod:   %@", self, NSStringFromClass([self class]), NSStringFromSelector(anInvocation.selector)];
    
    // 发送未识别方法通知
    [JHCrashGuard postUnrecognizedSelectorNotification:[self class] instance:[NSString stringWithFormat:@"%@", self] selector:anInvocation.selector isClassMethod:NO info:info];
}

#endif

@end
