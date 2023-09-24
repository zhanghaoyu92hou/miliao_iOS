//
//  WH_JXFileDetail_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 17/7/7.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXFileDetail_WHViewController.h"
#import "WH_JXShareFileObject.h"
#import "MCDownloader.h"
#import "WH_webpage_WHVC.h"
#import "UIImageView+WH_FileType.h"
#import "NSString+ContainStr.h"

@interface WH_JXFileDetail_WHViewController ()<UITextViewDelegate>

@property (strong, nonatomic) UIImageView * typeView;
@property (strong, nonatomic) UILabel * fileTitleLabel;
//@property (strong, nonatomic) UITextView * textView;

@property (nonatomic ,strong) UIButton *preBtn;
@property (strong, nonatomic) UIButton * downloadBtn;
@property (strong, nonatomic) UIView * downloadingView;

@property (strong, nonatomic) UILabel * receivedLabel;
@property (strong, nonatomic) UIProgressView * progressView;
@property (strong, nonatomic) UIButton * stopButton;

@property (assign, atomic) BOOL dalay;
@end

@implementation WH_JXFileDetail_WHViewController


-(instancetype)init{
    self = [super init];
    if (self) {
//        self.wh_heightHeader = JX_SCREEN_TOP;
//        self.wh_heightFooter = 0;
//        self.wh_isGotoBack = YES;
    }
    return self;
}


// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = _shareFile.fileName;
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    
    [self createHeadAndFoot];
    [self customView];
    
    
    NSString *fieldUrl = _shareFile.url;

    //由于有特殊字符时编码前后url前后不一样,导致编码后url不能被识别,所以把编码去除
    if ([NSString isHasChineseWithStr:fieldUrl]) {
        self.shareFieldUrl = [fieldUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];//编码
    }else{
        self.shareFieldUrl = fieldUrl;//不编码
    }
    
    NSLog(@"shareField url:%@" ,[NSURL URLWithString:self.shareFieldUrl]);
    
    if (self.shareFile) {
        [self WH_setViewDataWith:0 expectedSize:0 speed:0];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     MCDownloadReceipt *receipt = [[MCDownloader sharedDownloader] downloadReceiptForURLString:self.shareFieldUrl];
    if (receipt.state == MCDownloadStateDownloading) {
        [self downloadBtnAction];
    }
}
-(void)customView{
    if(!_typeView){
        _typeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, 60, 55)];
        _typeView.center = CGPointMake(self.wh_tableBody.center.x, _typeView.center.y);
        _typeView.layer.cornerRadius = 3;
        _typeView.layer.masksToBounds = YES;
//        _typeView.backgroundColor = [UIColor redColor];
        _typeView.backgroundColor = [UIColor whiteColor];
        [_typeView setFileType:[_shareFile.type integerValue]];
        [self.wh_tableBody addSubview:_typeView];
    }
    
    if(!_fileTitleLabel){
        _fileTitleLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:_shareFile.fileName font:sysFontWithSize(16) textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
        _fileTitleLabel.frame = CGRectMake(15, CGRectGetMaxY(_typeView.frame)+15, JX_SCREEN_WIDTH - 30, 25);
        _fileTitleLabel.center = CGPointMake(self.wh_tableBody.center.x, _fileTitleLabel.center.y);
        _fileTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.wh_tableBody addSubview:_fileTitleLabel];
    }
    
