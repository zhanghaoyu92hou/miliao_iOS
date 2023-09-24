//
//  WH_JXSelectImageView.h
//
//  Created by Reese on 13-8-22.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WCShareMoreDelegate <NSObject>

@optional
@end


@interface WH_JXSelectImageView :  UIView <UIScrollViewDelegate>

@property (nonatomic,weak) id delegate;
@property(assign) SEL wh_onImage;
@property(assign) SEL wh_onVideo;
@property(assign) SEL onFile;
@property(assign) SEL onCard;
@property(assign) SEL onLocation;
@property(assign) SEL wh_onVideoChat;
@property(assign) SEL wh_onAudioChat;
@property(assign) SEL wh_onGift;
@property(assign) SEL onCamera;
@property(assign) SEL onShake;
@property(assign) SEL onCollection;
@property(assign) SEL wh_onTransfer;
@property(assign) SEL onAddressBook;

@property (assign) SEL onTwoWayWithdrawal;

@property (nonatomic, strong) UIScrollView *wh_scrollView;
@property (nonatomic, assign) BOOL wh_isGroup;
@property (nonatomic, assign) BOOL wh_isGroupMessages;
@property (nonatomic, assign) BOOL wh_isDevice;
@property (nonatomic, strong) UIPageControl *wh_pageControl;

@end



