//
//  ThreeLivesViewController_iPhone.m
//  wordrace
//
//  Created by Taha Selim Bebek on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ThreeLivesViewController_iPhone.h"
#import "PauseViewController.h"
#import "GameOverViewController.h"
#import "Constants.h"

@interface ThreeLivesViewController_iPhone (P)
-(void)gameOver;
-(void)createAllWordsForCurrentLevel;
-(void)putNextQuestion;
-(void)updateLevelLabelForStart;
-(void)finishedShowingLevelLabel;
-(void)finishedMovingLevelLabel;
-(void)finishedMovingQuestion;
-(void)updateScoreBoard;
-(void)updateConsequtiveCorrectAnswersCountLabel;
-(void)updateLiveImages;
-(void)giveExtraLife;
-(void)checkCurrentLevel;
-(void)updateCurrentLevel;
-(void)startTheGame;
-(void)startNextQuestionAnimation;
-(void)upgradeLevel;
-(void)downgradeLevel;
-(void)showCorrectAnswerWithAnimation;
-(void)finishedMovingX;
-(void)finishedMovingXForCorrectQuestion;
-(void)userAnsweredWrongly;
-(void)userAnsweredCorrecty;
@end

@implementation ThreeLivesViewController_iPhone

#pragma mark -
#pragma mark game start and finish
#pragma mark -

-(void)startTheGame
{
    //NSLog(@"%s",__FUNCTION__);
    self.correctButton.userInteractionEnabled = NO;
    self.wrongButton.userInteractionEnabled = NO;
    
    currentScore = 0;
    consequtiveCorrectAnswersCount = 1;
    currentNumberOfLives = 3;
    levelUpgradeCount = 0;
    self.highScoreLabel.text = @"";
    self.levelPageControl.currentPage = levelUpgradeCount;

    [self updateLiveImages];
    [self updateScoreBoard];
    [self updateConsequtiveCorrectAnswersCountLabel];
    [self checkCurrentLevel];
    [self createAllWordsForCurrentLevel];
    [self updateLevelLabelForStart];
}

-(void)gameOver
{
    //NSLog(@"%s",__FUNCTION__);
    GameOverViewController* gameOverViewController = [[GameOverViewController alloc]initWithNibName:@"GameOverViewController" bundle:nil];

    NSUInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScoreThreeLives"];
    
    if (currentScore > highScore) 
    {
        gameOverViewController.didBrakeHighScore = YES;
        [[NSUserDefaults standardUserDefaults] setInteger:currentScore forKey:@"highScoreThreeLives"];
        highScore = currentScore;
    }
        
    gameOverViewController.parentGamePlayViewController = (UIViewController*)self;
    gameOverViewController.currentGameMode = 0;
    gameOverViewController.gameMode = GAMEMODE_THREELIVES_TITLE;
    gameOverViewController.currentLevel = currentLevel;
    gameOverViewController.score =currentScore;
    gameOverViewController.highScore = highScore;

    [self.navigationController pushViewController:gameOverViewController animated:NO];
    [gameOverViewController release];

}

#pragma mark -
#pragma mark question creation
#pragma mark -

-(void)createAllWordsForCurrentLevel
{
    //NSLog(@"%s",__FUNCTION__);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"EasyWord" inManagedObjectContext:self.managedObjectContext]];
    NSPredicate* levelPredicate = [NSPredicate predicateWithFormat:@"level == %@",[NSNumber numberWithInt:currentLevel]];
    [fetchRequest setPredicate:levelPredicate];
    
    NSError* errorCorrectWords = nil;
    self.allQuestionsCopyForWrongAnswers = [managedObjectContext executeFetchRequest:fetchRequest error:&errorCorrectWords];
    self.allQuestions = [[[NSMutableArray alloc] initWithArray:allQuestionsCopyForWrongAnswers] autorelease];
}

