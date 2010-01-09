//
//  TRPersonalRankingsViewController.m
//  tuxracer
//
//  Created by emmanuel de Roux on 24/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRPersonalRankingsViewController.h"
#import "TRRankingTableViewCell.h"
#import "TRScoresManager.h"
#import "ConnectionController.h"
#import "TRErrorsManager.h"
#import "TRFriendsManagerViewController.h"
#import "TRNavigationController.h"

@implementation TRPersonalRankingsViewController
@synthesize orderType=_orderType;


- (id)initWithSlope:(NSString*)slope andOrderType:(NSString*)order {
    if (self = [super initWithNibName:@"PersonalRankingsView" bundle:nil]) {
		_worldRanking = [[NSMutableArray alloc] init];
        _countryRanking = [[NSMutableArray alloc] init];
        _worldRankingInfos = [[NSMutableArray alloc] init];
        _countryRankingInfos = [[NSMutableArray alloc] init];
        _friendsRanking = [[NSMutableArray alloc] init];
        _friendsRankingInfos = [[NSMutableArray alloc] init];
		_currentSlope = [[NSString alloc] initWithString:slope];
        _playerCountry;
		self.orderType = order; 
		self.title=_currentSlope;
		self.hidesBottomBarWhenPushed = TRUE;
	}
    return self;
}

- (void)dealloc {
	[_worldRanking release];
    [_countryRanking release];
    [_friendsRanking release];
    [_worldRankingInfos release];
    [_countryRankingInfos release];
    [_friendsRankingInfos release];
    [_playerCountry release];
	[_currentSlope release];
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3; //Friends, Country, World in normal mode and Description , time trial, classic mode in Challenge mode
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    switch (section) {
        case 0:
            return [[prefs objectForKey:@"friendsList"] count] == 0 ? 1  : ([_friendsRanking count] + 1);
            break;
        case 1:
            return [_countryRanking count];
            break;
        case 2:
            return [_worldRanking count];
            break;
        default:
            break;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return friendsSectionHeader;
            break;
        case 1:
            [countryName setText:_playerCountry];
            return countrySectionHeader;
            break;
        case 2:
            return worldSectionHeader;
            break;
        default:
            break;
    }
    return NULL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	/* si c'est la dernière cell de la section 0 */
	if(indexPath.section == 0 && indexPath.row == ([rankingsTableView numberOfRowsInSection:0]-1)) {
		return UITableViewCellAccessoryDetailDisclosureButton;
	}
    else return UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/* si c'est la dernière cell de la section 0 */
    if(indexPath.section == 0 && indexPath.row == ([rankingsTableView numberOfRowsInSection:0]-1)) {
		TRFriendsManagerViewController* friendsManagerController = [[TRFriendsManagerViewController alloc] init];
		[self.navigationController pushViewController:friendsManagerController animated:YES];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (TRRankingTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* arrayToUse = nil;
    switch (indexPath.section) {
        case 0:
            arrayToUse = _friendsRanking;
            break;
        case 1:
            arrayToUse = _countryRanking;
            break;
        case 2:
            arrayToUse = _worldRanking;
            break;
        default:
            break;
    }
    
    TRRankingTableViewCell *cell = (TRRankingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil)
    {
        cell = [[[TRRankingTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"cellID" boldText:NO andOrderType:_orderType] autorelease];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([[prefs objectForKey:@"friendsList"] count] == 0 && arrayToUse == _friendsRanking)
    {
        [cell setText:NSLocalizedString(@"Empty Friends List.",@"")];
        [cell setTextAndButtonMode:YES];
		
    }
    else
    {
        if([arrayToUse count] > indexPath.row)
        {
            NSDictionary * result = [arrayToUse objectAtIndex:indexPath.row];
            NSDictionary * rankings = [result objectForKey:@"rankings"];
            [cell setBoldFont:[(NSNumber*)[result objectForKey:@"isCurrentUserRanking"] boolValue]];
            cell.rankingLabel.text = [rankings objectForKey:@"ranking"];
			cell.nameLabel.text = [rankings objectForKey:@"name"];
            cell.scoreLabel.text = [rankings objectForKey:@"score"];
            cell.herringLabel.text = [rankings objectForKey:@"herring"];
            cell.timeLabel.text = [rankings objectForKey:@"time"];
            cell.percentLabel.text = [NSString stringWithFormat:@"%.1f%%", [[rankings objectForKey:@"percent"] floatValue]];
            [cell setTextAndButtonMode:NO];
        }
        else {
            [cell setTextAndButtonMode:YES];
            [cell setText:NSLocalizedString(@"Edit Friends List.",@"")];
        }
    }
	[cell setChallengeInfoCell:NO];
	
	
	/* set selection style */
	/* si c'est la dernière cell de la section 0 */
	if(indexPath.section == 0 && indexPath.row == ([rankingsTableView numberOfRowsInSection:0]-1)) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	} else  cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
    [cell setSelected:NO];
    
    return cell;
}

#pragma mark Usefull functions
- (void) refreshView {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //Si un cache existe, on l'utilise
    if ([self.orderType isEqualToString:@"speed only"]) {
        [self treatData:[prefs objectForKey:[_currentSlope stringByAppendingString:@"SpeedOnly"]]];
    } else if ([self.orderType isEqualToString:@"classic"]) {
        [self treatData:[prefs objectForKey:_currentSlope]];
    }
	
    ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
    
    NSMutableString* queryString = [NSMutableString stringWithFormat:@"login=%@&mdp=%@&piste=%@&order=%@",[prefs objectForKey:@"username"],[prefs objectForKey:@"password"],_currentSlope,self.orderType];
    
    //Si le joueur ajouté des amis
    int i;
    for (i = 0; i<[[prefs objectForKey:@"friendsList"] count]; i++) {
        [queryString appendFormat:@"&friends[%d]=%@",i,[[prefs objectForKey:@"friendsList"] objectAtIndex:i]];
    }
    [conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:@"displayRanking.php"] withWaitMessage:NSLocalizedString(@"Refreshing ranking infos...",@"") sendResponseTo:[rankingsTableView delegate] withMethod:@selector(treatData:)];
}


- (void) resetData {
    [_worldRanking removeAllObjects];
    [_countryRanking removeAllObjects];
    [_friendsRanking removeAllObjects];
}

static inline NSDictionary * dictionaryByParsingResultsString(NSString * string, NSString * login)
{
    NSArray * ranks = [string componentsSeparatedByString:@"|||"];
    if([ranks count] < 6) return nil;
    BOOL isCurrentUser = [login isEqualToString:[ranks objectAtIndex:1]];
    return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSDictionary dictionaryWithObjectsAndKeys:
			 [ranks objectAtIndex:0], @"ranking",
			 [ranks objectAtIndex:1], @"name",
			 [ranks objectAtIndex:2], @"score",
			 [ranks objectAtIndex:3], @"herring",
			 [ranks objectAtIndex:4], @"time",
			 [NSNumber numberWithFloat:[[ranks objectAtIndex:5] floatValue]], @"percent",
			 nil
			 ], @"rankings",
			[NSNumber numberWithBool:isCurrentUser], @"isCurrentUserRanking",
			nil];
}

