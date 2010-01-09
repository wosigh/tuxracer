//
//  TRAppDelegate.m
//  tuxracer
//
//  Created by emmanuel de roux on 22/10/08.
//  Copyright école Centrale de Lyon 2008. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

#import "TRAppDelegate.h"
#import "sharedGeneralFunctions.h"
#import "game_type_select.h"

/* View Controllers */
#import "TRTimeTrialScoresViewController.h"
#import "TRClassicScoresViewController.h"
#import "TRChallengeViewController.h"
#import "TRPrefsViewController.h"
#import "TRRegisterViewController.h"
#import "TRGLViewController.h"
#import "TRChallengeSubscriptionViewController.h"
#import "ConnectionController.h"
#import "TRLicenseView.h"

/*Navigation Controller*/
#import "TRNavigationController.h"




static const float kHighFrameRateFPS = 60.;
static const float kLowFrameRateFPS = 10.;

int libtuxracer_main( int argc, char **argv );

const char* getRessourcePath() {
	return [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TRWC-data"] UTF8String];
}

const char* getConfigPath() {
    NSArray * array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);;
	return [[array objectAtIndex:0] UTF8String];
}

const char * challengeTextInfos() {
	return [[[TRAppDelegate sharedAppDelegate] challengeTextInfos] UTF8String];
}

void displayRankings()
{
    [[TRAppDelegate sharedAppDelegate] toggleRankingsView:nil];
}

void turnScreenToLandscape() {
    EAGLView *view = [EAGLView sharedView];
    
    //set up te status bar into portrait mode (usefull for alerts, because here the status bar is hidden)
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
	
    [CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
	
    // Rotates the view.
    CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
    view.transform = transform;
    
    // Repositions and resizes the view.
    CGRect contentRect = CGRectMake(-80, 80, 480, 320);
    view.bounds = contentRect;
	
    [view setNeedsDisplay];
}

void turnScreenToPortrait() {
    EAGLView *view = [EAGLView sharedView];
    
    //set up te status bar into portrait mode (usefull for alerts, because here the status bar is hidden)
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
	
    [CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
	
    // Rotates the view.
    CGAffineTransform transform = CGAffineTransformMakeRotation(0);
    view.transform = transform;
    
    // Repositions and resizes the view.
    CGRect contentRect = CGRectMake(0, 0, 320, 480);
    view.bounds = contentRect;
	
    [view setNeedsDisplay];
}

void showHowToPlayAtBegining() {
    //Affiche le register Panel si on est pas registered
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs boolForKey:@"registered"])
    {
        // Sometimes, this is called too soon (glView is not yet created). Wait for a run loop.
        [[TRAppDelegate sharedAppDelegate] performSelector:@selector(showHowToPlay:) withObject:nil afterDelay:0.];
    }
}

void showChallengeSuscribtion() {
    [[TRAppDelegate sharedAppDelegate] showChallengeSuscribtion];
}

void vibration()
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@implementation TRAppDelegate

@synthesize window;
@synthesize transitionView;
@synthesize prefsWindow;
@synthesize registerWindow;
@synthesize accelerometre;
@synthesize glViewController=_glViewController;

static id sharedAppDelegate = nil;
+ (TRAppDelegate *) sharedAppDelegate{
    return sharedAppDelegate;
}

- (id)init
{
    self = [super init];
    sharedAppDelegate = self;
    _isHighFrameRateMode = YES;
    return self;
}

- (void)dealloc {
    sharedAppDelegate = nil;
    self.glViewController = nil;
	[window release];
	[prefsWindow release];
	[registerWindow release];
	[super dealloc];
}

