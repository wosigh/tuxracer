//
//  TRChallengeViewController.m
//  tuxracer
//
//  Created by emmanuel de Roux on 24/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRChallengeViewController.h"
#import "ConnectionController.h"
#import "TRChallengeInfosViewController.h"
#import "TRErrorsManager.h"
#import "TRPlayerInfosViewController.h"
#import "sharedGeneralFunctions.h"
#import "TRChallengeResultsViewController.h"
#import "TRNavigationController.h"

static BOOL isCache = NO;

@implementation TRChallengeViewController

- (id)init {
    if (self = [super initWithNibName:@"ChallengeView" bundle:nil]) 
	{
		/* Commenté car apple ne veut pas entendre parler du challenge
		if (isChallengeOn()) {
			self.title=NSLocalizedString(@"World Challenge",@"Views/TRChallengeViewController.m");
			self.tabBarItem.title=NSLocalizedString(@"World Challenge",@"Views/TRChallengeViewController.m");
		}
		else {
			self.title=NSLocalizedString(@"Total Rankings",@"Views/TRChallengeViewController.m");
			self.tabBarItem.title=NSLocalizedString(@"Total Rankings",@"Views/TRChallengeViewController.m");
		}
		 */
		self.title=NSLocalizedString(@"Total Rankings",@"Views/TRChallengeViewController.m");
		self.tabBarItem.title=NSLocalizedString(@"Total Rankings",@"Views/TRChallengeViewController.m");
		
		
		self.tabBarItem.image=[UIImage imageNamed:@"cupTabBar.png"];
		_timeTrialChallengeRanking = [[NSMutableArray alloc] init];
		_classicChallengeRanking = [[NSMutableArray alloc] init];
    }
		
		
    return self;
}

- (void)dealloc {
	[_timeTrialChallengeRanking release];
	[_classicChallengeRanking release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewDidAppear:(BOOL)animated {
	if ([(TRNavigationController*)self.navigationController lastNavAction]!=POP) [self refreshView];	
}

#pragma mark tableView delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/*Dans certains cas la selection doit etre interdite. */
	if ([tableView cellForRowAtIndexPath:indexPath].selectionStyle==UITableViewCellSelectionStyleNone) return;
	
	//TRChallengeInfosViewController* challengeInfosViewController;
	TRChallengeResultsViewController*  challengeResultsViewController;
	TRPlayerInfosViewController* playerInfosViewController;
	NSString* currentPlayer;
	switch (indexPath.section) {
		case 0:
			if (isChallengeOn()) {
				//APPLE NE VEUT PAS QUE JE PARLE DU CHALLENGE DANS LE JEU, JE DOIS DONC LE FAIRE SUR MON SITE
				/*
				challengeInfosViewController = [[[TRChallengeInfosViewController alloc] init] autorelease];
				[self.navigationController pushViewController:challengeInfosViewController animated:YES];
				 */
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://challenge.barlow-server.com/results"]];
			}
			else {
				challengeResultsViewController = [[[TRChallengeResultsViewController alloc] init] autorelease];
				[self.navigationController pushViewController:challengeResultsViewController animated:YES];
			}
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			break;
		case 1:
			currentPlayer = [(TRRankingTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] playerName];
			playerInfosViewController = [[[TRPlayerInfosViewController alloc] initWithPlayerName:currentPlayer] autorelease];
			[self.navigationController pushViewController:playerInfosViewController animated:YES];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			break;
		case 2:
			currentPlayer = [(TRRankingTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] playerName];
			playerInfosViewController = [[[TRPlayerInfosViewController alloc] initWithPlayerName:currentPlayer] autorelease];
			[self.navigationController pushViewController:playerInfosViewController animated:YES];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			break;
		default:
			break;
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return NULL;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3; //time trial, classic mode in Challenge mode
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
			if (isChallengeOn()) {
				return 1; //C'est le HEADER de présentation du challenge : Une ligne pour la description rapie du concours et les liens vers le règlement, le sponsor, etc...
			} else return 0;
            break;
        case 1:
            return [_timeTrialChallengeRanking count]; //Ensuite Les 20 meilleurs joueurs de chaque mode (+1 si on est pa dans les 20 premiers)
            break;
        case 2:
            return [_classicChallengeRanking count];
            break;
        default:
            break;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
			return challengeSectionHeader;
            break;
        case 1:
			if (isChallengeOn()) return timeTrialSectionHeader;
			else return timeTrialNoChallengeSectionHeader;
            break;
        case 2:
            if (isChallengeOn()) return classicModeSectionHeader;
			else return classicModeNoChallengeSectionHeader;
            break;
        default:
            break;
    }
    return NULL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 163.0; //Hauteur du header du tournoi
            break;
        default:
            return 40.0;
            break;
    }
}

