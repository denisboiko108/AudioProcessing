//
//  MergeViewController.m
//  prism
//
//  Created by My Star on 5/14/16.
//  Copyright © 2016 Silver Star. All rights reserved.
//

#import "MergeViewController.h"
#import "AVFoundation/AVFoundation.h"
#import "CustomMergeCell.h"
#import "AddViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface MergeViewController ()<AVAudioPlayerDelegate, UITextFieldDelegate>{
    AVAudioPlayer *player;
    NSTimer *updateTimer;
    
    UIImage *imgPlay;
    UIImage *imgPause;
    
    CGFloat fHeightOfTableView;
    
    CGFloat fSumDurationsPlayed; //saves sum of durations played
    CGFloat fTotalDuration;
    
    NSMutableArray *fDurationArray;
    
    int nCurFileIndex;
    BOOL isPaused;
    
    NSInteger nSelectedIndex;
    
    UITextField *tfNewFileName;
    UIAlertView *alert;
}

@end

@implementation MergeViewController
@synthesize strCurFileName;

-(void)viewDidAppear:(BOOL)animated{
    //adjust moveup and movedown button positions
    [self.tableView reloadData];
    
    NSLog(@"viewDidAppear called!");
    
    //init fDurationArray
    fDurationArray = [[NSMutableArray alloc]init];
//    [fDurationArray addObject:[NSNumber numberWithFloat:0.0]];
    
    _lblCurTime.text = @"00:00";
    _lblDuration.text = [self strTotalDurationFromArray: strFileNameArray];
    
    _progressBar.maximumValue = fTotalDuration;
    _progressBar.minimumValue = 0.0;
    
    fSumDurationsPlayed = 0;
    nCurFileIndex = 0;
    _progressBar.value = 0.0;
    
    isPaused = NO;
    
    
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:150.0f/255.0f green:0 blue:1 alpha:1]];
   
}

-(NSString*) strTotalDurationFromArray: (NSMutableArray*)fileNameArray{
    NSString *strTotalDuration;
    
    fTotalDuration = 0;
    
    int totalSoundsInQueue = (int)[fileNameArray count];
    for (int i=0; i<totalSoundsInQueue; i++) {
        NSString *sound = [fileNameArray objectAtIndex:i];
        
        NSArray *pathToFile = [NSArray arrayWithObjects:
                                   [self pathToAudioFilesFolder],
                                   sound,
                                   nil];
        NSURL *urlTemp = [NSURL fileURLWithPathComponents:pathToFile];
//        AVAudioPlayer *tempPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:urlPlayer error:NULL];
        
        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:urlTemp options:nil];
        CMTime audioDuration = audioAsset.duration;
        
        CGFloat fDuration = CMTimeGetSeconds(audioDuration);
        
        [fDurationArray addObject:[NSNumber numberWithFloat:fDuration]];
        
        fTotalDuration += fDuration;
        
    }
    
    strTotalDuration = [NSString stringWithFormat:@"%02d:%02d", ((int)fTotalDuration)/60, ((int)fTotalDuration)%60];
    
    NSLog(@"fDurationArray: %@", fDurationArray);
    return strTotalDuration;
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
    
    
    

    //set strFileNameArray & bArray
    strFileNameArray = [[NSMutableArray alloc]init];
    [strFileNameArray addObject:strCurFileName];
    
    if (!bArray) {
        bArray    = [NSMutableArray array];
    }
    for (int i=0; i<[strFileNameArray count]; i++) {
        [bArray addObject:[NSNumber numberWithBool:NO]];
    }
    
    fHeightOfTableView = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 230;
    
    
    imgPlay = [UIImage imageNamed:@"play.png"];
    imgPause = [UIImage imageNamed:@"pause_small.png"];
    
    [_btnPlay setImage:imgPlay forState:UIControlStateNormal];
    
    updateTimer = nil;
    
    _lblDuration.adjustsFontSizeToFitWidth = YES;
    _lblCurTime.adjustsFontSizeToFitWidth = YES;
   
    
    // Load the the sample file, use mono or stero sample
