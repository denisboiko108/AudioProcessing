//
//  RecordedFilesViewController.m
//  prism
//
//  Created by My Star on 5/7/16.
//  Copyright © 2016 Silver Star. All rights reserved.
//

#import "RecordedFilesViewController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomRecordCell.h"
#import "TrimViewController.h"
#import "MergeViewController.h"
#import <MessageUI/MessageUI.h>
#import <DropboxSDK/DropboxSDK.h>
#import "MBProgressHUD.h"

#define RENAME 0
#define DELETE 1

@interface RecordedFilesViewController ()<UITableViewDataSource,UITableViewDelegate, AVAudioPlayerDelegate, UITextFieldDelegate, /*MFMailComposeViewControllerDelegate,*/ DBRestClientDelegate>{
    CGFloat fHeightOfTableView;
    NSInteger nSelectedIndex;
    
    AVAudioPlayer *player;
    
    UITextField *tfNewFileName;
    
    DBRestClient *restClient;
}

@end

@implementation RecordedFilesViewController

-(void)viewDidAppear:(BOOL)animated{
    
    if ([bArray count] != [strFileNameArray count]) {
        [bArray addObject:[NSNumber numberWithBool:NO]];
    }
    
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate *delegate = (AppDelegate*)[ UIApplication sharedApplication].delegate;
    strFileNameArray = delegate.strFileNameArray;
    
    NSLog(@"strFileNameArray in RecordedFilesVC: %@", strFileNameArray);
    if (!bArray) {
        bArray    = [NSMutableArray array];
    }
    for (int i=0; i<[strFileNameArray count]; i++) {
        [bArray addObject:[NSNumber numberWithBool:NO]];
    }
    
    fHeightOfTableView = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height;
    
    //customize back button
    UIImage *buttonImage = [UIImage imageNamed:@"mic.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;

    
}
- (void)back {
    //stop player if playing
    if (player.playing) {
        [player stop];
    }
    
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
    static NSString *CellIdentifier = @"CustomRecordCell";
    
    CustomRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // set play button image according to player state
    if (player.playing) {
        [cell.btnPlay setImage:[UIImage imageNamed:@"cell_stop.png"] forState:UIControlStateNormal];
    }else{
        [cell.btnPlay setImage:[UIImage imageNamed:@"cell_play.png"] forState:UIControlStateNormal];
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
        
        //save currently selected index
        nSelectedIndex = indexPath.section;
        
        

    }
}


#pragma mark - button listeners
- (IBAction)btnRenameTapped:(id)sender {
    NSLog(@"btnRenameTapped");
    if (player.playing) {
        [player stop];
    }
    
    //show an alert to enter a new file name
    NSString *alertTitle = @"New File Name";
    
//    NSString *alertMessage = @"Enter new file name";
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    
    
    
    tfNewFileName = [[UITextField alloc] initWithFrame:CGRectMake(10,0,245,25)];
    tfNewFileName.placeholder = @"New File Name Here";
    tfNewFileName.borderStyle = UITextBorderStyleRoundedRect;
    tfNewFileName.keyboardType = UIKeyboardTypeAlphabet;
    tfNewFileName.delegate = self;
    v.tag = 1;
    
    [v addSubview:tfNewFileName];
    
    
    alert = [[UIAlertView alloc] initWithTitle:alertTitle message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
    [alert setValue:v  forKey:@"accessoryView"];
    alert.tag = RENAME;
    
    [alert show];
}
-(void)renameFileNameTo:(NSString*)strTargetFileName{
    NSString *strCurFileName = [strFileNameArray objectAtIndex:nSelectedIndex];
    NSString *strCurPath = [[self pathToAudioFilesFolder]stringByAppendingPathComponent:strCurFileName];
    NSString *strTargetPath = [[self pathToAudioFilesFolder]stringByAppendingPathComponent:strTargetFileName ];
    
    NSFileManager *fm = [[NSFileManager alloc]init];
    NSError *err = NULL;
    BOOL result = [fm moveItemAtPath:strCurPath toPath:strTargetPath error:&err];
    
    if (!result) {
        NSLog(@"File rename error: %@", err);
    }
}

- (IBAction)btnPlayTapped:(id)sender {
    //stop player if playing and change to play icon
    if (player.playing) {
        [player stop];
        
        //reload specific section animated to change to play icon
        NSRange range   = NSMakeRange(nSelectedIndex, 1);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];

        return;
    }
    
    NSArray *pathToFile = [NSArray arrayWithObjects:
                           [self pathToAudioFilesFolder],
                           [strFileNameArray objectAtIndex:nSelectedIndex ],
                           nil];
    NSURL *urlPlayer = [NSURL fileURLWithPathComponents:pathToFile];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:urlPlayer error:nil];
    
    if (player != nil) {
        
        player.delegate = self;
    }
    
    if ([player play]) {
        //change to stop icon
        //reload specific section animated to change to play icon
        NSRange range   = NSMakeRange(nSelectedIndex, 1);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    }
    else
        NSLog(@"Could not play %@\n", player.url);

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

- (IBAction)btnUploadTapped:(id)sender {
//    if (player.playing) {
//        [player stop];
//    }
//    
//    UIAlertController * view=   [UIAlertController
//                                 alertControllerWithTitle:nil
//                                 message:nil
//                                 preferredStyle:UIAlertControllerStyleActionSheet];
//    
//    
//    UIAlertAction* email = [UIAlertAction
//                         actionWithTitle:@"Email"
//                         style:UIAlertActionStyleDefault
//                         handler:^(UIAlertAction * action)
//                         {
//                             //Do some thing here
//                             [self showEmail];
//                             [view dismissViewControllerAnimated:YES completion:nil];
//                             
//                         }];
//    UIAlertAction* dropbox = [UIAlertAction
//                            actionWithTitle:@"Upload to Dropbox"
//                            style:UIAlertActionStyleDefault
//                            handler:^(UIAlertAction * action)
//                            {
//                                //Do some thing here
//                                [self uploadToDropbox];
//                                [view dismissViewControllerAnimated:YES completion:nil];
//                                
//                            }];
//    UIAlertAction* cancel = [UIAlertAction
//                             actionWithTitle:@"Cancel"
//                             style:UIAlertActionStyleCancel
//                             handler:^(UIAlertAction * action)
//                             {
//                                 [view dismissViewControllerAnimated:YES completion:nil];
//                                 
//                             }];
//    
//    
//    [view addAction:email];
//    [view addAction:dropbox];
//    [view addAction:cancel];
//    [self presentViewController:view animated:YES completion:nil];
    
    NSString *strCurFileName = [strFileNameArray objectAtIndex:nSelectedIndex ];
    NSArray *pathToFile = [NSArray arrayWithObjects:
                           [self pathToAudioFilesFolder],
                           strCurFileName,
                           nil];
    NSURL *urlPlayer = [NSURL fileURLWithPathComponents:pathToFile];
    NSArray *objectsToShare = @[strCurFileName, urlPlayer];
//    NSMutableArray *temp = [[NSMutableArray alloc]init];
//    [temp addObject:urlPlayer];
//    NSArray *objectsToShare = [NSArray arrayWithArray:temp];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    [controller setValue:@"Hello" forKey:@"subject"];
    
    NSArray *excludedActivities = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    
//    if (IS_IPAD) {
//        controller.modalPresentationStyle = UIModalPresentationPopover;
//    }
//    [self presentViewController:controller animated:YES completion:nil];
//    if (IS_IPAD) {
//        UIPopoverPresentationController * popController = [controller popoverPresentationController];
//        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
//        popController.sourceView = self.btnShare;
//        
//    }
    
    


    [controller setCompletionWithItemsHandler:^(NSString  *activityType, BOOL completed, NSArray  *returnedItems, NSError * activityError) {
        // react to the completion
        if (completed) {
            
            // user shared an item
            NSLog(@"We used activity type%@", activityType);
            
        } else {
            
            // user cancelled
            NSLog(@"We didn't want to share anything after all.");
        }
        
        if (activityError) {
            NSLog(@"An Error occured: %@, %@", activityError.localizedDescription, activityError.localizedFailureReason);
        }
    }];
    
    // and present it
    [self presentViewController:controller animated:YES completion:^{
        // executes after the user selects something
    }];
}
    
//-(void)showEmail{
//    // Email Subject
//    NSString *emailTitle = @"Hello";
//    // Email Content
//    NSString *messageBody = @"I'd like to send this audio file.";
//    // To address
////    NSArray *toRecipients = [NSArray arrayWithObject:@"support@appcoda.com"];
//    
//    
//    if ([MFMailComposeViewController canSendMail]) {
//        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
//        mc.mailComposeDelegate = self;
//        [mc setSubject:emailTitle];
//        [mc setMessageBody:messageBody isHTML:NO];
////        [mc setToRecipients:toRecipients];
//        
//        // Get the resource path and read the file using NSData
//        NSString *filename = [strFileNameArray objectAtIndex:nSelectedIndex];
//        NSString *filePath = [[self pathToAudioFilesFolder] stringByAppendingPathComponent:filename];
//        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
//        
//        // Determine the MIME type
//        NSString *mimeType = @"audio/m4a";
//        
//        // Add attachment
//        [mc addAttachmentData:fileData mimeType:mimeType fileName:filename];
//        
//        // Present mail view controller on screen
//        [self presentViewController:mc animated:YES completion:NULL];
//    }else{
//       
//        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to send email. Configure your mail account please." preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction* ok = [UIAlertAction
//                             actionWithTitle:@"OK"
//                             style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action)
//                             {
//                                 [controller dismissViewControllerAnimated:YES completion:nil];
//                                 [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"mailto:test@test.com"]];
//                                 
//                             }];
//        [controller addAction:ok];
//        [self presentViewController:controller animated:YES completion:nil];
//    }
//    
//}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            
            [self showSuccessAlert];
            
            
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}
-(void)showSuccessAlert{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"Email Sent successfully!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [controller dismissViewControllerAnimated:YES completion:nil];
                             
                             
                         }];
    [controller addAction:ok];
    [[self topMostController] presentViewController:controller animated:YES completion:nil];

}

