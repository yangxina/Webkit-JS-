//
//  WebkitViewController.m
//  Objc-Webkit-JS
//
//  Created by 小星星 on 2018/8/17.
//  Copyright © 2018年 yangxin. All rights reserved.
//

#import "WebkitViewController.h"
#import "WeakScriptDelegate.h"
#import  <WebKit/WebKit.h>

static NSString * kListener = @"JSListener";
static NSString * kListenerOther = @"JSListenerOther";

@interface WebkitViewController () <WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebViewConfiguration * webConfig;
@property (nonatomic, strong) WKWebView * webView;
@property (nonatomic, strong) UIBarButtonItem * barButtonLeft;
@property (nonatomic, strong) UIBarButtonItem * barButtonRight;


@end

@implementation WebkitViewController

// MARK: - Geter Funcs

- (WKWebViewConfiguration *)webConfig {
    if (!_webConfig) {
        _webConfig = [[WKWebViewConfiguration alloc] init];
    }
    return _webConfig;
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , self.view.bounds.size.height) configuration:self.webConfig];
        _webView.navigationDelegate = self;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.backgroundColor = [UIColor whiteColor];
        
        // 添加两个 MessageHandler 的代理， 这里的 MessageHandler: 用self，会导致出站时，不调用dealloc 方法，当前VC释放不掉，内存泄漏。
        [_webView.configuration.userContentController addScriptMessageHandler:[[WeakScriptDelegate alloc] initWith:self] name:kListener];
        [_webView.configuration.userContentController addScriptMessageHandler:[[WeakScriptDelegate alloc] initWith:self] name:kListenerOther];
    }
    return _webView;
}

- (UIBarButtonItem *)barButtonLeft {
    if (!_barButtonLeft) {
        _barButtonLeft = [[UIBarButtonItem alloc]initWithTitle: @"CallJs" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonLeftClick:)];
    }
    return _barButtonLeft;
}

- (UIBarButtonItem *)barButtonRight {
    if (!_barButtonRight) {
        _barButtonRight = [[UIBarButtonItem alloc]initWithTitle: @"CallJss" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonRightClick:)];
    }
    return _barButtonRight;
}

// MARK: - Life Cycle

- (void)dealloc {
    // 如果你仔细观察，如果使用
    NSLog(@" >>>>>>>>>> Current VC Dealloc");
    [_webView.configuration.userContentController removeScriptMessageHandlerForName: kListener];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName: kListenerOther];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    [self.navigationItem setRightBarButtonItems:@[self.barButtonLeft, self.barButtonRight]];
    NSString * urlStr = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource: @"test" ofType: @"html"]];
    NSURL * url = [NSURL URLWithString:urlStr];
    [self.webView loadRequest: [NSURLRequest requestWithURL:url]];
    
}

// MARK: - User -Action  点击 调用JS 方法，传递参数

/// 单个参数
- (void)barButtonLeftClick: (UIBarButtonItem *)leftBar {
    
    NSString * email = @"504672006@qq.com";
    
    NSString * jsString = [NSString stringWithFormat:@"nativeToJavaScript('%@')", email];              //@"nativeToJavaScript('\(params)')"   swift
    [self.webView evaluateJavaScript:jsString completionHandler:^(id _Nullable respons, NSError * _Nullable error) {
        if (error != nil) {
            
            NSLog(@"get Info from JS : %@", respons);
        }
    }];
}

/// 多个参数
- (void)barButtonRightClick: (UIBarButtonItem *)rightBar {
    NSArray * params = @[@"NicooYoung", @"13579246810" , @"504672006@qq.com"];
    
    NSString * jsString = [NSString stringWithFormat:@"changeHead('%@,%@,%@')", params[0], params[1], params[2]];   //@"changeHead('\(params)')"   swift
    [self.webView evaluateJavaScript:jsString completionHandler:^(id _Nullable respons, NSError * _Nullable error) {
        if (error != nil) {
            
            NSLog(@"get Info from JS : %@", respons);
        }
    }];
}

// MARK: - js交互获取到JS传来的参数

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString: kListener]) {
        NSLog(@"JS通过 <Listener> 调用原生传来参数： \n%@", message.body);
    } else if ([message.name isEqualToString: kListenerOther]) {
        NSLog(@"JS通过 <ListenerOther> 调用原生传来参数： \n%@", message.body);
    }
}




// MARK: - WKNavigationDelegate

// 决定导航的动作，通常用于处理跨域的链接能否导航。
// WebKit对跨域进行了安全检查限制，不允许跨域，因此我们要对不能跨域的链接单独处理。
// 但是，对于Safari是允许跨域的，不用这么处理。
// 这个是决定是否Request

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

// MARK: - 开始响应
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

// MARK: - 开始加载数据 ,显示菊花来转一转
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

// MARK: - 当main frame接收到服务重定向时调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

// MARK: - 当main frame导航完成时，会回调
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"webHieght = %lu", result);
    }];
}

// MARK: - 当web content处理完成时，会回调
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    
}

 // MARK: - 当main frame最后下载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}
 // MARK: - 当main frame开始加载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
