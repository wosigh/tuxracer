#include <stdio.h>
#define bool int
#define bool_t bool

void winsys_get_gravity(float * grav_x, float * grav_y) {
  *grav_x = 1;
  *grav_y = 1;
}

void winsys_perform_on_main_thread_sync2( void (*func)(void*, void*), void * arg1, void * arg2 ) {
  func(arg1, arg2);
}

const char * winsys_localized_string( const char * key, const char * comment ) {
  return key;
}
void winsys_show_rankings( void ) {
  printf("4 Not implemented\n");
}

void saveScoreOnlineAfterRace(char* raceName,int score,int herring,int minutes,int seconds,int hundredths){
  printf("5 Not implemented\n");
}

void displayRankingsAfterRace(char* raceName,int score,int herring,int minutes,int seconds,int hundredths) {
  printf("6 Not implemented\n");
}

void dirtyScores () {
  printf("7 Not implemented\n");
}

void doYouWantToConnectToFacebook() {
  printf("8 Not implemented\n");
}

void publishFirstScore(char*score,char*course,char*mode) {
  printf("9 Not implemented\n");
}

void publishNewHighScore(char*score,char*course,char*mode,char* classementMondial, char* classementNational, char* classementTotal) {
  printf("10 Not implemented\n");
}

void stop_music() {
  printf("11 Not implemented\n");
}

void winsys_set_high_framerate(bool_t highframerate) {
  printf("12 Not implemented\n");
}

void hideFBButton(int hide) {
  printf("13 Not implemented\n");
}

bool plyrWantsToSaveOrDisplayRankingsAfterRace() {
  printf("14 Not implemented\n");
  return 0;
}

bool plyrWantsToDisplayRankingsAfterRace() {
  printf("15 Not implemented\n");
  return 0;
}

bool isPlayerRegistered() {
  printf("16 Not implemented\n");
  return 0;
}

bool isChallengeOn() {
  printf("17 Not implemented\n");
  return 0;
}

bool wasChallengePresented() {
  printf("18 Not implemented\n");
  return 0;
}

bool isRaceAllowedToPublishOnFacebook(const char* mode, const char* raceName) {
  printf("19 Not implemented\n");
  return 0;
}

void allowRaceToPublishOnFacebook(const char* mode, const char* raceName) {
  printf("20 Not implemented\n");
}

void disallowRaceToPublishOnFacebook(const char* mode, const char* raceName) {
  printf("21 Not implemented\n");
}

void loadFBButton(){
  printf("22 Not implemented\n");
}

#if 0
const char* getRessourcePath() {
  printf("23 Not implemented\n");
  return NULL;
}

const char* getConfigPath() {
  printf("24 Not implemented\n");
  return NULL;
}
#endif

const char * challengeTextInfos() {
  return "textInfoEn";
}

void displayRankings()
{
  printf("26 Not implemented\n");
}

void turnScreenToLandscape() {
#if 0
  int i,j;
  printf("GO landscape?\n");
  for (i=0; i<0x100; i++) {
    printf("try %d\n", i);
    for (j=0; j<0x100; j++) {
      printf("j %d\n", j);
    PDL_SetOrientation(i,j);
    SDL_Delay(20);
    }
  }
  glRotatef( -90.0, 0, 0, 1 );
#else
  printf("ROTATE!\n");
  PDL_SetOrientation("left");
  PDL_SetOrientation(3);
  PDL_ScreenTimeoutEnable(5);
#endif
}

void turnScreenToPortrait() {
  printf("28 Not implemented\n");
}

void showHowToPlayAtBegining() {
  printf("29 Not implemented\n");
}

void showChallengeSuscribtion() {
  printf("30 Not implemented\n");
}

void vibration() {
  printf("31 Not implemented\n");
}
