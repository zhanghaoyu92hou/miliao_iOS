//
//  WH_PaySystemQrView.m
//  Tigase
//
//  Created by 闫振奎 on 2019/8/27.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_PaySystemQrView.h"

@interface WH_PaySystemQrView ()

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *qrImageView;
@property (nonatomic, strong) UIButton *saveBtn;
//@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation WH_PaySystemQrView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    _coverView = [UIView new];
    [self addSubview:_coverView];
    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsZero);
    }];
    _coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [_coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCoverView)]];
    
    _bgView = [UIView new];
    [self addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(63);
        make.right.offset(-63);
        make.centerY.offset(0);
        make.height.offset(280);
    }];
    _bgView.backgroundColor = [UIColor whiteColor];
    _bgView.layer.cornerRadius = 7;
    _bgView.layer.masksToBounds = YES;
    
    _qrImageView = [UIImageView new];
    [_bgView addSubview:_qrImageView];
    [_qrImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(17);
        make.right.offset(-17);
        make.top.offset(18);
        make.height.equalTo(_qrImageView.mas_width);
    }];
    
    _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_bgView addSubview:_saveBtn];
    [_saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_qrImageView.mas_bottom).offset(2);
        make.centerX.offset(0);
        make.size.mas_equalTo(CGSizeMake(124, 32));
    }];
    _saveBtn.layer.cornerRadius = 5;
    _saveBtn.layer.masksToBounds = YES;
    _saveBtn.layer.borderWidth = 1;
    _saveBtn.layer.borderColor = HEXCOLOR(0x999999).CGColor;
    [_saveBtn setTitle:@"保存二维码" forState:UIControlStateNormal];
    [_saveBtn setTitleColor:HEXCOLOR(0x999999) forState:UIControlStateNormal];
    [_saveBtn addTarget:self action:@selector(clickSaveBtn) forControlEvents:UIControlEventTouchUpInside];
    
//    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self addSubview:_closeBtn];
//    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.offset(0);
//        make.top.equalTo(_bgView.mas_bottom).offset(16);
//        make.size.mas_equalTo(CGSizeMake(20, 20));
//    }];
//    _closeBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.76];
//    [_closeBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//    [_closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickCoverView{
    [self dismiss];
}

- (void)setQrUrl:(NSString *)qrUrl{
    if (_qrUrl != qrUrl) {
        _qrUrl = [qrUrl copy];
        [_qrImageView sd_setImageWithURL:[NSURL URLWithString:_qrUrl]];
    }
}

- (void)clickSaveBtn{
    //点击保存二维码
    if (_qrImageView.image) {
        [self saveImageToPhotos:_qrImageView.image];
    } else {
        [GKMessageTool showText:@"加载二维码中,请稍等"];
    }
}


- (void)clickCloseBtn{
    //点击关闭按钮
    [self dismiss];
}

- (void)dismiss{
    [self removeFromSuperview];
}

#pragma mark 保存图片
- (void)saveImageToPhotos:(UIImage*)savedImage{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

#pragma mark 系统的完成保存图片的方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    NSString *msg = nil ;
    if (error != NULL) {
        msg = @"保存图片失败" ;
    } else {
        msg = @"保存图片成功" ;
    }
    [GKMessageTool showText:msg];
}

@end
