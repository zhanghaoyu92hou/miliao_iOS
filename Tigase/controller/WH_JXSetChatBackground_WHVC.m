//
//  WH_JXSetChatBackground_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2017/12/8.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXSetChatBackground_WHVC.h"
#import "WH_JXCamera_WHVC.h"

#define HEIGHT 50

@interface WH_JXSetChatBackground_WHVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,WH_JXCamera_WHVCDelegate>

@end

@implementation WH_JXSetChatBackground_WHVC

- (instancetype)init {
    if ([super init]) {
        
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.wh_isGotoBack = YES;
    self.title = Localized(@"JX_SettingUpChatBackground");
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self createHeadAndFoot];
    self.wh_tableBody.backgroundColor = HEXCOLOR(0xf0eff4);
    self.wh_tableBody.scrollEnabled = YES;
    
    int h=9;
    int w=JX_SCREEN_WIDTH;
    
    WH_JXImageView* iv;
    iv = [self WH_createMiXinButton:Localized(@"JX_SelectionFromHandsetAlbum") drawTop:YES drawBottom:YES icon:nil click:@selector(onPickPhoto)];
    iv.frame = CGRectMake(0,h, w, HEIGHT);
    h+=iv.frame.size.height;
    
    iv = [self WH_createMiXinButton:Localized(@"JX_TakeAPicture") drawTop:NO drawBottom:YES icon:nil click:@selector(onCamera)];
    iv.frame = CGRectMake(0,h, w, HEIGHT);
    h+=iv.frame.size.height + 11;
    
    iv = [self WH_createMiXinButton:Localized(@"JX_RestoreDefaultBackground") drawTop:YES drawBottom:YES icon:nil click:@selector(onDefault)];
    iv.frame = CGRectMake(0,h, w, HEIGHT);
}

// 从手机相册选择
- (void)onPickPhoto {
    
    UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
    [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imgPicker setDelegate:self];
    [imgPicker setAllowsEditing:NO];
    [self presentViewController:imgPicker animated:YES completion:^{}];
}

// 拍照
- (void)onCamera {
    WH_JXCamera_WHVC *vc = [WH_JXCamera_WHVC alloc];
    vc.cameraDelegate = self;
    vc.isPhoto = YES;
    vc = [vc init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

// 恢复默认
- (void)onDefault {
    
    if (self.userId.length > 0) {
        [g_constant.userBackGroundImage removeObjectForKey:[NSString stringWithFormat:@"%@_%@" ,MY_USER_ID ,self.userId]];
        BOOL isSuccess = [g_constant.userBackGroundImage writeToFile:backImage atomically:YES];
        
        [g_notify postNotificationName:kSetBackGroundImageView_WHNotification object:nil];
        if (isSuccess) {
            [g_App showAlert:Localized(@"JX_SetUpSuccess")];
        }else {
            [g_App showAlert:Localized(@"JX_SettingFailure")];
        }
        return;
    }else{
        [g_constant.chatBackgrounImage removeObjectForKey:MY_USER_ID];
        BOOL isSuccess = [g_constant.chatBackgrounImage writeToFile:ChatBackgroundImage atomically:YES];
        [g_notify postNotificationName:kSetBackGroundImageView_WHNotification object:nil];
        if (isSuccess) {
            [g_App showAlert:Localized(@"JX_SetUpSuccess")];
        }else {
            [g_App showAlert:Localized(@"JX_SettingFailure")];
        }
    }
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:kChatBackgroundImagePath]) {
        [g_App showAlert:Localized(@"JX_SetUpSuccess")];
        return;
    }
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:kChatBackgroundImagePath error:&error];
    if (!error) {
        [g_App showAlert:Localized(@"JX_SetUpSuccess")];
    }else {
        [g_App showAlert:Localized(@"JX_SettingFailure")];
    }
}


#pragma mark ----------图片选择完成-------------
//UIImagePickerController代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    UIImage  * chosedImage=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSData *imageData = UIImageJPEGRepresentation(chosedImage, 1);
    BOOL isSuccess = NO;
    if (self.userId.length > 0) {
//        if ([self.delegate respondsToSelector:@selector(setChatBackgroundVC:image:)]) {
//            [self.delegate setChatBackgroundVC:self image:chosedImage];
//        }
        [g_constant.userBackGroundImage setObject:imageData forKey:[NSString stringWithFormat:@"%@_%@" ,MY_USER_ID ,self.userId]];
        isSuccess = [g_constant.userBackGroundImage writeToFile:backImage atomically:YES];
        [g_notify postNotificationName:kSetBackGroundImageView_WHNotification object:chosedImage];

    }else {
        [g_constant.chatBackgrounImage setObject:imageData forKey:MY_USER_ID];
        [g_constant.chatBackgrounImage writeToFile:ChatBackgroundImage atomically:YES];
        
        isSuccess = [imageData writeToFile:kChatBackgroundImagePath atomically:YES];
        [g_notify postNotificationName:kSetBackGroundImageView_WHNotification object:chosedImage];
        
    }
    if (isSuccess) {
        [g_App showAlert:Localized(@"JX_SetUpSuccess")];
    }else {
        [g_App showAlert:Localized(@"JX_SettingFailure")];
    }
    
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:^{
    }];
}

// 拍照
- (void)cameraVC:(WH_JXCamera_WHVC *)vc didFinishWithImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    BOOL isSuccess = NO;
    if (self.userId.length > 0) {
//        if ([self.delegate respondsToSelector:@selector(setChatBackgroundVC:image:)]) {
//            [self.delegate setChatBackgroundVC:self image:image];
//        }
        [g_constant.userBackGroundImage setObject:imageData forKey:[NSString stringWithFormat:@"%@_%@" ,MY_USER_ID ,self.userId]];
        isSuccess = [g_constant.userBackGroundImage writeToFile:backImage atomically:YES];
        
        [g_notify postNotificationName:kSetBackGroundImageView_WHNotification object:image];
    }else {
        [g_constant.chatBackgrounImage setObject:imageData forKey:MY_USER_ID];
        [g_constant.chatBackgrounImage writeToFile:ChatBackgroundImage atomically:YES];
        
        isSuccess = [imageData writeToFile:kChatBackgroundImagePath atomically:YES];
        
    }
    if (isSuccess) {
        [g_App showAlert:Localized(@"JX_SetUpSuccess")];
    }else {
        [g_App showAlert:Localized(@"JX_SettingFailure")];
    }
    
}

-(WH_JXImageView*)WH_createMiXinButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon click:(SEL)click{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.wh_delegate = self;
    [self.wh_tableBody addSubview:btn];
    //    [btn release];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(25, 0, JX_SCREEN_WIDTH-100, HEIGHT)];
    p.text = title;
    p.font = sysFontWithSize(16);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    p.wh_delegate = self;
    p.didTouch = click;
    [btn addSubview:p];
    
    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, (HEIGHT-20)/2, 20, 20)];
        iv.image = [UIImage imageNamed:icon];
        [btn addSubview:iv];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT-0.5,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3, 13, 20, 20)];
        iv.image = [UIImage imageNamed:@"set_list_next"];
        [btn addSubview:iv];
    }
    
    return btn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)sp_getUsersMostLikedSuccess {
    NSLog(@"Get User Succrss");
}
@end