- (TransitionView*)transitionView{
	return transitionView;	
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
    self.glViewController = [[[TRGLViewController alloc] init] autorelease];
	
    //hiddes status bar
	[application setStatusBarHidden:TRUE animated:TRUE];
	
    //places glView into the transitionView
	CGRect glViewFrame = self.glViewController.view.frame;
    [transitionView setBackgroundColor:[UIColor redColor]];
    glViewFrame.size = transitionView.bounds.size;
    self.glViewController.view.frame = glViewFrame;
	[window setBackgroundColor:[UIColor blackColor]];
	[transitionView addSubview:self.glViewController.view];
    [self.glViewController.glView startAnimation];
	[window makeKeyAndVisible];
    
    //Sets up the accelerometer
    accelerometre = [[TRAccelerometerDelegate alloc] init];
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:accelerometre];
	
	//Detecte si le challenge est toujours en cours ou non
	[self getChallengeInfos];
	
	//Pour les personnes qui viennent d'updater l'app depuis une version < 1.5, il faut récupérer le nom du pays enregistré dans la base et le mettre dans les prefs
	[self recupCountry];
	
	//Initialise les prefs la première fois qu'on lance le jeu
	[TRPrefsViewController setDefaults];
	
    //Prevents screen dimming
    application.idleTimerDisabled = YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    if (g_game.mode==RACING) set_game_mode(PAUSED);
	
	self.glViewController.glView.animationInterval = 1.0 / 5.0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    self.glViewController.glView.animationInterval = 1.0 / (_isHighFrameRateMode ? kHighFrameRateFPS : kLowFrameRateFPS);
}

- (void)setIsHighFrameRateMode:(BOOL)high
{
    if(high != _isHighFrameRateMode) {
        _isHighFrameRateMode = high;
        self.glViewController.glView.animationInterval = 1.0 / (high ? kHighFrameRateFPS : kLowFrameRateFPS);
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / (high ? kAccelerometerFrequency : 2.))]; // quasi never up update
    }
}

- (BOOL)isHighFrameRateMode
{
    return _isHighFrameRateMode;
}

- (void) getChallengeInfos {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString* phpPage=@"isChallengeOn.php";
	[prefs setObject:@"Retrieving challenge information..." forKey:@"textInfoEn"];
	[prefs setObject:@"Recuperation des infos sur le challenge..." forKey:@"textInfoFr"];
	
	NSMutableString* queryString;
	if(![prefs valueForKey:@"registered"]) [prefs setBool:NO forKey:@"registered"];
	if(![prefs valueForKey:@"wasChallengePresented"]) [prefs setBool:YES forKey:@"wasChallengePresented"];//NEW
	if ([prefs objectForKey:@"registered"] && [prefs objectForKey:@"wasChallengePresented"]) queryString = [NSMutableString stringWithFormat:@"wasChallengePresented=%@&login=%@&mdp=%@",[prefs objectForKey:@"wasChallengePresented"],[prefs objectForKey:@"username"],[prefs objectForKey:@"password"]];
	else queryString=@"";
	[prefs synchronize];
	ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
	[conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:phpPage] withWaitMessage:NULL sendResponseTo:self withMethod:@selector(treatChallengeInfos:)];
}

- (void) treatChallengeInfos:(NSString*)data {
	//On ne traite pas les erreurs ici, si il y a erreur, tant pis
	
	//structure : errorStatus \r\t\n\r\t\n isChallengeOn||infoEN||InfoFr
	NSArray* datas = [data componentsSeparatedByString:@"\r\t\n\r\t\n"];
	if ([datas count]==2 &&  [[datas objectAtIndex:0] intValue] == ALL_IS_OK)
	{
		NSArray* infosArray = [[datas objectAtIndex:1] componentsSeparatedByString:@"||"];
		NSArray* keys = [NSArray arrayWithObjects:@"isChallengeOn",@"textInfoEn",@"textInfoFr",nil];
		NSDictionary* infos = [NSDictionary dictionaryWithObjects:infosArray forKeys:keys];		//infos = 0 ou 1 selon que le challenge est en cours ou non

		NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
		[prefs setBool:[[infos objectForKey:@"isChallengeOn"] intValue] forKey:@"isChallengeOn"];
		[prefs setObject:[infos objectForKey:@"textInfoEn"] forKey:@"textInfoEn"];
		[prefs setObject:[infos objectForKey:@"textInfoFr"] forKey:@"textInfoFr"];
	}
}

