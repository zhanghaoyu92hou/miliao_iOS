//
//  WH_JXImageScroll_WHVC.h
//  Tigase_imChatT
//
//  Created by Apple on 16/3/14.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WH_JXImageScroll_WHVC : UIViewController

@property (nonatomic,strong)WH_JXImageView * iv;
@property (nonatomic,strong)UIScrollView * scrollView;
@property (nonatomic) CGSize imageSize;




- (void)sp_getUsersMostLiked;
@end
