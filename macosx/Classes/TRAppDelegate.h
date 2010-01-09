//
//  TRAppDelegate.h
//  tuxracer
//
//  Created by emmanuel de roux on 22/10/08.
//  Copyright école Centrale de Lyon 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransitionView.h"
#import "winsys.h"
#import "TRAccelerometerDelegate.h"
#import "TRPrefsViewController.h"
#import "TRGLViewController.h"
#import "AudioManager.h"

@class EAGLView;

@interface TRAppDelegate : NSObject <UIApplicationDelegate,UINavigationControllerDelegate> {
    IBOutlet UIWindow *window;
	
	TransitionView* transitionView;
    TRGLViewController *_glViewController;

	NSThread * thread;
	UIView *prefsWindow;
	UIView *registerWindow;
    TRAccelerometerDelegate * accelerometre;
    BOOL _isHighFrameRateMode;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) TRGLViewController *glViewController;

@property (nonatomic, retain) IBOutlet TransitionView* transitionView;
@property (nonatomic, retain) IBOutlet UIView *prefsWindow;
@property (nonatomic, retain) IBOutlet UIView *registerWindow;
@property (nonatomic, retain) TRAccelerometerDelegate * accelerometre;
@property BOOL isHighFrameRateMode;


- (IBAction)toggleRankingsView:(id)sender;

- (IBAction)showLicense:(id)sender;
- (void)openWebSite;
- (void)showPreferences:(id)sender;
- (void)showChallengeSuscribtion;
- (TransitionView*)transitionView;
+ (TRAppDelegate *)sharedAppDelegate;
- (void)getChallengeInfos;
- (void) treatChallengeInfos:(NSString*)data;
- (void)recupCountry;
- (void) treatRecupCountry:(NSString*)data;
- (NSString*)challengeTextInfos;
	
- (void)slideViewControllerIn:(UIViewController *)viewController animated:(BOOL)animated;
- (void)slideViewControllerOut:(UIViewController *)viewController animated:(BOOL)animated;
@end

