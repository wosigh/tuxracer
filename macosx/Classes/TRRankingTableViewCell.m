//
//  TRRankingTableViewCell.m
//  tuxracer
//
//  Created by emmanuel de Roux on 06/12/08.
//  Copyright 2008 école Centrale de Lyon. All rights reserved.
//

#import "TRRankingTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "sharedGeneralFunctions.h"


@implementation TRRankingTableViewCell
@synthesize infosChallengeLabel, rankingLabel, nameLabel, scoreLabel, timeLabel, herringLabel, scoreImg, herringImg, timeImg, percentLabel,nbRacePlayer,nbRaceToDo,orderType=_orderType;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier boldText:(BOOL)bold andOrderType:(NSString*)orderType {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        
		// we need a view to place our labels on.
		UIView *myContentView = self.contentView;
        
        self.infosChallengeLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:15.0 bold:true];
		self.infosChallengeLabel.textAlignment = UITextAlignmentLeft; // default
		//self.infosChallengeLabel.backgroundColor = [UIColor redColor];
		[myContentView addSubview:self.infosChallengeLabel];
		[self.infosChallengeLabel release];
        
		self.rankingLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:18.0 bold:bold];
		self.rankingLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.rankingLabel];
		[self.rankingLabel release];
        
        self.nameLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:18.0 bold:bold];
		self.nameLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.nameLabel];
		[self.nameLabel release];

        self.percentLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:11.0 bold:bold];
		self.percentLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.percentLabel];
		[self.percentLabel release];
        
        self.scoreLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:11.0 bold:bold];
		self.scoreLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.scoreLabel];
		[self.scoreLabel release];
        
        self.timeLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:11.0 bold:bold];
		self.timeLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.timeLabel];
		[self.timeLabel release];
        
        self.herringLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:11.0 bold:bold];
		self.herringLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.herringLabel];
		[self.herringLabel release];

        self.scoreImg = [self newImageWithName:@"calculatriceicon.png"];
        [myContentView addSubview:self.scoreImg];
        [self.scoreImg release];
        
        self.herringImg = [self newImageWithName:@"herringicon.png"];
        [myContentView addSubview:self.herringImg];
        [self.herringImg release];
        
        self.timeImg = [self newImageWithName:@"timeicon.png"];
		[myContentView addSubview:self.timeImg];
		[self.timeImg release];

        _textAndButtonMode = YES;
        [self setTextAndButtonMode:NO]; 
		
		self.orderType = orderType;
	}
    
	return self;
}

- (NSString*) playerName {
	return nameLabel.text;	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}

-(void) setBoldFont:(BOOL)bold {
    UIFont* oldFont;
    
    oldFont = self.rankingLabel.font;
    self.rankingLabel.font = bold?[UIFont boldSystemFontOfSize:oldFont.pointSize]:[UIFont systemFontOfSize:oldFont.pointSize];
    
    oldFont = self.nameLabel.font;
    self.nameLabel.font = bold?[UIFont boldSystemFontOfSize:oldFont.pointSize]:[UIFont systemFontOfSize:oldFont.pointSize];

    oldFont = self.percentLabel.font;
    self.percentLabel.font = bold?[UIFont boldSystemFontOfSize:oldFont.pointSize]:[UIFont systemFontOfSize:oldFont.pointSize];
    
    oldFont = self.scoreLabel.font;
    self.scoreLabel.font = bold?[UIFont boldSystemFontOfSize:oldFont.pointSize]:[UIFont systemFontOfSize:oldFont.pointSize];
    
    oldFont = self.herringLabel.font;
    self.herringLabel.font = bold?[UIFont boldSystemFontOfSize:oldFont.pointSize]:[UIFont systemFontOfSize:oldFont.pointSize];
    
    
    oldFont = self.timeLabel.font;
    self.timeLabel.font = bold?[UIFont boldSystemFontOfSize:oldFont.pointSize]:[UIFont systemFontOfSize:oldFont.pointSize];
}

