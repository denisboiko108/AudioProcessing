//
//  CustomRecordCell.h
//  prism
//
//  Created by My Star on 5/7/16.
//  Copyright © 2016 Silver Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomRecordCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnRename;
@property (weak, nonatomic) IBOutlet UIButton *btnUpload;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnTrim;
@property (weak, nonatomic) IBOutlet UIButton *btnMerge;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

@end
