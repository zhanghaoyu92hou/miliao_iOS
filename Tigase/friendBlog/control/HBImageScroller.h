//
//  HBImageScroller.h
//  MyTest
//
//  Created by weqia on 13-7-31.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBImageScroller : UIScrollView
{
    UIImageView * _wh_imageView;
    BOOL max;
    
    id _target;
    SEL _tapOnceAction;
    
    CGSize _beginSize;
    CGSize _beginImageSize;
    
    float _scale;
    float _imgScale;
   
}
@property(nonatomic,readonly) UIImageView *wh_imageView;
@property(nonatomic,assign) UIViewController *wh_controller;

-(id)initWithImage:(UIImage*)image andFrame:(CGRect)frame; //  根据图片,frame初始化

-(void)WH_addTarget:(id)target  tapOnceAction:(SEL)action;  //添加单击事件的委托方法

-(void)WH_setImage:(UIImage*)image;

-(void)WH_setImageWithURL:(NSString*)url  andSmallImage:(UIImage*)image;


-(void)WH_setImageWithURL:(NSString *)url ;

-(void)WH_reset;  //还原



typedef enum {
    RegionTopLeft=0,
    RegionBottomLeft,
    RegionTopRight,
    RegionBottomRight
} LocationRegion;
- (void)sp_checkUserInfo;
@end
