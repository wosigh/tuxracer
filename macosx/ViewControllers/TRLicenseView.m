//
//  TRLicenseView.m
//  tuxracer
//
//  Created by Moi on 22/04/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import "TRLicenseView.h"


@implementation TRLicenseView


- (id)init {
    if (self = [super initWithNibName:@"LicenseView" bundle:nil]) {
		self.title=@"License";
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//Loads License Text
	NSString* licensePath = [[[NSBundle mainBundle] pathForResource:@"license" ofType:@"html"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[licenseWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:licensePath]]];
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


- (void)dealloc {
    [super dealloc];
}


@end
