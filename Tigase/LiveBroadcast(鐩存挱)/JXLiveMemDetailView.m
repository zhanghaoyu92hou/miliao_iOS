//
//  MiXin_JXLiveMemDetail_MiXinView.m
//  shiku_im
//
//  Created by 1 on 17/7/30.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "MiXin_JXLiveMemDetail_MiXinView.h"
#import "JXLiveMemObject.h"

@interface MiXin_JXLiveMemDetail_MiXinView ()

@property (nonatomic, assign) NSInteger myType;
@property (nonatomic, assign) BOOL isShowBg;

@property (nonatomic, copy) NSString * roomName;
@property (nonatomic, copy) NSString * notice;

//bg
@property (nonatomic, strong) UIControl * bgControl;

//main
@property (nonatomic, strong) UIView * mainView;

//close
@property (nonatomic, strong) UIButton * closeButton;

//头像
@property (nonatomic, strong) UIImageView * headImgView;

//name
@property (nonatomic, strong) UILabel * nameLabel;

//主页
@property (nonatomic, strong) UIButton * hisPageButton;

//公告
@property (nonatomic, strong) UILabel * noticeLabel;



@property (nonatomic, strong) UITextView * roomNameText;
@property (nonatomic, strong) UITextView * noticeText;

@property (nonatomic, strong) UIButton * editName;
@property (nonatomic, strong) UIButton * editNotice;


@end

@implementation MiXin_JXLiveMemDetail_MiXinView

+(instancetype)memDetailView:(JXLiveMemObject *)memData myType:(NSInteger)myType garyBg:(BOOL)isShowBg frame:(CGRect)frame{
    return [[MiXin_JXLiveMemDetail_MiXinView alloc] initWith:memData myType:(NSInteger)myType garyBg:isShowBg Frame:frame];
}

-(instancetype)initWith:(JXLiveMemObject *)memData myType:(NSInteger)myType garyBg:(BOOL)isShowBg Frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _memData = memData;
        _myType = myType;
        _isShowBg = isShowBg;
        [self customSubviews];
    }
    return self;
}


