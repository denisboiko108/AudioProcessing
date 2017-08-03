//
//  AppDelegate.h
//  prism
//
//  Created by My Star on 5/6/16.
//  Copyright © 2016 Silver Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, DBSessionDelegate, DBNetworkRequestDelegate>{
    NSString *relinkUserId;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *strFileNameArray;

@property int downloadFileIndex;

@end

