//
//  TRPrizeListViewController.m
//  tuxracer
//
//  Created by emmanuel de Roux on 30/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRPrizeListViewController.h"
#import "TRPrizeViewController.h"


@implementation TRPrizeListViewController


- (id)init {
    if (self = [super initWithNibName:@"PrizeListView" bundle:nil]) {
        self.title=NSLocalizedString(@"To win",@"TRPrizeListViewController.m");
		_timeTrialPrizes = [[NSArray alloc] initWithObjects:@"Zag Skis H112",@"Zag Skis Mutant",@"Furlan Snowboard Lacrimossa",@"Julbo Around noir",@"Julbo Cartel",@"T-shirt Zag Skis",nil];
		_classicPrizes = [[NSArray alloc] initWithObjects:@"Zag Skis Slap",@"Zag Skis Purist",@"Furlan Snowboard Puppy Tiger",@"Julbo Around noir",@"Julbo Cartel",@"T-shirt Zag Skis",nil];
		
		_timeTrialPrizesNames = [[NSArray alloc] initWithObjects:@"H112",@"Mutant",@"Lacrimossa",@"Around noir",@"Cartel",@"T-Shirt",nil];
		_classicPrizesNames = [[NSArray alloc] initWithObjects:@"Slap",@"Purist",@"Puppy Tiger",@"Around noir",@"Cartel",@"T-Shirt",nil];
		_prizesNamesArrays = [[NSArray alloc] initWithObjects:_timeTrialPrizesNames,_classicPrizesNames,nil];
		
	
	}
    return self;
}

- (void)dealloc {
	[_timeTrialPrizes dealloc];
	[_classicPrizes dealloc];
	[_timeTrialPrizesNames dealloc];
	[_classicPrizesNames dealloc];
	[_prizesNamesArrays dealloc];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark dataSource
//Pour la première table view, celle qui affiche toutes les pistes
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return [_timeTrialPrizes count];
			break;
		case 1:
			return [_classicPrizes count];
			break;
		default:
			break;
	}
	return 0;
}

#pragma mark TableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return timeTrialHeader;
            break;
        case 1:
            return classicHeader;
            break;
        default:
            break;
    }
    return NULL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryDisclosureIndicator;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"cellID"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    NSArray* arrayToUse;
	switch (indexPath.section) {
		case 0:
			arrayToUse=_timeTrialPrizes;
			break;
		case 1:
			arrayToUse=_classicPrizes;
			break;
		default:
			break;
	}
	
	/*display a small preview image in front of the name of the prize */
	//comme on réutilise des cellules, si elle contenait déjà une image, on la suprime
	if ([[cell.contentView subviews] count]>0 && [[[cell.contentView subviews] objectAtIndex:0] isKindOfClass:[UIImageView class]]) [[[cell.contentView subviews] objectAtIndex:0] removeFromSuperview];
	CGFloat boxSize=30.0; //taille du carré contenant l'image
	UIImage* previewImage = [[TRPrizeViewController sharedPrizeViewController:@"H112"] imageForPrize:[[_prizesNamesArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
	UIImageView* previewImageView = [[UIImageView alloc] initWithImage:previewImage];
	previewImageView.contentMode=UIViewContentModeScaleAspectFit;
	CGRect cellFrame = cell.contentView.frame;
	previewImageView.frame = CGRectMake(0, cellFrame.size.height/2-boxSize/2.0, boxSize, boxSize);
	[cell.contentView addSubview:previewImageView];
	[previewImageView release];
	cell.indentationWidth=1;//donne le with d'un indentation level. c'est 10 par défaut
	cell.indentationLevel=boxSize;
	[cell setFont:[UIFont systemFontOfSize:15]];
    [cell setText:[arrayToUse objectAtIndex:indexPath.row]];
    [cell setSelected:NO];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TRPrizeViewController* prizeViewController = [[[TRPrizeViewController alloc] initWithPrize:[[_prizesNamesArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]] autorelease];
	[self.navigationController pushViewController:prizeViewController animated:YES];
}


@end
