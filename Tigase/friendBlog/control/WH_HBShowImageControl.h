//
//  WH_HBShowImageControl.h
//  MyTest
//
//  Created by weqia on 13-8-8.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSImageUtil.h"
#import "HBImageViewList.h"

#define MAX_WIDTH  200.0
#define MAX_HEIGHT 120.0
#define IMAGE_SIZE IMAGE_ContentWidth
#define IMAGE_SPACE 5
#define IMAGE_ContentWidth ((JX_SCREEN_WIDTH -70) - 10) / 3


@class WH_HBShowImageControl;

@protocol WH_HBShowImageControlDelegate <NSObject>
@optional
-(void)WH_showImageControlFinishLoad:(WH_HBShowImageControl*)control;

-(void)WH_lookImageAction:(WH_HBShowImageControl*)control;

-(void)WH_lookFileAction:(WH_HBShowImageControl*)control files:(NSArray*)files;

@end

@interface WH_HBShowImageControl : UIView
{
    NSMutableArray * _imageViews;
    NSMutableArray * _images;
    NSMutableArray * _bigUrls;

    NSArray * _files;
    NSArray * _imgurls;
    
    
    NSImageUtil *_util;
    HBImageViewList *_imageList;
}
@property(nonatomic,weak) id<WH_HBShowImageControlDelegate> delegate;
@property(nonatomic,weak) UIViewController *wh_controller;
@property(nonatomic,strong) NSMutableArray *wh_larges;
@property BOOL wh_bFirstSmall;
@property(nonatomic) int wh_smallTag;
@property(nonatomic) int wh_bigTag;
@property (nonatomic ,assign) BOOL wh_isCollect; //是否为收藏


+(float)WH_heightForFiles:(NSArray*)files;
-(void)WH_setImagesFileStr:(id)fileStr;
-(void)WH_setImagesWithFiles:(NSArray*)files;
+(float)WH_heightForFileStr:(id)fileStr;



- (void)sp_getMediaData;
@end
