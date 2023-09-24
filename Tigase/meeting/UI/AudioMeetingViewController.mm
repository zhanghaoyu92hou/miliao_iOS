//
//  AudioMeetingViewController.m
//  shiku_im
//
//  Created by 1 on 17/3/28.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "AudioMeetingViewController.h"
#import "CallViewController.h"

@interface AudioMeetingViewController ()<UITextFieldDelegate>
{
    NgnBaseService<INgnSipService>* mSipService;
    UILabel * _noticeLabel;
    UITextField * _phoneTextF;
    UIButton * _starMeetBtn;
    UILabel * _loginStateLabel;
}

@end

@implementation AudioMeetingViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = Localized(@"JX_Meeting");
        self.isGotoBack = YES;
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        mSipService = [[NgnEngine sharedInstance] getSipService];
        if (!_type) {
            _type = AudioMeetingTypeNumberByUserSelf;
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self createHeadAndFoot];
    self.tableBody.backgroundColor = HEXCOLOR(0xf0eff4);
//    self.tableBody.contentSize = CGSizeMake(self_width, self_height);
    
    [self customUI];
    
    if (![self updateLoginState]) {
        [g_meeting stopMeeting];
        
        [g_meeting startMeeting];
    }
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_wait start:Localized(@"JXAudioMeetingVC_LoginSIP") delay:1.5];
    [self performSelector:@selector(updateLoginState) withObject:nil afterDelay:1.5];

}

-(BOOL)updateLoginState{
    
    if([[[NgnEngine sharedInstance] getSipService] isRegistered]){
        NSLog(@"ngn isRegistered success");
        _loginStateLabel.text = Localized(@"JXAudioMeetingVC_LoginFinish");
        _loginStateLabel.textColor = [UIColor greenColor];
        _starMeetBtn.enabled = YES;
        _starMeetBtn.backgroundColor = THEMECOLOR;
        return YES;
    }
    else {
        NSLog(@"ngn isRegistered faild");
        _loginStateLabel.text = Localized(@"JXAudioMeeting_NotLogin");
        _loginStateLabel.textColor = [UIColor grayColor];
        _starMeetBtn.enabled = NO;
        _starMeetBtn.backgroundColor = [UIColor grayColor];
        return NO;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)customUI{
    
    _loginStateLabel = [UIFactory createLabelWith:CGRectMake(JX_SCREEN_WIDTH-60-10, 10, 60, 20) text:Localized(@"JXAudioMeeting_NotLogin") font:g_factory.font13 textColor:[UIColor blackColor] backgroundColor:nil];
    _loginStateLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.tableBody addSubview:_loginStateLabel];
    
    
    _noticeLabel = [UIFactory createLabelWith:CGRectMake(25, CGRectGetMaxY(_loginStateLabel.frame)+15, JX_SCREEN_WIDTH-25*2, 60) text:@"" font:g_factory.font16 textColor:[UIColor blackColor] backgroundColor:nil];
    _noticeLabel.numberOfLines = 0;
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.tableBody addSubview:_noticeLabel];
    
    if (_type == AudioMeetingTypeNumberByUserSelf) {
        _noticeLabel.text = Localized(@"JXAudioMeeting_InputPassWordToMeeting");
        _phoneTextF = [UIFactory createTextFieldWithRect:CGRectMake((JX_SCREEN_WIDTH-100)/2, CGRectGetMaxY(_noticeLabel.frame)+15, 100, 30) keyboardType:UIKeyboardTypePhonePad secure:NO placeholder:@"****" font:g_factory.font14 color:[UIColor blackColor] delegate:self];
    }else if (_type == AudioMeetingTypeGroupCall) {
        _noticeLabel.text = Localized(@"JXAudioMeeting_StartGroupCallNotice");
        _phoneTextF = [UIFactory createTextFieldWithRect:CGRectMake((JX_SCREEN_WIDTH-150)/2, CGRectGetMaxY(_noticeLabel.frame)+15, 150, 30) keyboardType:UIKeyboardTypePhonePad secure:NO placeholder:nil font:g_factory.font14 color:[UIColor blackColor] delegate:self];
        _phoneTextF.text = self.call;
    }
    
    [self.tableBody addSubview:_phoneTextF];
    
    
    _starMeetBtn = [UIFactory createButtonWithRect:CGRectMake(25, CGRectGetMaxY(_phoneTextF.frame) +50, JX_SCREEN_WIDTH-25*2, 40) title:Localized(@"JXAudioMeetingVC_StartMeeting") titleFont:g_factory.font16 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(startMeeting) target:self];
    _starMeetBtn.backgroundColor = THEMECOLOR;
    _starMeetBtn.layer.masksToBounds = YES;
    _starMeetBtn.layer.cornerRadius = 7;
    
    [self.tableBody addSubview:_starMeetBtn];
    
    
}
-(void)startMeeting{
    if (_phoneTextF.text.length <= 0){
        return;
    }
    [_phoneTextF resignFirstResponder];
    
    [CallViewController makeAudioCallWithRemoteParty:_phoneTextF.text toUserName:nil andSipStack: [mSipService getSipStack]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