-(void) treatError:(NSString*)erreur{
	[[TRErrorsManager sharedErrorsManager] treatError:erreur];
}

- (void) treatData:(NSString*) data {
    //Sur chaque ligne, une série de data séparés par le symbole  |||
    //chaaque ligne est materialisee par \r\n
    //Les lignes sont regroupees par paquets, separes par des \r\t\n\r\t\n
    //paquet n°1 : une seule ligne : le pays du joueur
    //paquet n°2 : plusieurs lignes : les classement mondial
    //paquet n°3 : plusieurs lignes : les classement National
    //paquet n°4 : plusieurs lignes : les classement Amical
    //paquet n°5 : une seule ligne : le resultCode
	
    TRDebugLog("%s\n",[data UTF8String]);
	
	//Si aucun cache n'est enregistré ça quitte le traitement du cache
    if ([data isEqualToString:@""]) return;
	
    NSArray* datas = [data componentsSeparatedByString:@"\r\t\n\r\t\n"];
	
    //Si le cache n'est pas vide
    if ([datas count] > 1) {
        //On traite l'éventuelle erreur
        if ([datas count]==2) [self treatError:[datas objectAtIndex:1]];
        else if ([datas count]>2 && [datas count]!=5) [self treatError:[NSString stringWithFormat:@"%d",SERVER_ERROR]];
        else {
            [self treatError:[datas objectAtIndex:4]];
            if ([[datas objectAtIndex:4] intValue] == RANKINGS_OK) {
                //On efface ce qu'il y avait avant
                [self resetData];
                
                //On recupère le pays du joueur
                [_playerCountry release];
                _playerCountry = [[datas objectAtIndex:0] retain];
                
                //On recupere le login du joueur
                NSString* login = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
                
                //on recupere les lignes de classement mondial
                //les lignes sont de la forme : classement|||login|||score|||herring|||time
                NSArray* world = [[datas objectAtIndex:1] componentsSeparatedByString:@"\r\n"];
				
                for (NSString * rawString in world) {
                    NSDictionary * dict = dictionaryByParsingResultsString(rawString, login);
                    if(dict) [_worldRanking addObject:dict];
                }
                
                //on recupere les lignes de classement National
                NSArray* country = [[datas objectAtIndex:2] componentsSeparatedByString:@"\r\n"];
                for (NSString * rawString in country) {
                    NSDictionary * dict = dictionaryByParsingResultsString(rawString, login);
                    if(dict) [_countryRanking addObject:dict];
                }
                
                //on recupere les lignes de classement des amis
                NSArray* friends = [[datas objectAtIndex:3] componentsSeparatedByString:@"\r\n"];
                for (NSString * rawString in friends) {
                    NSDictionary * dict = dictionaryByParsingResultsString(rawString, login);
                    if(dict) [_friendsRanking addObject:dict];
                }
                
                //save cache
               if ([self.orderType isEqualToString:@"speed only"]) {
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[_currentSlope stringByAppendingString:@"SpeedOnly"]];
                } else if ([self.orderType isEqualToString:@"classic"]) {
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:_currentSlope];
                }
				
                [rankingsTableView reloadData];
            }
        }
    }
}

@end
