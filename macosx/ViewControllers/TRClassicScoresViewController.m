//
//  TRClassicScoresViewController.m
//  tuxracer
//
//  Created by emmanuel de Roux on 24/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRClassicScoresViewController.h"
#import "ConnectionController.h"
#import "sharedGeneralFunctions.h"
#import "TRSlopeInfoCell.h"
#import "myHTTPErrors.h"
#import "save.h"
#import "game_over.h"
#import "TRErrorsManager.h"
#import "TRPersonalRankingsViewController.h"
#import "TRNavigationController.h"


static id sharedClassicScoreViewViewController=nil;
static BOOL isCache = NO;

@implementation TRClassicScoresViewController
@synthesize orderType=_orderType;

- (id)init {
    if (self = [super initWithNibName:@"ClassicScoresView" bundle:nil]) {
        self.title = NSLocalizedString(@"Classic mode",@"Views/TRClassicScoresViewController.m");
		self.tabBarItem.image = [UIImage imageNamed:@"herringiconTabBar.png"];
		sharedClassicScoreViewViewController=self;
		_scoreManager = [[TRScoresManager alloc] init];
		self.orderType = @"classic";
    }
    return self;
}


- (void)dealloc {
	self.orderType = nil;
	sharedClassicScoreViewViewController=nil;
	[_listOfCourses release];
	[_scoreManager release];
    [super dealloc];
}

+ (id)sharedClassicScoreViewController {
 	if(!sharedClassicScoreViewViewController)
		sharedClassicScoreViewViewController = [[[self alloc] init] autorelease];
	return sharedClassicScoreViewViewController;
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
    [self treatData:[prefs objectForKey:@"rankingCache"]];
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
	//On ne traite pas l'erreur des fichiers cache
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
    if (![data isEqualToString:@""]) {
        NSArray* datas = [data componentsSeparatedByString:@"\r\t\n\r\t\n"];
        //On traite l'éventuelle erreur
        if([datas count] < 2)
            [self treatError:[NSString stringWithFormat:@"%d", SERVER_ERROR]];
        else
        {
            [self treatError:[datas objectAtIndex:1]];
            if ([[datas objectAtIndex:1] intValue] == RANKINGS_OK) {
                //on recupere la liste des pistes
                [_listOfCourses release];
                _listOfCourses = [[[datas objectAtIndex:0] componentsSeparatedByString:@"\r\n"] retain];
                
                //save cache
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
				[prefs setObject:data forKey:@"rankingCache"];
				
                //reload data
                [classicTableView reloadData];
            } else {
				//C'est qu'on est dans le cas ou le mec a aucun scores enregistrés.
				//save cache
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
				[prefs setObject:data forKey:@"rankingCache"];
				[_listOfCourses release];
				_listOfCourses=[[NSMutableArray alloc] init];
				[classicTableView reloadData];	
			}
        }
    }
    else {
        [_listOfCourses release];
        _listOfCourses=[[NSMutableArray alloc] init];
        [classicTableView reloadData];
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
