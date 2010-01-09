//
//  TRChallengeInfosViewController.m
//  tuxracer
//
//  Created by emmanuel de Roux on 24/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRChallengeInfosViewController.h"
#import "TRPrizeListViewController.h"
#import "TRChallengeRulesViewController.h"

@implementation TRChallengeInfosViewController

- (id)init {
    if (self = [super initWithNibName:@"ChallengeInfosView" bundle:nil]) {
        self.title=NSLocalizedString(@"Challenge infos",@"Views/TRChallengeInfosViewController.m");
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

- (IBAction)displayPrizes:(id)sender{
	TRPrizeListViewController* prizesListViewController = [[[TRPrizeListViewController alloc] init] autorelease];
	[self.navigationController pushViewController:prizesListViewController animated:YES];	
}

- (IBAction)readRules:(id)sender{
	TRChallengeRulesViewController* challengeRulesViewController = [[[TRChallengeRulesViewController alloc] init] autorelease];
	[self.navigationController pushViewController:challengeRulesViewController animated:YES];
}
@end
