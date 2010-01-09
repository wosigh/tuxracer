//
//  TRPlayerInfosCell.m
//  tuxracer
//
//  Created by emmanuel de Roux on 25/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRPlayerInfosCell.h"


@implementation TRPlayerInfosCell

// we need to synthesize the labels

@synthesize titleLabel, playerScoreLabel, iPhoneScoreLabel, iPhoneComparaisonLabel, playerRankingLabel, iPhoneRankingLabel, playerNameLabel, youLabel, playerHeaderLabel, scoreHeaderLabel, differenceHeaderLabel,rankingHeaderLabel,warning, mode=_mode;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        
		// we need a view to place our labels on.
		UIView *myContentView = self.contentView;
        
		self.titleLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:14.0 bold:YES];
		self.titleLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.titleLabel];
		[self.titleLabel release];
        
        self.playerScoreLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:NO];
		self.playerScoreLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.playerScoreLabel];
		[self.playerScoreLabel release];
        
        self.iPhoneScoreLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:NO];
		self.iPhoneScoreLabel.textAlignment = UITextAlignmentLeft; // default
		self.iPhoneScoreLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
		[myContentView addSubview:self.iPhoneScoreLabel];
		[self.iPhoneScoreLabel release];
		
		self.iPhoneComparaisonLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:NO];
		self.iPhoneComparaisonLabel.textAlignment = UITextAlignmentLeft; // default
		self.iPhoneComparaisonLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
		[myContentView addSubview:self.iPhoneComparaisonLabel];
		[self.iPhoneComparaisonLabel release];
        
        self.playerRankingLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:NO];
		self.playerRankingLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.playerRankingLabel];
		[self.playerRankingLabel release];
		
		self.iPhoneRankingLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:NO];
		self.iPhoneRankingLabel.textAlignment = UITextAlignmentLeft; // default
		self.iPhoneRankingLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
		[myContentView addSubview:self.iPhoneRankingLabel];
		[self.iPhoneRankingLabel release];
		
		self.playerNameLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:NO];
		self.playerNameLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.playerNameLabel];
		[self.playerNameLabel release];
		
		self.youLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:NO];
		self.youLabel.textAlignment = UITextAlignmentLeft; // default
		self.youLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
		[myContentView addSubview:self.youLabel];
		[self.youLabel release];
		
		/*Create headers */
		self.playerHeaderLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:YES];
		self.playerHeaderLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.playerHeaderLabel];
		[self.playerHeaderLabel release];
		
		self.scoreHeaderLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:YES];
		self.scoreHeaderLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.scoreHeaderLabel];
		[self.scoreHeaderLabel release];
		
		self.differenceHeaderLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:YES];
		self.differenceHeaderLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.differenceHeaderLabel];
		[self.differenceHeaderLabel release];
		
		self.rankingHeaderLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:YES];
		self.rankingHeaderLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.rankingHeaderLabel];
		[self.rankingHeaderLabel release];
		
		/* create the warning image under a "No Score" line */
		self.warning = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
		[myContentView addSubview:self.warning];
		[self.warning release];
	}
    
	return self;
}

