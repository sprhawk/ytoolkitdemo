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
//FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Hongbo YANG OR
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

#import "FacebookNewsFeedViewController.h"
#import <ytoolkit/ymacros.h>
#import <ytoolkit/yoauth.h>
#import <ytoolkit/ycocoaadditions.h>
#import "ASIFormDataRequest.h"
#import "SBJson.h"

@implementation FacebookNewsFeedViewController
+ (NSString *)description {
    return @"Facebook OAuth 2.0 demo";
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - delegate


#pragma mark - network
- (void)loadFeedStream
{
    if (self.accesstoken) {
        NSString * urlString = @"https://graph.facebook.com/me/home";
        NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.accesstoken, YOAuthv2AccessToken, nil];
        
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:
                                   [NSURL URLWithString:
                                    [urlString URLStringByAddingParameters:parameters]]];
        request.delegate = self;
        [request startAsynchronous];
    }
    else {
        
        
    }
}

- (void)startLogin
{
    FacebookLoginSelectorViewController * login = [[[FacebookLoginSelectorViewController alloc] 
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
        value = [value objectForKey:@"data"];
        if (YIS_INSTANCE_OF(value, NSArray)) {
            [self.messages removeAllObjects];
            for (id item in value) {
                if (YIS_INSTANCE_OF(item, NSDictionary)) {
                    NSString * message = [item objectForKey:@"message"];
                    if (YIS_INSTANCE_OF(message, NSString)) {
                        [self.messages addObject:message];
                    }
                    else {
                        message = [item objectForKey:@"story"];
                        if (YIS_INSTANCE_OF(message, NSString)) {
                            [self.messages addObject:message];
                        }
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

#define ACCESSTOKEN_KEY @"facebookaccesstoken"
#define REFRESHTOKEN_KEY  @"facebookrefreshtoken"

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
