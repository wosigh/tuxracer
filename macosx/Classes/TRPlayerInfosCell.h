//
//  TRPlayerInfosCell.h
//  tuxracer
//
//  Created by emmanuel de Roux on 25/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TRPlayerInfosCell : UITableViewCell {
	// adding the labels we want to show in the cell
	UILabel *titleLabel;
	UILabel *playerScoreLabel;
    UILabel *iPhoneScoreLabel;
	UILabel *iPhoneComparaisonLabel;
    UILabel *playerRankingLabel;
	UILabel *iPhoneRankingLabel;
	
	UILabel *playerNameLabel;
	UILabel *youLabel;
	
	/* headers */
	UILabel *playerHeaderLabel;
	UILabel *scoreHeaderLabel;
	UILabel *differenceHeaderLabel;
	UILabel *rankingHeaderLabel;
	
	/* When no scores */
	UIImageView* warning;
	
	NSString *_mode;
}

// gets the data from another class
-(void)setData:(NSArray *)data;

// internal function to ease setting up label text and image
-(UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

// you should know what this is for by know
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *playerScoreLabel;
@property (nonatomic, retain) UILabel *iPhoneScoreLabel;
@property (nonatomic, retain) UILabel *iPhoneComparaisonLabel;
@property (nonatomic, retain) UILabel *playerRankingLabel;
@property (nonatomic, retain) UILabel *iPhoneRankingLabel;
@property (nonatomic, retain) UILabel *playerNameLabel;
@property (nonatomic, retain) UILabel *youLabel;
@property (nonatomic, retain) UILabel *playerHeaderLabel;
@property (nonatomic, retain) UILabel *scoreHeaderLabel;
@property (nonatomic, retain) UILabel *differenceHeaderLabel;
@property (nonatomic, retain) UILabel *rankingHeaderLabel;
@property (nonatomic, retain) UIImageView *warning;
@property (nonatomic, retain) NSString *mode;

@end
