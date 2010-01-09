//
//  TRPlayerInfosViewController.h
//  tuxracer
//
//  Created by emmanuel de Roux on 25/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TRPlayerInfosViewController : UIViewController {
	IBOutlet UILabel* pays;
	IBOutlet UILabel* timeTrialChallengeRanking;
	IBOutlet UILabel* classicChallengeRanking;
	IBOutlet UILabel* prix;
	IBOutlet UITableView* playerScoresTableView;
	
	IBOutlet UIView* infosSectionHeader;
	IBOutlet UIView* timeTrialSectionHeader;
    IBOutlet UIView* classicModeSectionHeader;
	
	IBOutlet UIView* prize123TimeTrial;
	IBOutlet UIView* prize123Classic;
	IBOutlet UIView* prize456;
	IBOutlet UIView* prize78;
	IBOutlet UIView* prize910;
	
	NSMutableDictionary* _playerInfos;
	
	NSString* _erreur;
	NSString* _playerName;
	NSString* _timeTrialWorldRanking;
	NSString* _classicWorldRanking;
}
- (id)initWithPlayerName:(NSString*) playerName;
- (void) loadPlayerInfos:(NSString*) playerName;
- (IBAction)displayPrize:(id)sender;
- (IBAction)get123infos:(id)sender;
+ (id)sharedPlayerInfosDelegate;

@end
