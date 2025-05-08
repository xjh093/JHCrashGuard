//
//  ViewController.m
//  JHCrashGuardDemo
//
//  Created by Hao on 2025/4/30.
//

#import "ViewController.h"
#import "ClassA.h"
#import "ClassB.h"
#import "JHCrashGuard.h"

@interface ViewController ()
@property (nonatomic,  strong) UITextView *textView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 在注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCrashMessage:) name:JHCrashGuardUnrecognizedSelectorNotification object:nil];
    
    //
    CGFloat X = 0;
    CGFloat Y = 0;
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, 280, 100);
    label.text = @"JHCrashGuard 防护已启用\n会自动添加崩溃的类🥳 下次生效！";
    label.textColor = [UIColor orangeColor];
    label.font = [UIFont boldSystemFontOfSize:22];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor systemGray6Color];
    label.center = CGPointMake(self.view.center.x, CGRectGetMaxY(label.frame)+30);
    label.numberOfLines = 0;
    [self.view addSubview:label];
    
    X = CGRectGetMinX(label.frame);
    Y = CGRectGetMaxY(label.frame);
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(X, Y+20, 280, 60);
        button.backgroundColor = [UIColor systemGray4Color];
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        [button setTitle:@"触发崩溃 - 自定义类，实例方法" forState:0];
        [button setTitleColor:[UIColor blackColor] forState:0];
        [button addTarget:self action:@selector(buttonAction1) forControlEvents:1<<6];
        [self.view addSubview:button];
        
        X = CGRectGetMinX(button.frame);
        Y = CGRectGetMaxY(button.frame);
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(X, Y+20, 280, 60);
        button.backgroundColor = [UIColor systemGray4Color];
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        [button setTitle:@"触发崩溃 - 自定义类，类方法" forState:0];
        [button setTitleColor:[UIColor blackColor] forState:0];
        [button addTarget:self action:@selector(buttonAction2) forControlEvents:1<<6];
        [self.view addSubview:button];
        
        X = CGRectGetMinX(button.frame);
        Y = CGRectGetMaxY(button.frame);
    }
    
    UITextView *textView = [[UITextView alloc] init];
    textView.frame = CGRectMake(0, Y+20, CGRectGetWidth(self.view.frame), 350);
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont systemFontOfSize:14];
    textView.textAlignment = NSTextAlignmentLeft;
    textView.showsVerticalScrollIndicator = NO;
    textView.backgroundColor = [UIColor systemGray6Color];
    [self.view addSubview:textView];
    _textView = textView;
    

    
    /*
     搭配 AvoidCrash 使用，捕获常见的
     
     @"NSNull",
     @"NSNumber",
     @"NSString",
     @"NSDictionary",
     @"NSArray"
     */
    
    //[self test1];
    //[self test2];
}

- (void)buttonAction1
{
    ClassA *classA = [[ClassA alloc] init];
    [classA methodA];
}

- (void)buttonAction2
{
    [ClassB methodB];
}

- (void)test1
{
    //
    id array = @[].mutableCopy;
    [array setObject:@"666" forKey:@"888"];
    
    //
    id dic = @{}.mutableCopy;
    [dic addObject:@"888"];
}

- (void)test2
{
    id string = @"123";
    [string addObject:@"456"];
    NSLog(@"string:%@",string);
    
    //
    id number = @(3);
    NSLog(@"length:%@",@([number length]));
}



- (void)handleCrashMessage:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    NSString *text = [NSString stringWithFormat:@"检测到未实现的方法调用:\n"
                      @"类名: %@\n"
                      @"实例: %@\n"
                      @"方法: %@\n"
                      @"类型: %@\n"
                      @"时间: %@\n"
                      @"位置: %@\n"
                      @"名称: %@\n"
                      @"原因: %@\n"
                      @"堆栈: %@",
                      userInfo[JHCrashGuardClassNameKey],
                      userInfo[JHCrashGuardInstanceNameKey],
                      userInfo[JHCrashGuardSelectorNameKey],
                      [userInfo[JHCrashGuardIsClassMethodKey] boolValue] ? @"类方法" : @"实例方法",
                      userInfo[JHCrashGuardTimestampKey],
                      userInfo[JHCrashGuardErrorPlaceKey],
                      userInfo[JHCrashGuardExceptionNameKey],
                      userInfo[JHCrashGuardExceptionReasonKey],
                      userInfo[JHCrashGuardCallStackSymbolsKey]];
    
    NSLog(@"%@", text);
    
    _textView.text = [NSString stringWithFormat:@"%@\n\n%@", _textView.text, text];
    
    // 可以在这里上报到服务器或进行其他处理
}

@end
