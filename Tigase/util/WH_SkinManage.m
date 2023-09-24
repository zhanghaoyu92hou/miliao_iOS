//
//  SkinManage.m
//  Tigase_imChatT
//
//  Created by 1 on 17/10/23.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_SkinManage.h"
#import "UIImage+WH_Tint.h"

//#define skinName    @"skinName"
//#define skinColor   @"skinColor"
//#define skinIndex   @"skinIndex"

SkinDictKey const SkinDictKeyName    = @"skinName";
SkinDictKey const SkinDictKeyColor   = @"skinColor";
SkinDictKey const SkinDictKeyStartColor   = @"skinStartColor";
SkinDictKey const SkinDictKeyEndColor   = @"skinEndColor";
SkinDictKey const SkinDictKeyIndex   = @"skinIndex";
SkinDictKey const SkinDictKeyImageSuffix   = @"imageSuffix";

static WH_SkinManage * _shareInstance = nil;

@interface WH_SkinManage ()

@property (nonatomic, strong) UIImage *navImage;

@end

@implementation WH_SkinManage

+(instancetype)sharedInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[WH_SkinManage alloc] init];
    });
    return _shareInstance;
}

-(instancetype)init{
    if (self = [super init]) {
        [self makeThemeList];
        
        NSNumber * current = [g_default objectForKey:SkinDictKeyIndex];
        if (current == nil) {
            //设置首次安装默认主题为第一个
            [g_default setObject:[NSNumber numberWithUnsignedInteger:0] forKey:SkinDictKeyIndex];
            [g_default synchronize];
            current = [NSNumber numberWithUnsignedInteger:0];
            
        }
        
        NSDictionary * skinDict = [self searchSkinByIndex:[current unsignedIntegerValue]];
        if(skinDict){
            _themeName = skinDict[SkinDictKeyName];
            _themeColor = skinDict[SkinDictKeyColor];
            _themeStartColor = skinDict[SkinDictKeyStartColor];
            _themeEndColor = skinDict[SkinDictKeyEndColor];
            _themeIndex = [skinDict[SkinDictKeyIndex] unsignedIntegerValue];
            _imageSuffix = skinDict[SkinDictKeyImageSuffix];
        }
        
    }
    return self;
}
/*
 薰衣草紫
 商务蓝 _1
 橘黄色 _2
 马尔斯绿 _3
 浅咖色 _4
 */
-(void)makeThemeList{
    NSMutableArray * skinList = [NSMutableArray array];
    [skinList addObject:[self makeASkin:@"默认白" themeColor:HEXCOLOR(0x0093FF) startColor:HEXCOLOR(0x0093FF) endColor:HEXCOLOR(0x0093FF) index:SkinType_BusinessBlue imageSuffix:@""]];
    [skinList addObject:[self makeASkin:@"薰衣草紫" themeColor:HEXCOLOR(0xB57FDE) startColor:HEXCOLOR(0xB57FDE) endColor:HEXCOLOR(0xD7B2F2) index:SkinType_LavenderPurple imageSuffix:@""]];
    [skinList addObject:[self makeASkin:@"橘黄色" themeColor:HEXCOLOR(0xFFAD69) startColor:HEXCOLOR(0xFFAD69) endColor:HEXCOLOR(0xFAE3BC) index:SkinType_OrangePurple imageSuffix:@"_2"]];
    [skinList addObject:[self makeASkin:@"马尔斯绿" themeColor:HEXCOLOR(0x00CEB2) startColor:HEXCOLOR(0x00CEB2) endColor:HEXCOLOR(0x83FFEE) index:SkinType_MESGreen imageSuffix:@"_3"]];
    [skinList addObject:[self makeASkin:@"浅咖色" themeColor:HEXCOLOR(0xD1774E) startColor:HEXCOLOR(0xD1774E) endColor:HEXCOLOR(0xFCC4AA) index:SkinType_TintCoffee imageSuffix:@"_4"]];
    
    
    
    // 粉色替换了，这是之前的粉色:0xff9ffe
    NSMutableArray * skinNameList = [NSMutableArray array];
    for (NSDictionary * skinDict in skinList) {
        [skinNameList addObject:skinDict[SkinDictKeyName]];
    }
    
    _skinNameList = skinNameList;
    _skinList = skinList;
}

-(NSDictionary *)makeASkin:(NSString *)name color:(UIColor *)color index:(SkinType)skinType{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:name forKey:SkinDictKeyName];
    [dict setObject:color forKey:SkinDictKeyColor];
    [dict setObject:[NSNumber numberWithUnsignedInteger:skinType] forKey:SkinDictKeyIndex];
    
    return dict;
}

