//
//  MiXin_JXShare_MiXinCell.m
//  wahu_im
//
//  Created by p on 2018/11/3.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "WH_ReadDelTimeCell.h"

@implementation WH_ReadDelTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self creatUI];
    }
    return self;
}

-(void)creatUI{
    
    [self.contentView addSubview:self.bottomView];
    self.bottomView.frame = CGRectMake(0, 5, JX_SCREEN_WIDTH, 80);

}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        self.clockImageV = [UIImageView new];
        
        self.settingBtn = [UIButton new];
        self.bottomTitleLb = [UILabel new];
        
        [_bottomView addSubview:self.bottomTitleLb];
        [_bottomView addSubview:self.settingBtn];
        [_bottomView addSubview:self.clockImageV];
        
        self.bottomTitleLb.font = [UIFont systemFontOfSize:10];
        self.bottomTitleLb.textColor = RGB(140, 154, 184);
        self.bottomTitleLb.text = @"您设置了消息5秒后消失";
        self.clockImageV.image = [UIImage imageNamed:@"闹钟"];
        
        
        
        
        [self.settingBtn setTitle:@"点击更改" forState:UIControlStateNormal];
        self.settingBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.settingBtn setTitleColor:RGB(0, 147, 255) forState:UIControlStateNormal];
        [self.settingBtn addTarget:self action:@selector(clickSettingBtn) forControlEvents:UIControlEventTouchUpInside];
        
        [self layoutIfNeeded];
        
        //设置销毁时间
        [self.clockImageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_bottomView.mas_top).offset(0);
            make.centerX.mas_equalTo(_bottomView.mas_centerX);
            make.height.width.mas_equalTo(14);
        }];
        
        [self.bottomTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.clockImageV.mas_bottom).offset(14);
            make.height.mas_equalTo(10);
            make.centerX.mas_equalTo(self.clockImageV.mas_centerX);
        }];
        [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bottomTitleLb.mas_bottom);
            make.bottom.mas_equalTo(_bottomView.mas_bottom);
            make.centerX.mas_equalTo(self.bottomTitleLb);
        }];
    }
    return  _bottomView;
}


//设置按钮
- (void) clickSettingBtn{
    !self.clickSettingBtnClick ? : self.clickSettingBtnClick();
}

- (void)setMsg:(WH_JXMessageObject *)msg {
    _msg = msg;
    
    NSArray * timeArr = @[@"5秒", @"10秒", @"30秒", @"1分钟", @"5分钟", @"30分钟", @"1小时", @"6小时", @"12小时", @"1天", @"一星期"];
    if (self.msg.isMySend) {
        if ([self.msg.isReadDel integerValue] - 1 < timeArr.count) {
            self.bottomTitleLb.text = [NSString stringWithFormat:@"您设置了消息%@后消失", timeArr[[self.msg.isReadDel integerValue] - 1]];
        }
    }else {
        self.bottomTitleLb.text = [NSString stringWithFormat:@"对方设置了阅读消息%@后消失", timeArr[[self.msg.isReadDel integerValue] - 1]];
    }
}



@end
