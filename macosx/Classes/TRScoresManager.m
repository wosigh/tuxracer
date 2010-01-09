//
//  TRScoresManager.m
//  tuxracer
//
//  Created by emmanuel de Roux on 23/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRScoresManager.h"
#import "ConnectionController.h"
#import "TRTimeTrialScoresViewController.h"
#import "sharedGeneralFunctions.h"
#import "game_over.h"
#import "save.h"
#import "myHTTPErrors.h"
#import "TRErrorsManager.h"

void saveScoreOnlineAfterRace(char* raceName,int score,int herring,int minutes,int seconds,int hundredths){
    char buff[10];
    sprintf( buff, "%02d:%02d:%02d", minutes, seconds, hundredths );
    [[[TRScoresManager sharedScoresManager] retain] saveScoreOnlineAfterRace:score onPiste:[NSString stringWithCString:raceName] herring:herring time:buff];
	[[TRScoresManager sharedScoresManager] release];
}

void displayRankingsAfterRace(char* raceName,int score,int herring,int minutes,int seconds,int hundredths){
    char buff[10];
    sprintf( buff, "%02d:%02d:%02d", minutes, seconds, hundredths );
    [[[TRScoresManager sharedScoresManager] retain] displayRankingsAfterRace:score onPiste:[NSString stringWithCString:raceName] herring:herring time:buff];
	[[TRScoresManager sharedScoresManager] release];
}

void dirtyScores ()
{
    [[TRScoresManager sharedScoresManager] dirtyScores];
}

static id sharedScoresManager=nil;

@implementation TRScoresManager

+ (id)sharedScoresManager {
 	if(!sharedScoresManager)
		sharedScoresManager = [[[self alloc] init] autorelease];
	return sharedScoresManager;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		_fb = [[TRFacebookController sharedFaceBookController] retain];
		sharedScoresManager=self;
	}
	return self;
}

- (void) dealloc
{
	sharedScoresManager=nil;
	[_fb release];
	[super dealloc];
}

#pragma mark Saving scores functions

- (NSString*)gameOrderType {
    if (g_game.is_speed_only_mode) return @"speed only";
    else return @"classic";
}

//called by a C func
- (void) saveScoreOnlineAfterRace:(int)score onPiste:(NSString*)piste herring:(int)herring time:(char*)time{   
    //On enregistre le score en ligne que si l'utilisateur l'a choisi dans les prefs
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    if([prefs boolForKey:@"saveScoresAfterRace"]) {
        ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
        NSMutableString* queryString = [NSMutableString stringWithFormat:@"login=%@&mdp=%@&piste=%@&order=%@&score=%d&herring=%d&time=%s",[prefs valueForKey:@"username"],[prefs valueForKey:@"password"],piste,[self gameOrderType],score,herring,time];
        //Si le joueur ajouté des amis
        int i;
        for (i = 0; i<[[prefs objectForKey:@"friendsList"] count]; i++) {
            [queryString appendFormat:@"&friends[%d]=%@",i,[[prefs objectForKey:@"friendsList"] objectAtIndex:i]];
        }
        [conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:@"saveScore.php"] withWaitMessage:NSLocalizedString(@"Saving score online...",@"") sendResponseTo:self withMethod:@selector(treatSaveScoreAfterRaceResult:)];
		
        //Set this to true so the user car go back to race select screen by touching the screen whatever happens (cancel, error, all good, etc...)
        g_game.rankings_displayed=true;
    }
    else {
        [self displayRankingsAfterRace:score onPiste:piste herring:herring time:time];
    }
}

//calls a C func
- (void) syncScores {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
    NSString* queryString = [NSString stringWithFormat:@"login=%@&mdp=%@&%s",[prefs valueForKey:@"username"],[prefs valueForKey:@"password"],editSynchronizeScoresRequest()];
    [conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:@"synchronize.php"] withWaitMessage:NSLocalizedString(@"Saving unsaved scores online...",@"") sendResponseTo:self withMethod:@selector(treatSyncScoresResult:)];
}