-(void)putNextQuestion
{
    //NSLog(@"%s",__FUNCTION__);
    NSInteger numberOfWords = [allQuestions count];
    NSInteger numberOfWordsForWrongAnswers = [allQuestionsCopyForWrongAnswers count];
    
    if (numberOfWords == 0) {
        [self createAllWordsForCurrentLevel];
        numberOfWords = [allQuestions count];
        numberOfWordsForWrongAnswers = [allQuestionsCopyForWrongAnswers count];
    }
    int rng = arc4random() % numberOfWords;
    
    NSManagedObject* word = [allQuestions objectAtIndex:rng];
    
    [currentQuestion release];
    currentQuestion = [[Question alloc] init];
    currentQuestion.englishText = [word valueForKey:@"englishString"];
    
    int rngCorrect = arc4random() % 2;
    if (rngCorrect == 0) {
        currentQuestion.correct = YES;
        currentQuestion.translationText = [word valueForKey:@"translationString"];
        currentQuestion.correctAnswer = [word valueForKey:@"translationString"];
    }
    else
    {
        int rngWrong = 0;
        NSManagedObject* wordFalse = nil;
        do {
            rngWrong = arc4random() % numberOfWordsForWrongAnswers;
            wordFalse = [allQuestionsCopyForWrongAnswers objectAtIndex:rngWrong];
            currentQuestion.translationText = [wordFalse valueForKey:@"translationString"];
            currentQuestion.correctAnswer = [word valueForKey:@"translationString"];
            currentQuestion.correct = NO;
        } while ([[wordFalse valueForKey:@"translationString"] isEqualToString:[word valueForKey:@"translationString"]]);
    }
    
    [allQuestions removeObjectAtIndex:rng];
    
    self.upperTextLabel.text = currentQuestion.englishText;
    self.lowerTextLabel.text = currentQuestion.translationText;
}

#pragma mark -
#pragma mark updates without animation
#pragma mark -

-(void)updateScoreBoard
{
    //NSLog(@"%s",__FUNCTION__);
    self.scoreBoardLabel.text = [NSString stringWithFormat:@"%i",currentScore];
}

-(void)updateConsequtiveCorrectAnswersCountLabel
{
    //NSLog(@"%s",__FUNCTION__);
    self.consequtiveCorrectAnswersCountLabel.text = [NSString stringWithFormat:@"x %i",consequtiveCorrectAnswersCount];
}


-(void)updateLiveImages
{
    //NSLog(@"%s",__FUNCTION__);
    switch (currentNumberOfLives) {
        case 0:
            self.firstLifeImageView.highlighted = YES;
            self.secondLifeImageView.highlighted = YES;
            self.thirdLifeImageView.highlighted = YES;
            break;
        case 1:
            self.firstLifeImageView.highlighted = NO;
            self.secondLifeImageView.highlighted = YES;
            self.thirdLifeImageView.highlighted = YES;
            break;
        case 2:
            self.firstLifeImageView.highlighted = NO;
            self.secondLifeImageView.highlighted = NO;
            self.thirdLifeImageView.highlighted = YES;
            break;
        case 3:
            self.firstLifeImageView.highlighted = NO;
            self.secondLifeImageView.highlighted = NO;
            self.thirdLifeImageView.highlighted = NO;
            break;
    }
}

-(void)giveExtraLife
{
    //NSLog(@"%s",__FUNCTION__);
    currentNumberOfLives = currentNumberOfLives +1;
    [self updateLiveImages];    
}

-(void)checkCurrentLevel
{    
    //NSLog(@"%s",__FUNCTION__);
    currentLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentLevel"];
}

-(void)updateCurrentLevel
{
    [[NSUserDefaults standardUserDefaults] setInteger:currentLevel forKey:@"currentLevel"];
}

#pragma mark -
#pragma mark level upgrade and downgrade
#pragma mark -

-(void)upgradeLevel
{
    //NSLog(@"%s",__FUNCTION__);
    if (currentNumberOfLives != 3) 
    {
        [self giveExtraLife];
    }
    
    levelUpgradeCount = 0;
    self.levelPageControl.currentPage = levelUpgradeCount;
    if (currentLevel != 39) {
        self.highScoreLabel.text = @"";
        currentLevel = currentLevel + 1;
        
        NSString* lockString = [NSString stringWithFormat:@"Level%i",currentLevel];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:lockString];
        
        [self updateCurrentLevel];
        [self createAllWordsForCurrentLevel];
        [self updateLevelLabelForStart];
    }
}

-(void)downgradeLevel
{
    //NSLog(@"%s",__FUNCTION__);
    levelUpgradeCount = 0;
    self.levelPageControl.currentPage = levelUpgradeCount;
    
    if (currentLevel != 0) {
        self.highScoreLabel.text = @"";
        currentLevel = currentLevel - 1;
        [self updateCurrentLevel];
        [self createAllWordsForCurrentLevel];
        [self updateLevelLabelForStart];
    }
    else
    {
        [self startNextQuestionAnimation];
    }
}


