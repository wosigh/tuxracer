//
//  prefsDelegate.m
//  tuxracer
//
//  Created by emmanuel de Roux on 19/11/08.
//  Copyright 2008 école Centrale de Lyon. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TRPrefsViewController.h"
#import "EAGLView.h"
#import "AudioManager.h"
#import "myHTTPErrors.h"
#import "ConnectionController.h"
#import "multiplayer.h"
#import "TRFriendsManagerViewController.h"
#import "TRRegisterViewController.h"
#import "TRErrorsManager.h"
#import "TRChallengeSubscriptionViewController.h"

bool plyrWantsToSaveOrDisplayRankingsAfterRace() {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    return ([prefs boolForKey:@"saveScoresAfterRace"]||[prefs boolForKey:@"displayRankingsAfterRace"]);
}

bool plyrWantsToDisplayRankingsAfterRace() {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    return ([prefs boolForKey:@"displayRankingsAfterRace"]);
}

bool isPlayerRegistered() {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs boolForKey:@"registered"];
}

bool isChallengeOn() {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs boolForKey:@"isChallengeOn"];
}

bool wasChallengePresented() {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs boolForKey:@"wasChallengePresented"];
}

bool isRaceAllowedToPublishOnFacebook(const char* mode, const char* raceName) {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if (!strcmp(mode,"Speed Only")) return [[prefs objectForKey:@"SpeedOnlyRacesAllowedToPublishOnFacebook"] valueForKey:[NSString stringWithUTF8String:raceName]];
	else return [[prefs objectForKey:@"ClassicRacesAllowedToPublishOnFacebook"] valueForKey:[NSString stringWithUTF8String:raceName]];
	return true;
}

void allowRaceToPublishOnFacebook(const char* mode, const char* raceName) {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *dico;
	if (!strcmp(mode,"Speed Only")) {
		dico = [NSMutableDictionary dictionaryWithDictionary:[prefs objectForKey:@"SpeedOnlyRacesAllowedToPublishOnFacebook"]];
		[dico setObject:@"YES" forKey:[NSString stringWithUTF8String:raceName]];
		[prefs setObject:dico forKey:@"SpeedOnlyRacesAllowedToPublishOnFacebook"];
	}
	else 
	{
		dico = [NSMutableDictionary dictionaryWithDictionary:[prefs objectForKey:@"ClassicRacesAllowedToPublishOnFacebook"]];
		[dico setObject:@"YES" forKey:[NSString stringWithUTF8String:raceName]];
		[prefs setObject:dico forKey:@"ClassicRacesAllowedToPublishOnFacebook"];
	}
	[prefs synchronize];
}

void disallowRaceToPublishOnFacebook(const char* mode, const char* raceName) {
	if (raceName==nil) return;
	
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *dico;
	if (!strcmp(mode,"Speed Only")) {
		dico = [NSMutableDictionary dictionaryWithDictionary:[prefs objectForKey:@"SpeedOnlyRacesAllowedToPublishOnFacebook"]];
		[dico removeObjectForKey:[NSString stringWithUTF8String:raceName]];
		[prefs setObject:dico forKey:@"SpeedOnlyRacesAllowedToPublishOnFacebook"];
	}
	else 
	{
		dico = [NSMutableDictionary dictionaryWithDictionary:[prefs objectForKey:@"ClassicRacesAllowedToPublishOnFacebook"]];
		[dico removeObjectForKey:[NSString stringWithUTF8String:raceName]];
		[prefs setObject:dico forKey:@"ClassicRacesAllowedToPublishOnFacebook"];
	}
	[prefs synchronize];
}

static TRPrefsViewController * sharedPrefsViewController = nil;

@implementation TRPrefsViewController
@synthesize musicVolume,soundsVolume;

+ (id)sharedPrefsViewController{
    if(!sharedPrefsViewController)
        sharedPrefsViewController = [[[self alloc] init] autorelease];
    return sharedPrefsViewController;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)init {
    if (self = [super initWithNibName:@"PrefsView" bundle:nil]) {
        self.title = NSLocalizedString(@"Settings",@"Classes/TRPrefsViewController.m");
		sharedPrefsViewController=self;
    }
    return self;
}

