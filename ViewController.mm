//
//  ViewController.m
//  prism
//
//  Created by My Star on 5/6/16.
//  Copyright © 2016 Silver Star. All rights reserved.
//

#import "ViewController.h"
#include "CALevelMeter.h"
#import "AppDelegate.h"


@interface ViewController ()<UITextFieldDelegate>{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
    NSTimer		*updateTimer;
    BOOL isNewFile;
    
    NSURL *urlPlayer;
    
    UITextField *tfNewFileName;
    UIAlertView *alert;
    
    BOOL isPaused;
}

@end

@implementation ViewController

@synthesize lvlMeter_in;
@synthesize strFileNameArray;

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
- (NSString *) dateString
{
    // return a formatted string for a file name
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYMMdd_hhmmssa";
    return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".m4a"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // Hide Stop/Play/Prev/Next button when application launches
    [_btnPlay setHidden:YES];
    [_btnNext setHidden:YES];
    [_btnPrev setHidden:YES];
    [_btnStop setHidden:YES];
    
    
    recorder = NULL;
    isNewFile = YES;
    
    updateTimer = nil;
    self.lblCurrTime.adjustsFontSizeToFitWidth = YES;
    
    //init file array from the audioFiles folder
    NSArray *temp = [self listFileAtPath:[self pathToAudioFilesFolder]];

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.strFileNameArray = [temp mutableCopy];
    
    strFileNameArray = delegate.strFileNameArray;
    NSLog(@"strFileArray: %@", strFileNameArray);
    
    isPaused = NO;
    
}

-(NSArray*)listFileAtPath:(NSString *)path{
    NSLog(@"Listing all files found");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:path error:NULL];
    
    for (count = 0; count<(int)[directoryContent count]; count++) {
        NSLog(@"File %d: %@", (count+1), [directoryContent objectAtIndex:count]);
    }
    
    return directoryContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - current time and level meter
-(void)updateCurrentTimeForPlayer:(AVAudioPlayer *)p
{
    self.lblCurrTime.text = [NSString stringWithFormat:@"%02d:%02d", (int)p.currentTime / 60, (int)p.currentTime % 60, nil];
}
- (void)updateViewForPlayerState:(AVAudioPlayer *)p
{
    [self updateCurrentTimeForPlayer:p];
    
    if (updateTimer)
        [updateTimer invalidate];
    
    if (p.playing)
    {

        [lvlMeter_in setPlayer:p];
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:p repeats:YES];
    }
    else
    {
        
        [lvlMeter_in setPlayer:nil];
        updateTimer = nil;
    }
    
}
- (void)updateCurrentTime
{
    if ([player isPlaying]) {
        [self updateCurrentTimeForPlayer:player];
    }
    if ([recorder isRecording]) {
        [self updateCurrentTimeForRecorder:recorder];
    }
    
}

-(void)updateCurrentTimeForRecorder:(AVAudioRecorder *)p
{
    self.lblCurrTime.text = [NSString stringWithFormat:@"%02d:%02d", (int)p.currentTime / 60, (int)p.currentTime % 60, nil];
}
- (void)updateViewForRecorderState:(AVAudioRecorder *)p
{
    [self updateCurrentTimeForRecorder:p];
    
    if (updateTimer)
        [updateTimer invalidate];
    
    if (p.recording)
    {
        
        [lvlMeter_in setRecorder:p];
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:p repeats:YES];
    }
    else
    {
        
        [lvlMeter_in setRecorder:nil];
        updateTimer = nil;
    }
    
}

