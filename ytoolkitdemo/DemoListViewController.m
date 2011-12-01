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


#import "DemoListViewController.h"
#import <ytoolkit/ymacros.h>
#import "Doubanv1MeesageStreamViewController.h"
#import "TwitterTimelineListViewController.h"
#import "FacebookNewsFeedViewController.h"
#import "SinaweiboOAuthv2TimelineViewController.h"
#import "SinaweiboOAuthv1TimelineViewController.h"
#import "QQweiboOAuthv1TimelineViewController.h"
#import "FlickrListViewController.h"

@implementation DemoListViewController
@synthesize v1ViewControllers = _v1ViewControllers;
@synthesize v2ViewControllers = _v2ViewControllers;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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

    UIViewController * vc = nil;
    
    NSMutableArray * viewControllers = [NSMutableArray array];
    vc = [[[Doubanv1MeesageStreamViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    [viewControllers addObject:vc];
   
    vc = [[[TwitterTimelineListViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    [viewControllers addObject:vc];
    
    vc = [[[SinaweiboOAuthv1TimelineViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    [viewControllers addObject:vc];
    
    vc = [[[QQweiboOAuthv1TimelineViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    [viewControllers addObject:vc];
    
    vc = [[[FlickrListViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    [viewControllers addObject:vc];

    self.v1ViewControllers = viewControllers;
    
    viewControllers = [NSMutableArray arrayWithCapacity:3];
    vc = [[[FacebookNewsFeedViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    [viewControllers addObject:vc];
    
    vc = [[[SinaweiboOAuthv2TimelineViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    [viewControllers addObject:vc];
    
    self.v2ViewControllers = viewControllers;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.v1ViewControllers = nil;
    self.v2ViewControllers = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    switch (section) {
        case 0:
            return @"OAuth 1.0";
        case 1:
            return @"OAuth 2.0 (draft)";
    }
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [self.v1ViewControllers count];
        case 1:
            return [self.v2ViewControllers count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (0 == indexPath.section) {
        if (indexPath.row < [self.v1ViewControllers count]) {
            UIViewController * vc = [self.v1ViewControllers objectAtIndex:indexPath.row];
            cell.textLabel.text = [[vc class] description];
        }
    }
    else if (1 == indexPath.section) {
        if (indexPath.row < [self.v2ViewControllers count]) {
            UIViewController * vc = [self.v2ViewControllers objectAtIndex:indexPath.row];
            cell.textLabel.text = [[vc class] description];
        }
    }

    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (0 == indexPath.section) {
        if (indexPath.row < [self.v1ViewControllers count]) {
            UIViewController * vc = [self.v1ViewControllers objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (1 == indexPath.section) {
        if (indexPath.row < [self.v2ViewControllers count]) {
            UIViewController * vc = [self.v2ViewControllers objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark -
- (void)setV1ViewControllers:(NSArray *)v1ViewControllers {
    if (_v1ViewControllers != v1ViewControllers) {
        YRELEASE_SAFELY(_v1ViewControllers);
        _v1ViewControllers = [v1ViewControllers retain];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)setV2ViewControllers:(NSArray *)v2ViewControllers {
    if (_v2ViewControllers != v2ViewControllers) {
        YRELEASE_SAFELY(_v2ViewControllers);
        _v2ViewControllers = [v2ViewControllers retain];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
@end