-(void)customSubviews{
    if (_isShowBg) {
        _bgControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _bgControl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self addSubview:_bgControl];
        
        [_bgControl addTarget:self action:@selector(closeViewAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(40, 70, self.frame.size.width-80, self.frame.size.width)];
        _mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_mainView];
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(CGRectGetWidth(_mainView.frame)-30-5, 5, 30, 30);
//        [_closeButton setTitle:@"X" forState:UIControlStateNormal];
        [_closeButton setBackgroundImage:[[UIImage imageNamed:@"closeicon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _closeButton.tintColor = [UIColor redColor];
        [_closeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_mainView addSubview:_closeButton];
        [_closeButton addTarget:self action:@selector(closeViewAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self createDetailView];
    
    [self createManageButton];
    
    
}
-(void)createDetailView{
//    headImgView
    if (!_headImgView){
        _headImgView = [[UIImageView alloc] init];
        _headImgView.frame = CGRectMake(0, 60, 65, 65);
        _headImgView.center = CGPointMake(CGRectGetWidth(_mainView.frame)/2, _headImgView.center.y);
        [_headImgView headRadiusWithAngle:_headImgView.frame.size.width * 0.5];
        //        _headImageView.layer.borderWidth = 0.5;
        _headImgView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [_mainView addSubview:_headImgView];
        
        [g_server getHeadImageSmall:_memData.userId userName:_memData.nickName imageView:_headImgView];
    }
    
//    nameLabel
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headImgView.frame) +10, 150, 20)];
        _nameLabel.center = CGPointMake(_headImgView.center.x, _nameLabel.center.y);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.text = _memData.nickName;
        _nameLabel.font = SYSFONT(14);
        [_mainView addSubview:_nameLabel];
    }
    
    
//    hisPageButton
    if (!_hisPageButton) {
        _hisPageButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _hisPageButton.frame = CGRectMake(0, CGRectGetHeight(_mainView.frame) -35, 80, 25);
        _hisPageButton.center = CGPointMake(_headImgView.center.x, _hisPageButton.center.y);
        [_hisPageButton setTitle:Localized(@"JXLiveVC_TaPage") forState:UIControlStateNormal];
//        [_hisPageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [_mainView addSubview:_hisPageButton];
        [_hisPageButton addTarget:self action:@selector(hisPageAction) forControlEvents:UIControlEventTouchUpInside];
    }
////    noticeLabel
//    if ([_memData.type intValue] == 1) {//是主播,显示公告
//        if (!_noticeLabel) {
//            _noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_nameLabel.frame)+5, 300, 45)];
//            _noticeLabel.center = CGPointMake(_headImgView.center.x, _noticeLabel.center.y);
//            _noticeLabel.textAlignment = NSTextAlignmentCenter;
//            _noticeLabel.numberOfLines = 0;
//            _noticeLabel.font = SYSFONT(12);
//            [_mainView addSubview:_noticeLabel];
//        }
//
//    }
    
    
    
    if ([_memData.type intValue] == 1) {
        _roomNameText = [[UITextView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(_nameLabel.frame)+20, CGRectGetWidth(_mainView.frame)-40*2, 35)];
        _roomNameText.editable = NO;
        _roomNameText.font = g_factory.font18;
        [_mainView addSubview:_roomNameText];
        
        _noticeText = [[UITextView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(_roomNameText.frame)+10, CGRectGetWidth(_mainView.frame)-40*2, 45)];
        _noticeText.editable = NO;
        [_mainView addSubview:_noticeText];
    }
    
    if ([_memData.type intValue] == 1 && _myType == 1) {
        _editName = [UIButton buttonWithType:UIButtonTypeSystem];
        _editName.frame = CGRectMake(CGRectGetMaxX(_roomNameText.frame)+5, CGRectGetMinY(_roomNameText.frame), 25, 25);
        _editName.center = CGPointMake(_editName.center.x, _roomNameText.center.y);
        [_editName setTitle:Localized(@"JX_LiveChange") forState:UIControlStateNormal];
        [_editName setTitle:Localized(@"JX_LiveSave") forState:UIControlStateSelected];
        [_editName addTarget:self action:@selector(editNameAction:) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:_editName];
        
        _editNotice = [UIButton buttonWithType:UIButtonTypeSystem];
        _editNotice.frame = CGRectMake(CGRectGetMaxX(_noticeText.frame)+5, CGRectGetMinY(_noticeText.frame), 25, 25);
        _editNotice.center = CGPointMake(_editNotice.center.x, _noticeText.center.y);
        [_editNotice setTitle:Localized(@"JX_LiveChange") forState:UIControlStateNormal];
        [_editNotice setTitle:Localized(@"JX_LiveSave") forState:UIControlStateSelected];
        [_editNotice addTarget:self action:@selector(editNoticeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:_editNotice];
    }

}

-(void)createManageButton{
    
    if ([_memData.type intValue] == 1) {
        return;
    }
    
    if(_myType == 1 || _myType == 2){
        CGFloat manaY = CGRectGetHeight(_mainView.frame)-100;
        //    managerButton
        if (_myType == 1){
            if (!_managerButton) {
                _managerButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _managerButton.frame = CGRectMake(20, manaY, 100, 30);
                [_managerButton setBackgroundColor:THEMECOLOR];
                _managerButton.layer.cornerRadius = 5;
                _managerButton.layer.masksToBounds = YES;
                _managerButton.custom_acceptEventInterval = 1.f;
                [_managerButton setTitle:Localized(@"JXLiveVC_SetTheAdmin") forState:UIControlStateNormal];
                [_managerButton setTitle:Localized(@"JXLiveVC_IsTheAdmin") forState:UIControlStateSelected];
                [_mainView addSubview:_managerButton];
                
                [_managerButton addTarget:self action:@selector(manageGroupButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        //    shutUpButton
        if(!_shutUpButton){
            _shutUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _shutUpButton.frame = CGRectMake(CGRectGetMaxX(_managerButton.frame) +15, manaY, 80, 30);
            [_shutUpButton setBackgroundColor:THEMECOLOR];
            _shutUpButton.layer.cornerRadius = 5;
            _shutUpButton.layer.masksToBounds = YES;
            [_shutUpButton setTitle:Localized(@"JXLiveVC_SetGag") forState:UIControlStateNormal];
            [_shutUpButton setTitle:Localized(@"JXLiveVC_GagCancel") forState:UIControlStateSelected];
            [_mainView addSubview:_shutUpButton];
            
            [_shutUpButton addTarget:self action:@selector(manageGroupButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //    kickButton
        if (!_kickButton) {
            _kickButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _kickButton.frame = CGRectMake(CGRectGetMaxX(_shutUpButton.frame) +15, manaY, 50, 30);
            [_kickButton setBackgroundColor:THEMECOLOR];
            _kickButton.layer.cornerRadius = 5;
            _kickButton.layer.masksToBounds = YES;
            [_kickButton setTitle:Localized(@"JXLiveVC_Kick") forState:UIControlStateNormal];
            [_mainView addSubview:_kickButton];
            
            [_kickButton addTarget:self action:@selector(manageGroupButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    [self updateShow];
}




-(void)closeViewAction{
    [self actionDelegateType:JXLiveMemDetailActionTypeClose];
}
-(void)hisPageAction{
    [self actionDelegateType:JXLiveMemDetailActionTypeHisPage];
}
-(void)manageGroupButtonAction:(UIButton *)button{
    JXLiveMemDetailActionType type;
    if (button == _managerButton) {
        type = JXLiveMemDetailActionTypeSetManager;
    }else if (button == _shutUpButton) {
        if ([_memData.type intValue] == 2 && _myType == 2) {
            [g_server showMsg:Localized(@"JX_NoRightToSilenceTheAdministrator")];
            return;
        }
        type = JXLiveMemDetailActionTypeShutUp;
    }else if (button == _kickButton) {
        if ([_memData.type intValue] == 2 && _myType == 2) {
            [g_server showMsg:Localized(@"JX_NoRightToKickOutTheCaretaker")];
            return;
        }
        type = JXLiveMemDetailActionTypeKick;
    }else{
        type = JXLiveMemDetailActionTypeClose;
    }
    
    [self actionDelegateType:type];
}



-(void)actionDelegateType:(JXLiveMemDetailActionType)actionType{
    if (actionType == JXLiveMemDetailActionTypeUpdateRoom) {
        if (_roomNameText.text.length && _noticeText.text.length) {
            if (_delegate && [_delegate respondsToSelector:@selector(memDetailViewUpdateRoom:notice:)]) {
                [_delegate memDetailViewUpdateRoom:_roomNameText.text notice:_noticeText.text];
            }
        }else{
            [g_App showAlert:Localized(@"JX_LiveFillInTheFull")];
        }
    }else{
        if (_delegate && [_delegate respondsToSelector:@selector(memDetailViewDelegate:actionType:)]) {
            [_delegate memDetailViewDelegate:_memData actionType:actionType];
        }
    }
}

-(void)editNameAction:(UIButton *)button{
    button.selected = !button.selected;
    if (button.selected) {
        _roomNameText.editable = YES;
        [_roomNameText becomeFirstResponder];
        _editNotice.hidden = YES;
    }else{
        _roomNameText.editable = NO;
        [_roomNameText resignFirstResponder];
        [self actionDelegateType:JXLiveMemDetailActionTypeUpdateRoom];
        _editNotice.hidden = NO;
    }
}

-(void)editNoticeAction:(UIButton *)button{
    button.selected = !button.selected;
    if (button.selected) {
        _noticeText.editable = YES;
        [_noticeText becomeFirstResponder];
        _editName.hidden = YES;
    }else{
        _noticeText.editable = NO;
        [_noticeText resignFirstResponder];
        [self actionDelegateType:JXLiveMemDetailActionTypeUpdateRoom];
        _editName.hidden = NO;
    }
}


-(void)updateShow{
    if ([_memData.type intValue] == 2 || [_memData.type intValue] == 1) {
        _managerButton.selected = YES;
    }else {
        _managerButton.selected = NO;
    }
    
    _shutUpButton.enabled = YES;
    if ([_memData.state intValue] == 1) {
        _shutUpButton.selected = YES;
    }else{
        _shutUpButton.selected = NO;
    }
    
}


-(void)setRoomName:(NSString *)roomName{
    if (roomName != nil) {
        _roomName = roomName;
        _roomNameText.text = roomName;
    }
}

-(void)setNotice:(NSString *)notice{
    if (notice != nil){
        _notice = notice;
        _noticeText.text = notice;
    }
}
//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSEnumerator * touchEnum = [touches objectEnumerator];
//    for (UITouch * touch in touchEnum) {
//        NSLog(@"%@",touch.view);
//    }
//}


@end
