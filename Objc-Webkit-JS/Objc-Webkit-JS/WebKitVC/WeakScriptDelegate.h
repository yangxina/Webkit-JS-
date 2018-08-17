//
//  WeakScriptDelegate.h
//  Objc-Webkit-JS
//
//  Created by 小星星 on 2018/8/17.
//  Copyright © 2018年 yangxin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
@interface WeakScriptDelegate : NSObject <WKScriptMessageHandler>

@property (assign, nonatomic) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWith: (id<WKScriptMessageHandler>)scriptDelegate;
@end
