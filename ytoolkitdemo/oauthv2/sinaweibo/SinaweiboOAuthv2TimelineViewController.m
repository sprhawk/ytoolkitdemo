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

#import "SinaweiboOAuthv2TimelineViewController.h"
#import <ytoolkit/ymacros.h>
#import <ytoolkit/yoauth.h>
#import <ytoolkit/ycocoaadditions.h>
#import "ASIFormDataRequest.h"
#import "SBJson/SBJson.h"
#import "SinaweiboOAuthv2LoginSelectorViewController.h"

@implementation SinaweiboOAuthv2TimelineViewController

+ (NSString *)description
{
    return @"Sina Weibo OAuth 2.0 Demo";
}


#pragma mark - network
- (void)loadFeedStream
{
    if (self.accesstoken) {
        NSString * urlString = @"https://api.weibo.com/2/statuses/home_timeline.json";
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:
                                   [NSURL URLWithString:urlString]];
        request.delegate = self;
        [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth2 %@", self.accesstoken]];
        [request startAsynchronous];
    }
    else {
        
        
    }
}

- (void)startLogin
{
    SinaweiboOAuthv2LoginSelectorViewController * login = [[[SinaweiboOAuthv2LoginSelectorViewController alloc] 
                                                    initWithStyle:UITableViewStylePlain] 
                                                   autorelease];
    login.delegate = self;
    UINavigationController * navController = [[[UINavigationController alloc] 
                                               initWithRootViewController:login] 
                                              autorelease];
    [self presentModalViewController:navController animated:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    YLOG(@"response:%@", request.responseString);
    id value = [request.responseString JSONValue];
    if (YIS_INSTANCE_OF(value, NSDictionary)) {
        value = [value objectForKey:@"statuses"];
        if (YIS_INSTANCE_OF(value, NSArray)) {
            [self.messages removeAllObjects];
            for (id item in value) {
                if (YIS_INSTANCE_OF(item, NSDictionary)) {
                    NSString * message = [item objectForKey:@"text"];
                    if (YIS_INSTANCE_OF(message, NSString)) {
                        [self.messages addObject:message];
                    }
                }
            }
        }
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] 
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView * alertView = [[[UIAlertView alloc] initWithTitle:@"Facebook"
                                                          message:[request.error localizedDescription]
                                                         delegate:nil 
                                                cancelButtonTitle:@"OK" 
                                                otherButtonTitles:nil] autorelease];
    [alertView show];
    YLOG(@"Response:%@", request.responseString);
}

#pragma mark - properties

#define ACCESSTOKEN_KEY @"sinaweiboaccesstoken"
#define REFRESHTOKEN_KEY  @"sinaweiborefreshtoken"

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


- (void)setRefreshtoken:(NSString *)refreshtoken
{
    [super setRefreshtoken:refreshtoken];
    if ([super refreshtoken]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.refreshtoken forKey:REFRESHTOKEN_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)refreshtoken {
    
    NSString * token = [super refreshtoken];
    if (nil == token) {
        token = [[NSUserDefaults standardUserDefaults] objectForKey:REFRESHTOKEN_KEY];
        self.refreshtoken = token;
    }
    return token;
}

@end
