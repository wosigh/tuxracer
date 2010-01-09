//
//  TRChallengeResultsViewController.h
//  tuxracer
//
//  Created by emmanuel de Roux on 13/04/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TRChallengeResultsViewController : UIViewController {
	IBOutlet UIScrollView* scrollView;
	IBOutlet UIView* resultsView;
	IBOutlet UIView* waitResultsView;
	
	//Time trial challenge winners
	
	IBOutlet UILabel* TTCWinner1;
	IBOutlet UILabel* TTCWinner2;
	IBOutlet UILabel* TTCWinner3;
	IBOutlet UILabel* TTCWinner4;
	IBOutlet UILabel* TTCWinner5;
	IBOutlet UILabel* TTCWinner6;
	IBOutlet UILabel* TTCWinner7;
	IBOutlet UILabel* TTCWinner8;
	IBOutlet UILabel* TTCWinner9;
	IBOutlet UILabel* TTCWinner10;
	
	//Classic challenge winners
	
	IBOutlet UILabel* CCWinner1;
	IBOutlet UILabel* CCWinner2;
	IBOutlet UILabel* CCWinner3;
	IBOutlet UILabel* CCWinner4;
	IBOutlet UILabel* CCWinner5;
	IBOutlet UILabel* CCWinner6;
	IBOutlet UILabel* CCWinner7;
	IBOutlet UILabel* CCWinner8;
	IBOutlet UILabel* CCWinner9;
	IBOutlet UILabel* CCWinner10;
	
	//data arrays
	NSArray* _timeTrialChallengeWinners;
    NSArray* _classicChallengeWinners;
}

- (void) treatData:(NSString*) data;
@end
