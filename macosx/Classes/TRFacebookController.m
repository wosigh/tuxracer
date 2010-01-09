//
//  TRFacebookController.m
//  tuxracer
//
//  Created by emmanuel de Roux on 27/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRFacebookController.h"
#import "FBConnect.h"
#import "tuxracer.h"
#include <stdio.h>
#include <stdlib.h>
#import "sharedGeneralFunctions.h"

void hideFBButton(int hide) {
	[[TRFacebookController sharedFaceBookController] hideButton:hide];
}

void doYouWantToConnectToFacebook(){
	[[TRFacebookController sharedFaceBookController] doYouWantToConnectToFacebook];
}

void publishFirstScore(char*score,char*course,char*mode)
{
	[[TRFacebookController sharedFaceBookController] publishFirstScore:score surCourse:course enMode:mode];
}

void publishNewHighScore(char*score,char*course,char*mode,char* classementMondial, char* classementNational, char* classementTotal)
{
	[[TRFacebookController sharedFaceBookController] publishNewHighScore:score surCourse:course enMode:mode etClassementMondial:atoi(classementMondial) classementNational:atoi(classementNational) classementTotal:atoi(classementTotal)];
}

static TRFacebookController *sharedFaceBookController = nil;
static BOOL publishHighScoreAfterConnect=NO;
static FBDialog* publishNewHighScoreDialog=nil;
static const char* currentRaceName=nil;

@implementation TRFacebookController

//données perso relatives a mon application
static NSString* kApiKey = @"b4db7392c2f4353c258731b6a2059a94";
static NSString* tuxRiderFbRoot = TUXRIDER_FB_ROOT; //FIXME : veiller à le sortir des sources

+ (id)sharedFaceBookController{
    if(!sharedFaceBookController)
        sharedFaceBookController = [[[self alloc] init] autorelease];
    return sharedFaceBookController;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		sharedFaceBookController=self;
		/* Il faut absolument initialiser la session avant le bouton ! */
		_session = [[FBSession sessionForApplication:kApiKey secret:tuxRiderFbRoot delegate:self] retain];
		CGRect frame = CGRectMake(60, 420, 200, 31);//Cette frame c'est pour l'afficher en bas sous le menu
		_facebookButton = [[FBLoginButton alloc] initWithFrame:frame];
		_publishNewHighScoreArgs=NULL;
	}
	return self;
}

- (void) dealloc
{
	if (_publishNewHighScoreArgs) {
		[_publishNewHighScoreArgs release];
		_publishNewHighScoreArgs=NULL;
	}
	sharedFaceBookController = nil;
	[_facebookButton release];
	[_session dealloc];
	[super dealloc];
}

- (FBLoginButton*)button {
	return _facebookButton;
}

- (FBLoginButton*)resumeSessionAndUpdateButton //Normalement ct dans le view did load, mais la il faudra l'appeller depuis le viewDidLoad
{	
	[_session resume];
	_facebookButton.style = FBLoginButtonStyleWide;
	return _facebookButton;
}	

- (void)doYouWantToConnectToFacebook {
	/* Si ce message a déja été affiché une fois on se barre */
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"connectionToFacebookDejaPropose"]) return;
	
	/* Si on est deja connecté on se barre */
	if (_session.isConnected) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"connectionToFacebookDejaPropose"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		return;
	}
	
	/* Ce message ne peut s'afficher que pour des joueurs enregistrés */
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"registered"]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"connectionToFacebookDejaPropose"];
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New : Connect this game to your Facebook wall !",@"Classes/TRFacebookController.m") message:NSLocalizedString(@"You will be able to post your best results will on your Facebook wall in just one click, without leaving the game !",@"Classes/TRFacebookController.m") delegate:self cancelButtonTitle:NSLocalizedString(@"No",@"Classes/TRFacebookController.m") otherButtonTitles:NSLocalizedString(@"Connect",@"Classes/TRFacebookController.m"),nil];
		[alert show];
		[alert release];
	}
}

- (void)hideButton:(BOOL)hide //Normalement ct dans le view did load, mais la il faudra l'appeller depuis le viewDidLoad
{	
	_facebookButton.hidden=hide;
}

#pragma mark showing dialogs functions
//////////////////////////////////////////////////////////////////////////////////////////////////////
// showing dialogs functions


- (void)showLoginDialog {
	if (_session.isConnected) return;
	FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:_session] autorelease];
	dialog.delegate=self;
	[dialog show];	
}

