//
//Copyright (c) 2011, Hongbo Yang (hongbo@yang.me)
//All rights reserved.
//
//1. Redistribution and use in source and binary forms, with or without modification, are permitted 
//provided that the following conditions are met:
//
//2. Redistributions of source code must retain the above copyright notice, this list of conditions 
//and 
//the following disclaimer.
//
//3. Redistributions in binary form must reproduce the above copyright notice, this list of conditions
//and the following disclaimer in the documentation and/or other materials provided with the 
//distribution.
//
//Neither the name of the Hongbo Yang nor the names of its contributors may be used to endorse or 
//promote products derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
//IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
//FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
//CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
//DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
//DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
//IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT 
//OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "SinaweiboOAuthv1LoginViewController.h"

#import "SinaweiboClientCredentials.h"

#import "SBJson/SBJson.h"
#import <ytoolkit/ymacros.h>
#import <ytoolkit/ycocoaadditions.h>
#import <ytoolkit/yoauthadditions.h>

@implementation SinaweiboOAuthv1LoginViewController
@synthesize webView;
@synthesize activityIndicator;

#pragma mark - View lifecycle

- (void)donePINCode:(id)sender
{ 
    //What to do? no documentation... at http://open.weibo.com/wiki/Oauth
}

- (void)enterPINCode:(id)sender
{
    [UIView beginAnimations:@"pincode" context:NULL];
    [UIView setAnimationDuration:1.0f];
    [UIView commitAnimations];
    UIBarButtonItem * item = [[[UIBarButtonItem alloc] initWithTitle:@"Continue" 
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(donePINCode:)] autorelease];
    [self.navigationItem setLeftBarButtonItem:item animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://api.t.sina.com.cn/oauth/request_token"]];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    [request prepareOAuthv1AuthorizationHeaderUsingConsumerKey:kSinaweiboApiKey
                                             consumerSecretKey:kSinaweiboApiSecret
                                                         token:nil
                                                   tokenSecret:nil
                                               signatureMethod:YOAuthv1SignatureMethodHMAC_SHA1
                                                         realm:nil
                                                      verifier:nil
                                                      callback:kSinaweiboApiCallbackURL];
    //Note: the callback DOES NOT WORK! faint ~_~, even I set the app type to web app type as documented
    _step = 0;
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.activityIndicator startAnimating];
    [request startAsynchronous];
    
//    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Enter PIN code"
//                                                                              style:UIBarButtonItemStyleBordered
//                                                                             target:self action:@selector(enterPINCode:)] autorelease];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [webView release];
    [activityIndicator release];
    [super dealloc];
}


#pragma mark - Network
- (void)requestFinished:(ASIHTTPRequest *)request {
    YLOG(@"response:%@", request.responseString);
    NSDictionary * params = [request.responseString decodedUrlencodedParameters];
    self.accesstoken = [params objectForKey:YOAuthv1OAuthTokenKey];
    self.tokensecret = [params objectForKey:YOAuthv1OAuthTokenSecretKey];
    NSString * confirmed = [params objectForKey:YOAuthv1OAuthCallbackConfirmedKey];
    
    if(confirmed)NSLog(@"callback is confirmed:%@", confirmed);
    
    if (self.accesstoken && self.tokensecret) {
        if (0 == _step) {
            NSString * url = [NSString stringWithFormat:@"http://api.t.sina.com.cn/oauth/authorize?%@=%@&oauth_callback=%@", YOAuthv1OAuthTokenKey, self.accesstoken, kSinaweiboApiCallbackURL];
            NSMutableURLRequest * r = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            [self.webView loadRequest:r];
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            [self.activityIndicator startAnimating];
        }
        else {
            [self.delegate oauthv1LoginDidFinishLogging:self];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    UIAlertView * alertView = [[[UIAlertView alloc] initWithTitle:[[self class] description]
                                                          message:[request.error localizedDescription]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil] autorelease];
    [alertView show];
    
    YLOG(@"response:%@", request.responseString);
    NSDictionary * params = [request.responseString decodedUrlencodedParameters];
    id cn = [params objectForKey:@"error_CN"];
    YLOG(@"cn:%@", cn);
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView 
{
    [self.activityIndicator stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL * url = request.URL;
    NSString * s = [url absoluteString];
    NSString * host = [s host];
    YLOG(@"load Request to: %@", s);
    //Callback does not work!
    if ([host isEqualToString:[kSinaweiboApiCallbackURL host]]) {
        NSDictionary * p = [s queryParameters];
        NSString * verifier = [p objectForKey:YOAuthv1OAuthVerifierKey];
        NSString * token = [p objectForKey:YOAuthv1OAuthTokenKey];
        ASIHTTPRequest * r = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://api.t.sina.com.cn/oauth/access_token"]];
        [r setRequestMethod:@"POST"];
        r.delegate = self;
        [r prepareOAuthv1AuthorizationHeaderUsingConsumerKey:kSinaweiboApiKey
                                           consumerSecretKey:kSinaweiboApiSecret
                                                       token:token
                                                 tokenSecret:self.tokensecret
                                             signatureMethod:YOAuthv1SignatureMethodHMAC_SHA1
                                                       realm:nil
                                                    verifier:verifier
                                                    callback:nil];
        _step = 1;
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self.activityIndicator startAnimating];
        [r startAsynchronous];
        
        return NO;
    }
    return YES;
}


@end