#pragma mark - btn listeners
- (IBAction)btnRecordPauseTapped:(id)sender {
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) { // paused -> recording
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        isPaused = NO;
        //**************************************** prepare recording *************************************//
        if (isNewFile == YES) {
            
            isNewFile = NO;
            
            // Set the audio file
            NSArray *pathToFile = [NSArray arrayWithObjects:
                                   [self pathToAudioFilesFolder],
                                   [self dateString],
                                   nil];
            NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathToFile];
            
            // Setup audio session
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            
            NSError *setOverrideError;
            [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&setOverrideError];
            if(setOverrideError){
                NSLog(@"%@", [setOverrideError description]);
            }
            
            
            
            // Define the recorder setting
            NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
            
            [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
            [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
            [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
            
            
            // Initiate and prepare the recorder
            recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
            recorder.delegate = self;
            recorder.meteringEnabled = YES;
            [recorder prepareToRecord];
        }
        
        //*************************************************************************************************//
        // Start recording
        [recorder record];
        [_btnRecordPause setImage:[UIImage imageNamed:@"pause.png"] forState: UIControlStateNormal];
        
        [_btnPlay setHidden:YES];
        [_btnNext setHidden:YES];
        [_btnPrev setHidden:YES];
        [_btnStop setHidden:NO];
        
        //set lblFileName
        NSURL *url = recorder.url;
        NSString *strFileName = [url lastPathComponent];
        
        _lblFileName.text = strFileName;
        
        [self updateViewForRecorderState:recorder];
        
    } else { // recording -> paused
        
        // Pause recording
        [recorder pause];
        isPaused = YES;
        
        [_btnRecordPause setImage:[UIImage imageNamed:@"record.png"] forState: UIControlStateNormal];
        
        
        [self updateViewForRecorderState:recorder];
    }
    

}

- (IBAction)btnPrevTapped:(id)sender {
    if (player.playing) {
        [player stop];
        _lblCurrTime.text = @"00:00";
        [_btnPlay setHidden:NO];
        [_btnNext setHidden:NO];
        [_btnPrev setHidden:NO];
        [_btnStop setHidden:YES];
    }

    //get prev file name
    NSString *strCurFileName = [urlPlayer lastPathComponent];
    NSInteger curIndex = [strFileNameArray indexOfObject:strCurFileName];
    
    NSInteger prevIndex = (curIndex-1 > -1) ? curIndex-1 : curIndex;
    
    NSString *strPrevFileName = [strFileNameArray objectAtIndex:prevIndex];
    
    NSArray *pathToFile = [NSArray arrayWithObjects:
                           [self pathToAudioFilesFolder],
                           strPrevFileName,
                           nil];
    urlPlayer = [NSURL fileURLWithPathComponents:pathToFile];
    
    _lblFileName.text = strPrevFileName;
}

- (IBAction)btnNextTapped:(id)sender {
    if (player.playing) {
        [player stop];
        _lblCurrTime.text = @"00:00";
        [_btnPlay setHidden:NO];
        [_btnNext setHidden:NO];
        [_btnPrev setHidden:NO];
        [_btnStop setHidden:YES];
    }
    
    //get next file name
    NSString *strCurFileName = [urlPlayer lastPathComponent];
    NSInteger curIndex = [strFileNameArray indexOfObject:strCurFileName];
    
    NSInteger nextIndex = (curIndex+1 < [strFileNameArray count]) ? curIndex+1 : curIndex;
    
    NSString *strNextFileName = [strFileNameArray objectAtIndex:nextIndex];
    
    NSArray *pathToFile = [NSArray arrayWithObjects:
                           [self pathToAudioFilesFolder],
                           strNextFileName,
                           nil];
    urlPlayer = [NSURL fileURLWithPathComponents:pathToFile];
    
    _lblFileName.text = strNextFileName;

}

- (IBAction)btnPlayTapped:(id)sender {
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:urlPlayer error:nil];
        
        if (player != nil) {
            
            
//            player.numberOfLoops = 1;
            player.delegate = self;
        }
        
        if ([player play]) {
            
            
            [self updateViewForPlayerState:player];
            [_btnPlay setHidden:YES];
            [_btnNext setHidden:NO];
            [_btnPrev setHidden:NO];
            [_btnStop setHidden:NO];
        }
        else
            NSLog(@"Could not play %@\n", player.url);
    }
}

- (IBAction)btnStopTapped:(id)sender {
    
    isNewFile = YES;
    
    if ([recorder isRecording] || isPaused) {
        [recorder stop];
        urlPlayer = recorder.url;
    }
    
    if ([player isPlaying]) {
        [player stop];
        urlPlayer = player.url;
    }
    
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    [_btnRecordPause setImage:[UIImage imageNamed:@"record.png"] forState: UIControlStateNormal];
    
    [_btnPlay setHidden:NO];
    [_btnNext setHidden:NO];
    [_btnPrev setHidden:NO];
    [_btnStop setHidden:YES];
    
//    [self updateViewForPlayerState:player];
//    [self updateViewForRecorderState:recorder];
     _lblCurrTime.text = @"00:00";
    
    

}