- (void)publishFirstScore:(char*)score surCourse:(char*)course enMode:(char*)mode {
	if (!_session.isConnected || [[NSUserDefaults standardUserDefaults] boolForKey:@"firstScoreDisplayedOnFacebook"]) 
	{
		return;
	}
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstScoreDisplayedOnFacebook"];
	
	FBFeedDialog* dialog = [[[FBFeedDialog alloc] init] autorelease];
	dialog.delegate = self;
	dialog.templateBundleId = 83041656676; //Ce bundle id a été fait grace a l'outil dispo sur : http://developers.facebook.com/tools.php?feed
	
	//Rédaction de la news
	NSString* images = @"\"images\":[{\"src\":\"http://www.barlow-server.com/tuxriderworldchallenge/img/iconFB.png\", \"href\":\"http://challenge.barlow-server.com\"}]";
	NSString* shortStory = NSLocalizedString(@"\"shortStory\":\"Has just established his/her first score on Tux Rider World Challenge.\"",@"Classes/TRFacebookController.m");
	NSString* titleMessage = NSLocalizedString(@"\"titleMessage\":\"Has just established his/her first score on Tux Rider World Challenge.\"",@"Classes/TRFacebookController.m");
	NSString* mainMessage = [NSString stringWithFormat:NSLocalizedString(@"\"mainMessage\":\"participates now to the World Challenge of the iPhone Game <b>Tux Rider World Challenge</b>, and he/she has just established his/her first score on %s in %s mode : <b>%s</b>.\"",@"Classes/TRFacebookController.m"),course,mode,score];
	NSString* incitationMessage = NSLocalizedString(@"\"incitationMessage\":\"Do like him, play this game, be among the bests and <b>win pairs of skis, snowboards, ski googles, sunglasses, t-shirts, etc...</b>\"",@"Classes/TRFacebookController.m");
	NSString* linkMessage = NSLocalizedString(@"\"linkMessage\":\"How to participate ? What can I win ?\"",@"Classes/TRFacebookController.m");
	
	dialog.templateData = [NSString stringWithFormat:@"{%@,%@,%@,%@,%@,%@}",images,shortStory,titleMessage,mainMessage,incitationMessage,linkMessage]; //La c'est l'endroit ou je rentre l'adresse de l'image à afficher et les parametres genre ranking à lui passer
	
	[dialog show];
	/*
	 {,,,"mainMessage":"vient de s'inscrire au World Challenge du jeu iPhone Tux Rider World Challenge.","incitationMessage":"Vous aussi inscrivez vous !","linkMessage":"Comment participer ? Qu'y a-t-il a gagner ?"}*/
}

- (NSString*)addSuffix:(int)rank {
	switch (rank) {
		case 1:
			return NSLocalizedString(@"1st",@"Classes/TRFacebookController.m");
			break;
		case 2:
			return NSLocalizedString(@"2nd",@"Classes/TRFacebookController.m");
			break;
		case 3:
			return NSLocalizedString(@"3rd",@"Classes/TRFacebookController.m");
			break;
		default:
			return [NSString stringWithFormat:NSLocalizedString(@"%dth",@"Classes/TRFacebookController.m"),rank];
			break;
	}
	return [NSString stringWithFormat:NSLocalizedString(@"%dth",@"Classes/TRFacebookController.m"),rank];
}

