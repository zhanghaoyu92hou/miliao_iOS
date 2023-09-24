//
//  emojiViewController.h
//
//  Created by daxiong on 13-11-27.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_FaceView_WHController.h"
#import "WH_Favorites_WHVC.h"
@class WH_menuImageView;
@class WH_Gif_GHViewController;

@protocol emojiViewControllerDelegate <NSObject>

//表情按钮 被点击
- (void) selectImageNameString:(NSString*)imageName ShortName:(NSString *)shortName isSelectImage:(BOOL)isSelectImage;
//删除按钮 被点击
- (void) faceViewDeleteAction;

//添加表情按钮 被点击
- (void)emojiFaceView:(emojiViewController *)emojiFaceView didClickAddEmoticonButton:(UIButton *)addEmoticonButton;

// 发送自定义表情
- (void) selectFavoritWithString:(NSString *) str;
// 删除自定义表情
- (void) deleteFavoritWithString:(NSString *) str;

//动态图按钮 被点击
- (void)emojiFaceView:(emojiViewController *)emojiFaceView didClickOnGifViewWithZuIndex:(NSInteger)zuIndx index:(NSInteger)index dataDic:(NSDictionary *)dataDic;

@end

@interface emojiViewController : UIView<UIScrollViewDelegate>
{
    WH_menuImageView* _tb;//底部工具栏
    WH_FaceView_WHController* _faceView;//emjio表情
    WH_Gif_GHViewController* _gifView;//gif图
}

@property (nonatomic, weak) id<emojiViewControllerDelegate> delegate;
@property (nonatomic, strong) WH_FaceView_WHController* faceView;
@property (nonatomic, strong) WH_Favorites_WHVC *favoritesVC;

// 发送按钮
@property (nonatomic , strong) UIButton * sendButton;
// 代理
//@property (nonatomic , weak) id<WWEmojiFaceViewDelegate> delegate;
// 表情数据
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *shortNameArray;
@property (nonatomic, strong) NSMutableArray *shortNameArrayC;
@property (nonatomic, strong) NSMutableArray *shortNameArrayE;

//组动态图表情数据
@property (nonatomic , strong) NSArray * ZuGifEmotDataArray;

// 收藏表情数据
@property (nonatomic , strong) NSArray * MyEmotIconDataArray;

//选中的组图
@property (nonatomic, assign) NSInteger selIndex;




-(void)selectType:(int)n;
@end