- (void)setText:(NSString *)text
{
    self.nameLabel.text = text;
}

- (void)setTextAndButtonMode:(BOOL)textAndButtonMode
{
    _textAndButtonMode = textAndButtonMode;
    if(textAndButtonMode)
    {
        self.nameLabel.textAlignment = UITextAlignmentCenter;
        self.percentLabel.hidden=YES;
        self.rankingLabel.hidden=true;
        self.scoreLabel.hidden=true;
        self.herringLabel.hidden=true;
        self.timeLabel.hidden=true;
        self.scoreImg.hidden=true;
        self.timeImg.hidden=true;        
        self.herringImg.hidden=true;
        [self layoutSubviews];
        [self setNeedsDisplay];
    }
    else
    {
        //Au cas ou on réutilise une case qui a servi a etre celle d'une empty list friend, on reset tout
        self.accessoryType=UITableViewCellAccessoryNone;
        self.rankingLabel.hidden=false;
        if ([self.orderType isEqualToString:@"classic"]) {
            self.scoreLabel.hidden=false;
            self.herringLabel.hidden=false;
            self.scoreImg.hidden=false;        
            self.herringImg.hidden=false;
			self.timeLabel.hidden=false;
			self.timeImg.hidden=false;
        } else if ([self.orderType isEqualToString:@"speed only"]){
            self.scoreLabel.hidden=true;
            self.herringLabel.hidden=true;
            self.scoreImg.hidden=true;        
            self.herringImg.hidden=true;
			self.timeLabel.hidden=false;
			self.timeImg.hidden=false;
        }
        self.percentLabel.hidden=NO;
        self.nameLabel.textAlignment = UITextAlignmentLeft;
        [self layoutSubviews];
        [self setNeedsDisplay];
    } 
}


- (void)setTimeTrialOrClassicModeForChallenge:(BOOL)timeTrialMode
{
    
    if(timeTrialMode)
    {
		self.scoreLabel.hidden=true;
		self.herringLabel.hidden=true;
		self.scoreImg.hidden=true;        
		self.herringImg.hidden=true;
		self.timeLabel.hidden=false;
		self.timeImg.hidden=false;
        [self layoutSubviews];
        [self setNeedsDisplay];
    }
    else
    {
        //Au cas ou on réutilise une case qui a servi a etre celle d'une empty list friend, on reset tout
        self.accessoryType=UITableViewCellAccessoryNone;
        self.rankingLabel.hidden=false;
		self.scoreLabel.hidden=false;
		self.herringLabel.hidden=true;
		self.scoreImg.hidden=false;        
		self.herringImg.hidden=true;
		self.timeLabel.hidden=true;
		self.timeImg.hidden=true;
        self.percentLabel.hidden=NO;
        self.nameLabel.textAlignment = UITextAlignmentLeft;
        [self layoutSubviews];
        [self setNeedsDisplay];
    } 
}

