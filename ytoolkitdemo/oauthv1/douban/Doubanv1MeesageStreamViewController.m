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

#import "Doubanv1MeesageStreamViewController.h"
#import <ytoolkit/ymacros.h>
#import "ASIHTTPRequest+YOAuthv1Request.h"
#import "DoubanClientCredentials.h"
#import <SBJson/SBJson.h>
#import "DoubanOAuthv1LoginViewController.h"

@implementation Doubanv1MeesageStreamViewController

+ (NSString *)description {
    return @"Douban API demo";
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Douban API demo";
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


- (void)loadFeedStream 
{
    if (self.accesstoken && self.tokensecret) {
        NSURL * url = [NSURL URLWithString:@"http://api.douban.com/people/%40me/miniblog?alt=json"];
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:url];
        request.delegate = self;
        [request prepareOAuthv1RequestUsingConsumerKey:kDoubanConsumerKey
                                     consumerSecretKey:kDoubanConsumerSecretKey
                                                 token:self.accesstoken
                                           tokenSecret:self.tokensecret
                                                 realm:kDoubanRealm];
        [request startAsynchronous];
    }
}

- (void)startLogin
{
    DoubanOAuthv1LoginViewController * vc = [[[DoubanOAuthv1LoginViewController alloc] initWithNibName:@"DoubanOAuthv1LoginViewController" bundle:nil] autorelease];
    vc.delegate = self;
    [self presentModalViewController:vc animated:YES];
}


- (void)requestFinished:(ASIHTTPRequest *)request {
    YLOG(@"response:%@", request.responseString);
    id value = [request.responseString JSONValue];
    if (YIS_INSTANCE_OF(value, NSDictionary)) {
        value = [value objectForKey:@"entry"];
        if (YIS_INSTANCE_OF(value, NSArray)) {
            [self.messages removeAllObjects];
            for (id item in value) {
                id title = [item objectForKey:@"title"];
                if (YIS_INSTANCE_OF(title, NSDictionary)) {
                    NSString * content = [title objectForKey:@"$t"];
                    assert(YIS_INSTANCE_OF(content, NSString));
                    [self.messages addObject:content];
                }
            }
        }
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
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

#pragma mark - properties

#define ACCESSTOKEN_KEY @"doubanaccesstoken"
#define TOKENSECRET_KEY  @"doubantokensecret"

- (void)setAccesstoken:(NSString *)accesstoken {
    [super setAccesstoken:accesstoken];
    if ([super accesstoken]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.accesstoken forKey:ACCESSTOKEN_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)accesstoken {

    NSString * token = [super accesstoken];
    if (nil == token) {
        token = [[NSUserDefaults standardUserDefaults] objectForKey:ACCESSTOKEN_KEY];
        self.accesstoken = token;
    }
    return token;
}


- (void)setTokensecret:(NSString *)tokensecret
{
    [super setTokensecret:tokensecret];
    if ([super tokensecret]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.tokensecret forKey:TOKENSECRET_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)tokensecret {
    
    NSString * token = [super tokensecret];
    if (nil == token) {
        token = [[NSUserDefaults standardUserDefaults] objectForKey:TOKENSECRET_KEY];
        self.tokensecret = token;
    }
    return token;
}


@end
