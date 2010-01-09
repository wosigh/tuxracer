//
//  TRChallengeSubscriptionViewController.m
//  tuxracer
//
//  Created by Pierre d'Herbemont on 3/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TRChallengeSubscriptionViewController.h"
#import "TRAppDelegate.h"
#import "TRPrizeListViewController.h"
#import "TransitionView.h"
#import <QuartzCore/QuartzCore.h>
#import "ConnectionController.h"
#import "TRErrorsManager.h"
#import "TRRegisterViewController.h"
#import "TRNavigationController.h"
#import "save.h"
#import "game_type_select.h"

static id sharedSubscriptionViewController = nil;
static int continueAndDontRegister = 0;

@implementation TRChallengeSubscriptionViewController

+ (TRChallengeSubscriptionViewController *)sharedSubscriptionViewController
{
    if(!sharedSubscriptionViewController)
        sharedSubscriptionViewController = [[[self alloc] init] autorelease];
    return sharedSubscriptionViewController;
}

- (id)init {
	self.title=NSLocalizedString(@"Great News !",@"Classes/TRChallengeSubscriptionViewController.m");
	sharedSubscriptionViewController=self;
	_errorManager = [[TRErrorsManager alloc] init];
    return [super initWithNibName:@"ChallengeSubscriptionView" bundle:nil];
}


- (id)initForContinue {
	self.title=NSLocalizedString(@"Great News !",@"Classes/TRChallengeSubscriptionViewController.m");
	sharedSubscriptionViewController=self;
	_errorManager = [[TRErrorsManager alloc] init];
	continueAndDontRegister=1;
    return [super initWithNibName:@"ChallengeSubscriptionView" bundle:nil];
}

- (void) dealloc
{
	continueAndDontRegister = 0;
	sharedSubscriptionViewController = nil;
	[_errorManager release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animate {
	//remplace le bouton register par un bouton continue;
	if (continueAndDontRegister==1) {
		continueButton.frame=registerButton.frame;
		registerButton.hidden=true;
		registerButton.enabled=false;
		continueButton.hidden=false;
		continueButton.enabled=true;
		setActionAfterQuitting("");
	}
}

#pragma mark three button functions
- (IBAction)displayPrizes:(id)sender{
	TRPrizeListViewController* prizesListViewController = [[[TRPrizeListViewController alloc] init] autorelease];
	[self.navigationController pushViewController:prizesListViewController animated:YES];
}

-(IBAction)showRegisterView:(id)sender{
	TRRegisterViewController* registerViewController = [[[TRRegisterViewController alloc] init] autorelease];
	[self.navigationController pushViewController:registerViewController animated:YES];
	printf("ok");
}

/* appelée depuis TRErrorManager, pour des raisons de factorisation (résultat d'une alerte commune a deux views, prefs views et celle la ou directement depuis e bouton continue dans e cas d'une simple présentation*/
- (IBAction)finishSuscribtion:(id)sender
{	//Il n'est appelé qu'en cas de login, donc a la première inscription, donc à priori pas desoin e deleter les logins
    //delete_high_score();
    [[TRNavigationController sharedNavigationController] backToMainMenu];
}

- (IBAction)continue:(id)sender
{	//Il n'est appelé qu'en cas de de continue
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wasChallengePresented"];
	setActionAfterQuitting("play");
    [[TRNavigationController sharedNavigationController] backToMainMenu];
}

- (IBAction)testLogin:(id)sender {
    ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
    NSString* queryString = [NSString stringWithFormat:@"login=%@&mdp=%@",[login text],[mdp text]];
	[mdp resignFirstResponder];
    [conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:@"login.php"] withWaitMessage:NSLocalizedString(@"Checking login/password...",@"Classes/TRPrefsViewController.m") sendResponseTo:_errorManager withMethod:@selector(treatError:)];
}

- (IBAction)toggleLoginSubview:(id)sender{
	/*apparition du login subview */
	if ([loginView superview]==nil) {
		[self.view addSubview:disableView];
		[[TransitionView sharedTransitionView] insertSubview:loginView intoView:self.view transition:kCATransitionPush direction:kCATransitionFromBottom duration:0.3];
	}
	/*disparition du login subview */
	else {
		[[TransitionView sharedTransitionView] removeSubviewFromSuperView:loginView transition:kCATransitionPush direction:kCATransitionFromTop duration:0.3];
		[disableView removeFromSuperview];
	}
}

#pragma mark functions called by other controllers
-(NSString*) login{
	return login.text;
}

-(NSString*) mdp{
	return mdp.text;
}

- (BOOL)isInLoginView {
	return (int)[loginView superview];	
}

#pragma mark textFielldDelegate function
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	if ([theTextField isEqual:login]) {
		[mdp becomeFirstResponder];
	}
	
	if ([theTextField isEqual:mdp]) {
		[theTextField resignFirstResponder];
	}
	return YES;
}

@end