- (void)dealloc
{
	sharedPrefsViewController = nil;
	[super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    scrollView.contentSize = contentView.frame.size;
    [scrollView addSubview:contentView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self loadPrefs];
}


#pragma mark prefs functions
-(void) loadPrefs {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	//NSDictionary* dico = [prefs dictionaryRepresentation]; //can be useful for debug
    //If prefs are loaded for first time, set defaults
    [TRPrefsViewController setDefaults];
	
	//indicates that prefs defaults have been loaded at least once
    [prefs setObject:@"yes" forKey:@"defaultsLoadedOnce"];
    
	//Loads login and modify register label
	if ([prefs boolForKey:@"registered"]) {
		[loginLabel setEnabled:YES];
		[login setEnabled:YES];
		[login setText:[prefs valueForKey:@"username"]];
		[registerLabel setText:NSLocalizedString(@"Create a new account",@"Classes/TRPrefsViewController.m")];
	} else {
		[login setText:@"Not registered"];
	}
	
    //switch "save score online"
    [saveScoresOnline setEnabled:[prefs boolForKey:@"registered"]];
    [saveScoresOnline setOn:[prefs boolForKey:@"saveScoresAfterRace"]];
    //switch "Display Rankings"
	
    [displayRankings setEnabled:[prefs boolForKey:@"registered"]];
    [displayRankings setOn:[prefs boolForKey:@"displayRankingsAfterRace"]];
	
    //enable friends list label and button
    [friendsListButton setEnabled:[prefs boolForKey:@"registered"]];
	[friendsListLabel setEnabled:[prefs boolForKey:@"registered"]];
	
	//viewMode
    [viewMode setSelectedSegmentIndex:[prefs boolForKey:@"viewModeIsTuxEye"] ? 0 : 1 ];
	
	//MusicVolume
    musicVolume.value = [prefs floatForKey:@"musicVolume"];
    soundsVolume.value = [prefs floatForKey:@"soundsVolume"];
	
	[self.view setNeedsDisplay];
}

static const int kTRPreferencesVersion = 4;

+(void) setDefaults {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs objectForKey:@"defaultsLoadedOnce"]==nil || [[prefs objectForKey:@"version"] intValue] < kTRPreferencesVersion) {
        [prefs setObject:@"yetUpdated" forKey:@"defaultsLoadedOnce"];
        [prefs setFloat:0.5 forKey:@"musicVolume"];
        [prefs setFloat:0.5 forKey:@"soundsVolume"];
        if(![prefs valueForKey:@"username"]) [prefs setValue:@"" forKey:@"username"];
        if(![prefs valueForKey:@"password"]) [prefs setValue:@"" forKey:@"password"];
        if(![prefs valueForKey:@"pays"]) [prefs setValue:@"" forKey:@"pays"];
		/* registering prefs */
		if(![prefs valueForKey:@"registered"]) [prefs setBool:NO forKey:@"registered"];
		if(![prefs valueForKey:@"isChallengeOn"]) [prefs setBool:YES forKey:@"isChallengeOn"]; //NEW
		if(![prefs valueForKey:@"wasChallengePresented"]) [prefs setBool:YES forKey:@"wasChallengePresented"]; //NEW J'ai mis yes pour faire plaisir a Apple qui ne voulait pas que je parle du challenge dans le jeu
		if(![prefs valueForKey:@"saveScoresAfterRace"]) [prefs setBool:NO forKey:@"saveScoresAfterRace"];
		if(![prefs valueForKey:@"displayRankingsAfterRace"]) [prefs setBool:YES forKey:@"displayRankingsAfterRace"];
		if(![prefs valueForKey:@"viewModeIsTuxEye"]) [prefs setBool:NO forKey:@"viewModeIsTuxEye"];
        if(![prefs valueForKey:@"friendsList"]) [prefs setObject:[NSArray array] forKey:@"friendsList"];
		if(![prefs valueForKey:@"connectionToFacebookDejaPropose"]) [prefs setBool:NO forKey:@"connectionToFacebookDejaPropose"]; //NEW
		[prefs setBool:NO forKey:@"firstScoreDisplayedOnFacebook"]; //NEW
		[prefs setObject:[NSDictionary dictionary] forKey:@"ClassicRacesAllowedToPublishOnFacebook"]; //NEW
		[prefs setObject:[NSDictionary dictionary]  forKey:@"SpeedOnlyRacesAllowedToPublishOnFacebook"]; //NEW
        [prefs setObject:@"" forKey:@"rankingCache"];
        [prefs setObject:@"" forKey:@"rankingCacheSpeedOnly"];
        [prefs setObject:@"" forKey:@"challengeCache"];
		[prefs setObject:@"" forKey:@"challengeResultsCache"];
        [prefs setObject:[NSNumber numberWithInt:kTRPreferencesVersion] forKey:@"version"];
        //Pour chaque piste dont les rankings auront été consultés, un objet cache sera créé pour la clé "Nom de la piste" ou "Nom de la piste"."SpeedOnly"
        [prefs setInteger:0 forKey:@"needsSync"];
    }
}

