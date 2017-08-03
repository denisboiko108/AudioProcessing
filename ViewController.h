//
//  ViewController.h
//  prism
//
//  Created by My Star on 5/6/16.
//  Copyright © 2016 Silver Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CALevelMeter;

@interface ViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>{
    IBOutlet CALevelMeter				*lvlMeter_in;
}

@property (weak, nonatomic) IBOutlet UIButton *btnRecordPause;

@property (weak, nonatomic) IBOutlet UIButton *btnPrev;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;


@property (weak, nonatomic) IBOutlet UILabel *lblCurrTime;
@property (retain)				CALevelMeter	*lvlMeter_in;
@property (weak, nonatomic) IBOutlet UILabel *lblFileName;

@property (strong, nonatomic) NSMutableArray *strFileNameArray;


- (IBAction)btnRecordPauseTapped:(id)sender;
- (IBAction)btnPrevTapped:(id)sender;
- (IBAction)btnNextTapped:(id)sender;
- (IBAction)btnPlayTapped:(id)sender;
- (IBAction)btnStopTapped:(id)sender;

@end