-(void)updateLevelLabelForStart
{
    //NSLog(@"%s",__FUNCTION__);
    [levelLabel release];
    levelLabel = [[UILabel alloc] initWithFrame:self.upperTextLabel.frame];
    levelLabel.center = self.equalSignLabel.center;
    levelLabel.text = [NSString stringWithFormat:@"%@ %i",SELECTLEVEL_LEVEL_TITLE,currentLevel +1];
    levelLabel.textColor = [UIColor whiteColor];
    levelLabel.font = self.upperTextLabel.font;
    levelLabel.textAlignment = UITextAlignmentCenter;
    levelLabel.backgroundColor = [UIColor clearColor];
    levelLabel.alpha = 0.0;
    [self.view addSubview:levelLabel];
    
    self.upperTextLabel.frame = CGRectOffset(self.upperTextLabel.frame, 320, 0);
    self.lowerTextLabel.frame = CGRectOffset(self.lowerTextLabel.frame, 320, 0);
    self.equalSignLabel.frame = CGRectOffset(self.equalSignLabel.frame, 320, 0);
    self.upperTextLabel.alpha = 0.0;
    self.lowerTextLabel.alpha = 0.0;
    self.equalSignLabel.alpha = 0.0;
    
    [UIView beginAnimations:@"ShowLevelLabel" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(finishedShowingLevelLabel)];
    levelLabel.alpha = 1.0;
    [UIView commitAnimations];
}

-(void)finishedShowingLevelLabel
{
    //NSLog(@"%s",__FUNCTION__);
    [NSThread sleepForTimeInterval:1];
    [UIView beginAnimations:@"MoveLevelLabel" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(finishedMovingLevelLabel)];
    levelLabel.center = self.highScoreLabel.center;
    levelLabel.font = highScoreLabel.font;
    self.highScoreLabel.alpha = 0.0;
    [UIView commitAnimations];
}

-(void)finishedMovingLevelLabel
{
    //NSLog(@"%s",__FUNCTION__);
    self.highScoreLabel = levelLabel;
    [self putNextQuestion];
    
    [UIView beginAnimations:@"MoveLevelLabel" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(finishedMovingQuestion)];
    self.upperTextLabel.frame = CGRectOffset(self.upperTextLabel.frame, -320, 0);
    self.lowerTextLabel.frame = CGRectOffset(self.lowerTextLabel.frame, -320, 0);
    self.equalSignLabel.frame = CGRectOffset(self.equalSignLabel.frame, -320, 0);
    self.upperTextLabel.alpha = 1.0;
    self.lowerTextLabel.alpha = 1.0;
    self.equalSignLabel.alpha = 1.0;
    [UIView commitAnimations];
}

-(void)finishedMovingQuestion
{
    //NSLog(@"%s",__FUNCTION__);
    self.correctButton.userInteractionEnabled = YES;
    self.wrongButton.userInteractionEnabled = YES;
    self.pauseButton.userInteractionEnabled = YES;
}

#pragma mark -
#pragma mark next question animations
#pragma mark -


