//
//  TagView.h
//  CustomTag
//
//  Created by za4tech on 2017/12/15.
//  Copyright © 2017年 Junior. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TagViewDelegate <NSObject>

@optional

-(void)handleSelectTag:(NSString *)keyWord;

- (void)handleSelectTag:(NSString *)keyWord btn:(UIButton *)btn;

@end

@interface TagView : UIView

@property (nonatomic ,weak)id <TagViewDelegate>delegate;

//@property (nonatomic ,strong)NSArray * arr;

//@property (nonatomic ,strong)NSArray * items;

- (void)loadBtns:(NSArray *)items height:(CGFloat)height corner:(CGFloat)cor color:(UIColor *)text border:(UIColor *)color;

@end