- (IBAction)btnMergeTapped:(id)sender {
    if (player.playing) {
        [player stop];
    }
}

- (IBAction)btnTrimTapped:(id)sender {
    if (player.playing) {
        [player stop];
    }
}

- (IBAction)btnDeleteTapped:(id)sender {
    if (player.playing) {
        [player stop];
    }
    
    //show an alert to enter a new file name
    NSString *alertTitle = @"Confirm";
    
    NSString *alertMessage = @"Are you sure to delete the file?";
    
    UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    alertDelete.tag = DELETE;
    
    [alertDelete show];
    
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

#pragma mark - AVAudioPlayerDelegate protocol methods
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    //reload specific section animated to change to play icon
    NSRange range   = NSMakeRange(nSelectedIndex, 1);
    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    
    
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == RENAME) {
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
            
            //update strFileNameArray
            [strFileNameArray  setObject:strTargetFileName atIndexedSubscript:nSelectedIndex];
            
            //reload specific section animated to change to new file name
            NSRange range   = NSMakeRange(nSelectedIndex, 1);
            NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
            
        }
    }
    
    if (alertView.tag == DELETE) {
        
        if (buttonIndex == 1) {
            
            NSString *strCurFileName = [strFileNameArray objectAtIndex:nSelectedIndex];
            
            if ([self removeFile:strCurFileName]) {
                NSLog(@"Recorded file deleted.");
                
                //delete from strFileNameArray
                [strFileNameArray removeObject:strCurFileName];
                
                //reload all sections to delete the section
                [bArray replaceObjectAtIndex:nSelectedIndex withObject:[NSNumber numberWithBool:NO]];
                [_tableView reloadData];
              
                
            }else{
                NSLog(@"Failed to delete the recorded file");
            }
            
        }
        
    }

}

