//
//  WH_JXFriend_WHCell.m
//  share
//
//  Created by 1 on 2019/3/21.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXFriend_WHCell.h"
#import "WH_JXShareUser.h"

@interface WH_JXFriend_WHCell ()
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UILabel *name;

@end

@implementation WH_JXFriend_WHCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _imgV = [[UIImageView alloc] initWithFrame:CGRectMake(14,5,52,52)];
        _imgV.layer.cornerRadius = 25;
        _imgV.layer.masksToBounds = YES;
        _imgV.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [self.contentView addSubview:_imgV];

        _name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imgV.frame)+14, 25, JX_SCREEN_WIDTH - 115 -CGRectGetMaxX(_imgV.frame)-14, 14)];
        _name.textColor = HEXCOLOR(0x323232);
        _name.font = sysFontWithSize(16);
        [self.contentView addSubview:_name];
    }
    return self;
}

- (void)WH_setDataWithUser:(WH_JXShareUser *)user {
    _name.text = user.wh_userNickname;
    if (user.wh_roomId.length > 0) {
        
        if (MainHeadType) {//圆形
            _imgV.image = [UIImage imageNamed:@"groupImage"];
        }else{
            _imgV.image = [UIImage imageNamed:@"fangxinggroupImagePlaceholder"];
        }
    }else {
        [self WH_getHeadImageSmallWIthUserId:user.wh_userId imageView:_imgV];
    }
}

-(void)WH_getHeadImageSmallWIthUserId:(NSString*)userId imageView:(UIImageView*)iv{
    //    客服头像
    if([userId intValue]<10100 && [userId intValue]>=10000){
        iv.image = [UIImage imageNamed:[NSString stringWithFormat:@"im_10000"]];
        return;
    }
    // 支付
    if ([userId intValue] == [WAHU_TRANSFER intValue]) {
        iv.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_wahu_transfer"]];
        return;
    }
    NSString* s;
    if([userId isKindOfClass:[NSNumber class]])
        s = [(NSNumber*)userId stringValue];
    else
        s = userId;
    if([s length]<=0)
        return;
    
    //    // 我的其他手机设备头像
    //    if ([s isEqualToString:ANDROID_USERID] || [s isEqualToString:IOS_USERID]) {
    //        iv.image = [UIImage imageNamed:@"fdy"];
    //        return;
    //    }
    //    // 我的电脑端头像
    //    if ([s isEqualToString:PC_USERID] || [s isEqualToString:MAC_USERID] || [s isEqualToString:WEB_USERID]) {
    //        iv.image = [UIImage imageNamed:@"feb"];
    //        return;
    //    }
    
    NSString* dir  = [NSString stringWithFormat:@"%d",[s intValue] % 10000];
    NSString* url  = [NSString stringWithFormat:@"%@avatar/t/%@/%@.jpg",[share_defaults objectForKey:kDownloadAvatarUrl],dir,s];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    if (!image) {
        image = [UIImage imageNamed:@"avatar_normal"];
    }
    iv.image = image;
    //    [iv sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"avatar_normal"] options:SDWebImageRetryFailed];
}

@end
