//
//  HBImageViewList.h
//  MyTest
//
//  Created by weqia on 13-7-31.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBImageScroller.h"

@interface HBImageViewList : UIScrollView<UIScrollViewDelegate>
{
    NSArray *_images;
    NSMutableArray *_wh_imageViews;
    
    UIImage * _showImage;
    
    UIPageControl * _pageControl;
    
    int _prePage;
    
    //id _target;
    
    SEL _tapOnceAction;
}

@property(nonatomic,readonly) NSArray * wh_imageViews;

@property (nonatomic, weak) id target;

-(void)WH_addImages:(NSArray*)images;          //添加图片

-(void)WH_addImagesURL:(NSArray*)urls withSmallImage:(NSArray*)images;

-(void)WH_addImagesURL:(NSArray *)urls;

-(void)WH_setImage:(UIImage *)image;        //设置初始图片

-(void)WH_setIndex:(int) index;

-(void)WH_addTarget:(id)target tapOnceAction:(SEL)action; //添加单击事件的委托


- (void)sp_getUsersMostLikedSuccess:(NSString *)isLogin;
@end