/* récupère le nom du pays sur la base et le met dans les prefs pour ceux qui font une update depuis une version < à la 1.5 */
- (void) recupCountry {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString* phpPage=@"recupPays.php";
	
	/* On ne le récupère que si la valeur dans les prefs vaut celle par défaut à savoir "" et que le mec est enregistré, ce qui correspond au cas update depuis version < 1.5 */
	if ([[prefs valueForKey:@"pays"] isEqualToString:@""] && [prefs boolForKey:@"registered"]) {
		NSString* queryString = [NSString stringWithFormat:@"login=%@&mdp=%@",[prefs objectForKey:@"username"],[prefs objectForKey:@"password"]];	
		ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
		[conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:phpPage] withWaitMessage:NULL sendResponseTo:self withMethod:@selector(treatRecupCountry:)];
	}
}

- (void) treatRecupCountry:(NSString*)data {
	//On ne traite pas les erreurs ici, si il y a erreur, tant pis
	
	//structure : errorStatus \r\t\n\r\t\n isChallengeOn||infoEN||InfoFr
	NSArray* datas = [data componentsSeparatedByString:@"\r\t\n\r\t\n"];
	if ([datas count]==2 &&  [[datas objectAtIndex:0] intValue] == LOGIN_SUCCESSFUL)
	{
		NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
		[prefs setValue:[datas objectAtIndex:1] forKey:@"pays"];
		[prefs synchronize];
	}
}

-(NSString*) challengeTextInfos{
	return [[NSUserDefaults standardUserDefaults] objectForKey:NSLocalizedString(@"textInfoEn",@"Traduire par textInfoFr pour le francais ; dans TRAppDelegate.m")];
}

#pragma mark display Functions

- (IBAction)showLicense:(id)sender
{
	TRLicenseView* LicenseViewController = [[[TRLicenseView alloc] init] autorelease];
	UIBarButtonItem* website = [[[UIBarButtonItem alloc] initWithTitle:@"website" style:UIBarButtonItemStylePlain target:self action:@selector(openWebSite)] autorelease];
	LicenseViewController.navigationItem.rightBarButtonItem = website;	
	TRNavigationController* nav = [[[TRNavigationController alloc] initWithRootViewController:LicenseViewController andParentViewController:nil] autorelease];
  	[self slideViewControllerIn:nav animated:YES];
}

- (void)showRankings
{
	/* Create the tab bar Controller */
	UITabBarController* tabBarController = [[[UITabBarController alloc] initWithNibName:nil bundle:nil] autorelease];
	
	/* Create the view Controllers */
	TRTimeTrialScoresViewController* timeTrialViewController = [[[TRTimeTrialScoresViewController alloc] init] autorelease];
	TRClassicScoresViewController* classicViewController = [[[TRClassicScoresViewController alloc] init] autorelease];
	TRChallengeViewController* challengeViewController = [[[TRChallengeViewController alloc] init] autorelease];
	
	/* Create the navigation controllers */
	TRNavigationController* timeTrialNavigationController = [[[TRNavigationController alloc] initWithRootViewController:timeTrialViewController andParentViewController:tabBarController] autorelease];
	TRNavigationController* classicNavigationController = [[[TRNavigationController alloc] initWithRootViewController:classicViewController andParentViewController:tabBarController] autorelease];
	TRNavigationController* challengeNavigationController = [[[TRNavigationController alloc] initWithRootViewController:challengeViewController andParentViewController:tabBarController] autorelease];
	
	/* On met tout ça dans le tab bar controller */
	tabBarController.viewControllers = [NSArray arrayWithObjects:timeTrialNavigationController,classicNavigationController,challengeNavigationController,nil];
	
	
    [self slideViewControllerIn:tabBarController animated:NO];
}

- (void)quitRankings {
	[self slideViewControllerOut:[[TRTimeTrialScoresViewController sharedTimeTrialScoreViewController] tabBarController] animated:NO];
}

- (void)showPreferences:(id)sender
{
	TRNavigationController* nav = [[[TRNavigationController alloc] initWithRootViewController:[TRPrefsViewController sharedPrefsViewController] andParentViewController:nil] autorelease];
    [self slideViewControllerIn:nav animated:YES];
}

