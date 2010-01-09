//
//  TRScoresManager.h
//  tuxracer
//
//  Created by emmanuel de Roux on 23/03/09.
//  Copyright 2009 école Centrale de Lyon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TRFacebookController.h"

@interface TRScoresManager : NSObject {
	NSArray* _currentRankings;
	NSArray* _currentPercentage;
	TRFacebookController* _fb;
}
+ (id)sharedScoresManager;
- (void) saveScoreOnlineAfterRace:(int)score onPiste:(NSString*)piste herring:(int)herring time:(char*)time;
- (void) syncScores;
- (void) dirtyScores;
- (void) displayRankingsAfterRace:(int)score onPiste:(NSString*)piste herring:(int)herring time:(char*)time;
@end
