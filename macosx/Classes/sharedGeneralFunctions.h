/*
 *  sharedFunctions.h
 *  tuxracer
 *
 *  Created by emmanuel de roux on 06/11/08.
 *  Copyright 2008 école Centrale de Lyon. All rights reserved.
 *
 */

#ifdef __cplusplus
extern "C" {
#endif

    /* implémentées dans TRAppDelegate */
	const char* getRessourcePath(void);
	const char* getConfigPath(void);
    void turnScreenToLandscape(void);
    void turnScreenToPortrait(void);
    void vibration(void);
    void showHowToPlayAtBegining(void);
    void showChallengeSuscribtion(void);
	const char * challengeTextInfos(void);
     
    /* implémentées dans scoresManager */
    void saveScoreOnlineAfterRace(char* raceName,int score,int herring,int minutes,int seconds,int hundredths);
    void displayRankingsAfterRace(char* raceName,int score,int herring,int minutes,int seconds,int hundredths);
    void displayRankings(void);
    void dirtyScores (void);
    
    /* //implémentées dans TRAccelerometterDelegate */
    double accelerometerTurnFact(void);
    
    /* implementée dans TRPrefsViewController */
    bool plyrWantsToSaveOrDisplayRankingsAfterRace();
    bool plyrWantsToDisplayRankingsAfterRace();
    bool isPlayerRegistered(void);
	bool isChallengeOn(void);
	bool wasChallengePresented(void);
	bool isRaceAllowedToPublishOnFacebook(const char* mode, const char* raceName);
	void allowRaceToPublishOnFacebook(const char* mode, const char* raceName);
	void disallowRaceToPublishOnFacebook(const char* mode, const char* raceName);
	
	/* implementée dans TRFaceBookController */
	void loadFBButton();
	void hideFBButton(int hide);
	void doYouWantToConnectToFacebook();
	void publishFirstScore(char*score,char*course,char*mode);
	void publishNewHighScore(char*score,char*course,char*mode,char* classementMondial, char* classementNational, char* classementTotal);
	
#ifdef __cplusplus
}
#endif 