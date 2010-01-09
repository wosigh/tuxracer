//
//  TRRegisterViewController.m
//  tuxracer
//
//  Created by Pierre d'Herbemont on 3/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TRRegisterViewController.h"
#import "TRPickCountryViewController.h"
#import "ConnectionController.h"
#import "myHTTPErrors.h"
#import <QuartzCore/QuartzCore.h>
#import "TRNavigationController.h"
#import "sharedGeneralFunctions.h"
#import "save.h"
#import "TRFacebookController.h"
#import "FBLoginDialog.h"
#import "game_type_select.h"

static id sharedRegisterViewController = nil;

@implementation TRRegisterViewController

+ (TRRegisterViewController *)sharedRegisterViewController
{
    if(!sharedRegisterViewController)
        sharedRegisterViewController = [[[self alloc] init] autorelease];
    return sharedRegisterViewController;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)init {
    if (self = [super initWithNibName:@"RegisterView" bundle:nil]) {
        // Custom initialization
        self.title = NSLocalizedString(@"Register",@"Classes/TRRegisterViewController.m");
		_country = [[NSString alloc] init];
		_errorManager = [[TRErrorsManager alloc] init];
		sharedRegisterViewController = self;
    }
    return self;
}

- (void)dealloc {
	sharedRegisterViewController=nil;
	[_errorManager release];
	[_country release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	/* Gère les modifications de la registerView selon que le player est déjà registered ou non. */
	if([prefs boolForKey:@"registered"]) {
		loginTextLabel.text=NSLocalizedString(@"This will erase all your old best results !",@"Classes/TRRegisterViewController.m");
		loginTextLabel.textColor = [UIColor yellowColor];
		loginTextButton.hidden=true;
		warningImg.hidden=false;
		infoLabel.hidden=true;
		infoButton.hidden=true;
	}
	
	/* Gère les modifications de la registerView selon qu'il y a toujours un challenge ou non. */
	scrollView.contentSize = contentView.frame.size;
    [scrollView addSubview:contentView];
    [RegLogin setText:@""];
    [RegMdp1 setText:@""];
    [RegMdp2 setText:@""];
    [RegPays setTitle:NSLocalizedString(@"Choose one",@"Classes/TRPrefsViewController.m") forState:UIControlStateNormal];
	
	/* Gère les modifications de la registerView selon que le mec s'est déjà connecté sur facebook ou non. */
	if ([[TRFacebookController sharedFaceBookController] isConnected]) {
		fbSwitch.hidden=true;
		fbLabel.hidden=true;
		fbTextView.hidden=true;
	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark external functions
- (void) setCountry:(NSString*)country{
	[RegPays setTitle:country forState:UIControlStateNormal];	
}

#pragma mark Register Window Functions

//Traite les différents cas d'erreurs possibles suite à une tentative de connection dans le cadre des preférences
-(void) treatError:(NSString*)erreur{
    int err = [erreur intValue];
    switch (err) {
        case SUSCRIBTION_SUCCESSFUL:
        {
            NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
			[preferences setValue:[RegLogin text] forKey:@"username"];
            [preferences setValue:[RegMdp1 text] forKey:@"password"];
			[preferences setValue:[RegPays titleForState:UIControlStateNormal] forKey:@"pays"];
            [preferences setBool:TRUE forKey:@"registered"];
            [preferences setBool:TRUE forKey:@"displayRankingsAfterRace"];
			[preferences setBool:YES forKey:@"connectionToFacebookDejaPropose"]; //Pour pas que l'alerte de connect facebook s'affiche juste après
			[preferences synchronize];
			[self finishSuscribtion];
			
			//affiche le login de facebook si le mec a dit qu'il voulait se connecter
			if ([fbSwitch isOn]) [[TRFacebookController sharedFaceBookController] showLoginDialog];
			
            break;            
        }
        default:
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error !",@"Classes/TRPrefsViewController.m") message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert setMessage:[ConnectionController messageForServerReturnValue:err]];
            [alert show];
            [alert release];
            break;            
        }
    }
	
    switch (err) {
        case LOGIN_TOO_LONG:
        case LOGIN_ALREADY_EXISTS:
            [RegLogin becomeFirstResponder];
            break;
        case DIFFERENTS_PASSWORDS:
        case PASSWORD_TOO_LONG:
        case PASSWORD_TOO_SHORT:
            [RegMdp1 becomeFirstResponder];
            break;
        case COUNTRY_EMPTY:
            [self listCountriesTransition:self];
            break;
    }
}

//vérifie une première fois les données avant de les envoyer
-(int) firstVerifForm{
    if ([[RegLogin text] length]>30||[[RegLogin text] length]<1) { return LOGIN_TOO_LONG; }
    if (![[RegMdp1 text] isEqualToString:[RegMdp2 text]]) { return DIFFERENTS_PASSWORDS; }
    if ([[RegMdp1 text] length]>30) {return PASSWORD_TOO_LONG; }
    if ([[RegMdp2 text] length]<5) {return PASSWORD_TOO_SHORT; }
    if ([[RegPays titleForState:UIControlStateNormal] isEqualToString:NSLocalizedString(@"Choose one",@"Classes/TRPrefsViewController.m")]) { return COUNTRY_EMPTY; }
    return DATA_OK;
}


- (IBAction)registerClick:(id)sender {
	if (isPlayerRegistered()){
		UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning !",@"Classes/TRRegisterViewController.m") message:NSLocalizedString(@"Are you sure to want to create a new account ? This will erase everything about your old account.",@"Classes/TRRegisterViewController.m") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Classes/TRRegisterViewController.m") otherButtonTitles:NSLocalizedString(@"Register",@"Classes/TRRegisterViewController.m"),nil] autorelease];
		[alert show];
	} else [self suscribe];
}