//    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"m4a"]];
//   
//    
//    player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
//    
//    if (player != nil) {
//        [self updateViewForPlayerInfo:player];
//        [self updateViewForPlayerState:player];
//        player.delegate = self;
//    }
    
    
    
    //	[[AVAudioSession sharedInstance] setDelegate: self];
    
    NSError *setCategoryError = nil;
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    
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

#pragma mark - button listeners

-(void)updateCurrentTimeForPlayer:(AVAudioPlayer *)p
{
    CGFloat fCurrentTime = fSumDurationsPlayed + p.currentTime;
    _lblCurTime.text = [NSString stringWithFormat:@"%02d:%02d", (int)fCurrentTime / 60, (int)fCurrentTime % 60, nil];
    _progressBar.value = fCurrentTime;
}

- (void)updateCurrentTime
{
    [self updateCurrentTimeForPlayer:player];
}

- (void)updateViewForPlayerState:(AVAudioPlayer *)p
{
    [self updateCurrentTimeForPlayer:p];
    
    if (updateTimer)
        [updateTimer invalidate];
    
    if (p.playing)
    {
        [_btnPlay setImage:((p.playing == YES) ? imgPause : imgPlay) forState:UIControlStateNormal];
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateCurrentTime) userInfo:p repeats:YES];
    }
    else
    {
        [_btnPlay setImage:((p.playing == YES) ? imgPause : imgPlay) forState:UIControlStateNormal];
        updateTimer = nil;
    }
    
}

//-(void)updateViewForPlayerInfo:(AVAudioPlayer*)p
//{
//    _lblDuration.text = [NSString stringWithFormat:@"%02d:%02d", (int)p.duration / 60, (int)p.duration % 60, nil];
//    _progressBar.maximumValue = p.duration;
//}

-(void)pausePlaybackForPlayer:(AVAudioPlayer*)p
{
    [p pause];
    [self updateViewForPlayerState:p];
}

-(void)startPlaybackForPlayer:(AVAudioPlayer*)p
{
    if (isPaused) {
        [p play];
        isPaused = NO;
        [self updateViewForPlayerState:p];
    }else{
        [self play:nCurFileIndex];
    }
   
}

- (IBAction)progressSliderMoved:(UISlider *)sender
{
    player.currentTime = sender.value;
    [self updateCurrentTimeForPlayer:player];
}

- (IBAction)btnMoveUpTapped:(id)sender {
    if (nSelectedIndex == 0) {
        return;
    }
    NSString *strFileName = [strFileNameArray objectAtIndex:nSelectedIndex];
    NSString *strFileName2 = [strFileNameArray objectAtIndex:nSelectedIndex-1];
    
    NSString *temp = [NSString stringWithString:strFileName];
    [strFileNameArray setObject:strFileName2 atIndexedSubscript:nSelectedIndex];
    [strFileNameArray setObject:temp atIndexedSubscript:nSelectedIndex-1];
    
    
    //duration array
    NSNumber *numDuration = [fDurationArray objectAtIndex:nSelectedIndex];
    NSNumber *numDuration2 = [fDurationArray objectAtIndex:nSelectedIndex-1];
    
    NSNumber *numTemp = [NSNumber numberWithFloat:[numDuration floatValue]];
    [fDurationArray setObject:numDuration2 atIndexedSubscript:nSelectedIndex];
    [fDurationArray setObject:numTemp atIndexedSubscript:nSelectedIndex-1];
    
    
    [self.tableView reloadData];
    
}

