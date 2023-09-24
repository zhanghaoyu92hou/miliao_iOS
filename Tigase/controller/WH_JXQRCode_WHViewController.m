//
//  WH_JXQRCode_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 17/9/14.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXQRCode_WHViewController.h"
#import "WH_QRImage.h"

@interface WH_JXQRCode_WHViewController ()

@property (nonatomic, strong) UIImageView * qrImageView;

@property (nonatomic, strong) UIButton * saveButton;


@end

@implementation WH_JXQRCode_WHViewController

-(instancetype)init{
    if (self = [super init]) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.title = Localized(@"JXQR_QRImage");
        self.wh_isGotoBack = YES;
    }
    return self;
}


// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    [self createHeadAndFoot];
    self.wh_tableBody.backgroundColor = THEMEBACKCOLOR;
    [self.wh_tableHeader addSubview:self.saveButton];
    
//    NSMutableDictionary * qrDict = [NSMutableDictionary dictionary];
    NSMutableString * qrStr = [NSMutableString stringWithFormat:@"%@?action=",g_config.website];
    if(self.type == QRUserType)
        [qrStr appendString:@"user"];
//        [qrDict setObject:@"user" forKey:@"action"];
    else if(self.type == QRGroupType)
        [qrStr appendString:@"group"];
//        [qrDict setObject:@"group" forKey:@"action"];
    if(self.userId != nil)
        [qrStr appendFormat:@"&tigId=%@",self.userId];
//        [qrDict setObject:self.userId forKey:@"shiku"];
    
    
//     = [[[SBJsonWriter alloc] init] stringWithObject:qrDict];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    if (self.type == QRGroupType) {
//        NSString *groupImagePath = [NSString stringWithFormat:@"%@%@/%@.%@",NSTemporaryDirectory(),g_myself.userId,self.userId,@"jpg"];
//        if (groupImagePath && [[NSFileManager defaultManager] fileExistsAtPath:groupImagePath]) {
//            imageView.image = [UIImage imageWithContentsOfFile:groupImagePath];
//        }else{
//            [roomData roomHeadImageRoomId:self.userId toView:imageView];
//        }
        [g_server WH_getRoomHeadImageSmallWithUserId:self.roomJId roomId:self.userId imageView:imageView];
    }else {
        [g_server WH_getHeadImageLargeWithUserId:self.userId userName:self.nickName imageView:imageView];
    }
    
    UIImage * qrImage = [WH_QRImage qrImageForString:qrStr imageSize:300 logoImage:imageView.image logoImageSize:70];
    _qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-300)/2, 100, 300, 300)];
    _qrImageView.image = qrImage;
    [self.wh_tableBody addSubview:_qrImageView];
    
}

-(void)saveButtonAction{
    UIImage * image = [self generateViewImage:_qrImageView];
    [self saveToLibary:image];
}

-(UIImage *)generateViewImage:(UIView *)view{
    CGSize s = view.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, YES, 1.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)saveToLibary:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (!error) {
        [g_server showMsg:Localized(@"JX_SaveSuessed") delay:1.5f];
    }else{
        [g_App showAlert:error.description];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIButton *)saveButton{
    if(!_saveButton){
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.frame = CGRectMake(JX_SCREEN_WIDTH-30-8, JX_SCREEN_TOP - 34, 30, 30);
        [_saveButton setImage:[UIImage imageNamed:@"saveLibary"] forState:UIControlStateNormal];
        [_saveButton setImage:[UIImage imageNamed:@"saveLibary"] forState:UIControlStateHighlighted];
        [_saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}



@end