- (TRRankingTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    NSArray* arrayToUse = nil;
	BOOL isTimeTrial;
	BOOL isChallengeInfoCell=NO;
    switch (indexPath.section) {
        case 0:
			isChallengeInfoCell=YES;
            break;
        case 1:
            arrayToUse = _timeTrialChallengeRanking;
			isTimeTrial=YES;
            break;
        case 2:
            arrayToUse = _classicChallengeRanking;
			isTimeTrial=NO;
            break;
        default:
            break;
    }
    
    TRRankingTableViewCell *cell = (TRRankingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cellID"];
	
    if (cell == nil || ![cell isKindOfClass:[TRRankingTableViewCell class]])
    {
        cell = [[[TRRankingTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"cellID" boldText:NO andOrderType:@"challenge"] autorelease];
    }
    
    if(indexPath.row < [arrayToUse count])
    {
        NSDictionary * result = [arrayToUse objectAtIndex:indexPath.row];
        NSDictionary * rankings = [result objectForKey:@"rankings"];
        [cell setBoldFont:[(NSNumber*)[result objectForKey:@"isCurrentUserRanking"] boolValue]];
		if ([[rankings objectForKey:@"ranking"] intValue] == -1) isChallengeInfoCell=YES;
        cell.rankingLabel.text = [rankings objectForKey:@"ranking"];
        cell.nameLabel.text = [rankings objectForKey:@"name"];
		cell.scoreLabel.text = [rankings objectForKey:@"totalScore"];
		cell.nbRacePlayer = [[rankings objectForKey:@"nbRacePlayer"] intValue];
		cell.nbRaceToDo = [[rankings objectForKey:@"nbRaceToDo"] intValue];
        cell.timeLabel.text = [rankings objectForKey:@"totalTime"];
        cell.percentLabel.text = [NSString stringWithFormat:@"%.1f%%", [[rankings objectForKey:@"percent"] floatValue]];
        [cell setTextAndButtonMode:NO];
		[cell setTimeTrialOrClassicModeForChallenge:isTimeTrial];
		if ([[rankings objectForKey:@"name"] isEqualToString:[prefs stringForKey:@"username"]] || indexPath.row>10) {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType=UITableViewCellAccessoryNone;
		}
		else {
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
		}
    }
    
	if (indexPath.section==0) {
		cell.nbRacePlayer = 0;
		cell.nbRaceToDo = 0;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	
	[cell setChallengeInfoCell:isChallengeInfoCell];
    [cell setSelected:NO];
    
    return cell;
}

#pragma mark usefull functions
- (void) refreshView {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	//Si un cache existe, on l'utilise
	isCache = YES;
    [self treatData:[prefs objectForKey:@"challengeCache"]];
	isCache = NO;
	
	ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
	NSMutableString* queryString = [NSMutableString stringWithFormat:@"login=%@&mdp=%@&registered=%@",[prefs objectForKey:@"username"],[prefs objectForKey:@"password"],[prefs objectForKey:@"registered"]];
	NSString* phpPage=@"displayChallengeRanking.php";
	
	[conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:phpPage] withWaitMessage:NSLocalizedString(@"Refreshing rankings...",@"") sendResponseTo:self withMethod:@selector(treatData:)];
}
	
- (void) resetData {
    [_timeTrialChallengeRanking removeAllObjects];
    [_classicChallengeRanking removeAllObjects];
}

static inline NSDictionary * dictionaryByParsingResultsStringTimeTrialMode(NSString * string, NSString * login)
{
    NSArray * ranks = [string componentsSeparatedByString:@"|||"];
    if([ranks count] < 6) return nil;
    BOOL isCurrentUser = [login isEqualToString:[ranks objectAtIndex:1]];
	int totalCents = [[ranks objectAtIndex:4] intValue];
	int cents = totalCents%100;
	int seconds = ((totalCents-cents)/100)%60;
	int minutes = (((totalCents-cents)/100)-seconds)/60;
	NSString* totalTime = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",minutes,seconds,cents];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSDictionary dictionaryWithObjectsAndKeys:
             [ranks objectAtIndex:0], @"ranking",
             [ranks objectAtIndex:1], @"name",
			 [ranks objectAtIndex:2], @"nbRacePlayer",
             [ranks objectAtIndex:3], @"nbRaceToDo",
             totalTime, @"totalTime",
             [NSNumber numberWithFloat:[[ranks objectAtIndex:5] floatValue]], @"percent",
             nil], @"rankings",
            [NSNumber numberWithBool:isCurrentUser], @"isCurrentUserRanking",
            nil];
}

