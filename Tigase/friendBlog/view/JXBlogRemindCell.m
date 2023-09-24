//
//  JXBlogRemindCell.m
//  Tigase_imChatT
//
//  Created by p on 2017/7/4.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "JXBlogRemindCell.h"
#import "WH_JXVideoPlayer.h"
#import "WH_AudioPlayerTool.h"

@interface JXBlogRemindCell ()

@property (nonatomic, strong) WH_JXImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIImageView *praiseImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *descImageView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) WH_JXVideoPlayer *player;
@property (nonatomic, strong) WH_AudioPlayerTool *audioPlayer;
@property (nonatomic, strong) UIButton *pauseBtn;
@property (nonatomic, strong) UIView *suSeparateLine;

@end

@implementation JXBlogRemindCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _wh_toplineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 0.5)];
        _wh_toplineView.backgroundColor = HEXCOLOR(0xf0f0f0);
        [self.contentView addSubview:_wh_toplineView];
        _wh_toplineView.hidden = YES;
        
        _headImageView = [[WH_JXImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
        [_headImageView  headRadiusWithAngle:_headImageView.frame.size.width * 0.5];
        [self.contentView addSubview:_headImageView];
        
        _suSeparateLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame)+5, 0, 0.5, 85)];
        _suSeparateLine.backgroundColor = HEXCOLOR(0xf0f0f0);
        [self.contentView addSubview:_suSeparateLine];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_suSeparateLine.frame) + 10, _headImageView.frame.origin.y, 100, 20)];
        _nameLabel.font = pingFangMediumFontWithSize(13);
        _nameLabel.textColor = HEXCOLOR(0x576B94);
        [self.contentView addSubview:_nameLabel];
        
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_suSeparateLine.frame) + 10, CGRectGetMaxY(_nameLabel.frame) + 5, JX_SCREEN_WIDTH - CGRectGetMaxX(_suSeparateLine.frame) - 10 - 80, 20)];
        _commentLabel.font = sysFontWithSize(13);
        _commentLabel.textColor = HEXCOLOR(0x3A404C);
        _commentLabel.numberOfLines = 0;
        [self.contentView addSubview:_commentLabel];
        
        _praiseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_suSeparateLine.frame.origin.x + 10, _commentLabel.frame.origin.y + 2, 14, 14)];
        _praiseImageView.image = [UIImage imageNamed:@"newicon_heart_praise"];
        [self.contentView addSubview:_praiseImageView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, CGRectGetMaxY(_commentLabel.frame) + 5, 100, 20)];
        _timeLabel.font = sysFontWithSize(13.0);
        _timeLabel.textColor = HEXCOLOR(0x969696);
        [self.contentView addSubview:_timeLabel];
        
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 70, _headImageView.frame.origin.y, 65, 65)];
        _descLabel.font = sysFontWithSize(13.0);
        _descLabel.textColor = [UIColor grayColor];
        _descLabel.numberOfLines = 0;
        [self.contentView addSubview:_descLabel];
        
        _descImageView = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 70, _headImageView.frame.origin.y, 65, 65)];
        [self.contentView addSubview:_descImageView];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 85 - .5, JX_SCREEN_WIDTH, .5)];
        _lineView.backgroundColor = HEXCOLOR(0xf0f0f0);
        [self.contentView addSubview:_lineView];
        
        _commentLabel.hidden = YES;
        _praiseImageView.hidden = YES;
        _descLabel.hidden = YES;
        _descImageView.hidden = YES;
        
    }
    return self;
}

-(void)WH_doRefresh:(JXBlogRemind *)br {
    
    [g_server WH_getHeadImageLargeWithUserId:br.fromUserId userName:br.fromUserName imageView:_headImageView];
    
    _nameLabel.text = br.fromUserName;
    
    if (br.type == kWCMessageTypeWeiboPraise) {
        _praiseImageView.hidden = NO;
        _commentLabel.hidden = YES;
    }else {
        _praiseImageView.hidden = YES;
        _commentLabel.hidden = NO;
        
        if (br.type == kWCMessageTypeWeiboComment) {
            _commentLabel.text = br.content;
            if (br.toUserName.length > 0) {
                _commentLabel.text = [NSString stringWithFormat:@"%@%@: %@", Localized(@"JX_Reply"),br.toUserName, br.content];
                NSRange range = [_commentLabel.text rangeOfString:br.toUserName];
                NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:_commentLabel.text];
                [att addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x5B6998) range:range];
                _commentLabel.attributedText = att;
            }
        }else {
            _commentLabel.text = Localized(@"JX_AndMentionYouAtTheAameTime");
        }
       
        CGSize size = [_commentLabel.text boundingRectWithSize:CGSizeMake(_commentLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_commentLabel.font} context:nil].size;
        if (size.height > 20) {
            _commentLabel.frame = CGRectMake(_commentLabel.frame.origin.x, _commentLabel.frame.origin.y, _commentLabel.frame.size.width, size.height);
            _timeLabel.frame = CGRectMake(CGRectGetMaxX(_suSeparateLine.frame) + 10, CGRectGetMaxY(_commentLabel.frame) + 5, 100, 20);
            _lineView.frame = CGRectMake(0, CGRectGetMaxY(_timeLabel.frame) + 5, JX_SCREEN_WIDTH, .5);
        }
    }
    
    self.timeLabel.text =  [TimeUtil getTimeStrStyle1:[br.timeSend timeIntervalSince1970]];
    self.suSeparateLine.height = self.lineView.frame.origin.y;
    switch (br.msgType) {
        case 1:{
            
                self.descImageView.hidden = YES;
                self.descLabel.hidden = NO;
                _pauseBtn.hidden = YES;
                self.descLabel.text = br.url;
            }
            
            break;
        case 2:{
                self.descImageView.hidden = NO;
                self.descLabel.hidden = YES;
                _pauseBtn.hidden = YES;
                [self.descImageView sd_setImageWithURL:[NSURL URLWithString:br.url] placeholderImage:[UIImage imageNamed:@"avatar_normal"]];
           
            }
            
            break;
        case 3:{
                self.descImageView.hidden = NO;
                self.descLabel.hidden = YES;
                _pauseBtn.hidden = YES;
            [g_server WH_getHeadImageLargeWithUserId:g_myself.userId userName:g_myself.userNickname imageView:self.descImageView];
                _audioPlayer = [[WH_AudioPlayerTool alloc] initWithParent:self.descImageView];
                _audioPlayer.wh_isOpenProximityMonitoring = NO;
            }
            
            break;
        case 4:{
                self.descImageView.hidden = NO;
                self.descLabel.hidden = YES;
                if (!_pauseBtn) {
                    _pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
                    _pauseBtn.center = CGPointMake(self.descImageView.frame.size.width/2,self.descImageView.frame.size.height/2);
                    [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"playvideo"] forState:UIControlStateNormal];
                    [self.descImageView addSubview:_pauseBtn];
                }
                _pauseBtn.hidden = NO;
                [FileInfo getFirstImageFromVideo:br.url imageView:self.descImageView];
//                [self.descImageView sd_setImageWithURL:[NSURL URLWithString:br.url] placeholderImage:[UIImage imageNamed:@"avatar_normal"]];
//                _player = [[WH_JXVideoPlayer alloc] initWithParent:self.descImageView];
                
            }
            
            break;

            
        default:
            break;
    }
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)sp_checkUserInfo {
    NSLog(@"Get Info Success");
}
@end
