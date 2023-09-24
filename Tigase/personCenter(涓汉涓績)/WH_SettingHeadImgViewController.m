//
//  WH_SettingHeadImgViewController.m
//  Tigase
//
//  Created by 齐科 on 2019/8/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_SettingHeadImgViewController.h"
#import "WH_SetGroupHeads_WHView.h"
#import "WH_JXCamera_WHVC.h"
#import "UIView+CustomAlertView.h"
#import "ImageResize.h"
#import "OBSHanderTool.h"
#import "UIImage+HBClass.h"

@interface WH_SettingHeadImgViewController () <UITableViewDelegate,UITableViewDataSource, WH_JXCamera_WHVCDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableArray *imageArray;
    UITableView *headTable;
    CGFloat headWidth; //!<  头像宽高
    CGFloat borderSpace;//!<  两边边距
    CGFloat verticalSpace;//!< 垂直方向间距
    CGFloat horizontalSpace; //!< 水平方向边距
    CGFloat headCellTotalHeight; //!< 默认头像视图总高度
    UIImage *selectedImage; //!< 选中图片的名称
    NSInteger selectedIndex; //!< 选中图片按钮的Tag
    UIView *maskView; //!< 头像选中图层
}

@property (nonatomic,strong) UIButton *confirmBtn;
@end

@implementation WH_SettingHeadImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"选择头像";
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    self.wh_isNotCreatewh_tableBody = YES;
    [self createHeadAndFoot];
    [self loadImages];
    [self loadSubView];
}

- (void)loadImages {
    imageArray = [NSMutableArray new];
    for (int i = 1; i<17; i++) {
        NSString *imgStr = [NSString stringWithFormat:@"headimage_%d",i];
        [imageArray addObject:imgStr];
    }
    
    /*
        计算默认头像的宽、高及边距和间距
        依据屏幕宽度计算头像视图宽高
     */
    borderSpace = 20;
    horizontalSpace = 25;
    verticalSpace = 20;
    headWidth = (JX_SCREEN_WIDTH - 10*2/*tableView两边距*/ - borderSpace*2/*内部边距*/ - horizontalSpace*3/*间距*/)/4;
    headCellTotalHeight = 20*2/*上下边距*/ + headWidth*4/*图片总高度*/ + verticalSpace*3/*间距总高度*/;
}
- (void)loadSubView {
    headTable = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - JX_SCREEN_TOP-JX_SCREEN_TOP) style:UITableViewStylePlain];
    [headTable setDelegate:self];
    [headTable setDataSource:self];
    [headTable setBackgroundColor:g_factory.globalBgColor];
    [headTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:headTable];
}

#pragma mark ---- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 56.0;
    if (indexPath.section == 1) {
        height = headCellTotalHeight;
    }else if (indexPath.section == 2) {
        height = 44;
    }
    
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SettingHeadIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = g_factory.globalBgColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, JX_SCREEN_WIDTH-20, 56)];
    backView.layer.cornerRadius = 10;
    backView.layer.masksToBounds = YES;
    backView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    backView.layer.borderWidth = g_factory.cardBorderWithd;
    backView.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:backView];
    switch (indexPath.section) {
        case 0:
            {
                UILabel *chooseLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, backView.width-40-12, 56)];
                chooseLabel.text = @"从相册选择";
                chooseLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
                chooseLabel.textColor = HEXCOLOR(0x3A404C);
                [backView addSubview:chooseLabel];
                UIImageView *rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(backView.width-20-12, (56-12)/2, 12, 12)];
                rightArrow.image = [UIImage imageNamed:@"icon_right_arrow"];
                [backView addSubview:rightArrow];
            }
            break;
        case 1:
        {
            backView.height = headCellTotalHeight;
            int imageIndex = 0;
            for (int i= 0; i<4; i++) {
                for (int j = 0; j<4; j++) {
                    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(borderSpace+(headWidth+horizontalSpace)*j, 20+(headWidth+verticalSpace)*i, headWidth, headWidth)];
                    [button setImage:[UIImage imageNamed:imageArray[imageIndex]] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(selectHeadImage:) forControlEvents:UIControlEventTouchUpInside];
                    button.layer.cornerRadius = headWidth/2;
                    button.layer.masksToBounds = YES;
                    button.tag = imageIndex;
                    [backView addSubview:button];
                    if ([self.defaultImage isEaqualToImage:button.imageView.image]) {
                        [self selectHeadImage:button];
                    }
                    imageIndex++;
                }
            }
        }
            break;
        case 2:
        {
            backView.height = 44;
            backView.backgroundColor = HEXCOLOR(0x0093FF);
            UIButton *confirmButton = [[UIButton alloc] initWithFrame:backView.bounds];
            [confirmButton setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
            [confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:confirmButton];
            self.confirmBtn = confirmButton;
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}
#pragma mark ---- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self pickImageFromeAlbum];
    }
}

#pragma mark -- TableView HeaderAndFooter
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 15;
    if (section == 2) {
        height = 20;
    }
    return height;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height = 15;
    if (section == 2) {
        height = 20;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, height)];
    headerView.backgroundColor = g_factory.globalBgColor;
    return headerView;
}

#pragma mark ----- 从相册选择

/**
        从相册选择图片
 */
