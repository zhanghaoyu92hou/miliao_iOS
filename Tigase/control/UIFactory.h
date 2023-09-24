//
//  UIFactory.h
//  SmartMeeting
//
//  Created by luddong on 12-3-30.
//  Copyright (c) 2012年 Twin-Fish. All rights reserved.
//

#import <UIKit/UIKit.h>

#define g_UIFactory [UIFactory sharedUIFactory]

@interface UIFactory : NSObject


/**--------------------------------
 * Create UITextField
 *
 * frame            :CGRect
 * delegate         :id<UITextFieldDelegate>
 * returnKeyType    :UIReturnKeyType
 * secureTextEntry  :BOOL
 * placeholder      :NSString
 * font             :UIFont
 *
 */
+ (id)WH_create_WHTextFieldWith:(CGRect)frame 
                 delegate:(id<UITextFieldDelegate>)delegate
            returnKeyType:(UIReturnKeyType)returnKeyType
          secureTextEntry:(BOOL)secureTextEntry
              placeholder:(NSString *)placeholder 
                     font:(UIFont *)font;


/**--------------------------------
 * Create UILabel
 *
 * frame :CGRect
 * label :NSString
 *
 */
+ (id)WH_create_WHLabelWith:(CGRect)frame 
                text:(NSString *)text;

/**--------------------------------
 * Create UILabel
 *
 * frame :CGRect
 * label :NSString
 *
 */
+ (id)WH_create_WHClearBackgroundLabelWith:(CGRect)frame 
                                text:(NSString *)text;

/**--------------------------------
 * Create UILabel
 *
 * frame            :CGRect
 * label            :NSString
 * backgroundColor  :UIColor
 *
 */
+ (id)WH_create_WHLabelWith:(CGRect)frame 
                text:(NSString *)text 
      backgroundColor:(UIColor *)backgroundColor;

/**--------------------------------
 * Create UILabel
 *
 * frame            :CGRect
 * label            :NSString
 * font             :UIFont
 * textColor        :UIColor
 * backgroundColor  :UIColor
 *
 */
+ (id)WH_create_WHLabelWith:(CGRect)frame 
                text:(NSString *)text 
                 font:(UIFont *)font 
            textColor:(UIColor *)textColor 
      backgroundColor:(UIColor *)backgroundColor;

/**--------------------------------
 * Convert Resizable (Stretchable) Image;
 *
 *  title           :NSString *
 *  message         :NSString *
 */
+(UIView*)createLine:(UIColor*)color parent:(UIView*)parent;
+(UIView*)createLine:(UIView*)parent;

+ (UIImage*)resizableImageWithSize:(CGSize)size
                             image:(UIImage*)image;

+ (UIButton *)WH_create_WHCommonButton:(NSString *)title target:(id)target action:(SEL)selector;

+ (UIButton *)WH_create_WHButtonWithTitle:(NSString *)title
                          titleFont:(UIFont *)font
                         titleColor:(UIColor *)titleColor
                             normal:(NSString *)normalImage
                           highlight:(NSString *)clickIamge;

+ (UIButton *)WH_create_WHButtonWithImage:(NSString *)normalImage
                           highlight:(NSString *)clickIamge
                             target:(id)target
                           selector:(SEL)selector;

+ (UIButton *)WH_create_WHButtonWithImage:(NSString *)normalImage
                           selected:(NSString *)clickIamge
                             target:(id)target
                           selector:(SEL)selector;

+ (UIButton *)WH_create_WHButtonWithTitle:(NSString *)title
                          titleFont:(UIFont *)font
                         titleColor:(UIColor *)titleColor
                             normal:(NSString *)normalImage
                          highlight:(NSString *)clickIamge
                           selected:(NSString *)selectIamge;

    
+ (UIButton *)WH_create_WHButtonWithRect:(CGRect)frame
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                          selected:(NSString *)clickIamge
                          selector:(SEL)selector
                            target:(id)target;

+ (UIButton *)WH_create_WHButtonWithRect:(CGRect)frame 
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                         highlight:(NSString *)clickIamge
                          selector:(SEL)selector
                            target:(id)target;

+ (UIButton *)WH_create_WHButtonWithRect:(CGRect)frame 
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                         highlight:(NSString *)clickIamge
                             fixed:(CGSize)fixedSize
                          selector:(SEL)selector
                            target:(id)target;

+ (UIButton *)WH_create_WHButtonWithRect:(CGRect)frame 
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                         highlight:(NSString *)clickIamge
                          selected:(NSString *)selectedImage
                          selector:(SEL)selector
                            target:(id)target;


+ (UITextField *)WH_create_WHTextFieldWithRect:(CGRect)frame
                            keyboardType:(UIKeyboardType)keyboardType
                                  secure:(BOOL)secure
                             placeholder:(NSString *)placeholder
                                    font:(UIFont *)font
                                   color:(UIColor *)color
                                delegate:(id)delegate;

