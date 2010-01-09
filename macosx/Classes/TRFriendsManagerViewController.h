//
//  TRFriendsManagerViewController.h
//  tuxracer
//
//  Created by emmanuel de Roux on 06/12/08.
//  Copyright 2008 école Centrale de Lyon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRPrefsViewController.h"
#import "myHTTPErrors.h"

@interface TRFriendsManagerViewController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate> {
    IBOutlet UITableView* friendsTableView;
    IBOutlet UITableViewCell* insertCell;
    IBOutlet UITextField* insertTextField;
    
    NSMutableArray* _friendsList;
    NSString* _loginBeingAdded;
    
    id _backTarget;
    SEL _backSelector;
}
+ (TRFriendsManagerViewController *) sharedFriendsManagerViewController;

- (void)addFriend:(NSString*)login;
- (BOOL) isAlreadyFriendOrYourself:(NSString*)friend;

- (BOOL)textFieldShouldEndEditing:(UITextField *)theTextField;
@end