- (IBAction)btnMoveDownTapped:(id)sender {
    if (nSelectedIndex+1 >= [strFileNameArray count]) {
        return;
    }
    NSString *strFileName = [strFileNameArray objectAtIndex:nSelectedIndex];
    NSString *strFileName2 = [strFileNameArray objectAtIndex:nSelectedIndex+1];
    
    NSString *temp = [NSString stringWithString:strFileName];
    [strFileNameArray setObject:strFileName2 atIndexedSubscript:nSelectedIndex];
    [strFileNameArray setObject:temp atIndexedSubscript:nSelectedIndex+1];
    
    
    //duration array
    NSNumber *numDuration = [fDurationArray objectAtIndex:nSelectedIndex];
    NSNumber *numDuration2 = [fDurationArray objectAtIndex:nSelectedIndex+1];
    
    NSNumber *numTemp = [NSNumber numberWithFloat:[numDuration floatValue]];
    [fDurationArray setObject:numDuration2 atIndexedSubscript:nSelectedIndex];
    [fDurationArray setObject:numTemp atIndexedSubscript:nSelectedIndex+1];
    
    
    [self.tableView reloadData];
}

- (IBAction)btnDeleteTapped:(id)sender {
    NSString *strFileName = [strFileNameArray objectAtIndex:nSelectedIndex];
    
    if ([player isPlaying]) {
        [player stop];
    }
    
    if (YES) {
        NSLog(@"Recorded file deleted.");
        
        //update total duration
        fTotalDuration = fTotalDuration - [[fDurationArray objectAtIndex:nSelectedIndex] floatValue];
        _lblDuration.text = [NSString stringWithFormat:@"%02d:%02d", ((int)fTotalDuration)/60, ((int)fTotalDuration)%60];
        
        //delete from durationArray
        [fDurationArray removeObjectAtIndex:nSelectedIndex];
        
        //delete from strFileNameArray
        [strFileNameArray removeObject:strFileName];
        
        //reload all sections to delete the section
        [bArray replaceObjectAtIndex:nSelectedIndex withObject:[NSNumber numberWithBool:NO]];
        [_tableView reloadData];
        
        //reset slider
        _progressBar.maximumValue = fTotalDuration;
    }

}
//- (BOOL)removeFile:(NSString *)filename
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *documentsPath = [self pathToAudioFilesFolder];
//    
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
//    NSError *error;
//    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
//    
//    return success;
//}
- (IBAction)btnPlayTapped:(id)sender {
    if (player.playing == YES){
        isPaused = YES;
        [self pausePlaybackForPlayer: player];
    }
    else
        [self startPlaybackForPlayer: player];
}

- (IBAction)btnMergeTapped:(id)sender {
    NSLog(@"btnMergeTapped");
    if (player.playing) {
        [player stop];
    }
    
    //show an alert to enter a new file name
    NSString *alertTitle = @"New File Name";
    
    //    NSString *alertMessage = @"Enter new file name";
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    
    
    
    tfNewFileName = [[UITextField alloc] initWithFrame:CGRectMake(10,0,245,25)];
    tfNewFileName.placeholder = @"Output File Name Here";
    tfNewFileName.borderStyle = UITextBorderStyleRoundedRect;
    tfNewFileName.keyboardType = UIKeyboardTypeAlphabet;
    tfNewFileName.delegate = self;
    v.tag = 1;
    
    [v addSubview:tfNewFileName];
    
    
    alert = [[UIAlertView alloc] initWithTitle:alertTitle message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
    [alert setValue:v  forKey:@"accessoryView"];
 
    
    [alert show];
}

- (BOOL) mergeFiles:(NSString*) strTargetFileName{
    
    NSError *error = nil;
    BOOL ok = NO;
   
    CMTime nextClipStartTime = kCMTimeZero;
    //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    for (int i = 0; i< [strFileNameArray count]; i++) {
        NSString *audioFileName = [strFileNameArray objectAtIndex:i];
        
        //Build the filename with path
        NSArray *pathToFile = [NSArray arrayWithObjects:                                                                  [self pathToAudioFilesFolder],                                                                  audioFileName,
            nil];
        NSURL *url = [NSURL fileURLWithPathComponents:pathToFile];
        
        AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
        if ([tracks count] == 0)
            return NO;
        CMTimeRange timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [avAsset duration]);
        AVAssetTrack *clipAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        ok = [compositionAudioTrack insertTimeRange:timeRangeInAsset  ofTrack:clipAudioTrack atTime:nextClipStartTime error:&error];
        if (!ok) {
            NSLog(@"Current Video Track Error: %@",error);
        }
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration);
    }
    
    // create the export session
    // no need for a retain here, the session will be retained by the
    // completion handler since it is referenced there
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:composition
                                           presetName:AVAssetExportPresetAppleM4A];
    if (nil == exportSession) return NO;
    
    NSArray *soundOneNew = [NSArray arrayWithObjects:                                                                  [self pathToAudioFilesFolder],                                                                  strTargetFileName,
        nil];

    
    // configure export session  output with all our parameters
    exportSession.outputURL = [NSURL fileURLWithPathComponents:soundOneNew]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    
    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
        } else {
            NSLog(@"Export Session Status: %ld", exportSession.status);
        }
    }];
    
    return YES;
}

