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

#import "OAuthv1BaseFeedViewController.h"
#import <ytoolkit/ymacros.h>

@implementation OAuthv1BaseFeedViewController
@synthesize accesstoken = _accesstoken;
@synthesize tokensecret = _tokensecret;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.accesstoken = nil;
    self.tokensecret = nil;
    [super dealloc];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


#pragma mark - Table view delegate

#pragma mark - network

- (void)oauthv1LoginDidFinishLogging:(OAuthv1BaseLoginViewController *)loginViewController {
    self.accesstoken = loginViewController.accesstoken;
    self.tokensecret = loginViewController.tokensecret;
    [self dismissModalViewControllerAnimated:YES];
}



#pragma mark - properties

@end
