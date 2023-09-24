//
//  ThirdLoginView.m
//  Tigase
//
//  Created by 齐科 on 2019/9/29.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "ThirdLoginView.h"
#import "JX_QQ_manager.h"

@interface ThirdLoginView()
{
    NSMutableArray *images;
}
@end

@implementation ThirdLoginView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubViews];
    }
    return self;
}
- (void)loadSubViews {
    images = [NSMutableArray new];
    if ([g_config.qqLoginStatus integerValue] == 1) {
        [images addObject:@"WH_QQ"];
    }
    if ([g_config.wechatLoginStatus integerValue] == 1) {
        [images addObject:@"WH_WeiXin"];
    }
    if (images.count == 0) {
        return;
    }
    CGFloat originY = self.height - 45/*按钮高度*/ - 20/*按钮和Label间距*/ - 20/*label高度*/;
    originY = ((originY - 56) > 0) ? (originY-56) : originY/2;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, JX_SCREEN_WIDTH, 20)];
    [titleLabel setText:@"使用第三方账户登录"];
    [titleLabel setTextColor:HEXCOLOR(0xB5C0D2)];
    [titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 12]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:titleLabel];
    CGFloat buttonWidth = 45.0;
    CGFloat margin = images.count == 1 ? (JX_SCREEN_WIDTH - buttonWidth)/2 :  (JX_SCREEN_WIDTH - buttonWidth*images.count - 60*(images.count-1))/2;
    for (int i = 0; i < images.count; i++) {
        UIButton *thirdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [thirdBtn setFrame:CGRectMake(margin + (45+60)*i, titleLabel.bottom + 20, buttonWidth, buttonWidth)];
        [thirdBtn setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [thirdBtn addTarget:self action:@selector(thirdLoginMethod:) forControlEvents:UIControlEventTouchUpInside];
        thirdBtn.tag = 100+i;
        [self addSubview:thirdBtn];
    }
}

- (void)thirdLoginMethod:(UIButton *)button {
    NSString *imageName = images[button.tag - 100];
    if ([imageName isEqualToString:@"WH_QQ"]) {
        if (self.thirdLoginBlock) {
            self.thirdLoginBlock(1);
        }
    }else if ([imageName isEqualToString:@"WH_WeiXin"]) {
        if (self.thirdLoginBlock) {
            self.thirdLoginBlock(2);
        }
    }
}

@end
