//
//  RecordedFilesViewController.h
//  prism
//
//  Created by My Star on 5/7/16.
//  Copyright © 2016 Silver Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordedFilesViewController : UIViewController{
    NSMutableArray *strFileNameArray;
    NSMutableArray *bArray;
    
    UIAlertView *alert;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (IBAction)btnRenameTapped:(id)sender;
- (IBAction)btnPlayTapped:(id)sender;
- (IBAction)btnUploadTapped:(id)sender;
- (IBAction)btnMergeTapped:(id)sender;
- (IBAction)btnTrimTapped:(id)sender;
- (IBAction)btnDeleteTapped:(id)sender;

@end
