//
//  AddViewController.m
//  prism
//
//  Created by My Star on 5/15/16.
//  Copyright © 2016 Silver Star. All rights reserved.
//

#import "AddViewController.h"
#import "AppDelegate.h"

@interface AddViewController (){
    CGFloat fHeightOfTableView;
    
    
}

@end

@implementation AddViewController
@synthesize strFileNameArray;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //customize back button
    UIImage *buttonImage = [UIImage imageNamed:@"done.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width-5, buttonImage.size.height-10);
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
    
    
    //init strFileNameArray
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.strFileNameArray = appDelegate.strFileNameArray;
    
    
    fHeightOfTableView = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height;
//    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    
    
//    self.tableView.allowsMultipleSelectionDuringEditing = YES;
//    [self.tableView setEditing:YES animated:YES];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
}

- (void)back {
    
    NSArray *cells = [self.tableView visibleCells];
    self.strSelectedFileNameArray = [[NSMutableArray alloc]init];
    
    for (UITableViewCell *cell in cells) {
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [self.strSelectedFileNameArray addObject:cell.textLabel.text];
        }
    }
    
    [delegate sendDataToMerge:self.strSelectedFileNameArray];
    
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - UITableView Datasource & Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int nDesiredCount = (int)fHeightOfTableView / 50 + 1;
    NSUInteger nArrayCount = [strFileNameArray count];
    return (nArrayCount > nDesiredCount) ? nArrayCount : nDesiredCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row < [strFileNameArray count]) {
        cell.textLabel.text = [self.strFileNameArray objectAtIndex:indexPath.row];
    }else{
        cell.textLabel.text = @"";
    }
    
    [[UITableViewCell appearance]setTintColor:[UIColor whiteColor]];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.backgroundColor = [UIColor darkGrayColor];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}



@end