//Appelée après qu'on ait cliqué sur le petit bouton send to facebook wall
- (void)publishNewHighScore:(const char*)score surCourse:(const char*)course enMode:(const char*)mode etClassementMondial:(int)classementMondial classementNational:(int)classementNational classementTotal:(int)classementTotal {
	currentRaceName=course;
	if (!_session.isConnected) {
		publishHighScoreAfterConnect=YES;
		if (_publishNewHighScoreArgs) {
			[_publishNewHighScoreArgs release];
			_publishNewHighScoreArgs=NULL;
		}
		_publishNewHighScoreArgs = [[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:score],@"score",[NSString stringWithUTF8String:course],@"course",[NSString stringWithUTF8String:mode],@"mode",[NSNumber numberWithInt:classementMondial],@"classementMondial",[NSNumber numberWithInt:classementNational],@"classementNational",[NSNumber numberWithInt:classementTotal],@"classementTotal",nil] retain];
		[self showLoginDialog];
		return;
	}
	
	publishHighScoreAfterConnect=NO;
	
	/////////// Publish the feed ////////////
	
	FBFeedDialog* dialog = [[[FBFeedDialog alloc] init] autorelease];
	publishNewHighScoreDialog = dialog;
	
	dialog.delegate = self;
	dialog.templateBundleId = [[NSUserDefaults standardUserDefaults] boolForKey:@"isChallengeOn"]?82970326676:86032571676; //Ces bundle id a été fait grace a l'outil dispo sur : http://developers.facebook.com/tools.php?feed. La seule différence entre les deux est e lien d'action à la fin qui varie en fonction de l'existence d'un challenge ou non.
	
	//Choses qui changent en fonction de si le challenge est actif ou non
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	NSString* pays = [[prefs valueForKey:@"pays"] isEqualToString:@""]?NSLocalizedString(@"his/her country",@"Classes/TRFacebookController.m"):[prefs valueForKey:@"pays"];
	
	BOOL isChallengeOn = [prefs boolForKey:@"isChallengeOn"];
	NSString* challengeLink = isChallengeOn?@"http://challenge.barlow-server.com":@"http://www.barlow-server.com";
	NSString* challengeWord = isChallengeOn?NSLocalizedString(@"challenge ranking",@"Classes/TRFacebookController.m"):NSLocalizedString(@"total ranking",@"Classes/TRFacebookController.m");
	NSString* challengeSentence1 = isChallengeOn?NSLocalizedString(@" Check out the prizes he/she can win!",@"Classes/TRFacebookController.m"):@"";
	NSString* challengeSentence2 = isChallengeOn?NSLocalizedString(@" Prizes are not so far away...",@"Classes/TRFacebookController.m"):@"";
	NSString* challengeSentence3 = isChallengeOn?NSLocalizedString(@"\"incitationMessage\":\"Do like him/her, participate, be among the bests pinguins and <b>win pairs of skis, snowboards, ski googles, sunglasses, t-shirts, etc...</b>\"",@"Classes/TRFacebookController.m"):NSLocalizedString(@"\"incitationMessage\":\"Do like him/her, participate and try to be among the bests pinguins!\"",@"Classes/TRFacebookController.m");;
	NSString* challengeSentence4 = isChallengeOn?NSLocalizedString(@"\"linkMessage\":\"How to participate ? What can I win ?\"",@"Classes/TRFacebookController.m"):NSLocalizedString(@"\"linkMessage\":\"How to participate?\"",@"Classes/TRFacebookController.m");
	NSString* challengeRankingSentence = @"";
	if (classementTotal != -1) {
		challengeRankingSentence = [NSString stringWithFormat:(isChallengeOn?NSLocalizedString(@"<br>Challenge ranking: <b>%@</b>",@"Classes/TRFacebookController.m"):NSLocalizedString(@"<br>Total ranking: <b>%@</b>",@"Classes/TRFacebookController.m")), [self addSuffix:classementTotal]];
	}
	
	//Rédaction de la news
	NSString* images = [NSString stringWithFormat:@"\"images\":[{\"src\":\"http://www.barlow-server.com/tuxriderworldchallenge/img/iconFB.png\", \"href\":\"%@\"}]",challengeLink];
	NSString* pseudo = [NSString stringWithFormat:@"\"pseudo\":\"<b>%@</b>\"",[prefs objectForKey:@"username"]];
	NSString* shortStory = NSLocalizedString(@"\"shortStory\":\"has just established a new record !\"",@"Classes/TRFacebookController.m");
	NSString* titleMessage = NSLocalizedString(@"\"titleMessage\":\"freerides in pinguin, and it turns out well for him/her !\"",@"Classes/TRFacebookController.m");
	NSString* mainMessage = [NSString stringWithFormat:NSLocalizedString(@"\"mainMessage\":\"has just established a new record on the iPhone game Tux Rider World Challenge on %s in %s mode : <b>%s</b>.<br>National ranking (%@): <b>%@</b><br>World ranking: <b>%@</b>%@",@"Classes/TRFacebookController.m"),course,mode,score,[prefs valueForKey:@"pays"],[self addSuffix:classementNational],[self addSuffix:classementMondial],challengeRankingSentence];
	
	//Rédaction du message additionel qui concerne les classements, quand le mec a fait un bon score.
	NSString* additionalMessage=@"\"";
	if (classementTotal <= 10 && classementTotal != -1) additionalMessage = [NSString stringWithFormat:NSLocalizedString(@"<br><br>Brillant pinguin! He entered in the top 10 of the %@.%@\"",@"Classes/TRFacebookController.m"),challengeWord,challengeSentence1];
	else if (classementTotal <= 100 && classementTotal != -1) additionalMessage = [NSString stringWithFormat:NSLocalizedString(@"<br><br>Good pinguin! He entered in the top 100 of the %@.%@\"",@"Classes/TRFacebookController.m"),challengeWord,challengeSentence2];
	else if (classementMondial <= 10) additionalMessage = NSLocalizedString(@"<br><br>Amazing! It is one of the 10 best pinguins in the world on this race!\"",@"Classes/TRFacebookController.m");
	else if (classementNational <= 10) additionalMessage = [NSString stringWithFormat:NSLocalizedString(@"<br><br>Amazing! It is one of the 10 best pinguins in %@ on this race!\"",@"Classes/TRFacebookController.m"),pays];
	else if (classementMondial <= 500) additionalMessage = NSLocalizedString(@"<br><br>What a great score! It is one of the best pinguins in the world on this race!\"",@"Classes/TRFacebookController.m");
	else if (classementNational <= 500) additionalMessage = [NSString stringWithFormat:NSLocalizedString(@"<br><br>It is a pretty good pinguin in %@!\"",@"Classes/TRFacebookController.m"),pays];
		
	NSString* incitationMessage = challengeSentence3;
	NSString* linkMessage = challengeSentence4;
	
	dialog.templateData = [NSString stringWithFormat:@"{%@,%@,%@,%@,%@%@,%@,%@}",images,pseudo,shortStory,titleMessage,mainMessage,additionalMessage,incitationMessage,linkMessage]; //La c'est l'endroit ou je rentre l'adresse de l'image à afficher et les parametres genre ranking à lui passer
	
	[dialog show];
}


