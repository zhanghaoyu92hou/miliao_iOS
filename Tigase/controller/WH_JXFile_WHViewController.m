//
//  WH_JXFile_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 17/7/4.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXFile_WHViewController.h"
#import "WH_JXShareFile_WHTableViewCell.h"
#import "WH_JXShareFileObject.h"
#import "WH_JX_DownListView.h"
#import "WH_JXFileDetail_WHViewController.h"
#import "MCDownloader.h"
#import "QBImagePickerController.h"
//#import <AssetsLibrary/ALAssetsLibrary.h>

@interface WH_JXFile_WHViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,QBImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSIndexPath * currentIndexpath;

@property (nonatomic, strong) UIButton * addFileButton;


@end

@implementation WH_JXFile_WHViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        self.wh_isGotoBack = YES;
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        
        [self.tableView setBackgroundColor:g_factory.globalBgColor];
        
        self.title = Localized(@"WaHu_JXRoomMember_WaHuVC_ShareFile");
        _dataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    [self WH_createHeadAndFoot];
    
    [self.tableView setBackgroundColor:g_factory.globalBgColor];
    
    [self customView];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
//    _table.wh_tableFooterView = [[UIView alloc] init];
    [_table registerClass:[WH_JXShareFile_WHTableViewCell class] forCellReuseIdentifier:NSStringFromClass([WH_JXShareFile_WHTableViewCell class])];
    [self WH_getServerData];
    
}

-(void)customView{
    if (!_addFileButton){
        _addFileButton = [UIFactory WH_create_WHButtonWithImage:@"WH_addressbook_add"
                                                highlight:nil
                                                   target:self
                                                 selector:@selector(addNewShareFile)];
        
        _addFileButton.frame = CGRectMake(JX_SCREEN_WIDTH - NAV_INSETS - 28, JX_SCREEN_TOP - 36, 28, 28);
        [self.wh_tableHeader addSubview:_addFileButton];
    }
}

