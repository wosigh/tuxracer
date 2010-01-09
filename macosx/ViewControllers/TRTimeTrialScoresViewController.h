//
//  TRTimeTrialScoresViewController.h
//  tuxracer
//
//  Created by emmanuel de Roux on 23/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRScoresManager.h"


@interface TRTimeTrialScoresViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView* timeTrialTableView;
	
	TRScoresManager* _scoreManager;
	NSMutableArray* _listOfCourses;
	NSString* _orderType;
	
	/*ne sais pas a quoi ces deux trucs servent, éventuellement à supprimer" */
    NSArray* _currentRankings;
    NSArray* _currentPercentage;
	
	
}
@property(copy) NSString* orderType;
+ (id)sharedTimeTrialScoreViewController;
- (void) refreshView:(BOOL)syncIfNeeded;
- (void) treatData:(NSString*) data;
- (void) treatError:(NSString*)erreur;
@end
