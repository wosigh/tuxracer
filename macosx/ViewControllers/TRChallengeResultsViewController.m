//
//  TRChallengeResultsViewController.m
//  tuxracer
//
//  Created by emmanuel de Roux on 13/04/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRChallengeResultsViewController.h"
#import "ConnectionController.h"
#import "TRErrorsManager.h"
#import "debug.h"
#import "myHTTPErrors.h"
#import "TRNavigationController.h"


@implementation TRChallengeResultsViewController


- (id)init {
    if (self = [super initWithNibName:@"ChallengeResultsView" bundle:nil]) {
        self.title=NSLocalizedString(@"Challenge results",@"Views/TRChallengeResultsViewController.m");
		self.hidesBottomBarWhenPushed = TRUE;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	if (_timeTrialChallengeWinners) [_timeTrialChallengeWinners release];
	if (_classicChallengeWinners) [_classicChallengeWinners release];
	[super dealloc];
}

- (void)viewDidLoad
{
    //
}



- (void) refreshView {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	//Si un cache existe, on l'utilise
    [self treatData:[prefs objectForKey:@"challengeResultsCache"]];
	
	ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
	NSMutableString* queryString = [NSMutableString stringWithFormat:@"login=%@&mdp=%@&registered=%@",[prefs objectForKey:@"username"],[prefs objectForKey:@"password"],[prefs objectForKey:@"registered"]];
	NSString* phpPage=phpPage=@"displayChallengeResults.php";
	
	[conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:phpPage] withWaitMessage:NSLocalizedString(@"Retreiving results...",@"") sendResponseTo:self withMethod:@selector(treatData:)];
}

- (void)viewWillAppear:(BOOL)animated {
	if ([(TRNavigationController*)self.navigationController lastNavAction]!=POP) [self refreshView];	
}



- (void) reloadWinners{
	
	//time trial challenge
	TTCWinner1.text = [_timeTrialChallengeWinners objectAtIndex:0];
	TTCWinner2.text = [_timeTrialChallengeWinners objectAtIndex:1];
	TTCWinner3.text = [_timeTrialChallengeWinners objectAtIndex:2];
	TTCWinner4.text = [_timeTrialChallengeWinners objectAtIndex:3];
	TTCWinner5.text = [_timeTrialChallengeWinners objectAtIndex:4];
	TTCWinner6.text = [_timeTrialChallengeWinners objectAtIndex:5];
	TTCWinner7.text = [_timeTrialChallengeWinners objectAtIndex:6];
	TTCWinner8.text = [_timeTrialChallengeWinners objectAtIndex:7];
	TTCWinner9.text = [_timeTrialChallengeWinners objectAtIndex:8];
	TTCWinner10.text = [_timeTrialChallengeWinners objectAtIndex:9];
	
	//Classic challenge
	CCWinner1.text = [_classicChallengeWinners objectAtIndex:0];
	CCWinner2.text = [_classicChallengeWinners objectAtIndex:1];
	CCWinner3.text = [_classicChallengeWinners objectAtIndex:2];
	CCWinner4.text = [_classicChallengeWinners objectAtIndex:3];
	CCWinner5.text = [_classicChallengeWinners objectAtIndex:4];
	CCWinner6.text = [_classicChallengeWinners objectAtIndex:5];
	CCWinner7.text = [_classicChallengeWinners objectAtIndex:6];
	CCWinner8.text = [_classicChallengeWinners objectAtIndex:7];
	CCWinner9.text = [_classicChallengeWinners objectAtIndex:8];
	CCWinner10.text = [_classicChallengeWinners objectAtIndex:9];
}

- (void) treatData:(NSString*) data {
    //Sur chaque ligne, une série de data séparés par le symbole  |||
    //chaaque ligne est materialisee par \r\n
    //Les lignes sont regroupees par paquets, separes par des \r\t\n\r\t\n
	//paquet n°1 : une seule ligne : le resultCode
    //paquet n°2 : plusieurs lignes : les classement contre la montre
    //paquet n°3 : plusieurs lignes : les classement Classique
    
    //Si aucun cache n'est enregistré ça quitte le traitement du cache
    if ([data isEqualToString:@""]) return;
    
    TRDebugLog("%s\n",[data UTF8String]);
    
    NSArray* datas = [data componentsSeparatedByString:@"\r\t\n\r\t\n"];
    
    if ([datas count] > 1) {
		//Si on est dans le cas de wait for results :
		if ([[datas objectAtIndex:0] intValue] == RESULTS_NOT_READY) {
			scrollView.contentSize = waitResultsView.frame.size;
			[scrollView addSubview:waitResultsView];
			return;
		}
		
        //sinon On traite l'éventuelle erreur
        if ([datas count]==2) [[TRErrorsManager sharedErrorsManager] treatError:[datas objectAtIndex:0]];
        else {
            [[TRErrorsManager sharedErrorsManager] treatError:[datas objectAtIndex:0]];
            if ([[datas objectAtIndex:0] intValue] != SERVER_ERROR) {
				//On crée la tableView
				scrollView.contentSize = resultsView.frame.size;
				[scrollView addSubview:resultsView];
				
                /*on recupere les lignes de classement Time trial */
                //les lignes affichent les dix premiers noms des 10 premiers winners
                _timeTrialChallengeWinners = [[NSArray alloc] initWithArray:[[datas objectAtIndex:1] componentsSeparatedByString:@"\r\n"]];
                
                /*on recupere les lignes de classement Classique*/
				_classicChallengeWinners = [[NSArray alloc] initWithArray:[[datas objectAtIndex:2] componentsSeparatedByString:@"\r\n"]];
                
                //save cache
			    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"challengeResultsCache"];
                
                [self reloadWinners];
            }
        }
    }
}

@end