//-(void)playSoundSequence{
//    int totalSoundsInQueue = (int)[strFileNameArray count];
//    NSLog(@"strFileNameArray: %@", strFileNameArray);
//    
//    for (int i=0; i<totalSoundsInQueue; i) {
//        NSString *sound = [strFileNameArray objectAtIndex:i];
//        
//        //wait until the audio player is not playing anything
//        while (![player isPlaying]) {
//            NSArray *pathToFile = [NSArray arrayWithObjects:
//                                   [self pathToAudioFilesFolder],
//                                   sound,
//                                   nil];
//            NSURL *urlPlayer = [NSURL fileURLWithPathComponents:pathToFile];
//            AVAudioPlayer *tempPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:urlPlayer error:NULL];
//            
//            player = tempPlayer;
//            
//            [player setVolume:1.0f];
//            [player prepareToPlay];
//            
//            if ([player play]) {
//                [self updateViewForPlayerState:player];
//                player.delegate = self;
//            }
//            
//            //increment for loop counter & move onto next iteration
//            fSumDurationsPlayed += [[fDurationArray objectAtIndex:i] floatValue];
//            i++;
//            
//        }
//    }
//    
//    //played all audio files, now set fSumDurationsPlayed to 0
//    fSumDurationsPlayed = 0;
//}

