//
//  TRPlayerInfosViewController.m
//  tuxracer
//
//  Created by emmanuel de Roux on 25/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRPlayerInfosViewController.h"
#import "ConnectionController.h"
#import "TRErrorsManager.h"
#import "TRPlayerInfosCell.h"
#import "myHTTPErrors.h"
#import "TRPrizeViewController.h"
#import "TRNavigationController.h"

static id sharedPlayerInfosDelegate=nil;

@implementation TRPlayerInfosViewController

+ (id)sharedPlayerInfosDelegate {
	if (!sharedPlayerInfosDelegate){
		sharedPlayerInfosDelegate = [[[self alloc] init] autorelease];
	}
	return sharedPlayerInfosDelegate;
}

- (id)initWithPlayerName:(NSString*) playerName {
    if (self = [super initWithNibName:@"PlayerInfosView" bundle:nil]) {
		_playerInfos = [[NSMutableDictionary alloc] init];
		_timeTrialWorldRanking = nil;
		_classicWorldRanking = nil;
		_playerName = [playerName retain];
		sharedPlayerInfosDelegate=self;
		self.title = [NSString  stringWithFormat:NSLocalizedString(@"Infos: %@",@"Classes/TRPlayerInfosViewController.m"),_playerName];
		self.hidesBottomBarWhenPushed = TRUE;
    }
    return self;
}

