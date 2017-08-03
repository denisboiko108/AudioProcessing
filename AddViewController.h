//
//  AddViewController.h
//  prism
//
//  Created by My Star on 5/15/16.
//  Copyright © 2016 Silver Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddViewController : UIViewController

@property(nonatomic, strong) NSMutableArray *strFileNameArray;
@property(nonatomic, strong) NSMutableArray *strSelectedFileNameArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, assign) id delegate;

@end

@protocol sendDataProtocal <NSObject>

-(void)sendDataToMerge: (NSMutableArray*) array;

@end