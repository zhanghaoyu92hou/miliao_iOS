//
//  photosViewController.h
//  sjvodios
//
//  Created by  on 19-5-6-2.
//  Copyright (c) 2019年 __APP__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@protocol JXServerResult;
@class WH_JXImageView;

@interface photosViewController : UIViewController<UIScrollViewDelegate>{
    int _wh_page;
    UIScrollView* sv;
    int      _photoCount;
    WH_JXImageView* _iv;
    NSMutableArray* _array;
}
@property(nonatomic,retain) NSMutableArray* wh_photos;
@property(nonatomic) int wh_page;
+(photosViewController*)showPhotos:(NSArray*)a;



@end
