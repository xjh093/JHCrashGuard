//
//  JHCrashGuard.h
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

// version: 2.0.0
// date: 2025-05-08 18:54:28

#import <Foundation/Foundation.h>

// 1 - 使用方法替换，针对「对象」和「类」方法。
// 0 - 使用方法交换，针对「对象」方法。
#define kReplaceImplementation 1


NS_ASSUME_NONNULL_BEGIN

// 定义通知相关常量
extern NSString * const JHCrashGuardUnrecognizedSelectorNotification;
extern NSString * const JHCrashGuardClassNameKey;
extern NSString * const JHCrashGuardSelectorNameKey;
extern NSString * const JHCrashGuardIsClassMethodKey;
extern NSString * const JHCrashGuardTimestampKey;
extern NSString * const JHCrashGuardInstanceNameKey;
extern NSString * const JHCrashGuardErrorPlaceKey;
extern NSString * const JHCrashGuardCallStackSymbolsKey;
extern NSString * const JHCrashGuardExceptionNameKey;
extern NSString * const JHCrashGuardExceptionReasonKey;

// 方法类型枚举
typedef NS_ENUM(NSUInteger, JHMethodType) {
    JHMethodTypeInstance,  // 实例方法
    JHMethodTypeClass      // 类方法
};

/// Handle crash of 'unrecognized selector'
@interface JHCrashGuard : NSObject

// 启用防护（初始不防护任何类）
+ (void)enableCrashGuard;

// 禁用崩溃防护
+ (void)disableCrashGuard;

// 添加需要防护的类
+ (void)addProtectedClass:(Class)aClass;

// 从异常信息中提取并注册需要防护的类
+ (void)registerProtectedClassFromException:(NSException *)exception;

// 清空之前防护的类
+ (void)resetPersistedProtectedClasses;

@end

NS_ASSUME_NONNULL_END
