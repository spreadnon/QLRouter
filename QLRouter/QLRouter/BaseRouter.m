//
//  BaseRouter.m
//  QLRouter
//
//  Created by iOS123 on 2019/12/2.
//  Copyright © 2019 CQL. All rights reserved.
//

#import "BaseRouter.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "UIApplication+RootVC.h"

// value为需要转换的变量
#define SetValue(value) [NSValue valueWithBytes:&value objCType:@encode(typeof(value))]

// value为NSValue返回值，Type为返回值类型
#define GetValue(value, Type)\
({\
NSUInteger valueSize = 0;\
NSGetSizeAndAlignment(@encode(Type), &valueSize, NULL);\
void * par = NULL;\
par = reallocf(par, valueSize);\
if (@available(iOS 11.0, *)) {\
[value getValue:par size:valueSize];\
} else {\
[value getValue:par];\
}\
(*((Type *)par));\
})\

@implementation BaseRouter
+ (void)baseOpenURL:(NSURL *)url{
    if (url.path.length>0) {
        NSString *vcName = [url.path substringFromIndex:1];
        NSDictionary *dic = [self getDicFromString:url.query];
        NSLog(@"vcN:   %@,dic:   %@   host: %@",vcName,dic,url.host);
        if(url.host && vcName.length>0){
            if([url.host isEqualToString:@"present"]) {
                [self basePresent:vcName dic:dic];
            }else{
                [self basePush:vcName dic:dic];
            }
        }
    }
}

+ (NSDictionary *)getDicFromString:(NSString *)string{
    if (string.length>0&&[string containsString:@"="]) {
        NSArray *keyValues = [string componentsSeparatedByString:@"&"];
        NSMutableDictionary *dic = @{}.mutableCopy;
        [keyValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [dic setObject:[obj componentsSeparatedByString:@"="].lastObject forKey:[obj componentsSeparatedByString:@"="].firstObject];
        }];
        return dic;
    }
    return nil;
}

#pragma mark - push控制器
// push控制器
+ (void)basePush:(NSString *)vcName dic:(NSDictionary *)dic{
    UIViewController *instance = [self initVC:vcName dic:dic];
    if (instance) {
        instance.hidesBottomBarWhenPushed=YES;
        [[[UIApplication sharedApplication] currentNavigationController] pushViewController:instance animated:YES];
    }
}
+ (void)basePush:(UIViewController *)fromVC toName:(NSString *)vcName dic:(NSDictionary *)dic{
    UIViewController *instance = [self initVC:vcName dic:dic];
    if (instance && fromVC) {
        instance.hidesBottomBarWhenPushed=YES;
        [fromVC.navigationController pushViewController:instance animated:YES];
    }
    
}
#pragma mark - Present控制器
+ (void)basePresent:(NSString *)vcName dic:(NSDictionary *)dic{
    id instance = [self initVC:vcName dic:dic];
    if (instance) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:instance];
        nav.navigationBar.barTintColor = [UIColor whiteColor];
        nav.navigationBar.backgroundColor = [UIColor whiteColor];
        nav.navigationBar.translucent = NO;
        [[[UIApplication sharedApplication] currentViewController] presentViewController:nav animated:YES completion:nil];
    }
}
+ (void)basePresent:(UIViewController *)fromVC toName:(NSString *)vcName dic:(NSDictionary *)dic{
    id instance = [self initVC:vcName dic:dic];
    if (instance && fromVC) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:instance];
        nav.navigationBar.barTintColor = [UIColor whiteColor];
        nav.navigationBar.backgroundColor = [UIColor whiteColor];
        nav.navigationBar.translucent = NO;
        [fromVC presentViewController:nav animated:YES completion:nil];
    }
}
#pragma mark - 初始化指定名字的VC
+ (id)initVC:(NSString *)vcName{
    id vc = [self initClass:vcName];
    if (vc) {
        if ([vc isKindOfClass:[UIViewController class]]) {
            return vc;
        }
        [self alertMessage:[NSString stringWithFormat:@"Class %@不是controller",vcName]];
        return nil;
    }else{
        [self alertMessage:[NSString stringWithFormat:@"Class %@不存在",vcName]];
        return nil;
    }
    return nil;
}
#pragma mark - 初始化指定名字的VC 并且给相应的属性赋值
+ (id)initVC:(NSString *)vcName dic:(NSDictionary *)dic{
    id instance = [self initVC:vcName];
    if (instance) {
        //下面是传值－－－－－－－－－－－－－－
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([self checkIsExistPropertyWithInstance:instance verifyPropertyName:key]) {
                //kvc给属性赋值
                NSLog(@"%@,%@",obj,key);
                [instance setValue:obj forKey:key];
            }else {
                NSLog(@"不包含key=%@的属性",key);
            }
        }];
    }
    return instance;
}
#pragma mark - 初始化指定名字的类
/**  返回类对象 */
+ (id)initClass:(NSString *)name{
    //类名(对象名)
    if (!name||name.length==0) {
        [self alertMessage:@"请传入class名"];
        return nil;
    }
    NSString *class = name;
    const char *className = [class cStringUsingEncoding:NSASCIIStringEncoding];
    Class newClass = objc_getClass(className);
    if (!newClass) {
        NSLog(@"Class %@不存在",name);
        return nil;
    }
    // 创建对象(写到这里已经可以进行随机页面跳转了)
    return [[newClass alloc] init];
}

