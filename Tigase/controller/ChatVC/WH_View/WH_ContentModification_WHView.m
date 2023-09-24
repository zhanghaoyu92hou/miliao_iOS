//
//  WH_ContentModification_WHView.m
//  Tigase
//
//  Created by Apple on 2019/7/4.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_ContentModification_WHView.h"

@implementation WH_ContentModification_WHView

@synthesize title ,wh_content ,isEdit ,isLimit;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSString *)content isEdit:(BOOL)edit isLimit:(BOOL)limit {
    self.isLimit = limit;
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        centerView.backgroundColor = [UIColor whiteColor];
        centerView.layer.masksToBounds = YES;
        [centerView radiusWithAngle:15];
        [self addSubview:centerView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, centerView.frame.size.width, 34)];
        [titleLabel setBackgroundColor:[UIColor whiteColor]];
        [titleLabel setText:title?:@""];
        [titleLabel setTextColor:HEXCOLOR(0x8C9AB8)];
        [titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 18]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [centerView addSubview:titleLabel];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setFrame:CGRectMake(12, 14, 28, 28)];
        [closeBtn setImage:[UIImage imageNamed:@"WH_CloseBtn"] forState:UIControlStateNormal];
        [closeBtn setImage:[UIImage imageNamed:@"WH_CloseBtn"] forState:UIControlStateHighlighted];
        [centerView addSubview:closeBtn];
        [closeBtn addTarget:self action:@selector(closeMethod) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, 54, centerView.frame.size.width, g_factory.cardBorderWithd)];
        [lView setBackgroundColor:g_factory.cardBorderColor];
        [centerView addSubview:lView];
        
        if (edit) {
            UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(12, 54.5 + 20, centerView.frame.size.width - 24, 60)];
            [cView setBackgroundColor:HEXCOLOR(0xE8E8EA)];
            [centerView addSubview:cView];
            cView.layer.masksToBounds = YES;
            cView.layer.cornerRadius = g_factory.cardCornerRadius;
            
            self.wh_cTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, cView.frame.size.width - 20, 40)];
            [self.wh_cTextField setDelegate:self];
            [self.wh_cTextField setPlaceholder:content?:@""];
//            [self.wh_cTextField setText:content?:@""];
            [self.wh_cTextField setTextColor:HEXCOLOR(0x3A404C)];
            [self.wh_cTextField setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 17]];
            [self.wh_cTextField setKeyboardType:UIKeyboardTypeDefault];
            [self.wh_cTextField setReturnKeyType:UIReturnKeyDone];
            [cView addSubview:self.wh_cTextField];
        }else{
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, lView.frame.origin.y + lView.frame.size.height + 20, centerView.frame.size.width - 24, 60)];
            [label setBackgroundColor:HEXCOLOR(0xffffff)];
            [label setText:content?:@""];
            [label setTextColor:HEXCOLOR(0x3A404C)];
            [label setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 18]];
            [label setNumberOfLines:0];
            [label setLineBreakMode:NSLineBreakByWordWrapping];
            [centerView addSubview:label];
        }
        
        UIView *btmView = [[UIView alloc] initWithFrame:CGRectMake(0, centerView.frame.size.height - 73, centerView.frame.size.width, g_factory.cardBorderWithd)];
        [btmView setBackgroundColor:g_factory.cardBorderColor];
        [centerView addSubview:btmView];
        
        NSArray *array = @[Localized(@"JX_Cencal") ,Localized(@"JX_Confirm")];
        for (int i = 0; i < array.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(12 + i*((centerView.frame.size.width - 24 - 17)/2 + + 17), centerView.frame.size.height - 59, (centerView.frame.size.width - 24 - 17)/2, 44)];
            [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
            if (i == 0) {
                [btn setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
                [btn setBackgroundColor:HEXCOLOR(0xffffff)];
                btn.layer.borderColor = g_factory.cardBorderColor.CGColor;
                btn.layer.borderWidth = g_factory.cardBorderWithd;
            }else{
                [btn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
                [btn setBackgroundColor:HEXCOLOR(0x0093FF)];
            }
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = g_factory.cardCornerRadius;
            [btn setTag:i];
            [centerView addSubview:btn];
            [btn addTarget:self action:@selector(buttonClickMethod:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    return self;
}

//进群验证提示框
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title promptContent:(NSString *)pContent content:(NSString *)content isEdit:(BOOL)edit isLimit:(BOOL)limit {
    self.isLimit = limit;
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        centerView.backgroundColor = [UIColor whiteColor];
        centerView.layer.masksToBounds = YES;
        [centerView radiusWithAngle:15];
        [self addSubview:centerView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, centerView.frame.size.width, 34)];
        [titleLabel setBackgroundColor:[UIColor whiteColor]];
        [titleLabel setText:title?:@""];
        [titleLabel setTextColor:HEXCOLOR(0x8C9AB8)];
        [titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 18]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [centerView addSubview:titleLabel];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setFrame:CGRectMake(12, 14, 28, 28)];
        [closeBtn setImage:[UIImage imageNamed:@"WH_CloseBtn"] forState:UIControlStateNormal];
        [closeBtn setImage:[UIImage imageNamed:@"WH_CloseBtn"] forState:UIControlStateHighlighted];
        [centerView addSubview:closeBtn];
        [closeBtn addTarget:self action:@selector(closeMethod) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, 54, centerView.frame.size.width, g_factory.cardBorderWithd)];
        [lView setBackgroundColor:g_factory.cardBorderColor];
        [centerView addSubview:lView];
        
        UILabel *pLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, lView.frame.size.height + lView.frame.origin.y + 15, centerView.frame.size.width - 40, 70)];
        [pLabel setBackgroundColor:HEXCOLOR(0xffffff)];
        [pLabel setText:pContent?:@""];
        [pLabel setTextColor:HEXCOLOR(0x3A404C)];
        [pLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 18]];
        [pLabel setNumberOfLines:0];
        [pLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [centerView addSubview:pLabel];
        
        if (edit) {
            UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(12, pLabel.frame.origin.y + pLabel.frame.size.height + 20, centerView.frame.size.width - 24, 60)];
            [cView setBackgroundColor:HEXCOLOR(0xE8E8EA)];
            [centerView addSubview:cView];
            cView.layer.masksToBounds = YES;
            
            cView.layer.cornerRadius = g_factory.cardCornerRadius;
            
            self.wh_cTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, cView.frame.size.width - 20, 40)];
            [self.wh_cTextField setDelegate:self];
            //            [cTextField setPlaceholder:@""];
