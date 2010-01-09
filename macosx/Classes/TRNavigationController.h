//
//  TRNavigationController.h
//  tuxracer
//
//  Created by Pierre d'Herbemont on 3/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum {
	LOADED,
	POP,
	PUSH,
} navActions;

@interface TRNavigationController : UINavigationController {
	UIViewController* _linkToParentViewController;
	navActions lastNavAction;
}
@property (nonatomic,readwrite) navActions lastNavAction;
+ (id)sharedNavigationController;
- (void)backToMainMenu;
- (id)initWithRootViewController:(UIViewController *)rootViewController andParentViewController:(UIViewController*)parentViewController;

@end
