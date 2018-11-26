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

@interface JHCrashGuard : NSObject
- (void)crashGuard;
@end

@implementation JHCrashGuard
- (void)crashGuard{}
@end

@implementation NSObject (JHCrashGuard)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *signature = [JHCrashGuard instanceMethodSignatureForSelector:@selector(crashGuard)];
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    anInvocation.target = nil;
    [anInvocation invoke];
}

#pragma clang diagnostic pop

@end
