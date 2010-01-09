//
//  TRChallengeViewController.h
//  tuxracer
//
//  Created by emmanuel de Roux on 24/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "myHTTPErrors.h"
#import "TransitionView.h"
#include "TRRankingTableViewCell.h"


@interface TRChallengeViewController : UIViewController {
    IBOutlet UITableView* challengeTableView;
    
    IBOutlet UIView* challengeSectionHeader;
    IBOutlet UIView* timeTrialSectionHeader;
    IBOutlet UIView* classicModeSectionHeader;
	
	IBOutlet UIView* timeTrialNoChallengeSectionHeader;
    IBOutlet UIView* classicModeNoChallengeSectionHeader;
    
    NSMutableArray* _timeTrialChallengeRanking;
    NSMutableArray* _classicChallengeRanking;
}

- (void) refreshView;
- (void) treatData:(NSString*) data;
- (void) resetData;

@end
