//
//  TRFriendsManagerViewController.m
//  tuxracer
//
//  Created by emmanuel de Roux on 06/12/08.
//  Copyright 2008 école Centrale de Lyon. All rights reserved.
//

#import "TRFriendsManagerViewController.h"
#import "ConnectionController.h"

static TRFriendsManagerViewController *sharedFriendsManagerViewController = nil;

@implementation TRFriendsManagerViewController

+ (TRFriendsManagerViewController *)sharedFriendsManagerViewController
{
    if(!sharedFriendsManagerViewController)
        sharedFriendsManagerViewController = [[[self alloc] init] autorelease];
    return sharedFriendsManagerViewController;
}

- (id) init
{
    self = [super initWithNibName:@"FriendsManagerView" bundle:nil];
    if (self != nil) {
        _friendsList = [[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"friendsList"]] retain];
        self.title = NSLocalizedString(@"Manage Friends",@"Classes/TRFriendsManagerViewController.m");
		sharedFriendsManagerViewController = self;
    }
    return self;
}

- (void) dealloc
{
	sharedFriendsManagerViewController = nil;
    [_loginBeingAdded release];
    [_friendsList release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.editing = YES;
    insertTextField.delegate = self;
    [self setEditing:YES animated:NO];
}


#pragma mark tableView delegate

- (void)setEditing:(BOOL)edit animated:(BOOL)animated
{
    //Go into edit mode
    if (edit) {
        //[editButton setTitle:NSLocalizedString(@"Cancel",@"Classes/TRFriendsManagerViewController.m")];
        
        //cas vide
        [insertTextField resignFirstResponder];
        [friendsTableView setEditing:TRUE animated:animated];
        [friendsTableView reloadData];
    }
    else {
        [friendsTableView setEditing:FALSE animated:animated];
        [friendsTableView reloadData];
    }
    
    [super setEditing:edit animated:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_friendsList count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            [_friendsList removeObjectAtIndex:indexPath.row];
            [[NSUserDefaults standardUserDefaults] setObject:_friendsList forKey:@"friendsList"];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
            break;
        case UITableViewCellEditingStyleInsert:
            break;
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellSeparatorStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [insertTextField resignFirstResponder];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"cellID"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    cell.text = [_friendsList objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark Friends Manager Functions

-(void)treatData:(NSString*)data {
    int error = [data intValue];
    if (error == LOGIN_EXISTS) {
        [_friendsList insertObject:_loginBeingAdded atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:_friendsList forKey:@"friendsList"];
        [insertTextField setText:@""];
        [friendsTableView reloadData];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error !",@"Classes/TRPrefsViewController.m") message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert setMessage:[ConnectionController messageForServerReturnValue:error]];
        [alert show];
        [alert release];
        [insertTextField setText:_loginBeingAdded];
    }
}

- (void)addFriend:(NSString*)login {
    if (![login isEqualToString:@""] && ![self isAlreadyFriendOrYourself:login]) {
        if(!_loginBeingAdded) [_loginBeingAdded release];
        _loginBeingAdded=[login retain];
        [insertTextField setText:_loginBeingAdded];
        ConnectionController* conn = [[[ConnectionController alloc] init] autorelease];
        NSString* queryString = [NSString stringWithFormat:@"login=%@",login];
        [conn postRequest:queryString atURL:[tuxRiderRootServer stringByAppendingString:@"checkLogin.php"] withWaitMessage:NSLocalizedString(@"Checking login...",@"Classes/TRFriendsManagerViewController.m") sendResponseTo:self withMethod:@selector(treatData:)];        
    } 
    else 
    {
        [insertTextField setText:@""];
    }
}

- (BOOL) isAlreadyFriendOrYourself:(NSString*)friend {
    for (NSString* name in _friendsList) {
        if ([name isEqualToString:friend]) 
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error !",@"Classes/TRFriendsManagerViewController.m") message:[NSString stringWithFormat:@"%@ %@",friend,NSLocalizedString(@"is already in your friends list.",@"Classes/TRFriendsManagerViewController.m")] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return YES;
        }
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([friend isEqualToString:[prefs objectForKey:@"username"]]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error !",@"Classes/TRFriendsManagerViewController.m") message:NSLocalizedString(@"You cannot be friend with yourself.",@"Classes/TRFriendsManagerViewController.m") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok",@"Classes/TRFriendsManagerViewController.m") otherButtonTitles:nil];
        [alert show];
        [alert release];
        return YES;
    }
    return NO;
}

#pragma mark TextField delegate function
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    [self addFriend:[textField text]];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
