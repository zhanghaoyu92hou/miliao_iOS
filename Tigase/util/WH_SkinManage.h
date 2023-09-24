//
//  SkinManage.h
//  Tigase_imChatT
//
//  Created by 1 on 17/10/23.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
//    SkinType_Default  =   0,  //淡钴绿0
//    SkinType_LeafGreen,       //粉叶绿1
//    SkinType_PowderAzure,     //粉天蓝2
//    SkinType_BusinessBlue,    //商务蓝3
//    SkinType_Blue,            //大海蓝4
//    SkinType_Pink,            //感性粉5
//    SkinType_Red,             //中国红6
//    SkinType_AmberYellow,     //琥珀黄7
//    SkinType_Orange,          //橘黄色8
//    SkinType_LightCoffee,     //浅咖色9
//    SkinType_BlueGray,        //蓝灰色10
//    SkinType_BurntUmber,      //深茶色11
//    SkinType_WHPurple,     //觅信紫12
//    SkinType_MESGreen,        //马尔斯绿13
//    SkinType_SHOringe,      //珊瑚橘14
//    SkinType_XRBGreen,     //杏仁饼绿15
//    SkinType_RoseRed,     //马卡龙玫瑰粉红16
    
//    SkinType_MESGreen  =   0,  //马尔斯绿13 默认颜色
//    SkinType_XRBGreen,     //杏仁饼绿15
//    SkinType_RoseRed,     //马卡龙玫瑰粉红16
//    SkinType_Pink,            //感性粉5
//    SkinType_WHPurple,     //觅信紫12
//    SkinType_SHOringe,      //珊瑚橘14
//    SkinType_AmberYellow,     //琥珀黄7
//    SkinType_PowderAzure,     //粉天蓝2
//    SkinType_Blue,            //大海蓝4
//    SkinType_BlueGray,        //蓝灰色10
    
    SkinType_BusinessBlue = 0, //商务蓝0
    SkinType_LavenderPurple,  //薰衣草紫 1
    SkinType_OrangePurple, //橘黄紫 2
    SkinType_MESGreen,  //马尔斯绿 3
    SkinType_TintCoffee, //浅咖色 4
    
} SkinType;

typedef NS_ENUM(NSInteger, JXSkinGradientDirection) {
    JXSkinGradientDirectionTopToBottom, //渐变从上到下(颜色有深到浅themeStartColor渐变到themeEndColor)
    JXSkinGradientDirectionBottomToTop,//渐变从下到上
    JXSkinGradientDirectionLeftToRight,//渐变从左到右
    JXSkinGradientDirectionRightToLeft,//渐变从右到左
};

typedef NSString * SkinDictKey NS_STRING_ENUM;
extern SkinDictKey const SkinDictKeyName;
extern SkinDictKey const SkinDictKeyColor;
extern SkinDictKey const SkinDictKeyIndex;

@interface WH_SkinManage : NSObject

/**
 主题皮肤颜色
 */
@property (readonly, nonatomic, strong) UIColor * themeColor;

/**
 主题渐变皮肤开始颜色
 */
@property (readonly, nonatomic, strong) UIColor * themeStartColor;

/**
 主题渐变皮肤结束颜色
 */
@property (readonly, nonatomic, strong) UIColor * themeEndColor;

/**
 主题皮肤名称
 */
@property (readonly, nonatomic, copy) NSString * themeName;

/**
 主题皮肤索引
 */
@property (readonly, nonatomic, assign) NSUInteger themeIndex;

/**
 主题图片后缀
 */
@property (readonly, nonatomic) NSString *imageSuffix;

/**
 主题列表
 */
@property (readonly, nonatomic, strong) NSArray<NSDictionary<SkinDictKey,id> *> * skinList;

/**
 主题皮肤名列表
 */
@property (readonly, nonatomic, strong) NSArray<NSString *> * skinNameList;

/**
 skin管理器单例对象

 @return skinManage
 */
+(instancetype)sharedInstance;

/**
 切换主题皮肤

 @param index 皮肤主题的索引type
 */
-(void)switchSkinIndex:(NSUInteger)index;

/**
 主题皮肤image对象

 @param imageName 图片文件名
 @return 主题皮肤图片
 */
-(UIImage *)themeImage:(NSString *)imageName;

/**
 图片名转换为当前主题皮肤的图片名
 eg. ic_find@2x ->ic_find_2@2x
 @param imageName 图片文件名
 @return 主题皮肤图片名
 */
-(NSString *)themeImageName:(NSString *)imageName;

/**
 生成主题色的图片

 @param imageName 图片文件名
 @return 渲染过的图片
 */
-(UIImage *)themeTintImage:(NSString *)imageName;

/**
 设置view背景渐变色
 
 @param view 待设置渐变的view
 @param gradientDirection 渐变方向
 */
- (void)setViewGradientWithView:(UIView *)view gradientDirection:(JXSkinGradientDirection)gradientDirection;

// 重置
-(void)resetInstence;


- (void)sp_upload;
@end