- (void)pickImageFromeAlbum {
    CGFloat viewH = 191;
    if (THE_DEVICE_HAVE_HEAD) {
        viewH = 191+24;
    }
    
    WH_SetGroupHeads_WHView *setGroupHeadsview = [[WH_SetGroupHeads_WHView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, viewH)];
    [setGroupHeadsview showInWindowWithMode:CustomAnimationModeShare inView:nil bgAlpha:0.5 needEffectView:NO];
    
    __weak typeof(setGroupHeadsview) weakShare = setGroupHeadsview;
    __weak typeof(self) weakSelf = self;
    [setGroupHeadsview setWh_selectActionBlock:^(NSInteger buttonTag) {
        if (buttonTag == 2) {
            //取消
            [weakShare hideView];
        }else if (buttonTag == 0) {
            //拍摄照片
            WH_JXCamera_WHVC *vc = [WH_JXCamera_WHVC alloc];
            vc.cameraDelegate = weakSelf;
            vc.isPhoto = YES;
            vc = [vc init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [weakSelf presentViewController:vc animated:YES completion:nil];
            [weakShare hideView];
        }else {
            //选择照片
            
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
            ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
            ipc.delegate = weakSelf;
            ipc.allowsEditing = YES;
            //选择图片模式
            ipc.modalPresentationStyle = UIModalPresentationCurrentContext;
            //    [g_window addSubview:ipc.view];
            if (IS_PAD) {
                UIPopoverController *pop =  [[UIPopoverController alloc] initWithContentViewController:ipc];
                [pop presentPopoverFromRect:CGRectMake((weakSelf.view.frame.size.width - 320) / 2, 0, 300, 300) inView:weakSelf.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }else {
                [weakSelf presentViewController:ipc animated:YES completion:nil];
            }
            
            [weakShare hideView];
            
        }
    }];
}

- (void)cameraVC:(WH_JXCamera_WHVC *)vc didFinishWithImage:(UIImage *)image {
    selectedImage = [ImageResize image:image fillSize:CGSizeMake(640, 640)];
    if (!self.isNeedRegistFirst && selectedImage != nil) {
        [self upLoadImageRequest];
    }else{

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.confirmBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
    }
    
}

#pragma mark ---- ImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    selectedImage = [ImageResize image:[info objectForKey:@"UIImagePickerControllerEditedImage"] fillSize:CGSizeMake(640, 640)];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (!self.isNeedRegistFirst && selectedImage != nil) {
        [self upLoadImageRequest];
    }else{

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.confirmBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        });

    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ----- Button Action
- (void)selectHeadImage:(UIButton *)button {
    if (!maskView) {
        maskView = [[UIView alloc] initWithFrame:button.bounds];
        maskView.userInteractionEnabled = NO;
        UIImageView *checkView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        checkView.center = maskView.center;
        checkView.userInteractionEnabled = YES;
        checkView.image = [UIImage imageNamed:@"head_check"];
        [maskView addSubview:checkView];
        maskView.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7].CGColor;
        [self selectDefaultImageAction:button];
    }else if (maskView.superview != nil) {
        if (selectedIndex == button.tag) {//如果点击已选中的按钮则删除maskView
            [maskView removeFromSuperview];
            selectedImage = nil;
            selectedIndex = 0;
        }else {
            [maskView removeFromSuperview];
            [self selectDefaultImageAction:button];
        }
    }else {
        [self selectDefaultImageAction:button];
    }
}
//图片相关数据赋值
- (void)selectDefaultImageAction:(UIButton *)button {
    selectedImage = [UIImage imageNamed:imageArray[button.tag]];
    selectedIndex = button.tag;
    [button addSubview:maskView];
}

- (void)confirmButtonAction:(UIButton *)button {
    if (self.isNeedRegistFirst && selectedImage != nil) {
        if (self.changeHeadImageBlock) {
            self.changeHeadImageBlock(selectedImage);
            [self actionQuit];
        }
        return;
    }
    if (selectedImage) {
        [self upLoadImageRequest];
    }else {
        [g_App showAlert:Localized(@"SELECT_AVATARS")];
    }
}
- (void)upLoadImageRequest {
    [_wait start];
    __weak typeof(self) weakSelf = self;
    [OBSHanderTool WH_handleUploadOBSHeadImage:self.user.userId image:selectedImage toView:self success:^(int code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_wait stop];
            [g_server WH_delHeadImageWithUserId:_user.userId];
            [g_notify postNotificationName:kUpdateUser_WHNotifaction object:weakSelf userInfo:nil];
            [g_navigation WH_dismiss_WHViewController:weakSelf animated:YES];
            if (weakSelf.changeHeadImageBlock) {
                weakSelf.changeHeadImageBlock(selectedImage);
            }
        });
    } failed:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_wait stop];
            [g_App showAlert:error.localizedDescription];
        });        
    }];
}

#pragma mark ---  WH_JXConnectionDelegate

- (void)WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    dispatch_async(dispatch_get_main_queue(), ^{
        [g_server WH_delHeadImageWithUserId:self.user.userId];
        [g_App showAlert:Localized(@"JXAlert_UpdateOK")];
        [g_notify postNotificationName:kUpdateUser_WHNotifaction object:self userInfo:nil];
        [_wait stop];
        [self actionQuit];
        if (self.changeHeadImageBlock && selectedImage != nil) {
            self.changeHeadImageBlock(selectedImage);
        }
    });
}
- (int)WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict {
    [_wait stop];
    return WH_show_error;
}
- (int)WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error {//error为空时，代表超时
    [_wait stop];
    return WH_show_error;
}
- (void)WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload {
}
@end