- (void)dealloc {
	sharedPlayerInfosDelegate=nil;
	[_playerName release];
	[_timeTrialWorldRanking release];
	[_classicWorldRanking release];
	[_playerInfos release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewDidAppear:(BOOL)animated {
	if ([(TRNavigationController*)self.navigationController lastNavAction]!=POP) [self loadPlayerInfos:_playerName];
}

- (IBAction)displayPrize:(id)sender{
	NSArray* prizes = [NSArray arrayWithObjects:@"H112",@"Mutant",@"Lacrimossa",@"Slap",@"Purist",@"Puppy Tiger",@"Around noir",@"Cartel",@"T-Shirt",nil];
	NSString* prize = [prizes objectAtIndex:([sender tag]-1)];
	TRPrizeViewController* prizeViewController = [[[TRPrizeViewController alloc] initWithPrize:prize] autorelease];
	[self.navigationController pushViewController:prizeViewController animated:YES];
}

- (IBAction)get123infos:(id)sender{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Info" message:NSLocalizedString(@"The first one chooses one of the three prizes, the second one picks up one of the two remainings, and the third one wins the last one.",@"Classes/TRPlayerInfosViewController.m") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)displayPotentialPrizes{
	/* On récupère le classement valant pour les lots, sachant que si le mec est pas classé ici son classement vaut -1 */
	int ranking;
	if ([[_playerInfos objectForKey:@"speedOnlyChallengeRanking"] intValue]==-1) ranking = [[_playerInfos objectForKey:@"classicChallengeRanking"] intValue];
	else if ([[_playerInfos objectForKey:@"classicChallengeRanking"] intValue]==-1) ranking = [[_playerInfos objectForKey:@"speedOnlyChallengeRanking"] intValue];
	else ranking = min([[_playerInfos objectForKey:@"speedOnlyChallengeRanking"] intValue],[[_playerInfos objectForKey:@"classicChallengeRanking"] intValue]);
	
	/* En cas d'égalité, c'est le cadeau du mode speed only qui est séléctionné */
	int isSpeedOnly = (ranking==[[_playerInfos objectForKey:@"speedOnlyChallengeRanking"] intValue]);
	
	/*selectione le cadeau à afficher */
	UIView* potentialPrizeView;
	switch (ranking) {
		case 1:
		case 2:
		case 3:
			potentialPrizeView = (isSpeedOnly)?prize123TimeTrial:prize123Classic;
			break;
		case 4:
		case 5:
		case 6:
			potentialPrizeView = prize456;
			break;
		case 7:
		case 8:
			potentialPrizeView = prize78;
			break;
		case 9:
		case 10:
			potentialPrizeView = prize910;
			break;
		default:
			break;
	}
	
	/* place le cadeau */
	CGRect frame = CGRectMake(40, 65, 280, 40);
	potentialPrizeView.frame = frame;
	[infosSectionHeader addSubview:potentialPrizeView];
}

- (void) loadPlayerInfos:(NSString*) playerName {
	
	//Pas de cache pour les player infos, ca ferait trop et ca n'a pas de sens.
    ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableString* queryString = [NSMutableString stringWithFormat:@"login=%@&mdp=%@&playerName=%@&registered=%d",[prefs objectForKey:@"username"],[prefs objectForKey:@"password"],_playerName,[prefs boolForKey:@"registered"]];
	
    [conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:@"displayPlayerInfos.php"] withWaitMessage:NSLocalizedString(@"Refreshing Player infos...",@"") sendResponseTo:self withMethod:@selector(treatData:)];
}

- (void) treatData:(NSString*) data {
	printf("%s\n",[data UTF8String]);
	/*schéma de la réponse :
	 
	 n°de l'erreur
	 \r\t\n\r\t\t
	 paysDuPlayer||DateDinscription Heure
	 
	 D'inscription||speed only Ranking||Classic Ranking
	 \r\t\n\r\t\t
	 playerScoresSpeedOnly\r\n
	 piste||score||worldRanking\r\n
	 ...
	 \r\t\n\r\t\t
	 iPhoneScoresSpeedOnly\r\n
	 piste||score||worldRanking\r\n
	 ...
	 \r\t\n\r\t\t
	 playerScoresClassic\r\n
	 piste||score||worldRanking\r\n
	 ...
	 \r\t\n\r\t\t
	 iPhoneScoresClassic\r\n
	 piste||score||worldRanking\r\n
	 ...
	 */
	NSArray* paquets = [data componentsSeparatedByString:@"\r\t\n\r\t\n"];
	
	/*gestion des erreurs*/
	_erreur = [paquets objectAtIndex:0];
	[[TRErrorsManager sharedErrorsManager] treatError:_erreur];
	
	//En cas d'erreur relou on se barre
	if ([_erreur intValue]!=RANKINGS_OK&&[_erreur intValue]!=NOT_RANKED_BOTH&&[_erreur intValue]!=NOT_RANKED_TIME_TRIAL&&[_erreur intValue]!=NOT_RANKED_CLASSIC) return;
	
	/*Charge toutes les infos dans le dictionaire _playerInfos*/
	[_playerInfos setObject:[[[paquets objectAtIndex:1] componentsSeparatedByString:@"||"] objectAtIndex:0] forKey:@"pays"];
	[_playerInfos setObject:[[[paquets objectAtIndex:1] componentsSeparatedByString:@"||"] objectAtIndex:1] forKey:@"suscribtionDate"]; //finalement je ne m'en sers pas
	[_playerInfos setObject:[[[paquets objectAtIndex:1] componentsSeparatedByString:@"||"] objectAtIndex:2] forKey:@"speedOnlyChallengeRanking"];
	[_playerInfos setObject:[[[paquets objectAtIndex:1] componentsSeparatedByString:@"||"] objectAtIndex:3] forKey:@"classicChallengeRanking"];
	int i;
	for (i=2;i<[paquets count];i++) {
		NSRange range;
		NSArray* petitPaquet = [[paquets objectAtIndex:i] componentsSeparatedByString:@"\r\n"];
		range.location = 1;
		range.length = [petitPaquet count]-1;
		[_playerInfos setObject:[petitPaquet subarrayWithRange:range] forKey:[petitPaquet objectAtIndex:0]];
	}
	
	[pays setText:[_playerInfos objectForKey:@"pays"]];
	NSString* timeTrialWorldRanking;
	if ([[_playerInfos objectForKey:@"speedOnlyChallengeRanking"] intValue]==-1) timeTrialWorldRanking = NSLocalizedString(@"Not ranked",@"Classes/TRPlayerInfosViewController.m"); else timeTrialWorldRanking = [_playerInfos objectForKey:@"speedOnlyChallengeRanking"];
	NSString* classicWorldRanking;
	if ([[_playerInfos objectForKey:@"classicChallengeRanking"] intValue]==-1) classicWorldRanking = NSLocalizedString(@"Not ranked",@"Classes/TRPlayerInfosViewController.m");  else classicWorldRanking = [_playerInfos objectForKey:@"classicChallengeRanking"];
	[timeTrialChallengeRanking setText:timeTrialWorldRanking];
	[classicChallengeRanking setText:classicWorldRanking];
	
	/* inutile désormais puisqu'apple ne veut pas qu'on parle du challenge dans l'iphone */
	//[self displayPotentialPrizes];
	[playerScoresTableView reloadData];
}

#pragma mark tableView delegate functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return NULL;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70;	
}