//    if (!_textView) {
//        _textView = [[UITextView alloc] init];
//        _textView.frame = CGRectMake(0, CGRectGetMaxY(_fileTitleLabel.frame), 150, 25);
//        _textView.center = CGPointMake(self.wh_tableBody.center.x, _textView.center.y);
//        _textView.delegate = self;
//        [self.wh_tableBody addSubview:_textView];
//        [self protocolIsSelect];
//    }
    
    if (!_preBtn) {
        _preBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_preBtn setFrame:CGRectMake(15, CGRectGetMaxY(_fileTitleLabel.frame), JX_SCREEN_WIDTH - 30, 25)];
        [_preBtn setBackgroundColor:self.view.backgroundColor];
        [self.wh_tableBody addSubview:_preBtn];
        NSString *preTitle = Localized(@"JXFile_fileBeforeOnline");
        [_preBtn setTitle:preTitle forState:UIControlStateNormal];
        [_preBtn setTitle:preTitle forState:UIControlStateHighlighted];
        [_preBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
//        [_preBtn.titleLabel setTextColor:[UIColor lightGrayColor]];
        [_preBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:preTitle];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:[[attributedString string] rangeOfString:Localized(@"JXFile_online")]];
        _preBtn.titleLabel.attributedText = attributedString;
        
        [_preBtn addTarget:self action:@selector(previewMethod) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    if(!_downloadBtn){
        _downloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _downloadBtn.backgroundColor = THEMECOLOR;
        [_downloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_downloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _downloadBtn.frame = CGRectMake(0, CGRectGetMaxY(_fileTitleLabel.frame) +45, 200, 30);
        _downloadBtn.center = CGPointMake(self.wh_tableBody.center.x, _downloadBtn.center.y);
        [self.wh_tableBody addSubview:_downloadBtn];
        [_downloadBtn addTarget:self action:@selector(downloadBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_downloadingView) {
        _downloadingView = [[UIView alloc] init];
        _downloadingView.backgroundColor = [UIColor clearColor];
        _downloadingView.frame = CGRectMake(30, CGRectGetMaxY(_fileTitleLabel.frame) +85, self_width-30*2, 40);
        _downloadingView.center = CGPointMake(self.wh_tableBody.center.x, _downloadingView.center.y);
        [self.wh_tableBody addSubview:_downloadingView];
        
        if(!_receivedLabel){
            _receivedLabel = [[UILabel alloc] init];
            _receivedLabel.font = sysFontWithSize(13);
            _receivedLabel.textAlignment = NSTextAlignmentCenter;
            _receivedLabel.frame = CGRectMake(0, 0, CGRectGetWidth(_downloadingView.frame), 17);
            [_downloadingView addSubview:_receivedLabel];
        }
        
        if (!_progressView) {
            _progressView = [[UIProgressView alloc] init];
            _progressView.frame = CGRectMake(0, 20, CGRectGetWidth(_downloadingView.frame)-30, 5);
            _progressView.progress = 0;
            _progressView.progressTintColor = [UIColor greenColor];
            _progressView.trackTintColor = [UIColor lightGrayColor];
            [_downloadingView addSubview:_progressView];
            //        progressImage
            //        trackImage
        }
        
        if (!_stopButton) {
            _stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _stopButton.frame = CGRectMake(CGRectGetMaxX(_progressView.frame)+3, 0, 25, 25);
            _stopButton.center = CGPointMake(_stopButton.center.x, _progressView.center.y);
            [_stopButton setBackgroundImage:[UIImage imageNamed:@"stopDownload"] forState:UIControlStateNormal];
            [_downloadingView addSubview:_stopButton];
            [_stopButton addTarget:self action:@selector(stopDownloadFile) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
}

-(void)WH_setViewDataWith:(NSInteger)receivedSize expectedSize:(NSInteger)expectedSize speed:(NSInteger)speed{
    
    MCDownloadReceipt *receipt = [[MCDownloader sharedDownloader] downloadReceiptForURLString:self.shareFieldUrl fileName:_shareFile.fileName];
    long fileSize = [_shareFile.size longLongValue];
    
    if (receipt.state == MCDownloadStateNone) {
        _downloadBtn.hidden = NO;
        _downloadingView.hidden = YES;
        NSString * downStr = nil;
        
        if (fileSize/1000.0/1000 >= 1) {
            downStr = [NSString stringWithFormat:@"%@(%.02fMB)",Localized(@"JX_Download"),fileSize/1000.0/1000];
        }else{
            downStr = [NSString stringWithFormat:@"%@(%.02fKB)",Localized(@"JX_Download"),fileSize/1000.0];
        }
        
        [_downloadBtn setTitle:downStr forState:UIControlStateNormal];
        [_downloadBtn setTitle:downStr forState:UIControlStateHighlighted];
    }else if (receipt.state == MCDownloadStateWillResume){
        _downloadBtn.hidden = YES;
        _downloadingView.hidden = NO;
        
        NSString * progressStr = nil;
        if (fileSize/1024.0/1024 >= 1) {
            progressStr = [NSString stringWithFormat:@"%@...(%.02fMB / %.02fMB)",Localized(@"JX_Downloading"),receipt.progress.completedUnitCount/1024.0/1024,receipt.progress.totalUnitCount/1024.0/1024];
        }else{
            progressStr = [NSString stringWithFormat:@"%@...(%.02fKB / %.02fKB)",Localized(@"JX_Downloading"),receipt.progress.completedUnitCount/1024.0,receipt.progress.totalUnitCount/1024.0];
        }
//        float progress = receivedSize / [_shareFile.size doubleValue];
//        [_progressView setProgress:progress animated:YES];
        [_progressView setProgress:receipt.progress.fractionCompleted animated:YES];

        _receivedLabel.text = progressStr;

        
    }else if (receipt.state == MCDownloadStateDownloading){
        _downloadBtn.hidden = YES;
        _downloadingView.hidden = NO;
        
        NSString * progressStr = nil;
        if (fileSize/1024.0/1024 >= 1) {
            progressStr = [NSString stringWithFormat:@"%@...(%.02fMB / %.02fMB)",Localized(@"JX_Downloading"),receipt.progress.completedUnitCount/1024.0/1024,receipt.progress.totalUnitCount/1024.0/1024];
        }else{
            progressStr = [NSString stringWithFormat:@"%@...(%.02fKB / %.02fKB)",Localized(@"JX_Downloading"),receipt.progress.completedUnitCount/1024.0,receipt.progress.totalUnitCount/1024.0];
        }
//        float progress = receivedSize / [_shareFile.size doubleValue];
        [_progressView setProgress:receipt.progress.fractionCompleted animated:YES];
        
        _receivedLabel.text = progressStr;
        
    }else if (receipt.state == MCDownloadStateCompleted) {
        _downloadBtn.hidden = NO;
        _downloadingView.hidden = YES;
        [_downloadBtn setTitle:Localized(@"JX_Open") forState:UIControlStateNormal];
        [_downloadBtn setTitle:Localized(@"JX_Open") forState:UIControlStateHighlighted];
        [_downloadBtn removeTarget:self action:@selector(downloadBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_downloadBtn addTarget:self action:@selector(openFileAction) forControlEvents:UIControlEventTouchUpInside];
        
    }else if (receipt.state == MCDownloadStateFailed) {
        _downloadBtn.hidden = NO;
        _downloadingView.hidden = YES;
        [_downloadBtn setTitle:Localized(@"JX_ReDownload") forState:UIControlStateNormal];
        [_downloadBtn setTitle:Localized(@"JX_ReDownload") forState:UIControlStateHighlighted];
        [_downloadBtn removeTarget:self action:@selector(downloadBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_downloadBtn addTarget:self action:@selector(retryDownload) forControlEvents:UIControlEventTouchUpInside];
    }else if (receipt.state == MCDownloadStateSuspened) {
        
    }
    
}


-(void)downloadBtnAction{
    
    [[MCDownloader sharedDownloader] downloadDataWithURL:[NSURL URLWithString:self.shareFieldUrl] progress:^(NSInteger receivedSize, NSInteger expectedSize, NSInteger speed, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self WH_setViewDataWith:receivedSize expectedSize:expectedSize speed:speed];
            
        });
    } completed:^(MCDownloadReceipt *receipt, NSError * _Nullable error, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self WH_setViewDataWith:0 expectedSize:0 speed:0];
            if (!error && finished) {
                [self openFileAction];
            }else{
                [g_App showAlert:error.description];
            }
 
        });
        
    }];
}

-(void)openFileAction{
    if (_dalay){
        return;
    }
    _dalay = YES;
    [self performSelector:@selector(delayClick) withObject:nil afterDelay:0.4];
    MCDownloadReceipt *receipt = [[MCDownloader sharedDownloader] downloadReceiptForURLString:self.shareFieldUrl fileName:_shareFile.fileName];
    
    WH_webpage_WHVC * webVC = [WH_webpage_WHVC alloc];
    webVC.url = receipt.filePath;
//    webVC.url = self.shareFieldUrl;
    webVC.titleString = _shareFile.fileName;
    webVC.isOpenFile = YES;
    webVC.isSend = YES;
    webVC.wh_isGotoBack = YES;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:webVC animated:YES];
}
-(void)stopDownloadFile{

    MCDownloadReceipt *receipt = [[MCDownloader sharedDownloader] downloadReceiptForURLString:self.shareFieldUrl];
    [[MCDownloader sharedDownloader] cancel:receipt completed:^{
        [self WH_setViewDataWith:0 expectedSize:0 speed:0];
    }];
}
-(void)delayClick{
    if (_dalay) {
        _dalay = NO;
    }
}

-(void)retryDownload{
    MCDownloadReceipt *receipt = [[MCDownloader sharedDownloader] downloadReceiptForURLString:self.shareFieldUrl];
    [[MCDownloader sharedDownloader] remove:receipt completed:^{
        [self downloadBtnAction];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (void)protocolIsSelect {
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:Localized(@"JXFile_fileBeforeOnline")];
//    [attributedString addAttribute:NSLinkAttributeName
//                             value:_shareFile.fileName
//                             range:[[attributedString string] rangeOfString:Localized(@"JXFile_online")]];
//
//    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:[[attributedString string] rangeOfString:Localized(@"JXFile_fileBefore")]];
//    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, attributedString.length)];
//    _textView.attributedText = attributedString;
//    _textView.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor],
//                                     NSUnderlineColorAttributeName: [UIColor lightGrayColor],
//                                     NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
//
//    _textView.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
//    _textView.scrollEnabled = NO;
//}

#pragma mark 预览事件
- (void)previewMethod {
    WH_webpage_WHVC * webVC = [WH_webpage_WHVC alloc];
    webVC.url = _shareFile.url;
    webVC.isSend = YES;
    webVC.wh_isGotoBack = YES;
    webVC.titleString = _shareFile.fileName;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    NSString *fieldUrl = _shareFile.fileName;
    NSString *chartStr = [fieldUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];//编码
    
    if ([[URL absoluteString] isEqualToString:chartStr]) {
        WH_webpage_WHVC * webVC = [WH_webpage_WHVC alloc];
        webVC.url = self.shareFieldUrl;
        webVC.isSend = YES;
        webVC.wh_isGotoBack = YES;
        webVC.titleString = _shareFile.fileName;
        webVC = [webVC init];
        [g_navigation.navigationView addSubview:webVC.view];
//        [g_navigation pushViewController:webVC animated:YES];
        return NO;
    }
    return YES;
}



@end
