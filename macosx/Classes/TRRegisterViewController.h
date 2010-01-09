//
//  TRRegisterViewController.h
//  tuxracer
//
//  Created by Pierre d'Herbemont on 3/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRErrorsManager.h"

@interface TRRegisterViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>{
	
	//main view
	IBOutlet UIScrollView* scrollView;
	IBOutlet UIView* contentView;
	
	//register view
	IBOutlet UILabel* loginTextLabel;
	IBOutlet UIButton* loginTextButton;
	IBOutlet UIImageView* warningImg;
	IBOutlet UILabel* infoLabel;
	IBOutlet UIButton* infoButton;
    IBOutlet UITextField* RegLogin;
    IBOutlet UITextField* RegMdp1;
    IBOutlet UITextField* RegMdp2;
    IBOutlet UIButton* RegPays;
    IBOutlet UIView* registerView;
	IBOutlet UISwitch* fbSwitch;
	IBOutlet UILabel* fbLabel;
	IBOutlet UITextView* fbTextView;
    NSString *_country;
	TRErrorsManager* _errorManager;
	
	//login popup
	IBOutlet UIView* loginView;
	IBOutlet UIView* disableView;
	IBOutlet UITextField* login;
	IBOutlet UITextField* mdp;
	IBOutlet UISwitch* saveScoresRaceSwitch;
}

+ (TRRegisterViewController *)sharedRegisterViewController;

//Register View
- (int)firstVerifForm;
- (void) treatError:(NSString*)erreur;
- (void) setCountry:(NSString*)country;

- (IBAction)registerClick:(id)sender;
- (void)suscribe;
- (IBAction)listCountriesTransition:(id)sender;

- (IBAction)whyRegister:(id)sender;

//function usefull only in suscribtion context
- (IBAction)toggleLoginSubview:(id)sender;
- (IBAction)testLogin:(id)sender;
- (BOOL)isInLoginView;
- (NSString*)login;
- (NSString*)mdp;
- (void)finishSuscribtion;

@end
