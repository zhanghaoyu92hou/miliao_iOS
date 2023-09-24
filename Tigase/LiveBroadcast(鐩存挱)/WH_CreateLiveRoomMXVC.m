//
//  WH_CreateLiveRoomMXVC.m
//  Tigase_imChatT
//
//  Created by 1 on 17/8/9.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_CreateLiveRoomMXVC.h"

@interface WH_CreateLiveRoomMXVC ()<UITextFieldDelegate>

@property (nonatomic, strong) UIImageView * headImgView;

@property (nonatomic, strong) UITextField * titleField;

@property (nonatomic, strong) UITextField * noticeField;

@property (nonatomic, strong) UIButton * createButton;

@end

@implementation WH_CreateLiveRoomMXVC

-(instancetype)init{
    if (self = [super init]) {
        self.wh_isGotoBack = YES;
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        
    }
    return self;
}


// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    [self createHeadAndFoot];
    self.title = Localized(@"JXLiveVC_CreatLiveRoom");
    self.wh_tableBody.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    
    [self.wh_tableBody addSubview:self.headImgView];
    
    [self.wh_tableBody addSubview:self.titleField];
    
    [self.wh_tableBody addSubview:self.noticeField];
     
    [self.wh_tableBody addSubview:self.createButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.wh_tableBody addGestureRecognizer:tap];

}

- (void)tapAction{
    [self.view endEditing:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [_titleField becomeFirstResponder];
}

-(UIImageView *)headImgView{
    if (!_headImgView){
        _headImgView = [[UIImageView alloc] init];
        _headImgView.frame = CGRectMake(0, 60, 65, 65);
        _headImgView.center = CGPointMake(JX_SCREEN_WIDTH/2, _headImgView.center.y);
        [_headImgView headRadiusWithAngle:_headImgView.frame.size.width * 0.5];
        //        _headImageView.layer.borderWidth = 0.5;
        _headImgView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [g_server WH_getHeadImageSmallWIthUserId:self.wh_userId userName:nil imageView:_headImgView];
    }
    return _headImgView;
}

-(UITextField *)titleField{
    if (!_titleField) {
        _titleField = [UIFactory WH_create_WHTextFieldWith:CGRectMake(25, CGRectGetMaxY(_headImgView.frame) +40, JX_SCREEN_WIDTH-25*2, 44) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JXLiveVC_InputRoomName") font:sysFontWithSize(13)];
    }
    return _titleField;
}
-(UITextField *)noticeField{
    if (!_noticeField) {
        _noticeField = [UIFactory WH_create_WHTextFieldWith:CGRectMake(25, CGRectGetMaxY(_titleField.frame) +20, JX_SCREEN_WIDTH-25*2, 44) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JXLiveVC_InputRoomNotice") font:sysFontWithSize(13)];
    }
    return _noticeField;
}

-(UIButton *)createButton{
    if (!_createButton) {
        _createButton = [UIFactory WH_create_WHCommonButton:Localized(@"JXLiveVC_CreatLiveRoom") target:self action:@selector(createButtonAction:)];
        _createButton.layer.cornerRadius = 7;
        _createButton.clipsToBounds = YES;
        _createButton.frame = CGRectMake(25,CGRectGetMaxY(_noticeField.frame) +40, JX_SCREEN_WIDTH- 25*2, 40);
    }
    return _createButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _titleField) {
        [_titleField resignFirstResponder];
        [_noticeField becomeFirstResponder];
    }else{
        [_noticeField resignFirstResponder];
    }
    return YES;
}

-(void)createButtonAction:(UIButton *)button{
    if (_titleField.text.length <= 0) {
        [g_App showAlert:Localized(@"JXLiveVC_InputRoomName")];
        return;
    }
    
    NSString *notice = _noticeField.text;
    
    if (_noticeField.text.length <= 0) {
//        [g_App showAlert:Localized(@"JXLiveVC_InputRoomNotice")];
//        return;
        notice = _titleField.text;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(createLiveRoomDelegate:notice:)]) {
        [_delegate createLiveRoomDelegate:_titleField.text notice:notice];
        [self actionQuit];
    }
    
}

@end
