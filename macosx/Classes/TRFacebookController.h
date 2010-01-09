//
//  TRFacebookController.h
//  tuxracer
//
//  Created by emmanuel de Roux on 27/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"


@interface TRFacebookController : NSObject  <FBDialogDelegate, FBSessionDelegate, FBRequestDelegate, UIAlertViewDelegate> {
	FBSession* _session;
	FBLoginButton* _facebookButton;
	NSDictionary* _publishNewHighScoreArgs;
}

+ (id)sharedFaceBookController;
- (FBLoginButton*)resumeSessionAndUpdateButton;
- (void)publishFirstScore:(char*)score surCourse:(char*)course enMode:(char*)mode;
- (void)publishNewHighScore:(const char*)score surCourse:(const char*)course enMode:(const char*)mode etClassementMondial:(int)classementMondial classementNational:(int)classementNational classementTotal:(int)classementTotal;
- (void)hideButton:(BOOL)hide;
- (FBLoginButton*)button;
- (void) doYouWantToConnectToFacebook;
- (BOOL) isConnected;
- (void)showLoginDialog;
	
@end
