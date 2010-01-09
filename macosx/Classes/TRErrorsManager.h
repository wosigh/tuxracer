//
//  TRErrorsManager.h
//  tuxracer
//
//  Created by emmanuel de Roux on 24/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TRErrorsManager : NSObject {
}
+ (id)sharedErrorsManager;
-(void) treatError:(NSString*)erreur;
@end
