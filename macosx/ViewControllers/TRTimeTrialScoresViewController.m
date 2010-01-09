//
//  TRTimeTrialScoresViewController.m
//  tuxracer
//
//  Created by emmanuel de Roux on 23/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRTimeTrialScoresViewController.h"
#import "ConnectionController.h"
#import "sharedGeneralFunctions.h"
#import "TRSlopeInfoCell.h"
#import "myHTTPErrors.h"
#import "save.h"
#import "game_over.h"
#import "TRPersonalRankingsViewController.h"
#import "TRErrorsManager.h"
#import "TRNavigationController.h"


static id sharedTimeTrialScoreViewViewController=nil;
static BOOL isCache = NO;

@implementation TRTimeTrialScoresViewController
@synthesize orderType=_orderType;

- (id)init {
    if (self = [super initWithNibName:@"TimeTrialScoresView" bundle:nil]) {
        self.title = NSLocalizedString(@"Time trial",@"Views/TRTimeTrialScoresViewController.m");
		self.tabBarItem.image = [UIImage imageNamed:@"timeicon.png"];
		sharedTimeTrialScoreViewViewController=self;
		_scoreManager = [[TRScoresManager alloc] init];
		self.orderType = @"speed only";
		
    }
    return self;
}


- (void)dealloc {
	sharedTimeTrialScoreViewViewController=nil;
	self.orderType = nil;
	[_listOfCourses release];
	[_scoreManager release];
    [super dealloc];
}

+ (id)sharedTimeTrialScoreViewController {
 	if(!sharedTimeTrialScoreViewViewController)
		sharedTimeTrialScoreViewViewController = [[[self alloc] init] autorelease];
	return sharedTimeTrialScoreViewViewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewDidAppear:(BOOL)animated {
	if ([(TRNavigationController*)self.navigationController lastNavAction]!=POP) [self refreshView:YES];	
}

#pragma mark usefull functions
- (void) refreshView:(BOOL)syncIfNeeded {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	//Si un cache existe, on l'utilise
	isCache = YES;
  	[self treatData:[prefs objectForKey:@"rankingCacheSpeedOnly"]];
	isCache = NO;
	
	//Si certains scores n'ont pas été sauvegardés en ligne, on averti l'utilisateur et on lui propose d'abord de le faire
    if ([prefs boolForKey:@"needsSync"]>0 && syncIfNeeded) {
        UIActionSheet* alert = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Unsaved scores detected. Do you want to save them online now ?",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"No",@"") destructiveButtonTitle:NSLocalizedString(@"Yes",@"") otherButtonTitles:nil];
        [alert setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [alert showInView:self.view];
        [alert release];
    }
    else {
        ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
        NSMutableString* queryString = [NSMutableString stringWithFormat:@"login=%@&mdp=%@&order=%@",[prefs objectForKey:@"username"],[prefs objectForKey:@"password"],self.orderType];
        //Si le joueur ajouté des amis
        int i;
        for (i = 0; i<[[prefs objectForKey:@"friendsList"] count]; i++) {
            [queryString appendFormat:@"&friends[%d]=%@",i,[[prefs objectForKey:@"friendsList"] objectAtIndex:i]];
        }
        
	    NSString* phpPage=@"displaySlopes.php";
        
        [conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:phpPage] withWaitMessage:NSLocalizedString(@"Refreshing rankings...",@"") sendResponseTo:self withMethod:@selector(treatData:)];
    }
	
}

#pragma mark actionSheet delegate
//this is only for the alert view concerning syncronizing
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
            //Yes
        case 0:
            [_scoreManager syncScores];
            break;
            //No
        case 1:
            [self refreshView:NO];
            break;
        default:
            break;
    }
}
#pragma mark tread HTTP response
-(void) treatError:(NSString*)erreur{
	if (!isCache) [[TRErrorsManager sharedErrorsManager] treatError:erreur];
}

- (void) treatData:(NSString*) data {
    //Sur chaque ligne, une série de data séparés par le symbole  |||
    //chaaque ligne est materialisee par \r\n
    //les lignes sont séparées en paquets, chacuns séparés par un \r\t\n\r\t\n
    //paquet n°1 : nom du pays
    //paquet n°2, 3 et 4 sur chaque ligne, nomdelapiste|||friendsRanking|||countryRanking|||worldRanking
    //paquer n°5 : une ligne, Status de la requete
    //Mais en cas d'erreur de conection, il n'y a qu'une seule ligne qui contient @"\r\t\n\r\t\n" puis le numéro de l'erreur
	
	//evite le cas ou on envoie un cache vide
    if (![data isEqualToString:@""]) {
        NSArray* datas = [data componentsSeparatedByString:@"\r\t\n\r\t\n"];
        //On traite l'éventuelle erreur
        if([datas count] < 2) {
            [self treatError:[NSString stringWithFormat:@"%d", SERVER_ERROR]];
		}
        else
        {
            [self treatError:[datas objectAtIndex:1]];
            if ([[datas objectAtIndex:1] intValue] == RANKINGS_OK) {
                //on recupere la liste des pistes
				[_listOfCourses release];
				_listOfCourses = [[NSMutableArray alloc] initWithArray:[[datas objectAtIndex:0] componentsSeparatedByString:@"\r\n"]];
                
                //save cache
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
			    [prefs setObject:data forKey:@"rankingCacheSpeedOnly"];
				
                //reload data
                [timeTrialTableView reloadData];
            } else {
				//C'est qu'on est dans le cas ou le mec a aucun scores enregistrés.
				//save cache
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
				[prefs setObject:data forKey:@"rankingCacheSpeedOnly"];
				[_listOfCourses release];
				_listOfCourses=[[NSMutableArray alloc] init];
				[timeTrialTableView reloadData];	
			}
        }
    }
    else {
        [_listOfCourses release];
        _listOfCourses=[[NSMutableArray alloc] init];
		[timeTrialTableView reloadData];
		[timeTrialTableView setNeedsDisplay];
    }
}


#pragma mark tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* currentSlope=[[(TRSlopeInfoCell*)[tableView cellForRowAtIndexPath:indexPath] titleLabel] text];
	TRPersonalRankingsViewController* personalRankingsViewController = [[[TRPersonalRankingsViewController alloc] initWithSlope:currentSlope andOrderType:self.orderType] autorelease];
    //affiche les personal rankings
	[self.navigationController pushViewController:personalRankingsViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return NULL;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark UITableViewDataSource for slopesView
//Pour la première table view, celle qui affiche toutes les pistes
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_listOfCourses count];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryDisclosureIndicator;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TRSlopeInfoCell *cell = (TRSlopeInfoCell*)[tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil || ![cell isKindOfClass:[TRSlopeInfoCell class]])
    {
        cell = [[[TRSlopeInfoCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"cellID"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    NSArray* data = [[_listOfCourses objectAtIndex:indexPath.row] componentsSeparatedByString:@"|||"];
    [cell setData:data];
    [cell setSelected:NO];
    
    return cell;
}
@end