#pragma mark datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if([_playerInfos count]>0) {
		NSArray* keys = [_playerInfos allKeys];
		return 1+([keys containsObject:@"playerScoresSpeedOnly"]?1:0)+([keys containsObject:@"playerScoresClassic"]?1:0);
	} else return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if([_playerInfos count]>0) {
		NSArray* keys = [_playerInfos allKeys];
		switch (section) {
			case 0:
				return infosSectionHeader;
				break;
			case 1:
				if ([keys containsObject:@"playerScoresSpeedOnly"]) return timeTrialSectionHeader;
				else if ([keys containsObject:@"playerScoresClassic"]) return classicModeSectionHeader;
				break;
			case 2:
				if ([keys containsObject:@"playerScoresSpeedOnly"] && [keys containsObject:@"playerScoresClassic"]) return classicModeSectionHeader;
				break;
			default:
				break;
		}
	}
    return NULL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 70.0;//C'était égal à 115 mais je le racourcis pour masquer toute allusion au challenge
			break;
		default:
			return 40.0;
			break;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if([_playerInfos count]>0) {
		NSArray* keys = [_playerInfos allKeys];
		switch (section) {
			case 0:
				return 0;
				break;
			case 1:
				if ([keys containsObject:@"playerScoresSpeedOnly"]) return [[_playerInfos objectForKey:@"playerScoresSpeedOnly"] count];
				else if ([keys containsObject:@"playerScoresClassic"]) return [[_playerInfos objectForKey:@"playerScoresClassic"] count];
				else return 0;
				break;
			case 2:
				if ([keys containsObject:@"playerScoresSpeedOnly"] && [keys containsObject:@"playerScoresClassic"]) return [[_playerInfos objectForKey:@"playerScoresClassic"] count];
				else return 0;
				break;
			default:
				break;
		}
	}
	return 0;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TRPlayerInfosCell *cell = (TRPlayerInfosCell*)[tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil || ![cell isKindOfClass:[TRPlayerInfosCell class]])
    {
        cell = [[[TRPlayerInfosCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"cellID"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	NSArray* scoresNames;
	NSString* mode;
	NSArray* keys = [_playerInfos allKeys];
	switch (indexPath.section) {
		case 1:
			if ([keys containsObject:@"playerScoresSpeedOnly"]) {
				scoresNames = [NSArray arrayWithObjects:@"playerScoresSpeedOnly",@"iPhoneScoresSpeedOnly",nil];
				mode = @"speed only";
			} else if ([keys containsObject:@"playerScoresClassic"]) {
				scoresNames = [NSArray arrayWithObjects:@"playerScoresClassic",@"iPhoneScoresClassic",nil];
				mode = @"classic";
			}
			break;
		case 2:
			if ([keys containsObject:@"playerScoresSpeedOnly"] && [keys containsObject:@"playerScoresClassic"]) {
				scoresNames = [NSArray arrayWithObjects:@"playerScoresClassic",@"iPhoneScoresClassic",nil];
				mode = @"classic";
			}
			break;
		default:
			break;
	}
	
	NSString* rowPlayer = ([keys containsObject:[scoresNames objectAtIndex:0]]) ? [[_playerInfos objectForKey:[scoresNames objectAtIndex:0]] objectAtIndex:indexPath.row] : nil;
	/* rowsiPhone is an array while rowsPlayer is a row of such an array. I did that to allow the iPhone to compare his score with the ranked player even if he is not ranked himself 
	 then I ewxtract formthis array the rowIphone wich is a row this time if it has the same pisteName than rowPlayer.*/ 
	NSArray* rowsIphone = ([keys containsObject:[scoresNames objectAtIndex:1]]) ? [_playerInfos objectForKey:[scoresNames objectAtIndex:1]] : nil;
	NSString* rowIphone = nil;
	if (rowPlayer!= nil) {
		for(NSString* row in rowsIphone) {
			if ([[[[row componentsSeparatedByString:@"||"] objectAtIndex:0] uppercaseString] isEqualToString:[[[rowPlayer componentsSeparatedByString:@"||"] objectAtIndex:0] uppercaseString]]) {
				rowIphone = row;
				break;
			}
		}
	}
	
	NSString* piste;
	NSString* scorePlayer;
	NSString* classementMondialPlayer;
	NSString* scoreIphone;
	NSString* classementMondialIphone;
	
	if (rowPlayer != nil ){
		piste = [[rowPlayer componentsSeparatedByString:@"||"] objectAtIndex:0];
		
		scorePlayer = [[rowPlayer componentsSeparatedByString:@"||"] objectAtIndex:1];
		classementMondialPlayer = [[rowPlayer componentsSeparatedByString:@"||"] objectAtIndex:2];
		
		if (rowIphone != nil ){
			scoreIphone = [[rowIphone componentsSeparatedByString:@"||"] objectAtIndex:1];
			classementMondialIphone = [[rowIphone componentsSeparatedByString:@"||"] objectAtIndex:2];
		} else {
			scoreIphone = NSLocalizedString(@"No score.",@"Classes/TRPlayerInfosViewController.m");
			classementMondialIphone = @"";
		}
	} else {
		piste = nil;
		scorePlayer = nil;
		classementMondialPlayer = nil;
	}
	
	NSArray* dataForCell = [NSArray arrayWithObjects:piste,_playerName,mode,scorePlayer,scoreIphone,classementMondialPlayer,classementMondialIphone,[_playerInfos objectForKey:@"speedOnlyChallengeRanking"],[_playerInfos objectForKey:@"classicChallengeRanking"],nil];
	[cell setData:dataForCell];
    [cell setSelected:NO];
    
    return cell;
}

@end
