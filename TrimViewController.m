//
//  TrimViewController.m
//  prism
//
//  Created by My Star on 5/12/16.
//  Copyright © 2016 Silver Star. All rights reserved.
//

#import "TrimViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "RETrimControl/RETrimControl.h"
#import "AppDelegate.h"
#import "FVSoundWaveView.h"
//#import "ProgressGradientView.h"
#define WAVEVIEW_WIDTH 270

@interface TrimViewController ()<RETrimControlDelegate, AVAudioPlayerDelegate, UITextFieldDelegate>{
    AVAudioPlayer *player;
    RETrimControl *trimControl;
    
    CGFloat fStartTime, fEndTime;
    NSString *strCurFileName;
    
    NSURL *urlPlayer;
    UILabel *lblCurrTime;
    UIImageView *ivLine;
    NSTimer		*updateTimer;
    float audioDurationSeconds;
    BOOL isPaused;
    BOOL isA;
    BOOL isB;
    
    UIAlertView *alert;
    UITextField *tfNewFileName;
    
//    ProgressGradientView *pgv;
//    CGFloat progress;
}

@end

@implementation TrimViewController{
    FVSoundWaveView* _soundWaveView;
}
@synthesize nSelectedIndex;
//@synthesize strSelectedIndex;
- (void)viewDidAppear:(BOOL)animated{
//    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"1.m4a" ofType:nil]];
    
//    _soundWaveView.soundURL = url;
    
    NSArray *pathToFile = [NSArray arrayWithObjects:
                  [self pathToAudioFilesFolder],
                  strCurFileName,
                  nil];
    
    NSURL *audioFileURL = [NSURL fileURLWithPathComponents:pathToFile];
    NSLog(@"audioFileURL: %@", audioFileURL);
    
    urlPlayer = audioFileURL;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:urlPlayer error:nil];
    isPaused = NO;
    isA = NO;
    isB = NO;
    
    int x = self.view.frame.size.width/2 - WAVEVIEW_WIDTH/2;
    int y = (self.view.frame.size.height) / 2.0f;
    [lblCurrTime setFrame:CGRectMake(x-20, y+55, 80, 20)];
    lblCurrTime.text = @"00:00";
    [self.view addSubview:lblCurrTime];
    
    [ivLine setFrame:CGRectMake(x, y-150, 1, 200)];
    [ivLine setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:ivLine];
    
    _soundWaveView.soundURL = audioFileURL;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //customize back button
    UIImage *buttonImage = [UIImage imageNamed:@"list.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
    
    //get current file name
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    strCurFileName = [delegate.strFileNameArray objectAtIndex:nSelectedIndex];
    _lblCurFileName.text = strCurFileName;
    
    //get duration of the audio file
    NSArray *pathToFile = [NSArray arrayWithObjects:
                           [self pathToAudioFilesFolder],
                           strCurFileName,
                           nil];
    NSURL *audioFileURL = [NSURL fileURLWithPathComponents:pathToFile];
    NSLog(@"audioFileURL: %@", audioFileURL);
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];
    player.delegate = self;
    player.volume = 1;
    NSLog(@"duration: %@", [NSString stringWithFormat:@"%f", player.duration]);
    
    
//    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:audioFileURL options:nil];
//    CMTime audioDuration = audioAsset.duration;
    audioDurationSeconds = player.duration;
    
    
    int x = self.view.frame.size.width/2 - WAVEVIEW_WIDTH/2;
    int y = (self.view.frame.size.height) / 2.0f;
    
    //show wave view
    _soundWaveView = [[FVSoundWaveView alloc] initWithFrame:CGRectMake(x, y-150, WAVEVIEW_WIDTH, 200)];
    [_soundWaveView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_soundWaveView];
    
    //show trimControl
    trimControl = [[RETrimControl alloc] initWithFrame:CGRectMake(x, y-178, WAVEVIEW_WIDTH, 28)];
    trimControl.length = audioDurationSeconds; // seconds
    trimControl.delegate = self;
    [self.view addSubview:trimControl];
    
    updateTimer = nil;
    lblCurrTime = [[UILabel alloc]init];
    ivLine = [[UIImageView alloc]init];
    