-(void)startNextQuestionAnimation
{
    //NSLog(@"%s",__FUNCTION__);
    [nextQuestionUpperTextLabel release];
    nextQuestionUpperTextLabel = [[UILabel alloc] initWithFrame:self.upperTextLabel.frame];
    nextQuestionUpperTextLabel.text = self.upperTextLabel.text;
    nextQuestionUpperTextLabel.textColor = [UIColor whiteColor];
    nextQuestionUpperTextLabel.font = self.upperTextLabel.font;
    nextQuestionUpperTextLabel.textAlignment = UITextAlignmentCenter;
    nextQuestionUpperTextLabel.backgroundColor = [UIColor clearColor];
    nextQuestionUpperTextLabel.numberOfLines = 0;
    [self.view addSubview:nextQuestionUpperTextLabel];
    
    [nextQuestionLowerTextLabel release];
    nextQuestionLowerTextLabel = [[UILabel alloc] initWithFrame:self.lowerTextLabel.frame];
    nextQuestionLowerTextLabel.text = self.lowerTextLabel.text;
    nextQuestionLowerTextLabel.textColor = [UIColor whiteColor];
    nextQuestionLowerTextLabel.font = self.lowerTextLabel.font;
    nextQuestionLowerTextLabel.textAlignment = UITextAlignmentCenter;
    nextQuestionLowerTextLabel.backgroundColor = [UIColor clearColor];
    nextQuestionLowerTextLabel.numberOfLines = 0;
    [self.view addSubview:nextQuestionLowerTextLabel];

    [nextQuestionEqualSignLabel release];
    nextQuestionEqualSignLabel = [[UILabel alloc] initWithFrame:self.equalSignLabel.frame];
    nextQuestionEqualSignLabel.text = self.equalSignLabel.text;
    nextQuestionEqualSignLabel.textColor = [UIColor whiteColor];
    nextQuestionEqualSignLabel.font = self.equalSignLabel.font;
    nextQuestionEqualSignLabel.textAlignment = UITextAlignmentCenter;
    nextQuestionEqualSignLabel.backgroundColor = [UIColor clearColor];
    nextQuestionEqualSignLabel.numberOfLines = 0;
    [self.view addSubview:nextQuestionEqualSignLabel];
    
    self.upperTextLabel.frame = CGRectOffset(self.upperTextLabel.frame, 320, 0);
    self.lowerTextLabel.frame = CGRectOffset(self.lowerTextLabel.frame, 320, 0);
    self.equalSignLabel.frame = CGRectOffset(self.equalSignLabel.frame, 320, 0);
    self.upperTextLabel.alpha = 0.0;
    self.lowerTextLabel.alpha = 0.0;
    self.equalSignLabel.alpha = 0.0;
    [self putNextQuestion];
    
    [UIView beginAnimations:@"ShowLevelLabel" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(finishedMovingQuestion)];
    self.upperTextLabel.frame = CGRectOffset(self.upperTextLabel.frame, -320, 0);
    self.lowerTextLabel.frame = CGRectOffset(self.lowerTextLabel.frame, -320, 0);
    self.equalSignLabel.frame = CGRectOffset(self.equalSignLabel.frame, -320, 0);
    self.upperTextLabel.alpha = 1.0;
    self.lowerTextLabel.alpha = 1.0;
    self.equalSignLabel.alpha = 1.0;
    
    nextQuestionUpperTextLabel.frame = CGRectOffset(nextQuestionUpperTextLabel.frame, -320, 0);
    nextQuestionLowerTextLabel.frame = CGRectOffset(nextQuestionLowerTextLabel.frame, -320, 0);
    nextQuestionEqualSignLabel.frame = CGRectOffset(nextQuestionEqualSignLabel.frame, -320, 0);
    nextQuestionUpperTextLabel.alpha = 0.0;
    nextQuestionLowerTextLabel.alpha = 0.0;
    nextQuestionEqualSignLabel.alpha = 0.0;
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark answered correctly
#pragma mark -

-(void)userAnsweredCorrecty
{
    //NSLog(@"%s",__FUNCTION__);
    currentScore = currentScore + consequtiveCorrectAnswersCount;
    
    if (consequtiveCorrectAnswersCount != 5) 
    {
        consequtiveCorrectAnswersCount = consequtiveCorrectAnswersCount +1;
    }
    
    [self updateScoreBoard];
    [self updateConsequtiveCorrectAnswersCountLabel];
    
    if (levelUpgradeCount != 4) 
    {
        levelUpgradeCount = levelUpgradeCount +1;
        self.levelPageControl.currentPage = levelUpgradeCount;
        [self startNextQuestionAnimation];
    }
    else
    {
        [self upgradeLevel];
    }
}

#pragma mark -
#pragma mark answered wrongly
#pragma mark -


-(void)showCorrectAnswerWithAnimation
{
    //NSLog(@"%s",__FUNCTION__);
    self.correctButton.userInteractionEnabled = NO;
    self.wrongButton.userInteractionEnabled = NO;
    self.pauseButton.userInteractionEnabled = NO;
    
    currentNumberOfLives = currentNumberOfLives - 1;
    consequtiveCorrectAnswersCount = 1;
    [self updateLiveImages];
    [self updateConsequtiveCorrectAnswersCountLabel];

    [xImage release];
    xImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Glyph3LivesOn.png"]];
    
    switch (currentNumberOfLives) {
        case 0:
            xImage.center = self.firstLifeImageView.center;
            break;
        case 1:
            xImage.center = self.secondLifeImageView.center;
            break;
        case 2:
            xImage.center = self.thirdLifeImageView.center;
            break;
    }
    [self.view addSubview:xImage];
    
    [UIView beginAnimations:@"MoveX" context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelegate:self];
    
    if (currentQuestion.correct) 
    {
        [UIView setAnimationDidStopSelector:@selector(finishedMovingXForCorrectQuestion)];
    }
    else
    {
        [UIView setAnimationDidStopSelector:@selector(finishedMovingX)];
    }
    xImage.center = self.lowerTextLabel.center;
    [UIView commitAnimations];
}

-(void)finishedMovingX
{
    //NSLog(@"%s",__FUNCTION__);
    [correctAnswerLabel release];
    correctAnswerLabel = [[UILabel alloc] initWithFrame:CGRectMake(320, self.lowerTextLabel.frame.origin.y, self.lowerTextLabel.frame.size.width, self.lowerTextLabel.frame.size.height)];
    correctAnswerLabel.alpha = 0.0;
    correctAnswerLabel.text = currentQuestion.correctAnswer;
    correctAnswerLabel.backgroundColor = [UIColor clearColor];
    correctAnswerLabel.textColor = [UIColor whiteColor];
    correctAnswerLabel.font = self.lowerTextLabel.font;
    correctAnswerLabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:correctAnswerLabel];
    
    [UIView beginAnimations:@"ShowCorrectAnswer" context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(userAnsweredWrongly)];
    correctAnswerLabel.alpha = 1.0;
    correctAnswerLabel.frame = self.lowerTextLabel.frame;
    self.lowerTextLabel.frame = CGRectOffset(self.lowerTextLabel.frame, -320, 0);
    xImage.frame = CGRectOffset(xImage.frame, -320, 0);
    [UIView commitAnimations]; 
}

