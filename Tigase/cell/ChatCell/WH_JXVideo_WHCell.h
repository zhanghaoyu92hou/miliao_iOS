//
//  MiXin_JXVideo_MiXinCell.h
//  wahu_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXBaseChat_WHCell.h"
@class WH_JXVideoPlayer;

@protocol WH_JXVideo_WHCellDelegate <NSObject>

- (void)WH_showVideoPlayerWithTag:(NSInteger)tag;

@end


@interface WH_JXVideo_WHCell : WH_JXBaseChat_WHCell{
}
@property (nonatomic,strong) WH_JXImageView * chatImage;
@property (nonatomic, strong) UIButton *pauseBtn;
//@property (nonatomic,assign) UIImage * videoImage;
@property (nonatomic,copy)   NSString *oldFileName;
@property (nonatomic, strong) WH_JXVideoPlayer *player;
@property (nonatomic, assign) NSInteger indexTag;
@property (nonatomic, assign) BOOL isEndVideo;
@property (nonatomic, strong) UILabel *videoProgress;

@property (nonatomic, assign) id<WH_JXVideo_WHCellDelegate>videoDelegate;

//- (void)timeGo:(NSString *)fileName;

// 看完视频后调用的方法
- (void)deleteMsg;


@end
