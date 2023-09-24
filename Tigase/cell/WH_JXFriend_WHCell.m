//
//  WH_JXFriend_WHCell.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXFriend_WHCell.h"
#import "JXLabel.h"
#import "WH_JXImageView.h"
#import "AppDelegate.h"
#import "WH_JXFriendObject.h"
#import "UIFactory.h"

@implementation WH_JXFriend_WHCell
@synthesize title,subtitle,rightTitle,bottomTitle,headImage,bage,user,target;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.selectionStyle  = UITableViewCellSelectionStyleNone;
        UIFont* f0 = sysFontWithSize(12);
        UIFont* f1 = sysFontWithSize(16);
        
        CGFloat btn1H = 28.f;
        
        _btn1 = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 150, 30, 70, 25)];
        _btn1.titleLabel.font = sysFontWithSize(12);
        [_btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btn1.backgroundColor = HEXCOLOR(0x0093FF);
        _btn1.layer.cornerRadius = btn1H / 2.f;
        _btn1.layer.masksToBounds = YES;
        
        
        _btn1.tag = self.tag;
        [self.contentView addSubview:_btn1];
        [_btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-10);
            make.centerY.offset(0);
            make.width.offset(56);
            make.height.offset(btn1H);
        }];

        [self update];

        _btn2 = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-75, 30, 70, 25)];
        _btn2.titleLabel.font = sysFontWithSize(15);
        [_btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btn2.backgroundColor = HEXCOLOR(0xf0f0f0);
        _btn2.layer.borderWidth = .5;
        _btn2.layer.borderColor = [HEXCOLOR(0xdcdcdc) CGColor];
        _btn2.layer.cornerRadius = 2.0;
        _btn2.layer.masksToBounds = YES;
        
        _btn2.tag = self.tag;
        [self.contentView addSubview:_btn2];
        [self update];
        
        
        int n = 64;
        UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0,0, JX_SCREEN_WIDTH, n)];
        v.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        self.selectedBackgroundView = v;
//        [v release];
        
//        [line release];

        WH_JXImageView* iv;
        iv = [[WH_JXImageView alloc]init];
        iv.userInteractionEnabled = NO;
        iv.wh_delegate = self;
        iv.didTouch = @selector(actionUser);
        iv.frame = CGRectMake(13,14,HEAD_SIZE,HEAD_SIZE);
        iv.layer.cornerRadius = iv.frame.size.width / 2;
        iv.layer.masksToBounds = YES;
        [self.contentView addSubview:iv];
//        [iv release];
        [g_server WH_getHeadImageSmallWIthUserId:user.userId userName:user.userNickname imageView:iv];
        
        CGFloat lineW = g_factory.cardBorderWithd;
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,n-0.5,JX_SCREEN_WIDTH,lineW)];
        line.backgroundColor = g_factory.cardBorderColor;
        [self.contentView addSubview:line];
        _topLine = [UIView new];
        [self addSubview:_topLine];
        [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.offset(0);
            make.height.offset(lineW);
        }];
        _topLine.backgroundColor = line.backgroundColor;
        _topLine.hidden = YES;
        
        _verticalLine = [UIView new];
        [self addSubview:_verticalLine];
        [_verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iv.mas_right).offset(13);
            make.top.bottom.offset(0);
            make.width.offset(lineW);
        }];
        _verticalLine.backgroundColor = line.backgroundColor;
        
        JXLabel* lb;
        //名字
        lb = [[JXLabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(iv.frame)+13+lineW+12, 10, JX_SCREEN_WIDTH - 115 -CGRectGetMaxX(iv.frame)-14, 23)];
        lb.textColor = HEXCOLOR(0x3A404C);
        lb.userInteractionEnabled = NO;
        lb.backgroundColor = [UIColor clearColor];
        lb.font = f1;
        [self.contentView addSubview:lb];
//        [lb release];
        _lbTitle = lb;
        [lb setText:self.title];
        
        //聊天消息
        lb = [[JXLabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(lb.frame), CGRectGetMaxY(lb.frame)+4, JX_SCREEN_WIDTH-86-50, 17)];
        lb.textColor = HEXCOLOR(0x969696);
        lb.userInteractionEnabled = NO;
        lb.backgroundColor = [UIColor clearColor];
        lb.font = f0;
        [self.contentView addSubview:lb];
//        [lb release];
        _lbSubtitle = lb;
        _lbSubtitle.text = [user getLastContent];
        
        //时间
        lb = [[JXLabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 120, 13, 115, 14)];
        lb.textColor = [UIColor lightGrayColor];
        lb.userInteractionEnabled = NO;
        lb.backgroundColor = [UIColor clearColor];
        lb.textAlignment = NSTextAlignmentRight;
        lb.font = sysFontWithSize(13);
        [self.contentView addSubview:lb];
        lb.hidden = YES;