//envoie les données pour s'inscrire
- (void)suscribe {
    int error = [self firstVerifForm];
    if (error == DATA_OK)
    {
        ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
        NSString* queryString = [NSString stringWithFormat:@"oldLogin=%@&login=%@&mdp1=%@&mdp2=%@&pays=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],[RegLogin text],[RegMdp1 text],[RegMdp2 text],[RegPays titleForState:UIControlStateNormal]];
        [conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:@"suscribe.php"] withWaitMessage:NSLocalizedString(@"Sending registration data...",@"Classes/TRPrefsViewController.m") sendResponseTo:self withMethod:@selector(treatError:)];
    } else [self treatError:[NSString stringWithFormat:@"%d",error]];
}

- (IBAction) listCountriesTransition:(id)sender{
    [self.navigationController pushViewController:[TRPickCountryViewController sharedPickCountryViewController] animated:YES];
}

#pragma mark functions useful only in subscribtion context

- (IBAction)whyRegister:(id)sender{
	UIAlertView* alert =  [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info",@"Classes/TRRegisterViewController.m") message:NSLocalizedString(@"Registering allows you to be ranked with other players around the world. It's free, it takes 5 seconds, and no personal information is required.",@"Classes/TRRegisterViewController.m") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
	[alert show];
}

- (IBAction)toggleLoginSubview:(id)sender{
	/*apparition du login subview */
	if ([loginView superview]==nil) {
		[self.view addSubview:disableView];
		[[TransitionView sharedTransitionView] insertSubview:loginView intoView:self.view transition:kCATransitionPush direction:kCATransitionFromBottom duration:0.3];
		[login becomeFirstResponder];
	}
	/*disparition du login subview */
	else {
		[[TransitionView sharedTransitionView] removeSubviewFromSuperView:loginView transition:kCATransitionPush direction:kCATransitionFromTop duration:0.3];
		[disableView removeFromSuperview];
	}
}

- (IBAction)testLogin:(id)sender{
	ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
    NSString* queryString = [NSString stringWithFormat:@"login=%@&mdp=%@",[login text],[mdp text]];
	[mdp resignFirstResponder];
    [conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:@"login.php"] withWaitMessage:NSLocalizedString(@"Checking login/password...",@"Classes/TRPrefsViewController.m") sendResponseTo:_errorManager withMethod:@selector(treatError:)];
}

- (BOOL)isInLoginView {
	return (int)[loginView superview];	
}

- (NSString*)login{
	return login.text;
}
- (NSString*)mdp{
	return mdp.text;	
}

- (void)finishSuscribtion
{
	//Par défaut, quand on se log-in, je considère que le mec a déjà été prévenu lors de son inscription, donc par défaut je lui met YES
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	if ([self isInLoginView]) [prefs setBool:YES forKey:@"saveScoresAfterRace"];
	//Sinon c'est qu'on est dans le cas "Register" et non login, donc ca dépend de ce que le mec à coché
	else {
		[prefs setBool:[saveScoresRaceSwitch isOn] forKey:@"saveScoresAfterRace"];
	}
	
	//On supprime les highscores et on reset les prefs pour pas ke des messages fb apparaissent n'importe quand
	delete_high_score();
	g_game.scores_just_reseted=true;
	[prefs setBool:NO forKey:@"firstScoreDisplayedOnFacebook"];
	
	/* retour d'ou on vient, en distinguant le cas ou on arrive ici depuis le pannel settings et le cas ou on arrive ici au début en cliquant sur play ou rankings */
	if([[self.navigationController viewControllers] containsObject:[TRPrefsViewController sharedPrefsViewController]])
		[self.navigationController popToRootViewControllerAnimated:YES];
	else
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wasChallengePresented"];
		setActionAfterQuitting("play"); //Si c pas registered ca fera rien
		[[TRNavigationController sharedNavigationController] backToMainMenu];
}


#pragma mark TextField delegate function
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	//login fields
	if ([textField isEqual:login]) {
		[mdp becomeFirstResponder];
	}
	
	if ([textField isEqual:mdp]) {
		[mdp resignFirstResponder];
		[self testLogin:nil];
	}
	
	//Register fields
	if ([textField isEqual:RegLogin]) {
		[RegMdp1 becomeFirstResponder];
	}
	
	if ([textField isEqual:RegMdp1]) {
		[RegMdp2 becomeFirstResponder];
	}
	
	if ([textField isEqual:RegMdp2]) {
		[RegMdp2 resignFirstResponder];
	}
	
	
	
    return YES;
}

#pragma mark alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
		switch (buttonIndex) {
			//Cancel
			case 0:
				break;
			//Register 
			case 1:
				[self suscribe];
				break;
			default:
				break;
		}
	}
@end
