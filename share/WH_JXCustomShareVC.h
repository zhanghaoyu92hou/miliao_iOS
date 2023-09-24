//
//  WH_JXCustomShareVC.h
//  share
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_JXCustomShareVC : UIViewController

-(void)WH_didServerNetworkResultSucces:(WH_JXNetwork*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1;
-(int)WH_didServerNetworkResultFailed:(WH_JXNetwork*)aDownload dict:(NSDictionary*)dict;
-(int)WH_didServerNetworkError:(WH_JXNetwork*)aDownload error:(NSError *)error;
-(void)WH_didServerNetworkStart:(WH_JXNetwork*)aDownload;

@end

NS_ASSUME_NONNULL_END
