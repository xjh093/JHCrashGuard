//
//  NSObject+JHCrashGuard.h
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

// version: 1.1.0
// date: 2025-05-06 11:08:55

#import <Foundation/Foundation.h>

static NSString *const JHCrashGuardClassNameKey = @"className";
static NSString *const JHCrashGuardInstanceNameKey = @"instanceName";
static NSString *const JHCrashGuardSelectorNameKey = @"selectorName";
static NSString *const JHCrashGuardIsClassMethodKey = @"isClassMethod";
static NSString *const JHCrashGuardTimestampKey = @"timestamp";
static NSString *const JHCrashGuardErrorPlaceKey = @"errorPlace";
static NSString *const JHCrashGuardCallStackSymbolsKey = @"callStackSymbols";
static NSNotificationName const JHCrashGuardUnrecognizedSelectorNotification = @"JHCrashGuardUnrecognizedSelectorNotification";

/// Handle crash of 'unrecognized selector'
@interface NSObject (JHCrashGuard)

@end

