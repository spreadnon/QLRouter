//
//  ViewController.m
//  QLRouter
//
//  Created by iOS123 on 2019/12/2.
//  Copyright © 2019 CQL. All rights reserved.
//

#import "ViewController.h"
#import "QLRouter.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, 50, 50)];
    closeBtn.backgroundColor = [UIColor blueColor];
    [closeBtn addTarget:self action:@selector(pushB) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
}

- (void)pushB{
    [BaseRouter basePush:@"BViewController" dic:@{@"str":@"123"}];
}
@end
