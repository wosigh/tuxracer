//
//  TRPickCountryViewController.m
//  tuxracer
//
//  Created by Pierre d'Herbemont on 3/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TRPickCountryViewController.h"
#import "TRAppDelegate.h"
#import "TRRegisterViewController.h"

static id sharedPickCountryViewController = nil;

@implementation TRPickCountryViewController

@synthesize myTableView, mySearchBar, listContent, filteredListContent, savedContent;

+ (id)sharedPickCountryViewController
{
    if(!sharedPickCountryViewController)
        sharedPickCountryViewController = [[[self alloc] init] autorelease];
    return sharedPickCountryViewController;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)init {
    if (self = [super initWithNibName:@"PickCountryView" bundle:nil]) {
        // Custom initialization
        self.title = NSLocalizedString(@"Choose a country...",@"Classes/TRPickCountryViewController.m");
		sharedPickCountryViewController=self;
    }
    return self;
}

- (void)dealloc {
	sharedPickCountryViewController = nil;
    [myTableView release];
    [mySearchBar release];
    
    [listContent release];
    [filteredListContent release];
    [savedContent release];
	
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    // create the master list
    NSString* allCountries = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"countries.txt"] encoding:NSUTF8StringEncoding error:NULL];
    listContent = [[[allCountries componentsSeparatedByString:@"|||"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] retain];
    
    // create our filtered list that will be the data source of our table, start its content from the master "listContent"
    filteredListContent = [[NSMutableArray alloc] initWithCapacity: [listContent count]];
    [filteredListContent addObjectsFromArray: listContent];
    
    // this stored the current list in case the user cancels the filtering
    savedContent = [[NSMutableArray alloc] initWithCapacity: [listContent count]]; 
    
    // don't get in the way of user typing
    mySearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    mySearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    mySearchBar.showsCancelButton = NO;    
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark UITableViewDataSource
//friends table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filteredListContent count];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"cellID"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    cell.text = [filteredListContent objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // only show the status bar's cancel button while in edit mode
    mySearchBar.showsCancelButton = YES;
    
    // flush and save the current list content in case the user cancels the search later
    [savedContent removeAllObjects];
    [savedContent addObjectsFromArray: filteredListContent];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    mySearchBar.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [filteredListContent removeAllObjects];	// clear the filtered array first
    
    // search the table content for cell titles that match "searchText"
    // if found add to the mutable array and force the table to reload
    //
    NSString *cellTitle;
    for (cellTitle in listContent)
    {
        NSComparisonResult result = [cellTitle compare:searchText options:NSCaseInsensitiveSearch
                                                 range:NSMakeRange(0, [searchText length])];
        if (result == NSOrderedSame)
        {
            [filteredListContent addObject:cellTitle];
        }
    }
    
    [myTableView reloadData];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // if a valid search was entered but the user wanted to cancel, bring back the saved list content
    if (searchBar.text.length > 0)
    {
        [filteredListContent removeAllObjects];
        [filteredListContent addObjectsFromArray: savedContent];
    }
    
    [myTableView reloadData];
    
    [searchBar resignFirstResponder];
    searchBar.text = @"";
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * selectedCountry = [[tableView cellForRowAtIndexPath:indexPath] text];
    TRDebugLog("%s selected !\n",[selectedCountry UTF8String]);
    [[NSUserDefaults standardUserDefaults] setValue:selectedCountry forKey:@"pays"];
	[[TRRegisterViewController sharedRegisterViewController] setCountry:selectedCountry];
    [self.navigationController popViewControllerAnimated:YES];
}



@end
