//
//Copyright (c) 2011, Hongbo Yang (hongbo@yang.me)
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without modification, are permitted 
//provided that the following conditions are met:
//
//Redistributions of source code must retain the above copyright notice, this list of conditions 
//and 
//the following disclaimer.
//
//Redistributions in binary form must reproduce the above copyright notice, this list of conditions
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

#import "FlickrLoginViewController.h"
#import "ASIHTTPRequest+YOAuthv1Request.h"
#import "FlickrClientCredentials.h"

#import "SBJson/SBJson.h"
#import <ytoolkit/ymacros.h>
#import <ytoolkit/ycocoaadditions.h>
#import <ytoolkit/yoauthadditions.h>
#import "QQWeiboClientCredentials.h"

@implementation FlickrLoginViewController
@synthesize webView;
@synthesize activityIndicator;
@synthesize verifier = _verifier;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://www.flickr.com/services/oauth/request_token"]];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    [request prepareQQOAuthv1QueryURIUsingConsumerKey:kFlickrAppKey
                                  consumerSecretKey:kFlickrAppSecret
                                              token:nil
                                        tokenSecret:nil
                                    signatureMethod:YOAuthv1SignatureMethodHMAC_SHA1
                                           verifier:nil
                                           callback:@"http://ytoolkitdemo/"];
    _step = 0;
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.activityIndicator startAnimating];
    [request startAsynchronous];
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

- (void)requestFinished:(ASIHTTPRequest *)request {
    YLOG(@"response:%@", request.responseString);
    NSDictionary * params = [request.responseString decodedUrlencodedParameters];
    self.accesstoken = [params objectForKey:YOAuthv1OAuthTokenKey];
    self.tokensecret = [params objectForKey:YOAuthv1OAuthTokenSecretKey];
    NSString * confirmed = [params objectForKey:YOAuthv1OAuthCallbackConfirmedKey];
    
    if(confirmed)NSLog(@"callback is confirmed:%@", confirmed);
    
    if (self.accesstoken && self.tokensecret) {
        if (0 == _step) {
            NSString * url = [NSString stringWithFormat:@"http://www.flickr.com/services/oauth/authorize?perms=read&%@=%@", YOAuthv1OAuthTokenKey, self.accesstoken];
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
    if ([host isEqualToString:@"ytoolkitdemo"]) {
        NSDictionary * p = [s queryParameters];
        if (nil == [p objectForKey:@"denied"]) {//what is the denied action for Flickr?
            self.verifier = [p objectForKey:YOAuthv1OAuthVerifierKey];
            ASIHTTPRequest * r = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://www.flickr.com/services/oauth/access_token"]];
            [r setRequestMethod:@"POST"];
            r.delegate = self;
            [r prepareQQOAuthv1QueryURIUsingConsumerKey:kFlickrAppKey
                                    consumerSecretKey:kFlickrAppSecret
                                                token:self.accesstoken
                                          tokenSecret:self.tokensecret
                                      signatureMethod:YOAuthv1SignatureMethodHMAC_SHA1
                                             verifier:self.verifier
                                             callback:nil];
            _step = 1;
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            [self.activityIndicator startAnimating];
            [r startAsynchronous];
        }
        else {
            YLOG(@"authorize denied:%@", [p objectForKey:@"denied"]);
        }
        
        return NO;
    }
    return YES;
}


@end