//            [self.wh_cTextField setText:content?:@""];
            [self.wh_cTextField setPlaceholder:content?:@""];
            [self.wh_cTextField setTextColor:HEXCOLOR(0x3A404C)];
            [self.wh_cTextField setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 17]];
            [self.wh_cTextField setKeyboardType:UIKeyboardTypeDefault];
            [self.wh_cTextField setReturnKeyType:UIReturnKeyDone];
            [cView addSubview:self.wh_cTextField];
        }else{
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, lView.frame.origin.y + lView.frame.size.height + 20, centerView.frame.size.width - 24, 60)];
            [label setBackgroundColor:HEXCOLOR(0xffffff)];
            [label setText:content?:@""];
            [label setTextColor:HEXCOLOR(0x3A404C)];
            [label setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 18]];
            [label setNumberOfLines:0];
            [label setLineBreakMode:NSLineBreakByWordWrapping];
            [centerView addSubview:label];
        }
        
        UIView *btmView = [[UIView alloc] initWithFrame:CGRectMake(0, centerView.frame.size.height - 73, centerView.frame.size.width, g_factory.cardBorderWithd)];
        [btmView setBackgroundColor:g_factory.cardBorderColor];
        [centerView addSubview:btmView];
        
        NSArray *array = @[Localized(@"JX_Cencal") ,Localized(@"JX_Confirm")];
        for (int i = 0; i < array.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(12 + i*((centerView.frame.size.width - 24 - 17)/2 + + 17), centerView.frame.size.height - 59, (centerView.frame.size.width - 24 - 17)/2, 44)];
            [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
            if (i == 0) {
                [btn setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
                [btn setBackgroundColor:HEXCOLOR(0xffffff)];
                btn.layer.borderColor = g_factory.cardBorderColor.CGColor;
                btn.layer.borderWidth = g_factory.cardBorderWithd;
            }else{
                [btn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
                [btn setBackgroundColor:HEXCOLOR(0x0093FF)];
            }
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = g_factory.cardCornerRadius;
            [btn setTag:i];
            [centerView addSubview:btn];
            [btn addTarget:self action:@selector(buttonClickMethod:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [self endEditing:YES];
        return NO;
    }
    
    if (self.isLimit) {
        if (self.wh_limitLen <= 0) {
            self.wh_limitLen = NAME_INPUT_MAX_LENGTH;
        }
        if([textField.text stringByReplacingCharactersInRange:range withString:string].length > self.wh_limitLen && ![string isEqualToString:@""]){
            if (!self.isShow) {
                self.isShow = YES;
                [g_App showAlert:Localized(@"JX_InputLimit")];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.isShow = NO;
                });
            }
            return NO;
        }
    }
    
    return YES;
}

- (void)closeMethod {
    [self.wh_cTextField resignFirstResponder];
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (void)buttonClickMethod:(UIButton *)button {
    [self.wh_cTextField resignFirstResponder];
    //0:取消 1:确定
    if (self.selectActionBlock) {
//        self.selectActionBlock(button.tag);
        if (button.tag == 1) {
            if (self.isEdit) {
                if (self.wh_cTextField.text.length == 0) {
                    [GKMessageTool showText:Localized(@"JXAlert_InputSomething")];
                    return;
                }else{
                    self.selectActionBlock(button.tag, self.wh_cTextField.text);
                }
            }else{
                self.selectActionBlock(button.tag, self.wh_cTextField.text);
            }
            
        } else{
            self.selectActionBlock(button.tag, self.wh_cTextField.text);
        }
    }
}


- (void)sp_getMediaData {
    NSLog(@"Get User Succrss");
}
@end
