//
//  TRGLViewController.h
//  tuxracer
//
//  Created by Pierre d'Herbemont on 3/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"
#import "FBConnect.h"
#import "TRFacebookController.h"

@interface TRGLViewController : UIViewController {
	EAGLView* _glView;
	TRFacebookController* _fb;
	UISwitch* _debugSwitch;
	UIButton* _licenseButton;
}
@property (retain, readonly) EAGLView * glView;
- (void)loadButton;
@end
