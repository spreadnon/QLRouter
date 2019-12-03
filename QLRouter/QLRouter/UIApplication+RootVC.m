//
//  UIApplication+RootVC.m
//  QLRouter
//
//  Created by iOS123 on 2019/12/2.
//  Copyright © 2019 CQL. All rights reserved.
//

#import "UIApplication+RootVC.h"


@implementation UIApplication (RootVC)
- (UIWindow *)mainWindow {
    //适配iOS13的 SceneDelegate， AppDelegate添加 @property (strong, nonatomic) UIWindow *window;
    for (UIWindow * obj in self.windows) {
        if ([obj isKeyWindow]) {
            return obj;
        }
    }
    return self.delegate.window;
}

- (UIViewController *)currentViewController {
    UIViewController *rootViewController = [self.mainWindow rootViewController];
    return [self getCurrentViewControllerFrom:rootViewController];
}

- (UIViewController *) getCurrentViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getCurrentViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getCurrentViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [self getCurrentViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

- (UINavigationController *)currentNavigationController {
    return [[self currentViewController] navigationController];
}
@end