+(UIButton*)WH_create_WHCheckButtonWithRect:(CGRect)frame
                             selector:(SEL)selector
                               target:(id)target;

+ (UIButton *)WH_create_WHRadioButtonWithRect:(CGRect)frame
                            normalImage:(NSString *)normalImage
                          selectedImage:(NSString *)selectedImage
                              labelText:(NSString *)labelText
                              textColor:(UIColor*)textColor
                               selector:(SEL)selector
                                 target:(id)target
                               thisView:(UIView*)thisView;

+ (UIButton *)WH_create_WHRadioButtonWithRect:(CGRect)frame
                              labelText:(NSString *)labelText
                              textColor:(UIColor*)textColor
                               selector:(SEL)selector
                                 target:(id)target
                               thisView:(UIView*)thisView;

+(UIButton*)WH_create_WHTopButton:(NSString*)s action:(SEL)action target:(id)target;

+ (NSString *)localized:(NSString *)key;

/**--------------------------------
 * Check Network Address Validation
 *
 *  address           :NSString *
 */
+ (BOOL)isValidIPAddress:(NSString *)address;
+ (BOOL)isValidPortAddress:(NSString *)address;
+ (BOOL)checkIntValueRange:(NSString *)value min:(int)min max:(int)max;
+ (NSString *)checkValidName:(NSString *)value;
+ (NSString *)checkValidPhoneNumber:(NSString *)value;

+ (void)showAlert:(NSString *)message;
+ (void)showAlert:(NSString *)message tag:(NSUInteger)tag delegate:(id)delegate;
+ (void)showConfirm:(NSString *)message tag:(NSUInteger)tag delegate:(id)delegate;

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)formatStr;
+ (NSDate *)dateFromString:(NSString *)str format:(NSString *)formatStr;

+ (UIButton *)WH_create_WHLogOutButton:(NSString *)title target:(id)target action:(SEL)selector;

+(void)freeTable:(NSMutableArray*)pool;
+(void)addToPool:(NSMutableArray*)pool object:(NSObject*)object;

+ (UIFactory*)sharedUIFactory;

+(void)onGotoBack:(UIViewController*)vc;

-(void)removeAllChild:(UIView*)parent;


//卡片,按钮相关
@property (nonatomic, strong) UIColor *cardBorderColor; //卡片/按钮 边框颜色
@property (nonatomic, strong) UIColor *cardBackgroundColor; //卡片/按钮 背景颜色
@property (nonatomic, assign) CGFloat cardCornerRadius; //卡片/按钮 倒角
@property (nonatomic ,assign) CGFloat cardBorderWithd ; //卡片边框宽度

//提示性文本相关
@property (nonatomic, strong) UIColor *promptBackgroundColor; //提示性标签背景颜色
@property (nonatomic, strong) UIColor *promptTextColor; //提示性标签前景色(文案颜色)

//全局相关
@property (nonatomic, strong) UIColor *globalBgColor; //全局背景底色
@property (nonatomic, assign) CGFloat globelEdgeInset; //全局界面距离屏幕左右距离
@property (nonatomic, strong) UIColor *navigatorTitleColor; //导航条标题颜色
@property (nonatomic, strong) UIFont *navigatorTitleFont; //导航条标题字体
@property (nonatomic, assign) CGFloat badgeWidthHeight; //全局角标宽高
@property (nonatomic, strong) UIColor *badgeBgColor; //全局角标背景颜色
@property (nonatomic, strong) UIColor *navigatorBgColor; //导航条颜色

//搜索条相关
@property (nonatomic, strong) UIColor *inputBorderColor; //输入框边框颜色
@property (nonatomic, strong) UIColor *inputBackgroundColor; //输入框背景颜色
@property (nonatomic, strong) UIColor *inputDefaultTextColor; //输入框默认文字颜色
@property (nonatomic, strong) UIFont *inputDefaultTextFont; //输入框默认文字字体

//取消框
@property (nonatomic, strong) UIColor *cancelBtnBorderColor;
@property (nonatomic, strong) UIColor *cancelBtnBackgroundColor;
@property (nonatomic, strong) UIColor *cancelBtnTextColor;
@property (nonatomic, strong) UIFont *cancelBtnFont; //!< 取消按钮字体

@property (nonatomic ,assign) CGFloat headViewCornerRadius; //!< 头像圆角

/**
 设置view为卡片样式
 
 @param view 待设置的view
 */
- (void)setViewCardStyle:(UIView *)view;

/**
 
 设置输入框输入长度限制
 @param textField 输入框
 */
- (void)setTextFieldInputLengthLimit:(UITextField *)textField maxLength:(NSUInteger)maxLength;

@end

@interface UIImage (ImageNamed)

+ (UIImage *)imageNamed:(NSString *)name;

@end

extern NSString *kStyle2Dir;