+ (id)initClass:(NSString *)name dic:(NSDictionary *)dic{
    id instance = [self initClass:name];
    if (instance) {
        //下面是传值－－－－－－－－－－－－－－
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([self checkIsExistPropertyWithInstance:instance verifyPropertyName:key]) {
                //kvc给属性赋值
                NSLog(@"%@,%@",obj,key);
                [instance setValue:obj forKey:key];
            }else {
                NSLog(@"不包含key=%@的属性",key);
            }
        }];
    }
    return instance;
}
#pragma mark - 检测对象是否存在该属性
/**
 *  检测对象是否存在该属性
 */
+ (BOOL)checkIsExistPropertyWithInstance:(id)instance verifyPropertyName:(NSString *)verifyPropertyName{
    unsigned int outCount, i;
    // 获取对象里的属性列表
    objc_property_t * properties = class_copyPropertyList([instance
                                                           class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property =properties[i];
        //  属性名转成字符串
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        // 判断该属性是否存在
        if ([propertyName isEqualToString:verifyPropertyName]) {
            free(properties);
            return YES;
        }
    }
    free(properties);
    // 再遍历父类中的属性
    Class superClass = class_getSuperclass([instance class]);
    //通过下面的方法获取属性列表
    unsigned int outCount2;
    objc_property_t *properties2 = class_copyPropertyList(superClass, &outCount2);
    
    for (int i = 0 ; i < outCount2; i++) {
        objc_property_t property2 = properties2[i];
        //  属性名转成字符串
        NSString *propertyName2 = [[NSString alloc] initWithCString:property_getName(property2) encoding:NSUTF8StringEncoding];
        // 判断该属性是否存在
        if ([propertyName2 isEqualToString:verifyPropertyName]) {
            free(properties2);
            return YES;
        }
    }
    free(properties2); //释放数组
    return NO;
}

#pragma mark - 消息转发调用方法

/**
 *调用某个类中的实例方法
 */
+ (id)actionMethodFromObj:(id)objc Selector:(NSString *)selector Prarms:(NSArray*)params{
    return  [self msgSendToObj:objc Selector:NSSelectorFromString(selector) Prarms:params];
}

+ (id)msgSendToObj:(id)obj Selector:(SEL)selector Prarms:(NSArray*)params{
    
    id value = nil;
    if (obj && selector) {
        if ([obj respondsToSelector:selector]) {
            NSMethodSignature * signature = [[obj class] instanceMethodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setSelector:selector];
            [invocation setTarget:obj];
            
            // 这里判断参数个数 与 params参数是否相等
            NSInteger paramCount = signature.numberOfArguments;
            if(params.count != paramCount - 2) {
                return nil;
            }
            
            // 设置参数
            for(int i = 0; i < paramCount - 2; i++) {
                id ref = params[i];
                if([ref isKindOfClass:[NSNull class]]) {
                    ref = nil;
                }
                
                // 设置参数
                [self setMethodArgument:invocation signature:signature param:ref atIndex:i + 2];
            }
            [invocation invoke];//perform 的传参表达方式
            
            // 返回值
            if(signature.methodReturnLength != 0){
                return [self getMethodArgument:invocation signature:signature];
            }
        }else{
#ifdef DEBUG
            NSLog(@"msgToTarget unRespondsToSelector -->>> %@",obj);
#endif
        }
    }
    return value;
}
/**
 *调用某个类中的类方法idz
 */
+ (id)actionMethodFromClass:(NSString *)className Selector:(NSString *)selector Prarms:(NSArray*)params{
    return  [self msgSendToClass:NSClassFromString(className) Selector:NSSelectorFromString(selector) Prarms:params];
}
+ (id)msgSendToClass:(Class)cClass Selector:(SEL)selector Prarms:(NSArray*)params{
    
    id value = nil;
    Method method = class_getClassMethod(cClass, selector);
    if((int)method != 0){
        //        [[cClass class] instanceMethodSignatureForSelector:selector];
        NSMethodSignature * signature = [cClass methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setTarget:cClass];
        
        // 这里判断参数个数 与 params参数是否相等
        NSInteger paramCount = signature.numberOfArguments;
        if(params.count != paramCount - 2) {
            return nil;
        }
        
        // 设置参数
        for(int i = 0; i < paramCount - 2; i++) {
            id ref = params[i];
            if([ref isKindOfClass:[NSNull class]]) {
                ref = nil;
            }
            
            // 设置参数
            [self setMethodArgument:invocation signature:signature param:ref atIndex:i + 2];
        }
        [invocation invoke];//perform 的传参表达方式
        
        // 返回值
        if(signature.methodReturnLength != 0){
            return [self getMethodArgument:invocation signature:signature];
        }
    }else{
#ifdef DEBUG
        NSLog(@"msgToClass unRespondsToSelector -->>> %@ %@",cClass,method);
#endif
    }
    return value;
}

// 设置函数参数
+ (void)setMethodArgument:(NSInvocation *)invocation signature:(NSMethodSignature *)signature param:(id)param atIndex:(NSInteger)index {
    const char * paramType = [signature getArgumentTypeAtIndex:index];
    
    if(!strcmp(paramType, @encode(id))) {
        [invocation setArgument:&param atIndex:index];
    }else if(!strcmp(paramType, @encode(void (^)(void)))) {
        // block
        [invocation setArgument:&param atIndex:index];
    }else {
        // 不确定类型，C数组、联合、结构体 等
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(paramType, &valueSize, NULL);
        
        void * par = NULL;
        par = reallocf(par, valueSize);
        if (@available(iOS 11.0, *)) {
            [param getValue:par size:valueSize];
        } else {
            // Fallback on earlier versions
            [param getValue:par];
        }
        
        [invocation setArgument:par atIndex:index];
    }
}

// 获取方法返回值
+ (id)getMethodArgument:(NSInvocation *)invocation signature:(NSMethodSignature *)signature {
    void * returnValue = nil;
    const char * paramType = signature.methodReturnType;
    
    if(!strcmp(paramType, @encode(id))) {
        [invocation getReturnValue:&returnValue];
    }else if(!strcmp(paramType, @encode(void (^)(void)))) {
        [invocation getReturnValue:&returnValue];
    }else {
        // 不确定类型，C数组、联合、结构体 等
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(paramType, &valueSize, NULL);
        
        void * par = NULL;
        par = reallocf(par, valueSize);
        [invocation getReturnValue:par];
        returnValue = (__bridge void *)([NSValue valueWithBytes:par objCType:paramType]);
    }
    
    return (__bridge id)(returnValue);
}

+(void)alertMessage:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { }];
    [alertController addAction:cancelAction];
    [[[UIApplication sharedApplication] currentViewController] presentViewController:alertController animated:YES completion:^{ }];
}


+ (void)popGestureChangeFromVC:(UIViewController *)vc enable:(BOOL)enable{
    if ([vc.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        //遍历所有的手势
        for (UIGestureRecognizer *popGesture in vc.navigationController.interactivePopGestureRecognizer.view.gestureRecognizers) {
            popGesture.enabled = enable;
        }
    }
}
@end
