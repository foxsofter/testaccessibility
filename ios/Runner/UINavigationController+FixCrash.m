//
//  UINavigationController+FixCrash.m
//  Runner
//
//  Created by foxsofter on 2020/3/18.
//  Copyright © 2020 The foxsofter Authors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>
#import <objc/runtime.h>
#import "UINavigationController+FixCrash.h"
#import "AppDelegate.h"


@implementation UINavigationController (FixCrash)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self instanceSwizzle:@selector(popViewControllerAnimated:)
              newSelector:@selector(thrio_popViewControllerAnimated:)];
  });
}

- (UIViewController * _Nullable)thrio_popViewControllerAnimated:(BOOL)animated {
  if (self.viewControllers.count > 1) {
      FlutterViewController *vc = self.viewControllers[self.viewControllers.count - 2];
      AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

      appDelegate.flutterEngine.viewController = vc;
      [self thrio_popViewControllerAnimated:YES];
  }
  return nil;
}

+ (void)instanceSwizzle:(SEL)oldSelector newSelector:(SEL)newSelector {
  Class cls = [self class];
  Method oldMethod = class_getInstanceMethod(cls, oldSelector);
  Method newMethod = class_getInstanceMethod(cls, newSelector);

  if (class_addMethod(cls, oldSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
    class_replaceMethod(cls, newSelector, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
  } else {
    method_exchangeImplementations(oldMethod, newMethod);
  }
}

@end
