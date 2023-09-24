//
//  WH_myMedia_WHVC.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_myMedia_WHVC.h"
#import "WH_JXChat_WHViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "WH_JXImageView.h"
//#import "WH_JX_WHCell.h"
#import "WH_JXRoomPool.h"
#import "JXTableView.h"
#import "WH_JXNewFriend_WHViewController.h"
#import "WH_menuImageView.h"
#import "WH_JXMedia_WHCell.h"
#import "WH_JXMediaObject.h"
#import "WH_recordVideo_WHViewController.h"
#import "WH_JXCamera_WHVC.h"
#import <photos/PHAssetResource.h>
#import <photos/PHFetchOptions.h>
#import <photos/PHFetchResult.h>
#import <Photos/PHAsset.h>
#import <Photos/PHImageManager.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>


#define kCameraVideoPath [FileInfo getUUIDFileName:@"mp4"]

@interface WH_myMedia_WHVC ()<WH_JXCamera_WHVCDelegate>

@end

@implementation WH_myMedia_WHVC
@synthesize delegate;
@synthesize didSelect;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = Localized(@"WaHu_PSMy_WaHuViewController_MyAtt");
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack   = YES;
        //self.view.frame = g_window.bounds;
        [self WH_createHeadAndFoot];
        self.wh_isShowFooterPull = NO;
//        _table.backgroundColor = HEXCOLOR(0xdbdbdb);

        UIButton* btn = [UIFactory WH_create_WHButtonWithImage:@"im_003_more_button_normal"
                                               highlight:nil
                                                  target:self
                                                selector:@selector(onAddVideo)];
        btn.custom_acceptEventInterval = 1.f;
        btn.frame = CGRectMake(JX_SCREEN_WIDTH - NAV_INSETS - 24, JX_SCREEN_TOP - 34, 24, 24);
        [self.wh_tableHeader addSubview:btn];
        _array=[[NSMutableArray alloc]init];
        [self getVersionVideo];
        if ([[WH_JXMediaObject sharedInstance] fetch].count > 0) {
            [_array addObjectsFromArray:[[WH_JXMediaObject sharedInstance] fetch]];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self WH_scrollToPageUp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WH_JXMedia_WHCell *cell=nil;
    NSString* cellName = [NSString stringWithFormat:@"msg_%ld",indexPath.row];
//    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell==nil){
        WH_JXMediaObject *p=_array[indexPath.row];
        cell = [WH_JXMedia_WHCell alloc];
        [_table WH_addToPool:cell];
        cell.media = p;
        cell.delegate = self;
        cell.tag = indexPath.row;
        cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXMediaObject *p=_array[indexPath.row];
    if(![[NSFileManager defaultManager] fileExistsAtPath:p.fileName]){
//        [g_App showAlert:Localized(@"JXAlert_NotHaveFile")];
//        return;
    }
    if (delegate && [delegate respondsToSelector:didSelect]) {
//		[delegate performSelector:didSelect withObject:p];
        [delegate performSelectorOnMainThread:didSelect withObject:p waitUntilDone:NO];
        [self actionQuit];
	}    
}

- (void)dealloc {
//    NSLog(@"WH_myMedia_WHVC.dealloc");
//    [_array release];
//    [super dealloc];
}

-(void)WH_getServerData{
//    if ([[WH_JXMediaObject sharedInstance] fetch].count > 0) {
//        [_array addObjectsFromArray:[[WH_JXMediaObject sharedInstance] fetch]];
//    }
}

