//
//  TRPrizeViewController.h
//  tuxracer
//
//  Created by emmanuel de Roux on 30/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TRPrizeViewController : UIViewController {
	NSDictionary* _prizesDescriptionAndPicture;
	NSArray* _prizesNames;
	NSDictionary* _sponsors;
	NSString* _prize;
	NSDictionary* _rankingsNeeded;
	
	IBOutlet UIImageView* prizeImage;
	IBOutlet UIImageView* sponsorImage;
	IBOutlet UITextView* description;
	IBOutlet UILabel* price;
	IBOutlet UILabel* website;
	IBOutlet UILabel* needed;
	IBOutlet UIButton* infoButton;
	
}
- (id)initWithPrize:(NSString*)prize;
- (IBAction)get123infos:(id)sender;
- (void)presentPrize:(NSString*)presentPrize;
- (UIImage*) imageForPrize:(NSString*)prizeName;
- (IBAction)visitWebSite:(id)sender;
+ (id)sharedPrizeViewController:(NSString*) prizeNameOrNil;
@end