#pragma mark - AVAudioRecorderDelegate protocol methods
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    _lblCurrTime.text = @"00:00";
    
    [_btnRecordPause setImage:[UIImage imageNamed:@"record.png" ] forState:UIControlStateNormal];
    
    [_btnPlay setHidden:NO];
    [_btnNext setHidden:NO];
    [_btnPrev setHidden:NO];
    [_btnStop setHidden:YES];
    
    _lblCurrTime.text = @"00:00";
    
    //show an alert to enter a new file name
    NSString *alertTitle = @"Recording Finished";
    
    //    NSString *alertMessage = @"Enter new file name";
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    
    
    
    tfNewFileName = [[UITextField alloc] initWithFrame:CGRectMake(10,0,245,25)];
    tfNewFileName.placeholder = @"New File Name Here";
    tfNewFileName.borderStyle = UITextBorderStyleRoundedRect;
    tfNewFileName.keyboardType = UIKeyboardTypeAlphabet;
    tfNewFileName.delegate = self;
    v.tag = 1;
    
    [v addSubview:tfNewFileName];
    
    
    alert = [[UIAlertView alloc] initWithTitle:alertTitle message:nil delegate:self cancelButtonTitle:@"Discard" otherButtonTitles:@"Save", nil];
    [alert setValue:v  forKey:@"accessoryView"];
    
    
    [alert show];

}
#pragma mark - AVAudioPlayerDelegate protocol methods
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    
    [_btnPlay setHidden:NO];
    [_btnNext setHidden:NO];
    [_btnPrev setHidden:NO];
    [_btnStop setHidden:YES];
    
    _lblCurrTime.text = @"00:00";
}

#pragma mark - segue method
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if (player.playing) {
        [player stop];
    }
    if (recorder.recording) {
        [recorder stop];
    }
    return YES;
}
-(void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
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
        // rename to a new file name entered
        [self renameFileNameTo:strTargetFileName];
        
        //reset recorder url
        NSArray *pathToFile = [NSArray arrayWithObjects:
                               [self pathToAudioFilesFolder],
                               strTargetFileName,
                               nil];
        urlPlayer = [NSURL fileURLWithPathComponents:pathToFile];
        
        
        //add to file name array
        [strFileNameArray addObject:strTargetFileName];
        NSLog(@"strFileNameArray: %@", strFileNameArray);
        
        //set file name label
        _lblFileName.text = strTargetFileName;

    }
    else{
        //delete the recorded file
        NSString *strCurFileName = [urlPlayer lastPathComponent];
        if ([self removeFile:strCurFileName]) {
            NSLog(@"Recorded file deleted.");
            //turn to the recording-standby state
            [_btnPlay setHidden:YES];
            [_btnNext setHidden:YES];
            [_btnPrev setHidden:YES];
            [_btnStop setHidden:YES];
            
            //set lblFileName
            
            _lblFileName.text = @"";
            
        }else{
            NSLog(@"Failed to delete the recorded file");
        }
        
        //delete from strFileNameArray
        [strFileNameArray removeObject:strCurFileName];
    }
    
}

-(void)renameFileNameTo:(NSString*)strTargetFileName{
    NSString *strCurFileName = [urlPlayer lastPathComponent];
    NSString *strCurPath = [[self pathToAudioFilesFolder]stringByAppendingPathComponent:strCurFileName];
    NSString *strTargetPath = [[self pathToAudioFilesFolder]stringByAppendingPathComponent:strTargetFileName ];
    
    NSFileManager *fm = [[NSFileManager alloc]init];
    NSError *err = NULL;
    BOOL result = [fm moveItemAtPath:strCurPath toPath:strTargetPath error:&err];
    
    if (!result) {
        NSLog(@"File rename error: %@", err);
    }
}

- (BOOL)removeFile:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [self pathToAudioFilesFolder];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    
    return success;
}


@end