-(void)finishedMovingXForCorrectQuestion
{
    //NSLog(@"%s",__FUNCTION__);
    [UIView beginAnimations:@"ShowCorrectAnswer" context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(userAnsweredWrongly)];
    xImage.alpha = 0.0;
    [UIView commitAnimations]; 
}

-(void)userAnsweredWrongly
{
    //NSLog(@"%s",__FUNCTION__);
    [NSThread sleepForTimeInterval:1];
    self.lowerTextLabel.text = currentQuestion.correctAnswer;
    [correctAnswerLabel removeFromSuperview];
    [xImage removeFromSuperview];
    if (!currentQuestion.correct) 
    {
        self.lowerTextLabel.frame = CGRectOffset(self.lowerTextLabel.frame, 320, 0);
    }

    if (currentNumberOfLives == 0) {
        
        [self gameOver];
        return;
    }
    [self downgradeLevel];
}

#pragma mark -
#pragma mark IBActions
#pragma mark -

-(IBAction)correctButtonPressed:(id)sender
{
    correctButton.userInteractionEnabled = NO;
    wrongButton.userInteractionEnabled = NO;
    
    if (currentQuestion.correct) 
    {
        [self userAnsweredCorrecty];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(showCorrectAnswerWithAnimation) withObject:nil waitUntilDone:YES];
    }
}

-(IBAction)wrongButtonPressed:(id)sender
{
    correctButton.userInteractionEnabled = NO;
    wrongButton.userInteractionEnabled = NO;

    if (currentQuestion.correct) 
    {
        [self performSelectorOnMainThread:@selector(showCorrectAnswerWithAnimation) withObject:nil waitUntilDone:YES];
    }
    else
    {
        [self userAnsweredCorrecty];
    }
}

-(IBAction)pauseButtonPressed:(id)sender
{
    PauseViewController* pauseViewController = [[PauseViewController alloc]initWithNibName:@"PauseViewController" bundle:nil];
    pauseViewController.parentGamePlayViewController = (UIViewController*)self;
    pauseViewController.currentGameMode = 0;
    pauseViewController.currentLevel = currentLevel;
    
    [self.navigationController pushViewController:pauseViewController animated:NO];
    [pauseViewController release];
}


#pragma mark -
#pragma mark Lifecycle
#pragma mark -

- (void)dealloc
{
    [managedObjectContext release];
    [correctButton release];
    [wrongButton release];
    [pauseButton release];
    
    [scoreBoardLabel release];
    [consequtiveCorrectAnswersCountLabel release];
    [highScoreLabel release];
    [upperTextLabel release];
    [lowerTextLabel release];
    [firstLifeImageView release];
    [secondLifeImageView release];
    [thirdLifeImageView release];
    [allQuestionsCopyForWrongAnswers release];
    [allQuestions release];
    [equalSignLabel release];
    [levelPageControl release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [scoreBoardLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:34]];
    [consequtiveCorrectAnswersCountLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:16]];

    //self.scoreBoardLabel.font = [UIFont fontWithName:@"Digital-7" size:34];
    //self.scoreBoardLabel.font = [UIFont systemFontOfSize:34];

    if (!receivedMemoryWarning) 
    {
        [self startTheGame];
    }
    else
    {
        receivedMemoryWarning = NO;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    receivedMemoryWarning = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Synthesizers
#pragma mark -

@synthesize managedObjectContext;
@synthesize correctButton;
@synthesize wrongButton;
@synthesize pauseButton;

@synthesize scoreBoardLabel;
@synthesize consequtiveCorrectAnswersCountLabel;
@synthesize highScoreLabel;
@synthesize upperTextLabel;
@synthesize lowerTextLabel;
@synthesize firstLifeImageView;
@synthesize secondLifeImageView;
@synthesize thirdLifeImageView;
@synthesize allQuestions;
@synthesize allQuestionsCopyForWrongAnswers;
@synthesize equalSignLabel;
@synthesize levelPageControl;

@end
