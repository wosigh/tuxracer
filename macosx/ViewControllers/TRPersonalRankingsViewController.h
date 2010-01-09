//
//  TRPersonalRankingsViewController.h
//  tuxracer
//
//  Created by emmanuel de Roux on 24/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myHTTPErrors.h"

@interface TRPersonalRankingsViewController : UIViewController {
    IBOutlet UITableView* rankingsTableView;
    IBOutlet UILabel* countryName;
    
    IBOutlet UIView* friendsSectionHeader;
    IBOutlet UIView* countrySectionHeader;
    IBOutlet UIView* worldSectionHeader;
    
    NSMutableArray* _worldRanking;
    NSMutableArray* _countryRanking;
    NSMutableArray* _worldRankingInfos;
    NSMutableArray* _countryRankingInfos;
    NSMutableArray* _friendsRanking;
    NSMutableArray* _friendsRankingInfos;
	NSString* _currentSlope;
    
	NSString* _orderType;
    NSString* _playerCountry;
}
@property(copy) NSString* orderType;
- (id)initWithSlope:(NSString*)slope andOrderType:(NSString*)order;
- (void) refreshView;
- (void) treatData:(NSString*) data;
- (void) resetData;

@end
