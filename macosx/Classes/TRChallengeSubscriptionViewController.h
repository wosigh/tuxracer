//
//  TRChallengeSubscriptionViewController.h
//  tuxracer
//
//  Created by Pierre d'Herbemont on 3/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRErrorsManager.h"


@interface TRChallengeSubscriptionViewController : UIViewController {
	IBOutlet UIView* loginView;
	IBOutlet UIView* disableView;
	IBOutlet UITextField* login;
	IBOutlet UITextField* mdp;
	IBOutlet UIButton* registerButton;
	IBOutlet UIButton* continueButton;
	TRErrorsManager* _errorManager;
}

+ (TRChallengeSubscriptionViewController *)sharedSubscriptionViewController;
- (id)initForContinue;
- (IBAction)displayPrizes:(id)sender;
- (IBAction)continue:(id)sender;
- (IBAction)showRegisterView:(id)sender;
- (IBAction)toggleLoginSubview:(id)sender;
- (IBAction)testLogin:(id)sender;
- (IBAction)finishSuscribtion:(id)sender;

/* appelées par l'exterieur */
- (NSString*)login;
- (NSString*)mdp;
- (BOOL)isInLoginView;
@end
