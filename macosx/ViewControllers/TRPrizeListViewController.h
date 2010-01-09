//
//  TRPrizeListViewController.h
//  tuxracer
//
//  Created by emmanuel de Roux on 30/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TRPrizeListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray* _timeTrialPrizes;
	NSArray* _classicPrizes;
	
	NSArray* _timeTrialPrizesNames;
	NSArray* _classicPrizesNames;
	NSArray* _prizesNamesArrays;
	
	IBOutlet UIView* timeTrialHeader;
	IBOutlet UIView* classicHeader;
}

@end