- (void)dealloc {
	// make sure you free the memory
	self.mode = nil;
    self.titleLabel = nil;
    self.playerScoreLabel = nil;
    self.iPhoneScoreLabel = nil;
	self.iPhoneComparaisonLabel = nil;
    self.playerRankingLabel = nil;
    self.iPhoneRankingLabel = nil;
    self.playerNameLabel = nil;
    self.youLabel = nil;
	self.playerHeaderLabel=nil;
	self.scoreHeaderLabel=nil;
	self.differenceHeaderLabel=nil;
	self.rankingHeaderLabel=nil;
	
	[super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
	[super setSelected:selected animated:animated];
    
	// Configure the view for the selected state
}

-(void)setData:(NSArray *)data {
    if([data count] < 7) return;
	/* set the title of the race and the header Labels values */
	self.titleLabel.text = [data objectAtIndex:0];
	self.playerHeaderLabel.text=NSLocalizedString(@"Player",@"Classes/TRPlayerInfosCell.m");
	self.differenceHeaderLabel.text=NSLocalizedString(@"Difference",@"Classes/TRPlayerInfosCell.m");
	self.rankingHeaderLabel.text=NSLocalizedString(@"Ranking",@"Classes/TRPlayerInfosCell.m");
	self.scoreHeaderLabel.text=@"Score";
	/* Set the values */
	self.playerNameLabel.text = [NSString stringWithFormat:@"%@: ",[data objectAtIndex:1]];
	self.mode = [data objectAtIndex:2];
	NSString* pts = ([self.mode isEqualToString:@"classic"] && ![[data objectAtIndex:6] isEqualToString:@""])?@" pts":@"";
	self.playerScoreLabel.text = [NSString stringWithFormat:@"%@%@",[data objectAtIndex:3],pts];
    self.iPhoneScoreLabel.text = [NSString stringWithFormat:@"%@%@",[data objectAtIndex:4],pts];
    self.playerRankingLabel.text = [NSString stringWithFormat:@"%@",[data objectAtIndex:5]];
	self.iPhoneRankingLabel.text = [NSString stringWithFormat:([[data objectAtIndex:6] isEqualToString:@""])?@"":@"%@",[data objectAtIndex:6]];
    self.youLabel.text = NSLocalizedString(@"You: ",@"Classes/TRPlayerInfosCell.m");
	self.warning.hidden=true;
	
	/* On traite d'abord le cas speed only */
	
	if ([self.mode isEqualToString:@"speed only"]) {
		/*Si le iPhone a fait un score, je regarde si son score est meilleur ou moins bon */
		if (![[data objectAtIndex:6] isEqualToString:@""]) {
			NSArray* donneesIphone = [[data objectAtIndex:4]componentsSeparatedByString:@":"];
			NSArray* donneesPlayer = [[data objectAtIndex:3] componentsSeparatedByString:@":"];
			
			/* converti le temps mm:ss:cc en centieles de secondes */
			int centsIphone = [[donneesIphone objectAtIndex:0] intValue]*60*100+[[donneesIphone objectAtIndex:1] intValue]*100+ [[donneesIphone objectAtIndex:2] intValue];
			int centsPlayer = [[donneesPlayer objectAtIndex:0] intValue]*60*100+[[donneesPlayer objectAtIndex:1] intValue]*100+ [[donneesPlayer objectAtIndex:2] intValue];
			
			/* fait la différence */
			UIColor* couleur;
			NSString* signe=@"";
			int difference = centsIphone-centsPlayer;
			if (difference > 0) {
				couleur = [UIColor redColor]; 
				signe = @"+";
			}else if (difference < 0) {
				couleur = [UIColor greenColor];
				signe = @"-";
			}
			
			/* met les couleurs */
			self.iPhoneScoreLabel.textColor=couleur;
			self.iPhoneComparaisonLabel.textColor=couleur;
			self.iPhoneRankingLabel.textColor=couleur;
			
			/* reconverti la difference en mm:ss:cc */
			difference = abs(difference);
			int cents = difference%100;
			int seconds = (difference-cents)/100%60;
			int minutes = ((difference - cents)/100 - seconds)/60;
			NSString* differenceString = [NSString stringWithFormat:@"%@%02d:%02d:%02d",signe,minutes,seconds,cents];
			self.iPhoneComparaisonLabel.text=differenceString;
			
			/* edit header : */
			self.scoreHeaderLabel.text=NSLocalizedString(@"Time",@"Classes/TRPlayerInfosCell.m");
		} 
			//Cas not Ranked
		else {
			iPhoneComparaisonLabel.text = @"";
			warning.hidden=false;
			self.iPhoneScoreLabel.textColor=[UIColor redColor];
		}
	} 
	/* Puis on traite le cas classic */
	else {
		/*Si le iPhone a fait un score, je regarde si son score est meilleur ou moins bon */
		if (![[data objectAtIndex:6] isEqualToString:@""]) {
			int scoreIphone = [[data objectAtIndex:4] intValue];
			int scorePlayer = [[data objectAtIndex:3] intValue];
			
			/* fait la différence */
			UIColor* couleur = [UIColor blackColor];
			NSString* signe=@"";
			int difference = scoreIphone-scorePlayer;
			if (difference > 0) {
				couleur = [UIColor greenColor]; 
				signe = @"+";
			}else if (difference < 0) {
				couleur = [UIColor redColor];
				signe = @"-";
			}
			difference=abs(difference);
			
			/* met les couleurs */
			self.iPhoneScoreLabel.textColor=couleur;
			self.iPhoneComparaisonLabel.textColor=couleur;
			self.iPhoneRankingLabel.textColor=couleur;
			
			/* affiche la difference en couleur */
			NSString* differenceString = [NSString stringWithFormat:@"%@%d pts",signe,difference];
			self.iPhoneComparaisonLabel.text=differenceString;
			
		} else {
			iPhoneComparaisonLabel.text = @"";
			warning.hidden=false;
			self.iPhoneScoreLabel.textColor=[UIColor redColor];
		}
	}
		 
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
   // getting the cell size
	CGRect contentRect = self.contentView.bounds;
    
	// In this example we will never be editing, but this illustrates the appropriate pattern
    // get the X pixel spot
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;
    
    frame = CGRectMake(boundsX + 10, 4, 270, 20);
    self.titleLabel.frame = frame;
	
	
    
	// place the playerName Label
    frame = CGRectMake(boundsX + 10, 24, 100, 14);
    self.playerHeaderLabel.frame = frame;
	
    // place the playerScoreLabel
    frame = CGRectMake(boundsX + 110, 24, 110, 14);
    self.scoreHeaderLabel.frame = frame;
	
	// place the differenceHeaderLabel
    frame = CGRectMake(boundsX + 170, 24, 50, 14);
    self.differenceHeaderLabel.frame = frame;
    
    // place playerRankingLabel
    frame = CGRectMake(boundsX + 250, 24, 60, 14);
    self.rankingHeaderLabel.frame = frame;
	
	/* Place the values Labels */
	
    // place the playerName Label
    frame = CGRectMake(boundsX + 10, 38, 100, 14);
    self.playerNameLabel.frame = frame;
	
	// place the You Label'
    frame = CGRectMake(boundsX + 10, 54, 100, 14);
    self.youLabel.frame = frame;
	
    // place the playerScoreLabel
    frame = CGRectMake(boundsX + 110, 38, 110, 14);
    self.playerScoreLabel.frame = frame;
	
	// place the iPhoneScoreLabel
    frame = CGRectMake(boundsX + 110, 54, 80, 14);
    self.iPhoneScoreLabel.frame = frame;
	
	// place the iPhoneComparaisonLabel
    frame = CGRectMake(boundsX + 170, 54, 50, 14);
    self.iPhoneComparaisonLabel.frame = frame;
    
    // place playerRankingLabel
    frame = CGRectMake(boundsX + 250, 38, 60, 14);
    self.playerRankingLabel.frame = frame;
    
    // place iPhoneRankingLabel
    frame = CGRectMake(boundsX + 250, 54, 60, 14);
    self.iPhoneRankingLabel.frame = frame;
	
	//place the warning image
	frame = CGRectMake(boundsX + 110-12-5, 55, 12, 12);
    self.warning.frame = frame;
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

@end
