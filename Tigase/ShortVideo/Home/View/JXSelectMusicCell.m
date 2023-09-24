//
//  JXSelectMusicCell.m
//  Tigase_imChatT
//
//  Created by p on 2018/12/5.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "JXSelectMusicCell.h"
#import "WH_JXSelectMusic_WHVC.h"

@interface JXSelectMusicCell ()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *nickName;


@end

@implementation JXSelectMusicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        _icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        _icon.userInteractionEnabled = YES;
        [self addSubview:_icon];
        _wh_playBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 20, 20)];
        [_wh_playBtn addTarget:self action:@selector(playBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_wh_playBtn setImage:[UIImage imageNamed:@"ic_music_state0"] forState:UIControlStateNormal];
        [_wh_playBtn setImage:[UIImage imageNamed:@"ic_music_state2"] forState:UIControlStateSelected];
        [_icon addSubview:_wh_playBtn];
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_icon.frame) + 10, _icon.frame.origin.y, 200, 20)];
        _name.font = [UIFont boldSystemFontOfSize:16.0];
        [self addSubview:_name];
        
        _nickName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_icon.frame) + 10, CGRectGetMaxY(_name.frame) + 10, 200, 20)];
        _nickName.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_nickName];
        
        _wh_selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 90, 23, 60, 25)];
        _wh_selectBtn.hidden = YES;
        _wh_selectBtn.backgroundColor = HEXCOLOR(0x4FC557);
        [_wh_selectBtn setTitle:Localized(@"JX_SelectMusicUse") forState:UIControlStateNormal];
        _wh_selectBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_wh_selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_wh_selectBtn addTarget:self action:@selector(WH_select_WHBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_wh_selectBtn];
        
        
        _wh_audioPlayer = [[WH_AudioPlayerTool alloc]initWithParent:self frame:CGRectNull isLeft:YES];
        _wh_audioPlayer.wh_isOpenProximityMonitoring = NO;
        _wh_audioPlayer.delegate = self;
        _wh_audioPlayer.didAudioPlayEnd = @selector(didAudioPlayEnd);
        _wh_audioPlayer.didAudioPlayBegin = @selector(didAudioPlayBegin);
        _wh_audioPlayer.didAudioOpen = @selector(didAudioOpen);
    }
    
    return self;
}

- (void)WH_select_WHBtnAction:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(selectMusicCell:WH_select_WHBtnAction:)]) {
        [self.delegate selectMusicCell:self WH_select_WHBtnAction:self.wh_model];
    }
}

- (void)didAudioPlayBegin {
    
    _wh_selectBtn.hidden = NO;
}

- (void)didAudioPlayEnd {
    _wh_playBtn.selected = NO;
}

- (void)playBtnAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    WH_JXSelectMusic_WHVC *vc = (WH_JXSelectMusic_WHVC *)self.delegate;
    JXSelectMusicCell *cell = [vc.tableView cellForRowAtIndexPath:vc.selectIndexPath];
    if (cell.wh_playBtn.selected && vc.selectIndexPath != self.wh_indexPath) {
        cell.wh_playBtn.selected = NO;
        cell.wh_selectBtn.hidden = YES;
        [cell.wh_audioPlayer wh_stop];
    }
    vc.selectIndexPath = self.wh_indexPath;
    
    if (btn.selected) {
    }
    
//    if (btn.selected) {
        [_wh_audioPlayer wh_switch];
//    }else {
//        [_audioPlayer stop];
//    }
}

- (void)setWh_model:(WH_JXSelectMusicModel *)model {
    _wh_model = model;
    
    [self.icon sd_setImageWithURL:[NSURL URLWithString:model.cover] placeholderImage:[UIImage imageNamed:@""]];
    _name.text = model.name;
    _nickName.text = model.nikeName;
    _wh_audioPlayer.wh_audioFile = [[NSString stringWithFormat:@"%@%@",g_config.downloadUrl,model.path] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)sp_getUsersMostLiked {
    NSLog(@"Check your Network");
}
@end
