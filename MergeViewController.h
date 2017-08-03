//
//  MergeViewController.h
//  prism
//
//  Created by My Star on 5/14/16.
//  Copyright © 2016 Silver Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MergeViewController : UIViewController{
    NSMutableArray *strFileNameArray;
    NSMutableArray *bArray;
}

@property (weak, nonatomic) IBOutlet UILabel *lblCurTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UISlider *progressBar;

@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnMerge;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@property (strong, nonatomic) NSMutableArray *strFileNameArray;
@property (strong, nonatomic) NSString *strCurFileName;


- (IBAction)btnPlayTapped:(id)sender;
- (IBAction)btnMergeTapped:(id)sender;

- (IBAction)progressSliderMoved:(UISlider*)sender;


- (IBAction)btnMoveUpTapped:(id)sender;
- (IBAction)btnMoveDownTapped:(id)sender;
- (IBAction)btnDeleteTapped:(id)sender;

@end
