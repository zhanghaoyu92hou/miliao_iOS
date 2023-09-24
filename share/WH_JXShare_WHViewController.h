//
//  WH_JXShare_WHViewController.h
//  share
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WH_JXShare_WHViewController;
@protocol JXShareVCDlegate <NSObject>

- (void)WH_sendToLifeCircleSucces:(WH_JXShare_WHViewController *)shareVC;

@end

@interface WH_JXShare_WHViewController : UIViewController

@property (nonatomic, strong) UIImage *wh_image;
@property (nonatomic, strong) NSDictionary *wh_dataDict;
@property (nonatomic, strong) UITextView *wh_textView;

@property (weak, nonatomic) id <JXShareVCDlegate> wh_delegate;

@end