- (IBAction) switchSaveScores:(id)sender{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:[saveScoresOnline isOn] forKey:@"saveScoresAfterRace"];
}

- (IBAction) switchDisplayRankings:(id)sender{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:[displayRankings isOn] forKey:@"displayRankingsAfterRace"];
}

- (IBAction) switchViewMode:(id)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL isTuxEyeMode = [viewMode selectedSegmentIndex] == 0;
    [prefs setBool:isTuxEyeMode forKey:@"viewModeIsTuxEye"];
    if([[EAGLView sharedView] tuxracerLoaded])
        setparam_view_mode(isTuxEyeMode ? 3 : 1);
}

- (IBAction) updateVolumePrefs:(id)sender {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    
    //Volume prefs
    [prefs setFloat:musicVolume.value forKey:@"musicVolume"];
    [[AudioManager sharedAudioManager] setMusicGainFactor:musicVolume.value];
    [prefs setFloat:soundsVolume.value forKey:@"soundsVolume"];
    [[AudioManager sharedAudioManager] setSoundGainFactor:soundsVolume.value];
}

//Traite les différents cas d'erreurs possibles suite à une tentative de connection dans le cadre des preférences
-(void) treatError:(NSString*)erreur{
   	[[TRErrorsManager sharedErrorsManager] treatError:erreur];
}

/* TO DELETE 
- (void)testLogin {
	ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
	NSString* queryString = [NSString stringWithFormat:@"login=%@&mdp=%@",[login text],[country text]];
	[conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:@"login.php"] withWaitMessage:NSLocalizedString(@"Checking login/password...",@"Classes/TRPrefsViewController.m") sendResponseTo:self withMethod:@selector(treatError:)];
}
*/
- (IBAction)showRegisterView:(id)sender
{
	[self.navigationController pushViewController:[TRRegisterViewController sharedRegisterViewController] animated:YES];
}

- (IBAction)showFriendsManagerView:(id)sender
{
	[self.navigationController pushViewController:[TRFriendsManagerViewController sharedFriendsManagerViewController] animated:YES];
}

#pragma mark alertView delegate
//gere l'alerte proposant d'enregistrer les scores en ligne à la fin de chaque partie automatiquement ou non, après un registering correct
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
	switch (buttonIndex) {
			//NO
		case 0:
			[preferences setBool:FALSE forKey:@"saveScoresAfterRace"];
			break;
			//YES 
		case 1:
			[preferences setBool:TRUE forKey:@"saveScoresAfterRace"];
			break;
		default:
			break;
	}
	[self loadPrefs];
}

#pragma mark fonctions appelées de l'exterieur

-(NSString*)login{
	return login.text;
}

/* TO DELETE 
-(NSString*)mdp{
	return mdp.text;
} */

@end