-(void)WH_getServerData{
    [g_server WH_roomShareListRoomIdWithRoomId:_room.roomId userId:nil pageSize:12 pageIndex:_page toView:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WH_JXShareFile_WHTableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WH_JXShareFile_WHTableViewCell class]) forIndexPath:indexPath];
    
    WH_JXShareFileObject * fileObject = _dataArray[indexPath.row];
    [cell setShareWH_FileList_WHCellWith:fileObject indexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
    return 64;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    WH_JXShareFileObject * fileObject = _dataArray[indexPath.row];
    memberData * myMem = nil;
    for (memberData * member in _room.members) {
        if ([[NSString stringWithFormat:@"%ld",member.userId] isEqualToString:g_myself.userId]) {
            myMem = member;
            break;
        }
    }
    
    if ([myMem.role integerValue] <= 2 || [fileObject.userId isEqualToString:g_myself.userId]) {
        return YES;
    }else{
        return NO;
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    WH_JXShareFileObject *obj = _dataArray[indexPath.row];
    if ([obj.userId isEqualToString:MY_USER_ID]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WH_JXShareFileObject * fileObject = _dataArray[indexPath.row];
        _currentIndexpath = indexPath;
        [g_server WH_roomShareDeleteRoomIdWithRoomId:fileObject.roomId shareId:fileObject.shareId toView:self];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    WH_JXShareFileObject * shareFile = _dataArray[indexPath.row];
    WH_JXFileDetail_WHViewController * detailVC = [[WH_JXFileDetail_WHViewController alloc] init];
    detailVC.shareFile = shareFile;
//    [g_window addSubview:detailVC.view];
    [g_navigation pushViewController:detailVC animated:YES];
}

#pragma mark - Network
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    
    [self WH_stopLoading];
    
    if([aDownload.action isEqualToString:wh_act_shareList]){
        if (_page == 0) {
            [_dataArray removeAllObjects];
        }
        NSMutableArray * tempAray = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in array1) {
            WH_JXShareFileObject * shareFile = [WH_JXShareFileObject shareFileWithDict:dict];
            [tempAray addObject:shareFile];
        }
        if (tempAray.count > 0) {
            [_dataArray addObjectsFromArray:tempAray];
            [_table reloadData];
        }
    }else if([aDownload.action isEqualToString:wh_act_shareAdd]){
        WH_JXShareFileObject * shareFile = [WH_JXShareFileObject shareFileWithDict:dict];
        [_dataArray addObject:shareFile];
        [_table reloadData];
    }else if([aDownload.action isEqualToString:wh_act_shareGet]){
        
    }else if([aDownload.action isEqualToString:wh_act_shareDelete]){
        [g_server showMsg:Localized(@"JXFile_deleteRoomFileSuccess")];
        [_dataArray removeObjectAtIndex:_currentIndexpath.row];
        [_table deleteRowsAtIndexPaths:@[_currentIndexpath] withRowAnimation:UITableViewRowAnimationRight];
    }else if ([aDownload.action isEqualToString:wh_act_UploadFile]){
        NSArray * listArray = @[@"audios",@"images",@"others",@"videos"];
        NSString * fileUrl = nil;
        NSString * fileName = nil;
        NSInteger fileType = 0;
        int tbreak = 0;
        for (int i = 0; i<listArray.count; i++) {
            NSArray * dataArray = [dict objectForKey:listArray[i]];
            if ([dataArray count]) {
                for (NSDictionary * dataDict in dataArray) {
                    fileUrl = dataDict[@"oUrl"];
                    fileName = dataDict[@"oFileName"];
                    tbreak = 1;
                    switch (i) {
                        case 0:
                            fileType = 2;//音频
                            break;
                        case 1:
                            fileType = 1;//图片
                            break;
                        case 2:
                            fileType = 9;//其他
                            break;
                        case 3:
                            fileType = 3;//视频
                            break;
                        default:{
                            NSString * fileExt = [fileName pathExtension];
                            if ([fileExt isEqualToString:@"jpg"] || [fileExt isEqualToString:@"jpeg"] || [fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"gif"] || [fileExt isEqualToString:@"bmp"])
                                fileType = 1;
                            else if ([fileExt isEqualToString:@"amr"] || [fileExt isEqualToString:@"mp3"] || [fileExt isEqualToString:@"wav"])
                                fileType = 2;
                            else if ([fileExt isEqualToString:@"mp4"] || [fileExt isEqualToString:@"mov"])
                                fileType = 3;
                            else if ([fileExt isEqualToString:@"ppt"] || [fileExt isEqualToString:@"pptx"])
                                fileType = 4;
                            else if ([fileExt isEqualToString:@"xls"] || [fileExt isEqualToString:@"xlsx"])
                                fileType = 5;
                            else if ([fileExt isEqualToString:@"doc"] || [fileExt isEqualToString:@"docx"])
                                fileType = 6;
                            else if ([fileExt isEqualToString:@"zip"] || [fileExt isEqualToString:@"rar"])
                                fileType = 7;
                            else if ([fileExt isEqualToString:@"txt"])
                                fileType = 8;
                            else if ([fileExt isEqualToString:@"pdf"])
                                fileType = 10;
                            else
                                fileType = 9;
                            
                            break;
                        }
                    }
                }
            }
            if (tbreak == 1){
                break;
            }
        }
        
        [g_server WH_roomShareAddRoomId:_room.roomId url:fileUrl fileName:fileName size:[NSNumber numberWithLong:aDownload.uploadDataSize] type:fileType toView:self];
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    if ([aDownload.action isEqualToString:wh_act_UploadFile]) {
        [_wait start:Localized(@"JXFile_uploading")];
    }else{
        [_wait start];
    }
}

#pragma mark ----------图片选择完成-------------
//UIImagePickerController代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([picker isMemberOfClass:[QBImagePickerController class]]) {
        if (info[@"UIImagePickerControllerMediaType"] == ALAssetTypeVideo){
//            NSURL * videoUrl = info[@"UIImagePickerControllerReferenceURL"];
        }
    }else{
        UIImage  * chosedImage=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //    UIImage  * editedImage=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    //    int imageWidth = chosedImage.size.width;
    //    int imageHeight = chosedImage.size.height;
        [self dismissViewControllerAnimated:NO completion:^{
            NSString* file = [FileInfo getUUIDFileName:@"jpg"];
            [g_server WH_saveImageToFileWithImage:chosedImage file:file isOriginal:NO];
            [g_server uploadFile:file validTime:@"-1" messageId:nil toView:self];
        }];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:^{

    }];
}


