//
//  WeakScriptDelegate.m
//  Objc-Webkit-JS
//
//  Created by 小星星 on 2018/8/17.
//  Copyright © 2018年 yangxin. All rights reserved.
//

#import "WeakScriptDelegate.h"


/**
 为了处理内存泄漏，将JS交互代理出来
 */
@implementation WeakScriptDelegate

- (instancetype)initWith: (id<WKScriptMessageHandler>)scriptDelegate
{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end
