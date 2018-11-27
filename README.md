# JHCrashGuard
crash guard，崩溃守护，防止崩溃

---

# Some Bugs

✅2.keyboard will show:

uncaught exception 'NSInvalidArgumentException', reason: '[NSXPCConnection sendInvocation]: A NULL reply block was passed into a message meant to be sent over a connection. (syncToKeyboardState:completionHandler:)' -2018-11-26

✅1.-[NSMethodSignature getArgumentTypeAtIndex:]: index (2) out of bounds [0, 1] -2018-11-26

---

# What

1.Handle crash of 'unrecognized selector'.

example:

```
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    id string = @"123";
    [string addObject:@"456"];
    NSLog(@"string:%@",string);
    
    id number = @(3);
    NSLog(@"length:%@",@([number length]));
    
    id person = [[Person alloc] init];
    NSLog(@"name:%@",[person name]);
}
```

the console log:
```
string:123
length:0
name:(null)
```


---

# Log

1.Handle crash of 'unrecognized selector'.(2018-11-26)
