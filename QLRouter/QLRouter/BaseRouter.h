//
//  BaseRouter.h
//  QLRouter
//
//  Created by iOS123 on 2019/12/2.
//  Copyright © 2019 CQL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseRouter : NSObject
+ (void)baseOpenURL:(NSURL *)url;
+ (NSDictionary *)getDicFromString:(NSString *)string;

+ (void)basePush:(NSString *)vcName dic:(NSDictionary *)dic;
+ (void)basePush:(UIViewController *)fromVC toName:(NSString *)vcName dic:(NSDictionary *)dic;

+ (void)basePresent:(NSString *)vcName dic:(NSDictionary *)dic;
+ (void)basePresent:(UIViewController *)fromVC toName:(NSString *)vcName dic:(NSDictionary *)dic;

+ (id)initClass:(NSString *)name;
+ (id)initClass:(NSString *)name dic:(NSDictionary *)dic;

+ (id)initVC:(NSString *)vcName;
+ (id)initVC:(NSString *)vcName dic:(NSDictionary *)dic;

+ (id)actionMethodFromObj:(id)objc
Selector:(NSString *)selector
  Prarms:(NSArray*)params;
+ (id)actionMethodFromClass:(NSString *)className
Selector:(NSString *)selector
  Prarms:(NSArray*)params;

+ (void)popGestureChangeFromVC:(UIViewController *)vc enable:(BOOL)enable;
@end

NS_ASSUME_NONNULL_END
