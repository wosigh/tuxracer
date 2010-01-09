//
//  TRPickCountryViewController.h
//  tuxracer
//
//  Created by Pierre d'Herbemont on 3/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TRPickCountryViewController : UIViewController {
    //countries View
    IBOutlet UITableView		*myTableView;
	IBOutlet UISearchBar		*mySearchBar;
	NSArray						*listContent;			// the master content
	NSMutableArray				*filteredListContent;	// the filtered content as a result of the search
	NSMutableArray				*savedContent;			// the saved content in case the user cancels a search    
}

+ (id)sharedPickCountryViewController;

//countries View
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) UISearchBar *mySearchBar;
@property (nonatomic, retain) NSArray *listContent;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, retain) NSMutableArray *savedContent;

@end
