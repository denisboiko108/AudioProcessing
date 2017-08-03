//
//  AppDelegate.m
//  prism
//
//  Created by My Star on 5/6/16.
//  Copyright © 2016 Silver Star. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize downloadFileIndex;

@synthesize strFileNameArray;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    strFileNameArray = [[NSMutableArray alloc]init];
    
    [NSThread sleepForTimeInterval:3];
    
    // Override point for customization after application launch.
    NSString *dropBoxAppKey = @"0w0tiws76g81thj";
    NSString *dropBoxAppSecret = @"ou7hp0qgj1k78nm";
    NSString *root = kDBRootDropbox;
    
    DBSession* session =
    [[DBSession alloc] initWithAppKey:dropBoxAppKey appSecret:dropBoxAppSecret root:root];
    session.delegate = self;
    [DBSession setSharedSession:session];
    
    [DBRequest setNetworkRequestDelegate:self];
    
    downloadFileIndex = 0;
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"OPEN_DROPBOX_VIEW" object:nil]];
        }
        return YES;
    }
    return NO;
}
#pragma mark - DBSessionDelegate methods
- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
    relinkUserId = userId;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *relink = [UIAlertAction actionWithTitle:@"Relink" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *controller = (UINavigationController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"NavigationController"];
        [[DBSession sharedSession] linkFromController:[controller visibleViewController]];
        
        relinkUserId = nil;
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:relink];
    [alertController addAction:cancel];
    
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    
//    [[[UIAlertView alloc] initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self
//                      cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil] show];

}

//#pragma mark UIAlertViewDelegate methods
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index
//{
//    if (index != alertView.cancelButtonIndex) {
//        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//        UINavigationController *controller = (UINavigationController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"NavigationController"];
//        [[DBSession sharedSession] linkFromController:[controller visibleViewController]];
//    }
//    relinkUserId = nil;
//}

#pragma mark - DBNetworkRequestDelegate methods
static int outstandingRequests;
- (void)networkRequestStarted
{
    outstandingRequests++;
    if (outstandingRequests == 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)networkRequestStopped
{
    outstandingRequests--;
    if (outstandingRequests == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
