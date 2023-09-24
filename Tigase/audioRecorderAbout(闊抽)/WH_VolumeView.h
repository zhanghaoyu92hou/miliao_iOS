//
//  JXVolumeView.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-7-24.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WH_VolumeView : UIView{
    WH_JXImageView* _input;
    WH_JXImageView* _volume;

}
@property(nonatomic,assign) double wh_volume;
-(void)wh_show;
-(void)wh_hide;
@end
