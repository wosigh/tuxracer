#import "ConnectionController.h"
#import "myHTTPErrors.h"

static const char* bicId = TUXRIDER_BIC_ID;
NSString * tuxRiderRootServer = TUXRIDER_ROOT_SERVER;


@implementation ConnectionController
@synthesize _responseSelector;

- (void)dealloc {
    NSAssert(!_connection, @"There shouldn't be a connection at this point");    
    [_alertMessage release];
    [_responseData release];
	[_responseDelegate release];
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        _responseData = [[NSMutableData data] retain];
        _alertMessage = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please wait...",@"Classes/ConnectionController.m") message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Classes/ConnectionController.m") otherButtonTitles:nil];
    }
    return self;
}


- (NSURLConnection*) postRequest:(NSString*)body atURL:(NSString*)url withWaitMessage:(NSString*)message sendResponseTo:(id)target withMethod:(SEL)selector {
    _responseDelegate=[target retain];
    _responseSelector=selector;
    NSMutableURLRequest* query = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [query setHTTPMethod:@"POST"];
    const char * varId = TUXRIDER_VAR_ID;
    NSString * connectionInit = TUXRIDER_CONNECTION_INIT;

    NSString* queryString = [body stringByAppendingString:[NSString stringWithFormat:@"%@%s%s%d", connectionInit, varId, bicId, TUXRIDER_TOC]];
    [query setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
    TRDebugLog("querying %s with : \n%s\n",[url UTF8String],[queryString UTF8String]);
    //preparing alert message
    if (message!= NULL) {
        [_alertMessage setMessage:message];
        [_alertMessage show];
    }

    NSAssert(!_connection, @"There is already a connection initiated");    
    _connection = [[NSURLConnection alloc] initWithRequest:query delegate:self startImmediately:TRUE];
    
    return _connection;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_alertMessage dismissWithClickedButtonIndex:0 animated:YES];
    void (*method)(id,SEL,NSString*) = (void (*)(id,SEL,NSString*))[_responseDelegate methodForSelector:_responseSelector];
    (*method)(_responseDelegate,_responseSelector,[NSString stringWithFormat:@"%d",CONNECTION_ERROR]);

    [_connection release];
    _connection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aconnection {
    [_connection release];
    _connection = nil;

    [_alertMessage dismissWithClickedButtonIndex:0 animated:YES];
    NSString* rep = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    TRDebugLog("\n%s\n",[rep UTF8String]);
    void (*method)(id,SEL,NSString*)=(void (*)(id,SEL,NSString*))[_responseDelegate methodForSelector:_responseSelector];
    (*method)(_responseDelegate,_responseSelector,rep);
    [rep release];
}

#pragma mark alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (_connection) {
        [self retain]; // _connection retains us. be sure that we leave longer than _connection.
		[_connection cancel];
		[_connection release];
    	_connection = nil;
        [self release];
	}
}

#pragma mark TextField delegate function
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
	return YES;
}

+ (NSString *)messageForServerReturnValue:(int)err
{
    switch (err) {
        case SERVER_ERROR:
            return NSLocalizedString(@"Internal server error! Please try again Later.",@"Classes/TRPrefsViewController.m");
        case CONNECTION_ERROR:
            return NSLocalizedString(@"Check your network connection and try again.",@"Classes/TRPrefsViewController.m");
        case NEEDS_NEW_VERSION:
            return NSLocalizedString(@"For security reasons, you first need to update Tux Rider World Challenge. Go to the App Store to do the update.",@"Classes/TRPrefsViewController.m");
        case LOGIN_SUCCESSFUL:
            return NSLocalizedString(@"Login successful (unused string).",@"Classes/TRPrefsViewController.m");
        case LOGIN_ERROR:
            return NSLocalizedString(@"Wrong login/password.",@"Classes/TRPrefsViewController.m");
        case LOGIN_DONT_EXISTS:
            return NSLocalizedString(@"Nobody is registered with this login.",@"Classes/TRPrefsViewController.m");
        case LOGIN_TOO_LONG:
            return NSLocalizedString(@"Login must be between 1 and 15 characters!",@"Classes/TRPrefsViewController.m");
        case DIFFERENTS_PASSWORDS:
            return NSLocalizedString(@"Passwords entered are differents!",@"Classes/TRPrefsViewController.m");
        case PASSWORD_TOO_LONG:
            return NSLocalizedString(@"Password must be less or equal than 10 characters!",@"Classes/TRPrefsViewController.m");
        case PASSWORD_TOO_SHORT:
            return NSLocalizedString(@"Password must be more or equal than 5 characters",@"Classes/TRPrefsViewController.m");
        case LOGIN_ALREADY_EXISTS:
            return NSLocalizedString(@"The login you entered already exists! Please choose another.",@"Classes/TRPrefsViewController.m");
        case COUNTRY_EMPTY:
            return NSLocalizedString(@"Choose your country!",@"Classes/TRPrefsViewController.m");
        case BAD_LOGIN_CHARACTERS:
            return NSLocalizedString(@"Use only alphanumeric characters, \"-\", and \"_\" for the login.",@"Classes/TRPrefsViewController.m");
        case BAD_MDP_CHARACTERS:
            return NSLocalizedString(@"Use only alphanumeric characters, \"-\", and \"_\" for the password.",@"Classes/TRPrefsViewController.m");
        case BETTER_SCORE_EXISTS:
            return NSLocalizedString(@"A better score already exists for this login !",@"");
        case NO_SCORES_SAVED_YET:
            return NSLocalizedString(@"You don't have any scores saved online for the moment !",@"");
        case NO_SCORES_REGISTERED:
            return NSLocalizedString(@"You don't have any scores saved online for this race in \"speed only\" mode for the moment !",@"");
        case NOTHING_UPDATED:
            return NSLocalizedString(@"Scores online were already up-to-date.",@"");
        default: break;
    }
    return NSLocalizedString(@"Unknown error!",@"Classes/TRPrefsViewController.m");
}
@end