-(NSDictionary *)makeASkin:(NSString *)name themeColor:(UIColor *)themeColor startColor:(UIColor *)startColor endColor:(UIColor *)endColor index:(SkinType)skinType imageSuffix:(NSString *)imageSuffix{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:name forKey:SkinDictKeyName];
    [dict setObject:themeColor forKey:SkinDictKeyColor];
    [dict setObject:startColor forKey:SkinDictKeyStartColor];
    [dict setObject:endColor forKey:SkinDictKeyEndColor];
    [dict setObject:[NSNumber numberWithUnsignedInteger:skinType] forKey:SkinDictKeyIndex];
    [dict setObject:imageSuffix forKey:SkinDictKeyImageSuffix];
    
    return dict;
}

-(NSDictionary *)searchSkinByIndex:(NSInteger)index{
//    for (int i = 0; i<_skinList.count; i++) {
//        NSDictionary * skinDict = _skinList[i];
//        if ([skinDict[SkinDictKeyIndex] unsignedIntegerValue] == index) {
//
//            return skinDict;
//        }
//    }
    if (index < _skinList.count) {
        return _skinList[index];
    }
    return nil;
}


-(void)switchSkinIndex:(NSUInteger)index{
    NSDictionary * skinDict = [self searchSkinByIndex:index];
    if(skinDict){
        _themeName = skinDict[SkinDictKeyName];
        _themeColor = skinDict[SkinDictKeyColor];
        _themeStartColor = skinDict[SkinDictKeyStartColor];
        _themeEndColor = skinDict[SkinDictKeyEndColor];
        _themeIndex = [skinDict[SkinDictKeyIndex] unsignedIntegerValue];
        _imageSuffix = skinDict[SkinDictKeyImageSuffix];
        self.navImage = nil;
        [g_default setObject:[NSNumber numberWithUnsignedInteger:_themeIndex] forKey:SkinDictKeyIndex];
        [g_default synchronize];
    }
}

-(UIImage *)themeImage:(NSString *)imageName{
    NSString * imageStr = [imageName copy];
    imageStr = [self themeImageName:imageStr];
    UIImage * img = [UIImage imageNamed:imageStr];
    if (img) {
        return img;
    }else{
        return [UIImage imageNamed:imageName];
    }
}

-(NSString *)themeImageName:(NSString *)imageName{
    NSString * imageStr;
    if ([imageName rangeOfString:@"@2x"].location != NSNotFound) {
        imageStr = [imageName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
    }else if ([imageName rangeOfString:@"@3x"].location != NSNotFound){
        imageStr = [imageName stringByReplacingOccurrencesOfString:@"@3x" withString:@""];
    }else{
        imageStr = imageName;
    }
    imageStr = [self getImageString:imageStr];
    return imageStr;
}

// 根据索引获取图片名
- (NSString *)getImageString:(NSString *)imageStr
{
//    if(_themeIndex != 0){
//        if (_themeIndex == 1) {
//            imageStr = [NSString stringWithFormat:@"%@_0",imageStr];
//        }else{
//            imageStr = [NSString stringWithFormat:@"%@_%tu",imageStr,_themeIndex];
//        }
//
//    }else{
//        imageStr = [NSString stringWithFormat:@"%@_1",imageStr];
//    }
    
    return [NSString stringWithFormat:@"%@%@",imageStr,_imageSuffix];
}

-(UIImage *)themeTintImage:(NSString *)imageName{
    
    if ([imageName isEqualToString:@"navBarBackground"] && self.navImage) {
        return self.navImage;
    }else {

        UIImage * tintImage = [[UIImage imageNamed:imageName] imageWithTintColor:self.themeColor];
        if ([imageName isEqualToString:@"navBarBackground"] && !self.navImage) {
            self.navImage = tintImage;
        }
        return tintImage;
    }
}


/**
 设置view背景渐变色

 @param view 待设置渐变的view
 @param gradientDirection 渐变方向
 */
- (void)setViewGradientWithView:(UIView *)view gradientDirection:(JXSkinGradientDirection)gradientDirection{
    //给view添加渐变图层
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame));
    switch (gradientDirection) {
        case JXSkinGradientDirectionTopToBottom:
        {
            gl.startPoint = CGPointMake(0.5, 0);
            gl.endPoint = CGPointMake(0.5, 1);
        }
            break;
        case JXSkinGradientDirectionBottomToTop:
        {
            gl.startPoint = CGPointMake(0.5, 1);
            gl.endPoint = CGPointMake(0.5, 0);
        }
            break;
        case JXSkinGradientDirectionLeftToRight:
        {
            gl.startPoint = CGPointMake(0, 0.5);
            gl.endPoint = CGPointMake(1, 0.5);
        }
            break;
        case JXSkinGradientDirectionRightToLeft:
        {
            gl.startPoint = CGPointMake(1, 0.5);
            gl.endPoint = CGPointMake(0, 0.5);
        }
            break;
            
        default:
            break;
    }
    gl.colors = @[(__bridge id)_themeStartColor.CGColor,(__bridge id)_themeEndColor.CGColor];
    gl.locations = @[@(0.0),@(1.0)];
    [view.layer insertSublayer:gl atIndex:0];
}

-(void)resetInstence{
    _shareInstance = [self init];
}


- (void)sp_upload {
    NSLog(@"Get Info Success");
}
@end
