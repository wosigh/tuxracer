//
//  TRPrizeViewController.m
//  tuxracer
//
//  Created by emmanuel de Roux on 30/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRPrizeViewController.h"

static id sharedPrizeViewController=nil;

@implementation TRPrizeViewController


// The designated initializer. Override to perform setup that is required before the view is loaded.

+ (id)sharedPrizeViewController:(NSString*) prizeNameOrNil {
 	if(!sharedPrizeViewController)
		sharedPrizeViewController = [[[self alloc] initWithPrize:prizeNameOrNil] autorelease];
	return sharedPrizeViewController;
}

- (id)initWithPrize:(NSString*)prize {
    if (self = [super initWithNibName:@"PrizeView" bundle:nil]) {
		
		sharedPrizeViewController=self;
		
		self.title=prize;
		_prize=prize;

		NSArray* H112 = [NSArray arrayWithObjects:NSLocalizedString(@"Flex remains stiff underfoot but softer at tip and tail for both stability and agility. The tips are longer in order to provide even greater flotation.\r\nThis is the Zag of strong skiers and hard sessions.",@"Views/TRPrizeViewController.m"),NSLocalizedString(@"$1049",@"Views/TRPrizeViewController.m"),@"H112.png",@"Zag",@"123",nil];
		NSArray* Slap = [NSArray arrayWithObjects:NSLocalizedString(@"Slightly directional in shape to maximise all-round performance, it’s just as at ease in backcountry freestyle sessions as in cool freeriding through the trees.\r\nThe perfect tool for skiers interested in everything except the piste...",@"Views/TRPrizeViewController.m"),NSLocalizedString(@"$900",@"Views/TRPrizeViewController.m"),@"Slap.png",@"Zag",@"123",nil];
		NSArray* Mutant = [NSArray arrayWithObjects:NSLocalizedString(@"Freestylers finds their weapon of predilection with the MUTANT.\r\nIdeal for the rail and big jumpshere remains nevertheless a great polyvalent ski which is comfortable on all types of snows and even during extemporized pow sessions.",@"Views/TRPrizeViewController.m"),NSLocalizedString(@"$600",@"Views/TRPrizeViewController.m"),@"Mutant.png",@"Zag",@"123",nil];
		NSArray* Purist = [NSArray arrayWithObjects:NSLocalizedString(@"Represents a marriage made in heaven between a piste ski and a freeride ski.\r\nThe generous sidecut will delight skiers and telemarkers of all abilities on the hard snow and its freeride dimensions and long tip will ensure excellent allround freeride performance.",@"Views/TRPrizeViewController.m"),NSLocalizedString(@"$850",@"Views/TRPrizeViewController.m"),@"Purist.png",@"Zag",@"123",nil];
		NSArray* Lacrimossa = [NSArray arrayWithObjects:NSLocalizedString(@"Boards new roots from the newest french brand that shapes freestyle/powder boards.\r\nThe board offered is the \"SPOTS\" that you can see on Furlan Snowboard website, This board is the same but the graphics are from the future collection.",@"Views/TRPrizeViewController.m"),NSLocalizedString(@"$800",@"Views/TRPrizeViewController.m"),@"Lacrimossa.png",@"Furlan",@"123",nil];;
		NSArray* Puppy_tiger = [NSArray arrayWithObjects:NSLocalizedString(@"Boards new roots from the newest french brand that shapes freestyle/powder boards.\r\nThe board offered is the \"DJE MADONE\" that you can see on Furlan Snowboard website, This board is the same but the graphics are from the future collection.",@"Views/TRPrizeViewController.m"),NSLocalizedString(@"$800",@"Views/TRPrizeViewController.m"),@"PuppyTiger.png",@"Furlan",@"123",nil];
		NSArray* Around_noir = [NSArray arrayWithObjects:NSLocalizedString(@"With its large spherical screen, the \"Around\" have the largest angle of vision ever. With their anatomic polishement and our full confort moss, those googles garantee fun and off-road confort.",@"Views/TRPrizeViewController.m"),NSLocalizedString(@"$130",@"Views/TRPrizeViewController.m"),@"AroundNoir.png",@"Julbo",@"456",nil];
		NSArray* Cartel = [NSArray arrayWithObjects:NSLocalizedString(@"A fun product designed for the snow sports!\r\nGlasses type: spectron x4\r\nComposition: injected",@"Views/TRPrizeViewController.m"),NSLocalizedString(@"$115",@"Views/TRPrizeViewController.m"),@"Cartel.png",@"Julbo",@"78",nil];
		NSArray* TShirt = [NSArray arrayWithObjects:NSLocalizedString(@"T-shirt designed by Zag Skis.",@"Views/TRPrizeViewController.m"),@"N.C.",@"T-Shirt.png",@"Zag",@"910",nil];
		
		_sponsors = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSArray arrayWithObjects:@"http://www.zagskis.com/",@"logo-zag.png",nil],[NSArray arrayWithObjects:@"http://www.furlansnowboard.com/",@"LOGO-furlan.png",nil],[NSArray arrayWithObjects:@"http://www.julbo-eyewear.com/",@"julbo+DJI-noir6.png",nil],nil] forKeys:[NSArray arrayWithObjects:@"Zag",@"Furlan",@"Julbo",nil]];
		_rankingsNeeded = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:NSLocalizedString(@"For the 1st, the 2nd or the 3rd",@"Views/TRPrizeViewController.m"),NSLocalizedString(@"For the 4th, the 5th and the 6th",@"Views/TRPrizeViewController.m"),NSLocalizedString(@"For the 7th and the 8th",@"Views/TRPrizeViewController.m"),NSLocalizedString(@"For the 9th and the 10th",@"Views/TRPrizeViewController.m"),nil] forKeys:[NSArray arrayWithObjects:@"123",@"456",@"78",@"910",nil]];
		
		_prizesNames = [[NSArray alloc] initWithObjects:@"H112",@"Slap",@"Mutant",@"Purist",@"Lacrimossa",@"Puppy Tiger",@"Around noir",@"Cartel",@"T-Shirt",nil];
		_prizesDescriptionAndPicture = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:H112,Slap,Mutant,Purist,Lacrimossa,Puppy_tiger,Around_noir,Cartel,TShirt,nil] forKeys:_prizesNames];
    }
    return self;
}

