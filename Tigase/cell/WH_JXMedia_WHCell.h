//
//  WH_JXMedia_WHCell.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXVideoPlayer.h"

@class WH_JXMediaObject;

@interface WH_JXMedia_WHCell : UITableViewCell{
    UIImageView* bageImage;
    UILabel* bageNumber;
    WH_JXVideoPlayer* _player;
}
@property (nonatomic,strong) UIButton* pauseBtn;
@property (nonatomic,strong) UIImageView* head;
@property (nonatomic,strong) NSString*  bage;
@property (nonatomic,strong) WH_JXMediaObject* media;
@property (nonatomic,weak) id delegate;

- (void)sp_getUserName;
@end
