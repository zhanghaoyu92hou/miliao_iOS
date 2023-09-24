//
//  MiXin_JXImage_MiXinCell.h
//  wahu_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXBaseChat_WHCell.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface WH_JXImage_WHCell : WH_JXBaseChat_WHCell
@property (nonatomic,strong) FLAnimatedImageView * chatImage;//cell里的UIView

@property (nonatomic,assign) int currentIndex;//当前选中图片的序号
@property (nonatomic,assign,getter=getImageWidth) int imageWidth;
@property (nonatomic,assign,getter=getImageHeight) int imageHeight;

@property (nonatomic, assign) BOOL isRemove;

@property (nonatomic, strong) UILabel *imageProgress;


- (void)deleteReadMsg;

//- (void)timeGo:(MiXin_JXMessageObject *)msg;

@end