//    pgv=[[ProgressGradientView alloc] initWithFrame:CGRectMake(x, 200, 300, 15)];
//    [self.view addSubview:pgv];
    
}

- (void)back {
    //stop player if playing
    if (player.playing) {
        [player stop];
    }
    if (updateTimer != nil) {
        [updateTimer invalidate];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSString *)pathToAudioFilesFolder {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                        NSUserDomainMask,
                                                                        YES) lastObject];
    
    NSString *audioFilesFolder = [documentsDirectory stringByAppendingPathComponent:@"audioFiles"];
    
    //    NSLog(@"audio files folder: %@", audioFilesFolder);
    
    // Create the folder if necessary
    BOOL isDir = NO;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:audioFilesFolder
                           isDirectory:&isDir] && isDir == NO) {
        [fileManager createDirectoryAtPath:audioFilesFolder
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:nil];
    }
    return audioFilesFolder;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - trim ctrl delegate
- (void)trimControl:(RETrimControl *)trimControl didChangeLeftValue:(CGFloat)leftValue rightValue:(CGFloat)rightValue
{
//    fStartTime = leftValue;
//    fEndTime = rightValue;
//    NSLog(@"Left = %f, right = %f", leftValue, rightValue);
}

#pragma mark - button listeners

- (IBAction)btnPlayTapped:(id)sender {
    if (player.playing) {
        [player pause];
        isPaused = YES;
        [_btnPlay setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
        
    }else{
        
        if (player != nil) {
            //            player.numberOfLoops = 1;
            player.delegate = self;
        }
        
        if ([player play]) {
            
            [_btnPlay setImage:[UIImage imageNamed:@"pause_small.png"] forState:UIControlStateNormal];
            [self updateViewForPlayerState:player];
        }
        else
            NSLog(@"Could not play %@\n", player.url);
        
    }

}

- (IBAction)btnATapped:(id)sender {
    if (isA == NO) {
        isA = YES;
        fStartTime = 0.0;
        fStartTime = player.currentTime;
        [_btnA setImage:[UIImage imageNamed:@"A_pressed.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)btnBTapped:(id)sender {
    if (isB == NO) {
        isB = YES;
        fEndTime = audioDurationSeconds;
        fEndTime = player.currentTime;
        [_btnB setImage:[UIImage imageNamed:@"B_pressed.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)btnRefreshTapped:(id)sender {
    [self refresh];
    
}
-(void)refresh{
    isA = NO;
    isB = NO;
    [_btnA setImage:[UIImage imageNamed:@"A.png"] forState:UIControlStateNormal];
    [_btnB setImage:[UIImage imageNamed:@"B.png"] forState:UIControlStateNormal];
}

- (IBAction)btnTrimTapped:(id)sender {
    if (player.playing) {
        [player pause];
        isPaused = YES;
        [_btnPlay setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
    if (isA && isB) {
        if (fabs(fStartTime-fEndTime) < 1.0) {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Too short Interval" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            [self refresh];
            return;
        }
        
        //show an alert to enter a new file name
        NSString *alertTitle = @"New File Name";
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
        
        tfNewFileName = [[UITextField alloc] initWithFrame:CGRectMake(10,0,245,25)];
        tfNewFileName.placeholder = @"Output File Name Here";
        tfNewFileName.borderStyle = UITextBorderStyleRoundedRect;
        tfNewFileName.keyboardType = UIKeyboardTypeAlphabet;
        tfNewFileName.delegate = self;
        v.tag = 1;
        
        [v addSubview:tfNewFileName];
        
        
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:nil delegate:self cancelButtonTitle:@"Discard" otherButtonTitles:@"Save", nil];
        [alert setValue:v  forKey:@"accessoryView"];
                
        [alert show];
        [self refresh];
    }
}


#pragma mark - AVAudioPlayerDelegate protocol methods
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
       
    [_btnPlay setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    
    int x = self.view.frame.size.width/2 - WAVEVIEW_WIDTH/2;
    int y = (self.view.frame.size.height) / 2.0f;
    [lblCurrTime setFrame:CGRectMake(x+WAVEVIEW_WIDTH-20, y+55, 80, 20)];
    [ivLine setFrame:CGRectMake(x+WAVEVIEW_WIDTH, y-150, 1, 200)];
}
#pragma mark - current time and indicator line
- (void)updateViewForPlayerState:(AVAudioPlayer *)p
{
    [self updateCurrentTimeForPlayer:p];
    
    if (updateTimer)
        [updateTimer invalidate];
    
    if (p.playing)
    {
        if(isPaused){
            isPaused = NO;
        }else{
            int x = self.view.frame.size.width/2 - WAVEVIEW_WIDTH/2;
            int y = (self.view.frame.size.height) / 2.0f;
            [lblCurrTime setFrame:CGRectMake(x-20, y+55, 80, 20)];
            [self.view addSubview:lblCurrTime];
            
            [ivLine setFrame:CGRectMake(x, y-150, 1, 200)];
            [ivLine setBackgroundColor:[UIColor redColor]];
            [self.view addSubview:ivLine];
        }
        
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateCurrentTime) userInfo:p repeats:YES];
    }
    else
    {
        updateTimer = nil;
    }
    
}
- (void)updateCurrentTime
{
    if ([player isPlaying]) {
        [self updateCurrentTimeForPlayer:player];
    }
    
}
-(void)updateCurrentTimeForPlayer:(AVAudioPlayer *)p
{
    CGRect frame = lblCurrTime.frame;
    frame.origin.x += 27.0f/audioDurationSeconds;
    lblCurrTime.frame= frame;
    
    frame = ivLine.frame;
    frame.origin.x += 27.0f/audioDurationSeconds;
    ivLine.frame= frame;
    
    CGFloat fCurrTime = p.currentTime + 0.1;
    lblCurrTime.text = [NSString stringWithFormat:@"%02d:%02d", (int)p.currentTime / 60, (int)fCurrTime % 60, nil];
    
//    progress += 300.0f/audioDurationSeconds;
//    [pgv setProgress:progress];
}

#pragma mark - trim method
- (BOOL)trimAudio: (NSString*)strTargetFileName;
{
    float vocalStartMarker = fStartTime<fEndTime ? fStartTime : fEndTime;
    float vocalEndMarker = fStartTime>fEndTime ? fStartTime : fEndTime;
    
    NSURL *audioFileInput = urlPlayer;
    NSArray *pathToFile = [NSArray arrayWithObjects:
                           [self pathToAudioFilesFolder],
                           strTargetFileName,
                           nil];
    NSURL *audioFileOutput = [NSURL fileURLWithPathComponents:pathToFile];
    
    if (!audioFileInput || !audioFileOutput)
    {
        return NO;
    }
    
    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
    AVAsset *asset = [AVAsset assetWithURL:audioFileInput];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                            presetName:AVAssetExportPresetAppleM4A];
    
    if (exportSession == nil)
    {
        return NO;
    }
    
    CMTime startTime = CMTimeMake((int)(floor(vocalStartMarker * 100)), 100);
    CMTime stopTime = CMTimeMake((int)(ceil(vocalEndMarker * 100)), 100);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    exportSession.outputURL = audioFileOutput;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = exportTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         if (AVAssetExportSessionStatusCompleted == exportSession.status)
         {
             // It worked!
         }
         else if (AVAssetExportSessionStatusFailed == exportSession.status)
         {
             // It failed...
         }
     }];
    
    return YES;
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1) {
        
        NSString *strTargetFileName = tfNewFileName.text;
        strTargetFileName = [strTargetFileName stringByAppendingString:@".m4a"];
        
        if ([tfNewFileName.text isEqualToString:@""]) {
            [tfNewFileName setBackgroundColor:[UIColor redColor]];
            
            [alert setMessage:@"Please fill in"];
            [alert show];
            return;
        }else{
            [tfNewFileName setBackgroundColor:[UIColor whiteColor]];
        }
        
        // save the trimmed file as strTargetFileName
        if ([self trimAudio:strTargetFileName]) {
            //update strFileNameArray
            AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSMutableArray *strFileNameArray = delegate.strFileNameArray;
            [strFileNameArray  addObject:strTargetFileName];
            

        }else{
            NSLog(@"Trim failed!!!");
        }
        
        
    }
    
}
@end