- (void)dealloc {
	sharedPrizeViewController=nil;
	[_rankingsNeeded release];
	[_prize release];
	[_sponsors release];
	[_prizesNames release];
	[_prizesDescriptionAndPicture release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self presentPrize:_prize];
}

- (IBAction)get123infos:(id)sender{
	NSString* msgTimeTrial=NSLocalizedString(@"The first one chooses among the \"H112\", the \"Mutant\" and the \"Lacrimossa\", the second one picks up one of the two remainings, and the third one wins the last one.",@"Views/TRPrizeViewController.m");
	NSString* msgClassic=NSLocalizedString(@"The first one chooses among the \"Slap\", the \"Purist\" and the \"Puppy Tiger\", the second one picks up one of the two remainings, and the third one wins the last one.",@"Views/TRPrizeViewController.m");
	NSString* msg;
	if ([[NSArray arrayWithObjects:@"H112",@"Mutant",@"Lacrimossa",nil] containsObject:_prize]) msg = msgTimeTrial; else msg = msgClassic;
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Info" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (UIImage*) imageForPrize:(NSString*)prizeName {
	return [UIImage imageNamed:[[_prizesDescriptionAndPicture objectForKey:prizeName] objectAtIndex:2]];
}

- (void)presentPrize:(NSString*)prizeName{
	if (![[[_prizesDescriptionAndPicture objectForKey:prizeName] objectAtIndex:4] isEqualToString:@"123"]) infoButton.hidden=true;
	description.text = [[_prizesDescriptionAndPicture objectForKey:prizeName] objectAtIndex:0];
	printf("%s\n",[[[_prizesDescriptionAndPicture objectForKey:prizeName] objectAtIndex:0] UTF8String]);
	price.text = [[_prizesDescriptionAndPicture objectForKey:prizeName] objectAtIndex:1];
	NSString* sponsorName=[[_prizesDescriptionAndPicture objectForKey:prizeName] objectAtIndex:3];
	website.text = [[_sponsors objectForKey:sponsorName] objectAtIndex:0];
	needed.text = [_rankingsNeeded objectForKey:[[_prizesDescriptionAndPicture objectForKey:prizeName] objectAtIndex:4]];
	prizeImage.image = [UIImage imageNamed:[[_prizesDescriptionAndPicture objectForKey:prizeName] objectAtIndex:2]];
	sponsorImage.image = [UIImage imageNamed:[[_sponsors objectForKey:sponsorName] objectAtIndex:1]];
}

- (IBAction)visitWebSite:(id)sender {
	NSString* sponsorName=[[_prizesDescriptionAndPicture objectForKey:_prize] objectAtIndex:3];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[_sponsors objectForKey:sponsorName] objectAtIndex:0]]];
}

@end
