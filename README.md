# iOS PAYCO 결제 데모

PAYCO APP 결제 연동을 위한 iOS 데모 앱과 가이드 입니다.
* Github: https://github.com/nhn/Payco_TechSupport.app_ios

## iOS 적용 가이드

### 1. 스킴 추가
* iOS PAYCO 결제 연동은 기본적으로 유니버셜링크 기반으로 동작합니다.  
  그런데 앱업데이트나 iOS 업데이트 과정에서 [유니버셜링크가 비활성화 되는 경우](https://openradar.appspot.com/4999496467480576)가 있어  
  이럴경우 PAYCO 결제 브릿지 웹뷰 내부에서는 URLSCheme 방식으로 우회하여 결제를 처리합니다.  
* PAYCO 결제 브릿지 웹뷰 내부에서 URLScheme 처리를 위해 가맹점 앱 내부에서 2가지 방안으로 처리할 수 있습니다.  
  ①`openURL:option:completionHandler:` 를 사용하거나  
  ②`canOpenURL(_:)로 앱의 설치 여부를 판단하는 코드가 있을 경우`,  
  Info.plist에 아래와 같이 앱 스킴이 추가되어야 합니다.  
     ```xml
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>payco</string>
        ...
    </array>
    ```
### 2. 쿠키 저장소 정책 변경
* 원활한 결제 플로우를 제공하기 위해 쿠키 저장소 정책을 `HTTPCookie.AcceptPolicy.always` 로 설정합니다.
* swift
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let cookieStorate: HTTPCookieStorage    = HTTPCookieStorage.shared
        cookieStorate.cookieAcceptPolicy        = .always
        ...
        return true
}
```
* Objective-C
```swift
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSHTTPCookieStorage *sHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    sHTTPCookieStorage.cookieAcceptPolicy   = NSHTTPCookieAcceptPolicyAlways;
    ...
    return YES;
}
```

### 3. 웹뷰 델리게이트 메소드 구현

* swift

```swift
//WKWebview를 사용할 경우, WKNavigationDelegate의 메소드 예시
func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        ...
        var policy: WKNavigationActionPolicy = .allow
        if let url: URL = navigationAction.request.url,
           let scheme: String = url.scheme {
            switch scheme {
                case "payco":
                    
                    policy = .cancel
                    
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:]) { (success) in
                            decisionHandler(policy)
                        }
                    } else {
                        UIApplication.shared.openURL(url)
                        decisionHandler(policy)
                    }
                    break
                
                default:
                    decisionHandler(policy)
                    break
            }
            ...
        }
//UIWebview를 사용할 경우, UIWebViewDelegate의 메소드 예시        
func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool
    {
        ...
        if let url: URL = request.url,
           let scheme: String = url.scheme {
           var result : Bool = true
            switch scheme {
                case "payco":
                    result = false
                    
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                    break
                
                default:
                    break
            }
        }
    }        

//UIWebview를 사용할 경우, UIWebViewDelegate의 메소드 예시
func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool
    {
        var shouldStartLoadWith: Bool = true
        
        if let url: URL = request.url,
           let scheme: String = url.scheme {
            
            switch scheme {
                case "payco":
                    
                    if #available(iOS 10.0, *) {
                        shouldStartLoadWith = false
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                    } else {
                        shouldStartLoadWith = false
                        UIApplication.shared.openURL(url)
                        
                    }
                    break
                
                default:
                    break
            }
            
        }
        return shouldStartLoadWith
    }
```


* Objective-C

```swift

//WKWebview를 사용할 경우, WKNavigationDelegate의 메소드 예시
- (void)webView:(WKWebView *)aWebView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    ...
    WKNavigationActionPolicy sPolicy    = WKNavigationActionPolicyAllow;
    NSURL *sURL                         = navigationAction.request.URL;
    NSString *sScheme                   = sURL.scheme;
    
    if ([@"payco" isEqualToString:sScheme]) {
        
        sPolicy = WKNavigationActionPolicyCancel;
        
        if (@available(iOS 10.0, *)) {
            
            [[UIApplication sharedApplication] openURL:sURL options:@{} completionHandler:^(BOOL sSuccess) {
                
                decisionHandler(sPolicy);
                
            }];
        }
        else {
            
            [[UIApplication sharedApplication] openURL:sURL];
            
            decisionHandler(sPolicy);
        }
    }
    ...
}


//UIWebview를 사용할 경우, UIWebViewDelegate의 메소드 예시
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *sURL                         = request.URL;
    NSString *sScheme                   = sURL.scheme;
    
    if ([@"payco" isEqualToString:sScheme]) {
        
        if (@available(iOS 10.0, *)) {
            
            [[UIApplication sharedApplication] openURL:sURL options:@{} completionHandler:^(BOOL sSuccess) {}];
            return NO;
        }
        else {
            
            [[UIApplication sharedApplication] openURL:sURL];
            return NO;
        }
    }
    
    return YES;
    
}
```

## PAYCO iOS 개발용 APP 연동 

* 테스트 URL : https://devcenter.payco.com/demo/easyPay2 
* ID/PW : payco/payco1234

### 1. PAYCO iOS 개발용 APP 다운로드

* URL : https://devcenter.payco.com/download/m/app
* ID/PW : payco/payco1234
* `주의 사항 : 해당 디바이스에서 앱스토어를 통해 설치한 PAYCO iOS 앱은 삭제해주셔야 합니다.` 

### 2. 결제 테스트를 위한 Webview 제작

* 1,2,3을 참고하여 https://devcenter.payco.com/demo/easyPay2를 로드하기 위한 Webview 제작하고, 필요한 델리게이트 메소드를 구현합니다.
* 해당 웹뷰에서  https://devcenter.payco.com/demo/easyPay2 페이지를 로드합니다.
* ID/PW : payco/payco1234 로 로그인합니다.
* `주문 예약 실행` 버튼을 클릭합니다.(주문 예약 API 호출을 시뮬레이션 하는 과정)
* `결제하기` 버튼을 클릭합니다.
* 화면이 전환되고, 노출되는 결제 브릿지 페이지에서 `PAYCO앱으로 결제` 버튼을 눌러서 PAYCO iOS 개발용 앱이 정상 구동되고, 결제 화면으로 전환되는지 확인합니다. 
