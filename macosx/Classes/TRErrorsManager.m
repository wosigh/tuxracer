//
//  TRErrorsManager.m
//  tuxracer
//
//  Created by emmanuel de Roux on 24/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRErrorsManager.h"
#import "myHTTPErrors.h"
#import "save.h"
#import "game_over.h"
#import "sharedGeneralFunctions.h"
#import "TRChallengeSubscriptionViewController.h"
#import "TRPrefsViewController.h"
#import "TRRegisterViewController.h"

static id sharedErrorsManager=nil;

@implementation TRErrorsManager
#pragma mark tread HTTP response

+ (id)sharedErrorsManager {
 	if(!sharedErrorsManager)
		sharedErrorsManager = [[[self alloc] init] autorelease];
	return sharedErrorsManager;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		sharedErrorsManager=self;
	}
	return self;
}

- (void) dealloc
{
	sharedErrorsManager=nil;
	[super dealloc];
}


-(void) treatError:(NSString*)erreur{
    int err = [erreur intValue];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error !",@"Classes/TRErrorsManager.m") message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	NSString *login, *mdp;
    switch (err) {
        case LOGIN_ERROR:
			if (![prefs boolForKey:@"registered"]) [alert setMessage:NSLocalizedString(@"You are not registered, so you have no rankings.",@"")];
            else [alert setMessage:NSLocalizedString(@"Wrong login or password.",@"")];
            [alert show];
            break;
			
		case LOGIN_SUCCESSFUL:
			/* Ce cas n'est appelé que depuis le pannel des prefs ou depuis l'inscription au challenge, il faut donc distinguer les deux cas pour savoir où récupérer les valeurs de login et de mdp */
			if ([[TRRegisterViewController sharedRegisterViewController] isInLoginView]) {
				login = [[TRRegisterViewController sharedRegisterViewController] login];
				mdp = [[TRRegisterViewController sharedRegisterViewController] mdp];
			}
			else {
				login = [[TRPrefsViewController sharedPrefsViewController] login];
				mdp = [[TRPrefsViewController sharedPrefsViewController] mdp];
			}
			
			[prefs setValue:login forKey:@"username"];
			[prefs setValue:mdp forKey:@"password"];
			[prefs setBool:TRUE forKey:@"registered"];
			[prefs setBool:TRUE forKey:@"displayRankingsAfterRace"];
			
			if ([[TRRegisterViewController sharedRegisterViewController] isInLoginView]) {
				[[TRRegisterViewController sharedRegisterViewController] finishSuscribtion];
			}
			
			break;
        case SERVER_ERROR:
            [alert setMessage:NSLocalizedString(@"Internal server error! Please try again Later.",@"")];
            [alert show];
            break;
        case CONNECTION_ERROR:
            [alert setMessage:NSLocalizedString(@"Check your network connection and try again.",@"")];
            [alert show];
            break;
        case SCORE_SAVED:
            //Work is done in score_controller.m, no alert to manage here
            break;
        case RANKINGS_AFTER_RACE_OBTAINED:
            //Work is done in score_controller.m, no alert to manage here
			break;
        case NEEDS_NEW_VERSION:
            [alert setTitle:NSLocalizedString(@"Score not saved !",@"")];
            [alert setMessage:NSLocalizedString(@"For security reasons, you need to update Tux Rider World Challenge to save scores online. Go to the App Store to do the update.",@"")];
            [alert show];
            break;
        case BETTER_SCORE_EXISTS:
            [alert setTitle:NSLocalizedString(@"Score not saved !",@"")];
            [alert setMessage:NSLocalizedString(@"A better score already exists for this login !",@"")];
            [alert show];
            break;
        case NO_SCORES_SAVED_YET:
            [alert setTitle:NSLocalizedString(@"No rankings available !",@"")];
            [alert setMessage:NSLocalizedString(@"You don't have any scores saved online for the moment !",@"")];
            [alert show];
            break;
        case SCORE_UPDATED:
            //Do nothing, OK
            break;
        case NOTHING_UPDATED:
            [alert setTitle:NSLocalizedString(@"No need to update !",@"")];
            [alert setMessage:NSLocalizedString(@"Scores online were already up-to-date.",@"")];
            [prefs setInteger:0 forKey:@"needsSync"];
            [alert show];
            break;
        case NO_SCORES_REGISTERED:
            [alert setTitle:NSLocalizedString(@"No rankings available !",@"Classes/TRErrorsManager.m")];
            [alert setMessage:NSLocalizedString(@"You don't have any scores saved online for this race in \"speed only\" mode for the moment !",@"")];
            [alert show];
            break;
        case RANKINGS_OK:
            //Do nothing
            break;
		case NOT_RANKED_TIME_TRIAL:
            //Do nothing
            break;
		case NOT_RANKED_CLASSIC:
            //[alert setTitle:NSLocalizedString(@"You are not ranked in Classic Challenge !",@"")];
            //[alert setMessage:NSLocalizedString(@"You must establish a personal record in each of its races.",@"")];
            //[alert show];
            break;
		case NOT_RANKED_BOTH:
            //Do nothing
            break;
		case ALL_IS_OK:
            //Do nothing
            break;
        default:
            [alert setMessage:NSLocalizedString(@"Unknown error!",@"")];
            [alert show];
            break;
    }
    [alert release];
}

#pragma mark alertView delegate
//gere l'alerte proposant d'enregistrer les scores en ligne à la fin de chaque partie automatiquement ou non, après un registering correct
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	[alertView release]; //au cas ou j'en aurai oublié un;
}

@end
