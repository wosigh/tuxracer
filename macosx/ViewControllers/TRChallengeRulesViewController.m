//
//  TRChallengeRulesViewController.m
//  tuxracer
//
//  Created by Moi on 27/04/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRChallengeRulesViewController.h"


@implementation TRChallengeRulesViewController

- (id)init {
    if (self = [super initWithNibName:@"ChallengeRulesView" bundle:nil]) {
        self.title=NSLocalizedString(@"Challlenge rules",@"ViewControllers/TRChallengeRulesViewController.m");
		self.hidesBottomBarWhenPushed = TRUE;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}

@end