-(void)play:(int)i{
    NSString *sound = [strFileNameArray objectAtIndex:i];
    
    NSArray *pathToFile = [NSArray arrayWithObjects:
                           [self pathToAudioFilesFolder],
                           sound,
                           nil];
    NSURL *urlPlayer = [NSURL fileURLWithPathComponents:pathToFile];
    
    player = [[AVAudioPlayer alloc]initWithContentsOfURL:urlPlayer error:NULL];
    player.delegate = self;
//    [player setVolume:1.0f];
    [player prepareToPlay];
    
    
    if (i>0) {
        fSumDurationsPlayed += [[fDurationArray objectAtIndex:i-1] floatValue];
    }
    
    
    if ([player play]) {
        [self updateViewForPlayerState:player];
    }
    
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


#pragma mark AVAudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)flag
{
    nCurFileIndex++;
    if (nCurFileIndex < [strFileNameArray count]){
        isPaused = NO;
        [self play:nCurFileIndex];
    }else{
        [p setCurrentTime:0.];
        nCurFileIndex = 0;
        isPaused = NO;
        fSumDurationsPlayed = 0;
        [self updateViewForPlayerState:p];
        
    }
    
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error
{
    NSLog(@"ERROR IN DECODE: %@\n", error);
}


#pragma mark - UITableView Datasource & Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    int nDesiredCount = (int)fHeightOfTableView / 50 + 1;
    NSUInteger nArrayCount = [strFileNameArray count];
    return (nArrayCount > nDesiredCount) ? nArrayCount : nDesiredCount;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section >= [strFileNameArray count]) {
        return 0;
    }
    if ([[bArray objectAtIndex:section] boolValue]) {
        return 1;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView              = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    headerView.tag                  = section;
    headerView.backgroundColor      = [UIColor darkGrayColor];
    
    if (section >= [strFileNameArray count]) {
        return headerView;
    }
    
    UILabel *headerString           = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20-50, 50)];
    headerString.text = [strFileNameArray objectAtIndex:section];
    headerString.textAlignment      = NSTextAlignmentLeft;
    headerString.textColor          = [UIColor whiteColor];
    [headerView addSubview:headerString];
    
    UITapGestureRecognizer  *headerTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
    [headerView addGestureRecognizer:headerTapped];
    
    //up or down arrow depending on the bool
    BOOL manyCells                  = [[bArray objectAtIndex:section] boolValue];
    
    UIImageView *upDownArrow        = [[UIImageView alloc] initWithImage:manyCells ? [UIImage imageNamed:@"dropup"] : [UIImage imageNamed:@"dropdown"] ];
    upDownArrow.autoresizingMask    = UIViewAutoresizingFlexibleLeftMargin;
    upDownArrow.frame               = CGRectMake(self.view.frame.size.width-40, 10, 30, 30);
    [headerView addSubview:upDownArrow];
    
    
    return headerView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer  = [[UIView alloc] initWithFrame:CGRectZero];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CustomMergeCell";
    
    CustomMergeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomMergeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // hide delete button if cell.text == strCurFileName
    if ([[strFileNameArray objectAtIndex:indexPath.section] isEqualToString:strCurFileName]) {
        [cell.btnDelete setEnabled:NO];
        
//        CGRect frame = cell.btnMoveUp.frame;
//        frame.origin.x = self.view.frame.size.width / 3;
//        [cell.btnMoveUp setFrame:frame];
//        [cell.btnMoveUp setHidden:YES];
//        [cell.btnMoveUp setHidden:NO];
//        
//        NSLog(@"moveup: %f", frame.origin.x);
//        
//        frame = cell.btnMoveDown.frame;
//        frame.origin.x = self.view.frame.size.width * 2 / 3;
//        [cell.btnMoveDown setFrame:frame];
        
    }else{
        [cell.btnDelete setEnabled:YES];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}
#pragma mark - gesture tapped
- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer{
    //stop player if playing
    if (player.playing) {
        [player stop];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    
    //save currently selected index
    nSelectedIndex = indexPath.section;
    
    if (indexPath.row == 0) {
        BOOL collapsed  = [[bArray objectAtIndex:indexPath.section] boolValue];
        collapsed       = !collapsed;
        
        //collapse all sections except selected section
        for (int i=0; i<[bArray count]; i++) {
            if (i==indexPath.section) {
                continue;
            }
            
            NSInteger nsi = i;
            NSNumber *num = [bArray objectAtIndex:nsi];
            if ([num intValue] == 1) {
                //collapse the section
                [bArray replaceObjectAtIndex:nsi withObject:[NSNumber numberWithBool:NO]];
                
                
                //reload the section
                NSRange range   = NSMakeRange(nsi, 1);
                NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
                [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
            }
            
        }
        
        
        [bArray replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithBool:collapsed]];
        
        NSLog(@"bArray%@", bArray);
        
        //reload the section
        NSRange range   = NSMakeRange(indexPath.section, 1);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
        
        
        
        
        
    }
}

#pragma mark - sendData deletegate method

-(void)sendDataToMerge: (NSMutableArray*) array{
    NSLog(@"sendDataToMerge called %@", array);
    
    [strFileNameArray addObjectsFromArray:array];
    
    for (int i=0; i<[array count]; i++) {
        [bArray addObject:[NSNumber numberWithBool:NO]];
    }
    
    [self.tableView reloadData];
}

#pragma mark - segue method

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([player isPlaying]) {
        [player stop];
        [self updateViewForPlayerState:player];
    }
    AddViewController *addViewController = (AddViewController*)[segue destinationViewController];
    addViewController.delegate = self;
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
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        // merge to a new file name entered
        [self mergeFiles:strTargetFileName];
        
        //update strFileNameArray of delegate
        AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [delegate.strFileNameArray addObject:strTargetFileName];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
    
}

@end
