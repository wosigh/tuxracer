//
//  prefsDelegate.h
//  tuxracer
//
//  Created by emmanuel de Roux on 19/11/08.
//  Copyright 2008 école Centrale de Lyon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransitionView.h"
#import "TRAppDelegate.h"
#import "FBConnect.h"

@interface TRPrefsViewController : UIViewController {
    //prefs View
    IBOutlet UISlider* musicVolume;
    IBOutlet UISlider* soundsVolume;
    IBOutlet UIButton* pays;
    IBOutlet UILabel* login;
	IBOutlet UILabel* registerLabel;
	IBOutlet UILabel* friendsListLabel;
	IBOutlet UILabel* loginLabel;
	
    IBOutlet UISwitch* saveScoresOnline;
    IBOutlet UISwitch* displayRankings;

    IBOutlet UIButton* friendsListButton;
    
    IBOutlet UISegmentedControl * viewMode;

    IBOutlet UIScrollView * scrollView;
    IBOutlet UIView * contentView;
}

+ (id)sharedPrefsViewController;
+ (void)setDefaults;

//prefs View
@property(nonatomic,retain) UISlider* musicVolume;
@property(nonatomic,retain) UISlider* soundsVolume;

//prefs View
- (IBAction)updateVolumePrefs:(id)sender;
- (IBAction)switchSaveScores:(id)sender;
- (IBAction)switchDisplayRankings:(id)sender;
- (IBAction)switchViewMode:(id)sender;

- (void)loadPrefs;

-(NSString*)login;
//-(NSString*)mdp;

- (IBAction)showRegisterView:(id)sender;
- (IBAction)showFriendsManagerView:(id)sender;

@end
