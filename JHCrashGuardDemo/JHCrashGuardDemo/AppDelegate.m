//
//  AppDelegate.m
//  JHCrashGuardDemo
//
//  Created by Hao on 2025/4/30.
//

#import "AppDelegate.h"
#import "JHCrashGuard.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

// 全局异常处理
void RegisterExceptionHandler(void) {
    NSSetUncaughtExceptionHandler(&HandleException);
}

void HandleException(NSException *exception) {
    // 1. 解析并注册需要防护的类
    [JHCrashGuard registerProtectedClassFromException:exception];
    
    // 2. 打印堆栈
    NSLog(@"崩溃捕获: %@\n堆栈: %@", exception.reason, exception.callStackSymbols);
    
    // 3. 可以在这里上报崩溃信息
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 注册异常处理器
    RegisterExceptionHandler();
    
    // 清空之前防护的类
    //[JHCrashGuard resetPersistedProtectedClasses];
    
    // 启用防护（初始不防护任何类）
    [JHCrashGuard enableCrashGuard];
        
    return YES;
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