- (void)showChallengeSuscribtion{
	UIViewController* viewController;
	//DANS CE CAS LA PAGE NE REDIRIGE PLUS VERS UN PANNEL DE REGISTER MAIS SERT JUSTE À PRÉSENTER LE CHALLENGE A PREMIÈRE FOIS.
	//JE LE COMMENTE ICI CAR APPLE NE VEUT PAS QUE JE PARLE DU CHALLENGE DANS LE JEU
	/*if (isPlayerRegistered() && isChallengeOn() && !wasChallengePresented()) {
		TRChallengeSubscriptionViewController* ChallengeSubscriptionViewController = [[[TRChallengeSubscriptionViewController alloc] initForContinue] autorelease];
		viewController=ChallengeSubscriptionViewController;
	}
	//DANS CE CAS LA PAGE REDIRIGE VERS UNE PAGE DE REGISTER
	else 
	if ( !isPlayerRegistered() && isChallengeOn()) {
		TRChallengeSubscriptionViewController* ChallengeSubscriptionViewController = [[[TRChallengeSubscriptionViewController alloc] init] autorelease];
		viewController=ChallengeSubscriptionViewController;
	} else {
		//DANS CE CAS ON TOMBE DIRECT SUR LA PAGE DE REGISTER
		TRRegisterViewController *RegisterViewController = [[[TRRegisterViewController alloc] init] autorelease];
		viewController = RegisterViewController;
	}
	 */
	
	//VA DIRECT SUR LA PAGE DE REGISTER POUR CONTENTER APPLE
	TRRegisterViewController *RegisterViewController = [[[TRRegisterViewController alloc] init] autorelease];
	viewController = RegisterViewController;
	
	TRNavigationController* nav = [[[TRNavigationController alloc] initWithRootViewController:viewController andParentViewController:nil] autorelease];
	[self slideViewControllerIn:nav animated:YES];
}

- (IBAction)toggleRankingsView:(id)sender;
{
	if ([self.glViewController.view superview]) [self showRankings];
	else [self quitRankings];
}

- (void)openWebSite
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.barlow-server.com/tuxriderworldchallenge"]];
}

#pragma mark functions to slide in and out of the glView, then, we use viewControllers

/* CES DEUX FONCTIONS NE DOIVENT ETRE APPELÉES QUE PAR UN NAVIGATION CONTROLLER, ICI CELUI QUI REMPLACE LA GLVIEW DANS CHAQUE CAS OU ON REPASSE A DE L'INTERFACE IPHONE */

- (void)slideViewControllerIn:(UIViewController *)viewController animated:(BOOL)animated
{
	[viewController retain];
    if([transitionView isTransitioning]) return;
    if(![self.glViewController.view superview]) return; // No super view for the root view, we don't support that
    [self.glViewController.glView stopAnimation];
	NSString * transition;
	NSString * direction;
	float duration;
	if (!animated) {
		transition = kCATransitionFade;
		direction=kCATransitionFromBottom;//ne sera pas pris en compte
		duration=0.01;
	} else  {
		transition = kCATransitionMoveIn;
		direction=kCATransitionFromBottom;
		duration=0.3;
	}
    [transitionView replaceSubview:self.glViewController.view withSubview:viewController.view transition:transition direction:direction duration:duration];
}

- (void)slideViewControllerOut:(UIViewController *)viewController animated:(BOOL)animated
{
    if([transitionView isTransitioning]) return;
	NSString * transition;
	NSString * direction;
	float duration;
	if (!animated) {
		transition = kCATransitionFade;
		direction=kCATransitionFromBottom;//ne sera pas pris en compte
		duration=0.01;
	} else  {
		transition = kCATransitionMoveIn;
		direction=kCATransitionFromTop;
		duration=0.3;
	}
    [transitionView replaceSubview:viewController.view withSubview:self.glViewController.glView transition:transition direction:direction duration:duration];
	[viewController release];
}
@end