static inline NSDictionary * dictionaryByParsingResultsStringClassicMode(NSString * string, NSString * login)
{
    NSArray * ranks = [string componentsSeparatedByString:@"|||"];
    if([ranks count] < 6) return nil;
    BOOL isCurrentUser = [login isEqualToString:[ranks objectAtIndex:1]];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSDictionary dictionaryWithObjectsAndKeys:
             [ranks objectAtIndex:0], @"ranking",
             [ranks objectAtIndex:1], @"name",
             [ranks objectAtIndex:2], @"nbRacePlayer",
             [ranks objectAtIndex:3], @"nbRaceToDo",
             [ranks objectAtIndex:4], @"totalScore",
             [NSNumber numberWithFloat:[[ranks objectAtIndex:5] floatValue]], @"percent",
             nil], @"rankings",
            [NSNumber numberWithBool:isCurrentUser], @"isCurrentUserRanking",
            nil];
}
-(void) treatError:(NSString*)erreur{
	if (!isCache) [[TRErrorsManager sharedErrorsManager] treatError:erreur];
}

- (void) treatData:(NSString*) data {
    //Sur chaque ligne, une série de data séparés par le symbole  |||
    //chaaque ligne est materialisee par \r\n
    //Les lignes sont regroupees par paquets, separes par des \r\t\n\r\t\n
    //paquet n°1 : plusieurs lignes : les classement contre la montre
    //paquet n°2 : plusieurs lignes : les classement Classique
    //paquet n°3 : une seule ligne : le resultCode
    
    //Si aucun cache n'est enregistré ça quitte le traitement du cache
    if ([data isEqualToString:@""]) return;
    
    TRDebugLog("%s\n",[data UTF8String]);
    
    NSArray* datas = [data componentsSeparatedByString:@"\r\t\n\r\t\n"];
    
    if ([datas count] > 1) {
        //On traite l'éventuelle erreur
        if ([datas count]==2) [self treatError:[datas objectAtIndex:1]];
        else {
            [self treatError:[datas objectAtIndex:2]];
            if ([[datas objectAtIndex:2] intValue] != SERVER_ERROR) {
                //On efface ce qu'il y avait avant
                [self resetData];
                
                //On recupere le login du joueur
                NSString* login = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
                
                /*on recupere les lignes de classement Time trial */
                //les lignes sont de la forme : classement|||login|||score|||herring|||time|||perccent
                NSArray* timeTrialRankings = [[datas objectAtIndex:0] componentsSeparatedByString:@"\r\n"];
                for (NSString * rawString in timeTrialRankings) {
                    NSDictionary * dict = dictionaryByParsingResultsStringTimeTrialMode(rawString, login);
                    if(dict) [_timeTrialChallengeRanking addObject:dict];
                }
                
                /*on recupere les lignes de classement Classique*/
                NSArray* classicRankings = [[datas objectAtIndex:1] componentsSeparatedByString:@"\r\n"];
                for (NSString * rawString in classicRankings) {
                    NSDictionary * dict = dictionaryByParsingResultsStringClassicMode(rawString, login);
                    if(dict) [_classicChallengeRanking addObject:dict];
                }
                
                
                //save cache
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
			    [prefs setObject:data forKey:@"challengeCache"];
                
                [challengeTableView reloadData];
            }
        }
    }
}


@end
