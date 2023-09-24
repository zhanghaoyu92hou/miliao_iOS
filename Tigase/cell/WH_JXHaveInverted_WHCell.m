//
//  WH_JXHaveInverted_WHCell.m
//  Tigase_imChatT
//
//  Created by 闫振奎 on 2019/6/11.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXHaveInverted_WHCell.h"

@implementation WH_JXHaveInverted_WHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.addBtn radiusWithAngle:self.addBtn.frame.size.height * 0.5];
    [self.headImgView headRadiusWithAngle:self.headImgView.frame.size.width * 0.5];
    [self.addBtn addTarget:self action:@selector(addFriendAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDataDic:(NSDictionary *)dataDic
{
    _dataDic = dataDic;
    
    NSString *userId = [NSString stringWithFormat:@"%@",dataDic[@"inviteUserId"]];
    NSString* dir  = [NSString stringWithFormat:@"%lld",[userId longLongValue] % 10000];
    
//    NSString* urlString  = [NSString stringWithFormat:@"%@avatar/t/%@/%@.jpg",g_config.downloadAvatarUrl,dir,userId];
    NSString* urlString  = [NSString stringWithFormat:@"%@avatar/t/%@/%@.jpg",[share_defaults objectForKey:kDownloadAvatarUrl],dir,userId];
    
    NSURL * url = [[NSURL alloc]initWithString:urlString];
    [self.headImgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avatar_normal"]];
    
    self.nickNameL.text = [NSString stringWithFormat:@"%@",dataDic[@"nickName"]];
    
    long long time = [dataDic[@"inviteCreateTime"] longLongValue];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    NSString *timeStr = [formatter stringFromDate:date];
    self.timeL.text = timeStr;
    
    
    //根据id数据库中查询好友信息
    BOOL isFriend = NO;
    for (NSString *friendId in self.friendIdArr) {
        if ([userId isEqualToString:friendId]) {
            isFriend = YES;
        }
    }
    
    if (isFriend) {
        self.addBtn.enabled = NO;
        [self.addBtn setTitle:@"已添加" forState:UIControlStateNormal];
        [self.addBtn setBackgroundColor:HEXCOLOR(0xd9d9d9)];
    }else{
        self.addBtn.enabled = YES;
        [self.addBtn setTitle:@"加好友" forState:UIControlStateNormal];
        [self.addBtn setBackgroundColor:THEMECOLOR];
    }
}

- (void)addFriendAction:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(WH_JXHaveInverted_WHCell:didClickAddFriendBtnAction:AndIndexPath:)]) {
        [self.delegate WH_JXHaveInverted_WHCell:self didClickAddFriendBtnAction:btn AndIndexPath:self.indexPath];
    }
}


- (void)sp_getUsersMostLiked {
    NSLog(@"Get User Succrss");
}
@end