- (void)setChallengeInfoCell:(BOOL)isChallengeInfoCell{
	if (isChallengeInfoCell) {
		if (nbRacePlayer!=nbRaceToDo) {
			self.infosChallengeLabel.textAlignment = UITextAlignmentLeft;
			self.infosChallengeLabel.adjustsFontSizeToFitWidth=true;
			self.infosChallengeLabel.text=[NSString stringWithFormat:NSLocalizedString(@"You're not ranked : %d race(s) on %d with no score",@""),(nbRaceToDo-nbRacePlayer),nbRaceToDo];
			self.infosChallengeLabel.font = [UIFont systemFontOfSize:13.0];
			self.infosChallengeLabel.textColor = [UIColor redColor];
			self.accessoryType=UITableViewCellAccessoryNone;
		} else {
			self.infosChallengeLabel.textAlignment = UITextAlignmentLeft;
			if (isChallengeOn()) {
				self.infosChallengeLabel.text=NSLocalizedString(@"Exceptional event for the bests ones",@"");
			}
			/* Disablé pour faire plaisir à APPLE
			else {
				self.infosChallengeLabel.text=NSLocalizedString(@"The challenge is over. See the results : ",@"");
			}*/
			self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
			self.infosChallengeLabel.font = [UIFont systemFontOfSize:15.0];
			self.infosChallengeLabel.textColor = [UIColor blackColor];
		}
        self.infosChallengeLabel.hidden=false;
		self.nameLabel.hidden=true;
		self.percentLabel.hidden=YES;
		self.rankingLabel.hidden=true;
        self.scoreLabel.hidden=true;
		self.herringLabel.hidden=true;
		self.timeLabel.hidden=true;
		self.scoreImg.hidden=true;
		self.timeImg.hidden=true;        
		self.herringImg.hidden=true;
		[self layoutSubviews];
		[self setNeedsDisplay];
	} else {
		self.infosChallengeLabel.hidden=true;
        self.nameLabel.hidden=false;
    }
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    
	// getting the cell size
    CGRect contentRect = self.contentView.bounds;
    
    // get the X pixel spot
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;
    

    if (!_textAndButtonMode) {
        // place the name label
        frame = CGRectMake(boundsX + 100, 4, 195, 20);
        self.nameLabel.frame = frame;
    }
    else {
        self.nameLabel.frame = CGRectMake(contentRect.origin.x+ 10, contentRect.origin.y+10, contentRect.size.width-20, contentRect.size.height-20);
    }

   // place the infosChallengeLabel
    frame = CGRectMake(boundsX+10, 10, 300, 20);
    self.infosChallengeLabel.frame = frame;
    
    // place the ranking label
    frame = CGRectMake(boundsX + 10, 4, 90, 20);
    self.rankingLabel.frame = frame;

    // place the percent label
    frame = CGRectMake(boundsX + 10, 30, 40, 10);
    self.percentLabel.frame = frame;

    if ([self.orderType isEqualToString:@"classic"])
        boundsX += 50;
    else
        boundsX += -3;

	// place the score image and label  
    if ([self.orderType isEqualToString:@"challenge"]) {
		
		frame = CGRectMake(boundsX + 105, 27, 10, 13);
    	self.scoreImg.frame = frame;
		frame = CGRectMake(boundsX + 122, 30, 70, 10);
		self.scoreLabel.frame = frame;
		
	} else {
		frame = CGRectMake(boundsX + 10, 27, 10, 13);
    	self.scoreImg.frame = frame;
		frame = CGRectMake(boundsX + 30, 30, 70, 10);
		self.scoreLabel.frame = frame;
		
	}
    
    // place the herring image
    frame = CGRectMake(boundsX + 190, 24, 20, 20);
    self.herringImg.frame = frame;
    
    // place the herring label
    frame = CGRectMake(boundsX + 220, 30, 20, 10);
    self.herringLabel.frame = frame;
        
    // place the time image
    frame = CGRectMake(boundsX + 100, 24, 20, 20);
    self.timeImg.frame = frame;
    
    // place the time label
    frame = CGRectMake(boundsX + 120, 30, 70, 10);
    self.timeLabel.frame = frame;
}

- (UIImageView *)newImageWithName:(NSString *)name
{
    UIImage* image = [UIImage imageNamed:name];
   	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    return imageView;
}

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold
{
    UIFont *font;
    if (bold) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    } else {
        font = [UIFont systemFontOfSize:fontSize];
    }
    
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	newLabel.backgroundColor = [UIColor whiteColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	newLabel.font = font;
    
	return newLabel;
}

- (void)dealloc {
	// make sure you free the memory
	self.orderType=nil;
    self.timeLabel = nil;
    self.herringLabel = nil;
    self.scoreImg = nil;
    self.herringImg = nil;
    self.timeImg = nil;
    self.rankingLabel = nil;
    self.nameLabel = nil;
    self.scoreLabel = nil;
	[super dealloc];
}

@end