#pragma mark - actions
-(void)addNewShareFile{
    memberData *data = [self.room getMember:g_myself.userId];
    BOOL flag = [data.role intValue] == 1 || [data.role intValue] == 2;
    if (!flag && !self.room.allowUploadFile) {
        [g_App showAlert:Localized(@"JX_NotUploadSharedFiles")];
        return;
    }
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    CGRect moreFrame = [self.wh_tableHeader convertRect:_addFileButton.frame toView:window];
    
    WH_JX_DownListView * downListView = [[WH_JX_DownListView alloc] initWithFrame:self.view.bounds];
//    downListView.listContents = @[@"上传文件",@"上传图片",@"上传视频"];
//    downListView.listImages = @[@"me_press",@"me_press",@"me_press"];
     downListView.wh_listContents = @[Localized(@"JXFile_uploadPhoto")];
//    Localized(@"JXFile_uploadVideo")
    __weak typeof(self) weakSelf = self;
    [downListView WH_downlistPopOption:^(NSInteger index, NSString *content) {
//        if (index == 0) {
//            [weakSelf showSelLocalFileView];
//        }else if (index == 1) {
            [weakSelf showSelImagePicker];
//        }else if (index == 1) {
//            [weakSelf showSelVideo];
//        }
     
    } whichFrame:moreFrame animate:YES];
    [downListView show];
}

-(void)showSelLocalFileView{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *strPath = [documentsDirectory stringByAppendingPathComponent:MCDownloadCacheFolderName];
    NSDirectoryEnumerator<NSString *> * myDirectoryEnumerator;
    myDirectoryEnumerator=  [fileManager enumeratorAtPath:strPath];
    
    while (strPath = [myDirectoryEnumerator nextObject]) {
        for (NSString * namePath in strPath.pathComponents) {
            NSLog(@"-----AAA-----%@", namePath  );
        }
    }
}

-(void)showSelImagePicker{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    ipc.modalPresentationStyle = UIModalPresentationFullScreen;
    //    [g_window addSubview:ipc.view];
    if (IS_PAD) {
        UIPopoverController *pop =  [[UIPopoverController alloc] initWithContentViewController:ipc];
        [pop presentPopoverFromRect:CGRectMake((self.view.frame.size.width - 320) / 2, 0, 300, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }else {
        [self presentViewController:ipc animated:YES completion:nil];
    }
}

-(void)showSelVideo{
    QBImagePickerController * videoPick = [[QBImagePickerController alloc] init];
    videoPick.filterType = QBImagePickerFilterTypeAllVideos;
    videoPick.delegate = self;
    videoPick.showsCancelButton = YES;
    videoPick.fullScreenLayoutEnabled = YES;
    
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:videoPick];
    [self presentViewController:navigationController animated:YES completion:NULL];
    
    
//    ALAssetsLibrary *library1 = [[ALAssetsLibrary alloc] init];
//    [library1 enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//        if (group) {
//            [group setAssetsFilter:[ALAssetsFilter allVideos]];
//            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
//                
//                if (result) {
//                    AlbumVideoInfo *videoInfo = [[AlbumVideoInfo alloc] init];
//                    videoInfo.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
//                    //                    videoInfo.videoURL = [result valueForProperty:ALAssetPropertyAssetURL];
//                    videoInfo.videoURL = result.defaultRepresentation.url;
//                    videoInfo.duration = [result valueForProperty:ALAssetPropertyDuration];
//                    videoInfo.name = [self getFormatedDateStringOfDate:[result valueForProperty:ALAssetPropertyDate]];
//                    videoInfo.size = result.defaultRepresentation.size; //Bytes
//                    videoInfo.format = [result.defaultRepresentation.filename pathExtension];
//                    [_albumVideoInfos addObject:videoInfo];
//                }
//            }];
//        } else {
//            //没有更多的group时，即可认为已经加载完成。
//            NSLog(@"after load, the total alumvideo count is %ld",_albumVideoInfos.count);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self showAlbumVideos];
//            });
//        }
//        
//    } failureBlock:^(NSError *error) {
//        NSLog(@"Failed.");
//    }];
}


- (void)sp_upload {
    NSLog(@"Continue");
}
@end