//        [lb release];
        [lb setText:self.bottomTitle];
        
        lb = [JXLabel new];
        [self.contentView addSubview:lb];
        [lb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_btn1);
        }];
        lb.textColor = HEXCOLOR(0x666666);
        lb.font = sysFontWithSize(12);
        lb.textAlignment = NSTextAlignmentRight;
        lb.text = _status;
        _statusLbl = lb;
        [self update];
        
        bageImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"noread"]];
        bageImage.frame = CGRectMake(43, 8-10, 25, 25);
        bageImage.backgroundColor = [UIColor clearColor];
        
        bageNumber=[[UILabel alloc]initWithFrame:CGRectZero];
        bageNumber.userInteractionEnabled = NO;
        bageNumber.frame = CGRectMake(0,0, 25, 25);
        bageNumber.backgroundColor = [UIColor clearColor];
        bageNumber.textAlignment = NSTextAlignmentCenter;
        bageNumber.text  = bage;
        bageNumber.textColor = [UIColor whiteColor];
        bageNumber.font = f0;
        
        if([bage intValue]>0){
            [self.contentView addSubview:bageImage];
            [bageImage addSubview:bageNumber];
        }
    }
    return self;
}

- (void) actionUser {
    if ([self.delegate respondsToSelector:@selector(friendCell:headImageAction:)]) {
        [self.delegate friendCell:self headImageAction:user.userId];
    }
}

-(void)dealloc{
//    NSLog(@"WH_JXFriend_WHCell.dealloc");
    self.title = nil;
    self.subtitle = nil;
    self.rightTitle = nil;
    self.bottomTitle = nil;
    self.headImage = nil;
    self.bage = nil;
    self.user = nil;
    self.target = nil;
//    [bageImage release];
//    [bageNumber release];
//    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setBage:(NSString *)s{
    bageImage.hidden = [s intValue]<=0;
    bageNumber.hidden = [s intValue]<=0;
    bageNumber.text = s;
    bage = s;
}

-(void)update{
    NSString* s = @"";SEL action=nil;
    NSString* s2 = @"";SEL action2=nil;
    if([user.isMySend boolValue]){
        switch ([user.type intValue]) {
            case XMPP_TYPE_SAYHELLO:
                
                user.status = [NSNumber numberWithInt:friend_status_addFriend];
                [user update];
//                s = @"再打招呼";
//                action = @selector(onSayHello:);
                break;
            case XMPP_TYPE_PASS:
                break;
            case XMPP_TYPE_FEEDBACK:
                if ([user.status intValue] == friend_status_hisAddFriend) {
                    s = Localized(@"JX_Pass");
                    action = @selector(WH_clickAddFriend:);
                    s2 = Localized(@"JX_Talk");//同时显示两个按钮
                    action2 = @selector(onFeedback:);
                }else {
                    s2 = Localized(@"JX_Talk");
                    action2 = @selector(onFeedback:);
                }
                break;
            case XMPP_TYPE_NEWSEE:
                s = Localized(@"JX_SayHi");
                action = @selector(onSayHello:);
                break;
            case XMPP_TYPE_DELSEE:
//                s = Localized(@"JX_FollowAngin");
                action = @selector(onSeeHim:);
                break;
            case XMPP_TYPE_DELALL:
//                s = Localized(@"JX_FollowAngin");
                action = @selector(onSeeHim:);
                break;
            default:
                break;
        }
    }else{
        switch ([user.type intValue]) {
            case XMPP_TYPE_SAYHELLO:
                s = Localized(@"JX_Pass");
                action = @selector(WH_clickAddFriend:);
                s2 = Localized(@"JX_Talk");//同时显示两个按钮
                action2 = @selector(onFeedback:);
                user.status = [NSNumber numberWithInt:friend_status_hisAddFriend];
                [user update];
                break;
            case XMPP_TYPE_PASS:
                break;
            case XMPP_TYPE_FEEDBACK:
                if ([user.status intValue] == friend_status_hisAddFriend) {
                    s = Localized(@"JX_Pass");
                    action = @selector(WH_clickAddFriend:);
                    s2 = Localized(@"JX_Talk");//同时显示两个按钮
                    action2 = @selector(onFeedback:);
                }else {
                    s2 = Localized(@"JX_Talk");
                    action2 = @selector(onFeedback:);
                }
                
                break;
            case XMPP_TYPE_NEWSEE:
                s = Localized(@"JX_AddFriend");
                action = @selector(WH_clickAddFriend:);
                break;
            case XMPP_TYPE_DELSEE:
                if([user.status intValue]==friend_status_none){
                    s = Localized(@"JX_Attion");
                    action = @selector(onSeeHim:);
                }
                if([user.status intValue]==friend_status_see){
                    s = Localized(@"JX_SayHi");
                    action = @selector(onSayHello:);
                }
                break;
            case XMPP_TYPE_RECOMMEND:
                if([user.status intValue]==friend_status_none){
                    s = Localized(@"JX_Attion");
                    action = @selector(onSeeHim:);
                }
                if([user.status intValue]==friend_status_see){
                    s = Localized(@"JX_SayHi");
                    action = @selector(onSayHello:);
                }
                break;
            default:
                break;
        }
    }
    _lbSubtitle.text = [user getLastContent];
    _btn1.hidden = [s length]==0;
    [_btn1 setTitle:s forState:UIControlStateNormal];
    [_btn1 addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    _btn2.hidden = YES;
//    _btn2.hidden = [s2 length]==0;
//    [_btn2 setTitle:s2 forState:UIControlStateNormal];
//    [_btn2 addTarget:target action:action2 forControlEvents:UIControlEventTouchUpInside];
    
    _statusLbl.hidden = !_btn1.hidden;
}


- (void)sp_getUsersMostFollowerSuccess:(NSString *)mediaInfo {
    NSLog(@"Get Info Failed");
}
@end
