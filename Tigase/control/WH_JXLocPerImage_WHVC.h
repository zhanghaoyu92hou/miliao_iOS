//
//  WH_JXLocPerImage_WHVC.h
//  Tigase_imChatT
//
//  Created by Apple on 16/10/23.
//  Copyright © 2016年 Reese. All rights reserved.
//

//#import <BaiduMapAPI_Map/BaiduMapAPI_Map.h>
//#import <BaiduMapAPI_Map/BMKMapComponent.h>//只引入所需的单个头文件
//#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件
@interface WH_JXLocPerImage_WHVC : BMKAnnotationView

@property (nonatomic,strong) WH_JXImageView * wh_headImage;
@property (nonatomic,strong) UIImageView * wh_pointImage;
@property (nonatomic,strong) UIView * wh_headView;
-(void)wh_setData:(NSDictionary*)data andType:(int)dataType;
-(void)wh_selectAnimation;
-(void)wh_cancelSelectAnimation;
@end
