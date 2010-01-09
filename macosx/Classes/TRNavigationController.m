//
//  TRNavigationController.m
//  tuxracer
//
//  Created by Pierre d'Herbemont on 3/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TRNavigationController.h"
#import "TRAppDelegate.h"

static id sharedNavigationViewController=nil;

@implementation TRNavigationController
@synthesize lastNavAction;
/* parent view est au cas au ou le controller est inclus dans un autre view controller, ce qui peut permettre de dire au back button initial de virer la parent view. mettre nil sinon. */

+ (id)sharedNavigationController {
 	if(!sharedNavigationViewController)
		sharedNavigationViewController = [[[self alloc] init] autorelease];
	return sharedNavigationViewController;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController andParentViewController:(UIViewController*)parentViewController
{
    if((self = [super initWithRootViewController:rootViewController])) {
        rootViewController.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(backToMainMenu)] autorelease];
        [[self navigationBar] setBarStyle:UIBarStyleBlackOpaque];
		_linkToParentViewController = [parentViewController retain];
		sharedNavigationViewController=self;
		printf("init : %d\n",[rootViewController retainCount]);
		self.lastNavAction=LOADED;
    }
    return self;
}

- (void) dealloc
{
	sharedNavigationViewController=nil;
	//Pas besoin de releaser _linkToParentViewController car c'est fait dans slideViewOut
	[super dealloc];
}

- (void)backToMainMenu
{
	UIViewController* viewController;
	if (_linkToParentViewController != nil) viewController = _linkToParentViewController; 
	else viewController = self;
	[[TRAppDelegate sharedAppDelegate] slideViewControllerOut:viewController animated:YES];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
	self.lastNavAction=POP;
	return [super popViewControllerAnimated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	self.lastNavAction=PUSH;
	[super pushViewController:viewController animated:animated];
}
@end
