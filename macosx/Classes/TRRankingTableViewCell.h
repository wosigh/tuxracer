//
//  TRRankingTableViewCell.h
//  tuxracer
//
//  Created by emmanuel de Roux on 06/12/08.
//  Copyright 2008 école Centrale de Lyon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRRankingTableViewCell : UITableViewCell {
    // adding the labels we want to show in the cell
	UILabel *rankingLabel;
	UILabel *nameLabel;
	UILabel *percentLabel;
    UILabel *scoreLabel;
    UILabel *timeLabel;
    UILabel *infosChallengeLabel;
    UILabel *herringLabel;
    UIImageView *scoreImg;
    UIImageView *herringImg;
    UIImageView *timeImg;
    IBOutlet UIView* rankingTableView;
    IBOutlet UIView* manageFriendsView;
    BOOL _textAndButtonMode;
	int nbRacePlayer;
	int nbRaceToDo;
	NSString* _orderType;
}

//init
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier boldText:(BOOL)bold andOrderType:(NSString*)orderType;
-(void) setBoldFont:(BOOL)bold;

- (void)setText:(NSString *)text;
- (void)setTextAndButtonMode:(BOOL)textAndButtonMode;
- (void)setTimeTrialOrClassicModeForChallenge:(BOOL)timeTrialMode;
- (void)setChallengeInfoCell:(BOOL)isChallengeInfoCell;

- (NSString*) playerName;

// internal function to ease setting up label text and image
-(UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;
- (UIImageView *)newImageWithName:(NSString *)name;

// you should know what this is for by know
@property (nonatomic, retain) UILabel *infosChallengeLabel;
@property (nonatomic, retain) UILabel *rankingLabel;
@property (nonatomic, retain) UILabel *percentLabel;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *scoreLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UILabel *herringLabel;
@property (nonatomic, retain) UIImageView *scoreImg;
@property (nonatomic, retain) UIImageView *herringImg;
@property (nonatomic, retain) UIImageView *timeImg;
@property (nonatomic, retain) NSString *orderType;
@property (assign) int nbRacePlayer;
@property (assign) int nbRaceToDo;
@end
