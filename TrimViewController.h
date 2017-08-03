//
//  TrimViewController.h
//  prism
//
//  Created by My Star on 5/12/16.
//  Copyright © 2016 Silver Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FVSoundWaveView.h"

@interface TrimViewController : UIViewController

//@property (nonatomic, strong) NSString *strSelectedIndex;
@property NSInteger nSelectedIndex;

@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnA;
@property (weak, nonatomic) IBOutlet UIButton *btnB;
@property (weak, nonatomic) IBOutlet UIButton *btnRefresh;
@property (weak, nonatomic) IBOutlet UIButton *btnTrim;
@property (weak, nonatomic) IBOutlet UILabel *lblCurFileName;

- (IBAction)btnPlayTapped:(id)sender;
- (IBAction)btnATapped:(id)sender;
- (IBAction)btnBTapped:(id)sender;
- (IBAction)btnRefreshTapped:(id)sender;
- (IBAction)btnTrimTapped:(id)sender;

@end
