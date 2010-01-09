//
//  TRGLViewController.m
//  tuxracer
//
//  Created by Pierre d'Herbemont on 3/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TRGLViewController.h"
#import "EAGLView.h"
#import "sharedGeneralFunctions.h"
#import "TRAppDelegate.h"

static TRGLViewController* sharedGLViewController=nil;

void loadFBButton(){
	[sharedGLViewController loadButton];	
}

@implementation TRGLViewController
@synthesize glView=_glView;
- (id)init
{
	_fb = [[TRFacebookController sharedFaceBookController] retain];
	_glView = [[EAGLView sharedView] retain];
	
	//TO DELETE : Debug switch to switch on mode registered or not
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	_licenseButton = [[UIButton buttonWithType:UIButtonTypeInfoLight] retain];
	_licenseButton.center = CGPointMake(290.0, 20.0);
	[_licenseButton addTarget:[TRAppDelegate sharedAppDelegate] action:@selector(showLicense:) forControlEvents:UIControlEventTouchUpInside];
	
	//debug switch button
	CGRect frame = CGRectMake(130, 10, 60, 30);
	_debugSwitch = [[UISwitch alloc] initWithFrame:frame];
	[_debugSwitch setOn:[prefs boolForKey:@"registered"]];
	[_debugSwitch addTarget:self action:@selector(toggleRegister) forControlEvents:UIControlEventValueChanged];
	
    return [self initWithNibName:nil bundle:nil];
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"Menu";
		sharedGLViewController=self;
    }
    return self;
}

- (void)dealloc {
	[_licenseButton release];
	[_debugSwitch release];
	[_glView release];
	[_fb release];
    self.view = nil;
    [super dealloc];
}

//(for debug only)
-(void)toggleRegister{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:[_debugSwitch isOn] forKey:@"registered"];
	[prefs setBool:![_debugSwitch isOn] forKey:@"wasChallengePresented"];
	[_fb publishNewHighScore:"76598pts" surCourse:"Cascade tenebreuse" enMode:"classic" etClassementMondial:6000 classementNational:2570 classementTotal:1];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    self.view = [[EAGLView alloc] init];
	//[self.view addSubview:_debugSwitch];//DEBUG
	[self.view addSubview:_licenseButton];
}

- (void)loadButton {
	[self.view addSubview:[_fb button]];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    EAGLView * glView = self.glView;
	
    //Launch tuxRacer
    [glView setupTuxRacer];
    
    //enable multitouch
    [glView setMultipleTouchEnabled:YES];
    
    //Starts animation
	glView.animationInterval = 1.0 / 60.0;
	
	//Resume faceook session
	[_fb resumeSessionAndUpdateButton];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Don't release that view, too critical
    //[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (EAGLView *)glView
{
    return (EAGLView *)self.view;
}

@end
