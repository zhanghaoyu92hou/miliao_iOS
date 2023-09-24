//
//  WH_JXPromotion_WHCell.m
//  Tigase_imChatT
//
//  Created by 闫振奎 on 2019/6/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXPromotion_WHCell.h"
@interface WH_JXPromotion_WHCell ()
@property (weak, nonatomic) IBOutlet UIButton *fuzhiContentBtn;
@property (weak, nonatomic) IBOutlet UILabel *isAvalueL;
@property (weak, nonatomic) IBOutlet UILabel *inventCodeL;

@end
@implementation WH_JXPromotion_WHCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    [self.fuzhiContentBtn radiusWithAngle:self.fuzhiContentBtn.frame.size.height * 0.5];
    [self.fuzhiContentBtn setBackgroundColor:THEMECOLOR];
    [self.fuzhiContentBtn addTarget:self action:@selector(fuzhiAction:) forControlEvents:UIControlEventTouchUpInside];
    self.fuzhiContentBtn.layer.shadowOffset = CGSizeMake(0,1);
    self.fuzhiContentBtn.layer.shadowOpacity = 0.2;
    self.fuzhiContentBtn.layer.shadowRadius = 4;
    self.fuzhiContentBtn.layer.cornerRadius = 14.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDataDic:(NSDictionary *)dataDic
{
    _dataDic = dataDic;
    self.inventCodeL.text = [NSString stringWithFormat:@"%@",dataDic[@"code"]];
    NSString *status = [NSString stringWithFormat:@"%@",dataDic[@"status"]];
    if ([status integerValue] == 1) { //未使用
        self.fuzhiContentBtn.hidden = NO;
        self.inventCodeL.textColor = THEMECOLOR;
        self.isAvalueL.textColor = THEMECOLOR;
        self.isAvalueL.text = @"有效";
        
    }else if ([status integerValue] == 2) { //已使用
        self.fuzhiContentBtn.hidden = YES;
        self.inventCodeL.textColor = HEXCOLOR(0xBEBEBE);
        self.isAvalueL.textColor = HEXCOLOR(0xBEBEBE);
        self.isAvalueL.text = @"已使用";
    }
    
}

- (void)fuzhiAction:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(WH_JXPromotion_WHCell:didSelCopyBtnActionWithCopyBtn:AndIndexPath:)]) {
        [self.delegate WH_JXPromotion_WHCell:self didSelCopyBtnActionWithCopyBtn:btn AndIndexPath:self.indexPath];
    }
}


- (void)sp_checkNetWorking:(NSString *)isLogin {
    NSLog(@"Get User Succrss");
}
@end
