//Copyright 2011 Hongbo YANG (hongbo@yang.me). All rights reserved.
//
//Redistribution and use in source and binary forms, with or without modification, are
//permitted provided that the following conditions are met:
//
//1. Redistributions of source code must retain the above copyright notice, this list of
//conditions and the following disclaimer.
//
//2. Redistributions in binary form must reproduce the above copyright notice, this list
//of conditions and the following disclaimer in the documentation and/or other materials
//provided with the distribution.
//
//THIS SOFTWARE IS PROVIDED BY Hongbo YANG ''AS IS'' AND ANY EXPRESS OR IMPLIED
//WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> OR
//CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//The views and conclusions contained in the software and documentation are those of the
//authors and should not be interpreted as representing official policies, either expressed
//or implied, of Hongbo YANG.


#import "DoubanOAuthv1LoginViewController.h"
#import <ytoolkit/NSMutableURLRequest+YOAuth.h>
#import <ytoolkit/ymacros.h>
#import <ytoolkit/ycocoaadditions.h>
#import <ytoolkit/yoauth.h>
#import "DoubanClientCredentials.h"

@implementation DoubanOAuthv1LoginViewController
@synthesize webView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _networkData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.douban.com/service/auth/request_token"]];
    
    // "old version of oauth.py (Douban is using) requires an 'OAuth realm=' format pattern
    // So, the realm should be specified (even @"")
    [request prepareOAuthv1RequestUsingConsumerKey:kDoubanConsumerKey
                                 consumerSecretKey:kDoubanConsumerSecretKey
                                             token:nil
                                       tokenSecret:nil
                                             realm:kDoubanRealm
                                          verifier:nil
                                          callback:nil];
    [NSURLConnection connectionWithRequest:request delegate:self];
    _step = 0;
    
}

- (void)viewDidUnload
{
    [self setWebView:nil];
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
    YRELEASE_SAFELY(_networkData);
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_networkData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_networkData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString * s = [[NSString alloc] initWithData:_networkData encoding:NSUTF8StringEncoding];
    if (s) {
        NSDictionary * p = [s decodedUrlencodedParameters];
        self.accesstoken = [p objectForKey:YOAuthv1OAuthTokenKey];
        self.tokensecret = [p objectForKey:YOAuthv1OAuthTokenSecretKey];
        if (self.accesstoken && self.tokensecret) {
            if (0 == _step) {
                NSDictionary * op = [NSDictionary dictionaryWithObjectsAndKeys:self.accesstoken, YOAuthv1OAuthTokenKey, 
                                     @"http://ytoolkitdemo/", YOAuthv1OAuthCallbackKey, nil];
                NSString * url = [@"http://www.douban.com/service/auth/authorize" URLStringByAddingParameters:op];
                NSURLRequest * r = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                [self.webView loadRequest:r];
            }
            else {
                [self.delegate oauthv1LoginDidFinishLogging:self];
            }
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL * url = request.URL;
    NSString * s = [url absoluteString];
    NSString * host = [s host];
    if ([host isEqualToString:@"ytoolkitdemo"]) {
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.douban.com/service/auth/access_token"]];
        [request prepareOAuthv1RequestUsingConsumerKey:kDoubanConsumerKey
                                     consumerSecretKey:kDoubanConsumerSecretKey 
                                                 token:self.accesstoken
                                           tokenSecret:self.tokensecret 
                                                 realm:kDoubanRealm];
        [_networkData setLength:0];
        _step = 1;
        [NSURLConnection connectionWithRequest:request delegate:self];
        return NO;
    }
    return YES;
}


@end