//called by a C func
- (void) displayRankingsAfterRace:(int)score onPiste:(NSString*)piste herring:(int)herring time:(char*)time{
    //On enregistre le score en ligne que si l'utilisateur l'a choisi dans les prefs
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    if([prefs boolForKey:@"displayRankingsAfterRace"]) {
        ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
        NSMutableString* queryString = [NSMutableString stringWithFormat:@"login=%@&mdp=%@&order=%@&piste=%@&score=%d&herring=%d&time=%s",[prefs valueForKey:@"username"],[prefs valueForKey:@"password"],[self gameOrderType],piste,score,herring,time];
        //Si le joueur ajouté des amis
        int i;
        for (i = 0; i<[[prefs objectForKey:@"friendsList"] count]; i++)
            [queryString appendFormat:@"&friends[%d]=%@",i,[[prefs objectForKey:@"friendsList"] objectAtIndex:i]];
        [conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:@"displayRankingsAfterRace.php"] withWaitMessage:NSLocalizedString(@"Getting rankings for this score...",@"") sendResponseTo:self withMethod:@selector(treatDisplayRankingsAfterRaceResult:)];
        
        //Set this to true so the user car go back to race select screen by touching the screen whatever happens (cancel, error, all good, etc...)
        g_game.rankings_displayed=true;
    }
}


- (void) dirtyScores {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:([prefs integerForKey:@"needsSync"]+1) forKey:@"needsSync"];
}

#pragma mark treat http results
- (void) treatSaveScoreAfterRaceResult:(NSString*)result {
    NSArray* datas = [result componentsSeparatedByString:@"\r\n"];
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    if ([datas count]==3){
        NSString* erreur = [datas objectAtIndex:2];
        [_currentRankings release];
        [_currentPercentage release];
        _currentRankings = [[[datas objectAtIndex:0] componentsSeparatedByString:@"|||"] retain];
        _currentPercentage = [[[datas objectAtIndex:1] componentsSeparatedByString:@"|||"] retain];
        [[TRErrorsManager sharedErrorsManager] treatError:erreur];
		if ([erreur intValue]==SCORE_SAVED) {
            //Set this to true so the rankings will be displayed
            g_game.needs_save_or_display_rankings=true;
            //function implemented in game_over.c
            displaySavedAndRankings([NSLocalizedString(@"Congratulations !",@"") UTF8String], [(NSString*)[_currentRankings objectAtIndex:0] UTF8String], [(NSString*)[_currentRankings objectAtIndex:1] UTF8String], [(NSString*)[_currentRankings objectAtIndex:2] UTF8String], [(NSString*)[_currentRankings objectAtIndex:3] UTF8String],[[_currentPercentage objectAtIndex:0] doubleValue], [[_currentPercentage objectAtIndex:1] doubleValue], [[_currentPercentage objectAtIndex:2] doubleValue],[[_currentPercentage objectAtIndex:3] doubleValue]);
            [prefs setInteger:([prefs integerForKey:@"needsSync"]-1) forKey:@"needsSync"];
		}
    } else [[TRErrorsManager sharedErrorsManager] treatError:[NSString stringWithFormat:@"%d",SERVER_ERROR ]];
}

- (void) treatDisplayRankingsAfterRaceResult:(NSString*)result {
    NSArray* datas = [result componentsSeparatedByString:@"\r\n"];
    if ([datas count]==3){
        NSString* erreur = [datas objectAtIndex:2];
        [_currentRankings release];
        [_currentPercentage release];
        _currentRankings = [[[datas objectAtIndex:0] componentsSeparatedByString:@"|||"] retain];
        _currentPercentage = [[[datas objectAtIndex:1] componentsSeparatedByString:@"|||"] retain];
        [[TRErrorsManager sharedErrorsManager] treatError:erreur];
		if ([erreur intValue]==RANKINGS_AFTER_RACE_OBTAINED) {
            //Set this to true so the rankings will be displayed
            g_game.needs_save_or_display_rankings=true;
            //function implemented in game_over.c
            displaySavedAndRankings([NSLocalizedString(@"World rankings",@"") UTF8String], [(NSString*)[_currentRankings objectAtIndex:0] UTF8String], [(NSString*)[_currentRankings objectAtIndex:1] UTF8String], [(NSString*)[_currentRankings objectAtIndex:2] UTF8String], [(NSString*)[_currentRankings objectAtIndex:3] UTF8String],[[_currentPercentage objectAtIndex:0] doubleValue], [[_currentPercentage objectAtIndex:1] doubleValue], [[_currentPercentage objectAtIndex:2] doubleValue], [[_currentPercentage objectAtIndex:3] doubleValue]);
		}
    } else [[TRErrorsManager sharedErrorsManager] treatError:[NSString stringWithFormat:@"%d",SERVER_ERROR ]];
    //Set this to true so the user car go back to race select screen by touching the screen
    g_game.rankings_displayed=true;
}

- (void) treatSyncScoresResult:(NSString*)result {
   NSString* error = result;
    if ([error intValue]==SCORE_UPDATED) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:0 forKey:@"needsSync"];
        [[TRTimeTrialScoresViewController sharedTimeTrialScoreViewController] refreshView:NO];
    } else [[TRErrorsManager sharedErrorsManager] treatError:error];
}
@end