#pragma mark FBDialogDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidSucceed:(FBDialog*)dialog {

	
	if (publishHighScoreAfterConnect==YES) {
		const char* score = [[_publishNewHighScoreArgs objectForKey:@"score"] UTF8String];
		const char* course = [[_publishNewHighScoreArgs objectForKey:@"course"] UTF8String];
		const char* mode = [[_publishNewHighScoreArgs objectForKey:@"mode"] UTF8String];
		int classementTotal = [[_publishNewHighScoreArgs objectForKey:@"classementTotal"] intValue];
		int classementMondial = [[_publishNewHighScoreArgs objectForKey:@"classementMondial"] intValue];
		int classementNational = [[_publishNewHighScoreArgs objectForKey:@"classementNational"] intValue];
		[self publishNewHighScore:score surCourse:course enMode:mode etClassementMondial:classementMondial classementNational:classementNational classementTotal:classementTotal];
		[_publishNewHighScoreArgs release];
		_publishNewHighScoreArgs = NULL;
	}
	
	/* Finalement je préfère ne pas faire disparaitre le bouton d'envoi à facebook une fois qu'on a cliqué dessus. Je le laisse en commente au cas ou je change d'avis. 
	//On desactive le petit bouton "send to facebook wall"
	if (dialog==publishNewHighScoreDialog) {
		const char* mode = g_game.is_speed_only_mode?"Speed Only":"Classic";
		const char* course = currentRaceName;
		disallowRaceToPublishOnFacebook(mode,course);
	}
	 */
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidCancel:(FBDialog*)dialog {
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error {
}

#pragma mark FBSessionDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////
// FBSessionDelegate

/* Cette fonction peut etre utile mais je sais pas encore comment on pourrait s'en servir */
- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	NSString* fql = [NSString stringWithFormat:
					 @"select uid,name,sex from user where uid == %lld", session.uid];
	NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
}

- (void)sessionDidLogout:(FBSession*)session {
	//A implémenter
}



#pragma mark FBRequestDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/* non implémenté, a voir si besoins */
- (void)request:(FBRequest*)request didLoad:(id)result {
	1;
}

/* non implémenté, a voir si besoins */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
	//
}

- (BOOL) isConnected {
	return _session.isConnected;
}

#pragma mark alertView delegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//gere l'alerte proposant d'enregistrer de se connecter à facebook
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	switch (buttonIndex) {
		case 0:
			//NO : do nothing
			break;
		case 1:
			//Connect
			[_facebookButton touchUpInside];
			break;
		default:
			break;
	}
}

@end
