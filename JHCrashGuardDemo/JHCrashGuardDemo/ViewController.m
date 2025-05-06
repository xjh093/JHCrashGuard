//
//  ViewController.m
//  JHCrashGuardDemo
//
//  Created by Hao on 2025/4/30.
//

#import "ViewController.h"
#import "ClassA.h"
#import "ClassB.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self test];
    [self test1];
    [ViewController test2];
}

- (void)test
{
    //
    ClassA *classA = [[ClassA alloc] init];
    [classA methodA];
    
    //
    id array = @[].mutableCopy;
    [array setObject:@"666" forKey:@"888"];
    
    //
    id dic = @{}.mutableCopy;
    [dic addObject:@"888"];
}

- (void)test1
{
    id string = @"123";
    [string addObject:@"456"];
    NSLog(@"string:%@",string);
    
    //
    id number = @(3);
    NSLog(@"length:%@",@([number length]));
}

+ (void)test2
{
    [ClassB methodB];
}

@end
