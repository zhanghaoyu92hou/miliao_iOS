//
//  PageLoadFootView.h
//  wq
//
//  Created by weqia on 13-7-22.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol PageLoadFootViewDelegate;
@interface PageLoadFootView : UIView
{
    UIImageView * image;
    UILabel * loadText;
    UILabel * finishText;
    
    BOOL isLoading;
}

@property(nonatomic,retain) id<PageLoadFootViewDelegate> delegate;

-(void)animmation;

-(void)begin;

-(void)WH_end;

-(void)WH_scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

-(void)WH_loadFinish;


@end

@protocol PageLoadFootViewDelegate <NSObject>

-(void)WH_footViewBeginLoad:(PageLoadFootView*)footView;


@end
