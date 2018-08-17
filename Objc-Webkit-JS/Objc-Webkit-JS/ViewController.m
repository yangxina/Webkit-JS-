//
//  ViewController.m
//  Objc-Webkit-JS
//
//  Created by 小星星 on 2018/8/17.
//  Copyright © 2018年 yangxin. All rights reserved.
//

#import "ViewController.h"
#import "WebkitViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)pushNextWebVC:(UIButton *)sender {
    WebkitViewController * webVC = [[WebkitViewController alloc]init];
    webVC.title = @"Objc - Js 交互";
    [self.navigationController pushViewController:webVC animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
