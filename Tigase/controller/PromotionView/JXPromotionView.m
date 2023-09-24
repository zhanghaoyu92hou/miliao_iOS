//
//  JXPromotionView.m
//  Tigase_imChatT
//
//  Created by 闫振奎 on 2019/6/6.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXPromotionView.h"
@interface JXPromotionView ()
@property (weak, nonatomic) IBOutlet UIView *PromotTitleV;
@property (weak, nonatomic) IBOutlet UIView *inverterContainerView;
@property (weak, nonatomic) IBOutlet UILabel *haveInvertNum;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet UIButton *fuzhiBtn;
@property (weak, nonatomic) IBOutlet UIView *ZheDangView;

@end
@implementation JXPromotionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
//    [self.inverterContainerView radiusWithAngle:self.inverterContainerView.frame.size.height*0.5];
//    [self.fuzhiBtn radiusWithAngle:10];
    [self.fuzhiBtn setBackgroundColor:THEMECOLOR];
    
    
    [[WH_SkinManage sharedInstance] setViewGradientWithView:self.inverterContainerView gradientDirection:JXSkinGradientDirectionLeftToRight];
    [[WH_SkinManage sharedInstance] setViewGradientWithView:self.ZheDangView gradientDirection:JXSkinGradientDirectionLeftToRight];
    
    
    self.fuzhiBtn.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.14].CGColor;
    self.fuzhiBtn.layer.shadowOffset = CGSizeMake(0,1);
    self.fuzhiBtn.layer.shadowOpacity = 1;
    self.fuzhiBtn.layer.shadowRadius = 6;
    self.fuzhiBtn.layer.cornerRadius = 22;
    
    self.inverterContainerView.layer.cornerRadius = 10;
    self.inverterContainerView.layer.masksToBounds = YES;
    
    self.ZheDangView.layer.masksToBounds = YES;
    
    _mainContentView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.14].CGColor;
    _mainContentView.layer.shadowOffset = CGSizeMake(0,1);
    _mainContentView.layer.shadowOpacity = 1;
    _mainContentView.layer.shadowRadius = 6;
    _mainContentView.layer.cornerRadius = 10;
    
    
    

}

- (IBAction)copyBtnClick:(UIButton *)sender {
    
    [GKMessageTool showText:@"复制成功"];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.contentLabel.text;
    
}

//跳转我的邀请界面
- (IBAction)haveInvertNumBtn:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(JXPromotionView:didClickMyInvertNumBtn:)]) {
        [self.delegate JXPromotionView:self didClickMyInvertNumBtn:sender];
    }
}

- (void)setDataDic:(NSDictionary *)dataDic
{   
    _dataDic = dataDic;
    if (dataDic != nil) {
//        NSDictionary*attribtDic =@{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        NSDictionary*attribtDic =@{};
        NSMutableAttributedString*attribtStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已邀请人数：%@",dataDic[@"inviteCount"]] attributes:attribtDic];
        self.haveInvertNum.attributedText= attribtStr;
        
        self.contentLabel.text = [NSString stringWithFormat:@"%@",dataDic[@"inviteCode"]];
    }
    
}


- (void)sp_didUserInfoFailed {
    NSLog(@"Check your Network");
}
@end