#pragma mark - segue method
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier]isEqualToString:@"segueToTrim"]) {
        TrimViewController *trimViewController = (TrimViewController*)[segue destinationViewController];
        trimViewController.nSelectedIndex = nSelectedIndex;
    }
    if ([[segue identifier]isEqualToString:@"segueToMerge"]) {
        MergeViewController *mergeViewController = (MergeViewController*)[segue destinationViewController];
        mergeViewController.strCurFileName = [strFileNameArray objectAtIndex:nSelectedIndex];
    }
    
}

#pragma mark - dropbox methods

-(void)uploadToDropbox{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //login
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
        NSLog(@"Not Linked!");
    }
    else{
        NSLog(@"Linked!");
        
        [self.navigationController.navigationItem.leftBarButtonItem setEnabled:NO];
        
        [self performSelector:@selector(uploadFileToDropBox:) withObject:[strFileNameArray objectAtIndex:nSelectedIndex] afterDelay:.1];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLoginDone) name:@"OPEN_DROPBOX_VIEW" object:nil];
    
    

}
-(void)dropboxLoginDone
{
    NSLog(@"Logged in!");
    
    [self.navigationController.navigationItem.leftBarButtonItem setEnabled:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(uploadFileToDropBox:) withObject:[strFileNameArray objectAtIndex:nSelectedIndex] afterDelay:.1];
}

-(void)uploadFileToDropBox:(NSString *)uploadFileName
{
    NSString *desfilePath =[ NSString stringWithFormat:@"/"];
    NSString *filePath = [[self pathToAudioFilesFolder] stringByAppendingPathComponent:uploadFileName];
    NSLog(@"filePath: %@", filePath);
    
    restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    restClient.delegate = self;
    
    if (restClient == nil) {
        NSLog(@"restClient is nil");
    }
    
    [restClient uploadFile:uploadFileName toPath:desfilePath withParentRev:@"" fromPath:filePath];
    
}

#pragma mark - DBRestClientDelegate Methods for Upload Data
-(void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.navigationController.navigationItem.leftBarButtonItem setEnabled:YES];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"Uploaded successfully!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    [controller addAction:ok];
    
    [[self topMostController] presentViewController:controller animated:YES completion:nil];
    
}

-(void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.navigationController.navigationItem.leftBarButtonItem setEnabled:YES];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"Failed to Upload!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    [controller addAction:ok];
    
    [[self topMostController] presentViewController:controller animated:YES completion:nil];
}

@end