-(void)WH_scrollToPageUp{
    [self WH_stopLoading];
    _refreshCount++;
//    [_array release];

    [self WH_getServerData];
    [_table reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

-(void)onAddVideo{
    
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        [g_server showMsg:Localized(@"JX_CanNotopenCenmar")];
        return;
    }
    
//    WH_recordVideo_WHViewController * videoRecordVC = [WH_recordVideo_WHViewController alloc];
//    videoRecordVC.maxTime = 30;
//    videoRecordVC.isReciprocal = NO;
//    videoRecordVC.delegate = self;
//    videoRecordVC.didRecord = @selector(newVideo:);
//    videoRecordVC = [videoRecordVC init];
//    [g_window addSubview:videoRecordVC.view];
    
    WH_JXCamera_WHVC *vc = [WH_JXCamera_WHVC alloc];
    vc.cameraDelegate = self;
    vc.maxTime = 30;
    vc.isVideo = YES;
    vc = [vc init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

// 視屏錄製回調
- (void)cameraVC:(WH_JXCamera_WHVC *)vc didFinishWithVideoPath:(NSString *)filePath timeLen:(NSInteger)timeLen {
    if( ![[NSFileManager defaultManager] fileExistsAtPath:filePath] )
        return;
    NSString* file = filePath;
    
    WH_JXMediaObject* p = [[WH_JXMediaObject alloc]init];
    p.userId = g_myself.userId;
    p.fileName = file;
    p.isVideo = [NSNumber numberWithBool:YES];
    p.timeLen = [NSNumber numberWithInteger:timeLen];
    [_array insertObject:p atIndex:0];
    [p insert];
    
    [_table reloadData];
}

-(void)newVideo:(WH_recordVideo_WHViewController *)sender;
{
    if( ![[NSFileManager defaultManager] fileExistsAtPath:sender.outputFileName] )
        return;
    NSString* file = sender.outputFileName;
    
    WH_JXMediaObject* p = [[WH_JXMediaObject alloc]init];
    p.userId = g_myself.userId;
    p.fileName = file;
    p.isVideo = [NSNumber numberWithBool:YES];
    p.timeLen = [NSNumber numberWithInt:sender.timeLen];
    [p insert];
//    [p release];

    [self WH_scrollToPageUp];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXMediaObject *p=_array[indexPath.row];
    [p delete];
    p = nil;
    
    [_array removeObjectAtIndex:indexPath.row];
    _refreshCount++;
    [_table reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark - 获取本地视频资源
- (void)getVersionVideo {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    // 这时 assetsFetchResults 中包含的，应该就是各个资源（PHAsset）
    for (NSInteger i = 0; i < assetsFetchResults.count; i++) {
        // 获取一个资源（PHAsset）
        PHAsset *phAsset = assetsFetchResults[i];
        if (phAsset.mediaType == PHAssetMediaTypeVideo) {
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            
            PHImageManager *manager = [PHImageManager defaultManager];
            
            [manager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AVURLAsset *urlAsset = (AVURLAsset *)asset;
                    //获取视频本地URL
                    NSURL *url = urlAsset.URL;
                    //本地URL存在并且没有保存在数据库
                    if (url && ![[WH_JXMediaObject sharedInstance] haveTheMediaWithPhotoPath:url.absoluteString]) {
                        // 获取视频data
                        NSData *data = [NSData dataWithContentsOfURL:url];
                        //获取视频拍摄时间
                        NSDate *date = [self getAudioCreatDate:url];
                        //新建一个路径并写入视频data
                        NSString *dataPath = kCameraVideoPath;
                        [data writeToFile:dataPath atomically:YES];
                        // 获取视频时长
                        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:nil];
                        NSInteger second = 0;
                        second = (NSInteger)urlAsset.duration.value / urlAsset.duration.timescale;
                        // 主线程更新界面
                        WH_JXMediaObject* p = [[WH_JXMediaObject alloc] init];
                        p.userId = MY_USER_ID;
                        p.fileName = dataPath;
                        p.isVideo = [NSNumber numberWithBool:YES];
                        p.timeLen = [NSNumber numberWithInteger:second];
                        p.createTime = date;
                        p.photoPath = url.absoluteString;
                        [p insert];
                        [_array insertObject:p atIndex:0];
                        [_table reloadData];
                    }
                });
            }];
        }
    }
}


- (NSDate *)getAudioCreatDate:(NSURL*)URL {
    NSDate *creatDate;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fm attributesOfItemAtPath:URL.path error:nil];
    if (fileAttributes) {
        if ((creatDate = [fileAttributes objectForKey:NSFileCreationDate])) {
            NSLog(@"date = %@",creatDate);
            return creatDate;
        }
    }
    return nil;
}




- (void)sp_getMediaData {
    NSLog(@"Get Info Success");
}
@end
