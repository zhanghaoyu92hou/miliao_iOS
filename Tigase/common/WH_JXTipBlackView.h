//
//  TipBlackView.h
//  Tigase_imChatT
//
//  Created by MacZ on 16/4/18.
//  Copyright (c) 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WH_JXTipBlackView : UIView{
    UILabel *_titleLabel;
}

- (id)initWithTitle:(NSString *)title;
- (void)show;

@end
