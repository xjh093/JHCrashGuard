//
//  AppDelegate.m
//  JHCrashGuardDemo
//
//  Created by Hao on 2025/4/30.
//

#import "AppDelegate.h"
#import "NSObject+JHCrashGuard.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 在App启动时注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCrashMessage:) name:JHCrashGuardUnrecognizedSelectorNotification object:nil];
    
    return YES;
}

- (void)handleCrashMessage:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    NSLog(@"检测到未实现的方法调用:\n"
          @"类名: %@\n"
          @"实例: %@\n"
          @"方法: %@\n"
          @"类型: %@\n"
          @"时间: %@\n"
          @"位置: %@\n"
          @"堆栈: %@",
          userInfo[JHCrashGuardClassNameKey],
          userInfo[JHCrashGuardInstanceNameKey],
          userInfo[JHCrashGuardSelectorNameKey],
          [userInfo[JHCrashGuardIsClassMethodKey] boolValue] ? @"类方法" : @"实例方法",
          userInfo[JHCrashGuardTimestampKey],
          userInfo[JHCrashGuardErrorPlaceKey],
          userInfo[JHCrashGuardCallStackSymbolsKey]
          );

    // 可以在这里上报到服务器或进行其他处理
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
