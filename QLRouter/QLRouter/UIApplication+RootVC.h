//
//  UIApplication+RootVC.h
//  QLRouter
//
//  Created by iOS123 on 2019/12/2.
//  Copyright © 2019 CQL. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (RootVC)
- (UIWindow *)mainWindow;
//当前控制器
- (UIViewController *)currentViewController;
//当前nav
- (UINavigationController *)currentNavigationController;
@end

NS_ASSUME_NONNULL_END
