//
//  JXTabButton.m
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-5-17.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "JXTabButton.h"
#import "WH_JXBadgeView.h"

#define ICON_SIZE 24

@implementation JXTabButton
@synthesize wh_iconName,wh_selectedIconName,wh_backgroundImageName,wh_selectedBackgroundImageName,wh_textColor,wh_selectedTextColor,wh_bage,wh_text,wh_isTabMenu;

- (void)show
{
//    self.backgroundColor = [UIColor whiteColor];
    
    _icon    = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-ICON_SIZE)/2, 4, ICON_SIZE, ICON_SIZE)];
    _lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-16, self.frame.size.width, 12)];
    _lbBage  = [[WH_JXBadgeView alloc] initWithFrame:CGRectMake(_icon.frame.origin.x+ICON_SIZE-7, 2, g_factory.badgeWidthHeight, g_factory.badgeWidthHeight)];

    if ([wh_iconName hasPrefix:@"http://"]||[wh_iconName hasPrefix:@"https://"]) {
        [_icon sd_setImageWithURL:[NSURL URLWithString:wh_iconName] placeholderImage:[UIImage imageNamed:@"guangchangmoren"]];
    }else {
        _icon.image = [UIImage imageNamed:wh_iconName];
    }

    _icon.userInteractionEnabled = NO;
    
    _lbTitle.text = wh_text;
    _lbTitle.font = sysFontWithSize(11);
    _lbTitle.textAlignment = NSTextAlignmentCenter;
    _lbTitle.userInteractionEnabled = NO;
    
    _lbBage.wh_badgeString  = wh_bage;
    _lbBage.userInteractionEnabled = YES;
    _lbBage.wh_didDragout = self.wh_onDragout;
    _lbBage.wh_delegate = self.wh_delegate;
    _lbBage.tag = self.tag;
    
    if(wh_backgroundImageName)
        [self setBackgroundImage:[UIImage imageNamed:wh_backgroundImageName] forState:UIControlStateNormal];
    if(wh_selectedBackgroundImageName)
        [self setBackgroundImage:[UIImage imageNamed:wh_selectedBackgroundImageName] forState:UIControlStateSelected];
    
    [self addSubview:_icon];
    [self addSubview:_lbTitle];
    [self addSubview:_lbBage];
}


-(void)dealloc{
//    [_icon release];
//    [_lbTitle release];
//    [_lbBage release];
    
    self.wh_iconName = nil;
    self.wh_selectedIconName = nil;
    self.wh_backgroundImageName = nil;
    self.wh_selectedBackgroundImageName = nil;
    self.wh_text = nil;
    self.wh_textColor = nil;
    self.wh_selectedTextColor = nil;
    self.wh_bage = nil;
    
//    [super dealloc];
}

-(void)setSelected:(BOOL)selected{
    if(selected){
//        _icon.image = ThemeImage(selectedIconName);//[UIImage imageNamed:selectedIconName];
        if ([wh_selectedIconName hasPrefix:@"http://"] || [wh_selectedIconName hasPrefix:@"https://"]) {
            [_icon sd_setImageWithURL:[NSURL URLWithString:wh_selectedIconName] placeholderImage:[UIImage imageNamed:@"guangchangxuanzhong"]];
        }else{
            _icon.image = ThemeImage(wh_selectedIconName);
        }
        
        _lbTitle.textColor = wh_selectedTextColor;
    }else{
//        _icon.image = ThemeImage(iconName);//[UIImage imageNamed:iconName];
        if ([wh_iconName hasPrefix:@"http://"]||[wh_iconName hasPrefix:@"https://"]) {
            [_icon sd_setImageWithURL:[NSURL URLWithString:wh_iconName] placeholderImage:[UIImage imageNamed:@"guangchangmoren"]];
        }else{
             _icon.image = ThemeImage(wh_iconName);
        }
        _lbTitle.textColor = wh_textColor;
    }
    [super setSelected:selected];
}

-(void)setWh_bage:(NSString *)s{
    if([s intValue]>99)
        s = @"99+";
    if([s intValue]<=0)
        s = @"";
    _lbBage.wh_badgeString = s;

//    if(![bage isEqualToString:s])
//       [bage release];
//    bage = [s retain];
    wh_bage = s;
}

@end
