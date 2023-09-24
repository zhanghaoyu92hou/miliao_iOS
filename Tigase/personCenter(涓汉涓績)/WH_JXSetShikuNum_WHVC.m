//
//  WH_JXSetShikuNum_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2019/4/11.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXSetShikuNum_WHVC.h"

#define HEIGHT 50

@interface WH_JXSetShikuNum_WHVC () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@end

@implementation WH_JXSetShikuNum_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.wh_isGotoBack   = YES;
    self.title = [NSString stringWithFormat:@"%@%@",Localized(@"WaHu_JXSetting_WaHuVC_Set"),Localized(@"JX_Communication")];
    
    self.wh_heightFooter = 0;
    self.wh_heightHeader = JX_SCREEN_TOP;
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self createHeadAndFoot];
    self.wh_tableBody.backgroundColor = HEXCOLOR(0xf0eff4);
    self.wh_tableBody.scrollEnabled = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.layer.masksToBounds = YES;
    [self.wh_tableBody addSubview:imageView];
    [g_server WH_getHeadImageLargeWithUserId:g_myself.userId userName:g_myself.userNickname imageView:imageView];
    [self.wh_tableBody addSubview:imageView];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 20, imageView.frame.origin.y, 200, imageView.frame.size.height)];
    name.font = [UIFont systemFontOfSize:18.0];
    name.text = g_myself.userNickname;
    [self.wh_tableBody addSubview:name];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(imageView.frame) + 50, JX_SCREEN_WIDTH - 40, 50)];
    _textField.delegate = self;
    [_textField becomeFirstResponder];
    _textField.keyboardType = UIKeyboardTypeASCIICapable;
    [self.wh_tableBody addSubview:_textField];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(_textField.frame.origin.x, CGRectGetMaxY(_textField.frame), _textField.frame.size.width, 2.0)];
    line.backgroundColor = THEMECOLOR;
    [self.wh_tableBody addSubview:line];
    
    UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(line.frame), line.frame.size.width, 60)];
    tip.font = [UIFont systemFontOfSize:15.0];
    tip.textColor = [UIColor lightGrayColor];
    tip.text = Localized(@"JX_CommunicationOnlySetOne");
    [self.wh_tableBody addSubview:tip];
    
    UIButton* _btn = [UIFactory WH_create_WHCommonButton:Localized(@"JX_Confirm") target:self action:@selector(onConfirm)];

    _btn.layer.cornerRadius = 5;
    _btn.clipsToBounds = YES;
    _btn.custom_acceptEventInterval = 1.0f;
    _btn.frame = CGRectMake(INSETS, CGRectGetMaxY(tip.frame) + 20, WIDTH, HEIGHT);
    [self.wh_tableBody addSubview:_btn];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.wh_tableBody addGestureRecognizer:tap];
}

- (void)tapAction{
    
    [self.view endEditing:YES];
}

- (void)onConfirm {
    self.user.account = _textField.text;
    g_myself.account = self.user.account;
    [g_server WH_updateWaHuNum:self.user toView:self];
}

-(BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string{
    
    NSUInteger lengthOfString = string.length;//lengthOfString的值始终为1
    
    for(NSInteger loopIndex =0; loopIndex < lengthOfString; loopIndex++) {
        unichar character = [string characterAtIndex:loopIndex];
        //将输入的值转化为ASCII值（即内部索引值），可以参考ASCII表            // 48-57;{0,9};65-90;{A..Z};97-122:{a..z}
        if(character <48) return NO;// 48 unichar for 0
        if(character >57&& character <65) return NO;
        if(character >90&& character <97) return NO;
        if(character >122) return NO;
        
    }
    return YES;
}


#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    
    if( [aDownload.action isEqualToString:wh_act_UserUpdate] ){
        self.user.setAccountCount = [NSString stringWithFormat:@"%ld",([g_myself.setAccountCount integerValue] + 1)];
        g_myself.setAccountCount = self.user.setAccountCount;
        if ([self.delegate respondsToSelector:@selector(setShikuNum:updateSuccessWithAccount:)]) {
            [self.delegate setShikuNum:self updateSuccessWithAccount:self.user.account];
            
            [self actionQuit];
        }
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)sp_upload {
    NSLog(@"Continue");
}

- (void)sp_checkUserInfo {
    NSLog(@"Continue");
}
@end
