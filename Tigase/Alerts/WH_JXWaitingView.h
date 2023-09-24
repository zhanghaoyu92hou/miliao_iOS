//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-5-31.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXImageView.h"

@interface WH_JXWaitingView : UIView{
    UIActivityIndicatorView* _aiv;
    UIImageView* _iv;
    UILabel* _title;
}
- (id)initWithTitle:(NSString*)s;
-(void)wh_start:(NSString*)s;
-(void)wh_stop;
+(WH_JXWaitingView*)sharedInstance;

@property (nonatomic,assign) BOOL wh_isShowing;
@end
