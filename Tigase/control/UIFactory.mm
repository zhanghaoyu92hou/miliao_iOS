//
//  UIFactory.m
//  SmartMeeting
//
//  Created by luddong on 12-3-30.
//  Copyright (c) 2012年 Twin-Fish. All rights reserved.
//

#import "WH_AlertView.h"
#import "WH_ConfirmView.h"
#import "UIFactory.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import <arpa/inet.h>




static UIFactory* factory;
NSString *kStyle2Dir;

#define kDefaultLanguage                @"kDefaultLanguage"
#define kDefaultIsFirstLaunch           @"kDefaultIsFirstLaunch"

/*
@implementation UIImage(ImageNamed)

+ (UIImage *)imageNamed:(NSString *)name {
    NSString *skin = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultSkin];
    NSString *image_file = nil;
    
    if (name == nil || [name length] == 0)
        return nil;
    
    if ([skin isEqualToString:SKIN_SECOND] == YES) {
        if ([[name pathExtension] isEqualToString:@""] == YES)  // Assumes test=>test.png
            image_file = [[NSBundle mainBundle] pathForResource:name ofType:@"png" inDirectory:kStyle2Dir];
        else
            image_file = [[NSBundle mainBundle] pathForResource:name  ofType:@"" inDirectory:kStyle2Dir];
    }
    if (image_file == nil) {
        if ([[name pathExtension] isEqualToString:@""] == YES)  //Assumes test=>test.png
            image_file = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
        else
            image_file = [[NSBundle mainBundle] pathForResource:name ofType:@""];
    }
    
    return [UIImage imageWithContentsOfFile:image_file];
}

@end*/


@implementation UIFactory

+ (UIFactory*)sharedUIFactory{
 
    if(factory == nil)
        factory = [[UIFactory alloc]init];
    return factory;
}

-(instancetype)init {
    self = [super init];
    
    //卡片/按钮相关
    self.cardBorderColor = HEXCOLOR(0xDBE0E7); //卡片/按钮 边框颜色
    self.cardBackgroundColor = HEXCOLOR(0xFFFFFF); //卡片/按钮 背景颜色
    self.cardCornerRadius = 10.0f; //卡片/按钮 倒角
    self.cardBorderWithd = 0.5f;
    
    //提示性文本相关
    self.promptBackgroundColor = [UIColor colorWithWhite:0 alpha:0.7]; //提示性标签背景颜色
    self.promptTextColor = HEXCOLOR(0xFFFFFF); //提示性标签前景色(文案颜色)
    
    //全局相关
    self.globalBgColor = HEXCOLOR(0xF5F7FA); //全局背景底色
    self.globelEdgeInset = 10.0f; //全局界面距离屏幕左右距离
    self.navigatorTitleColor = HEXCOLOR(0x333333);
    self.badgeWidthHeight = 17.0f;
    self.badgeBgColor = HEXCOLOR(0xFF5651);
    
    //搜索条相关
    self.inputBorderColor = HEXCOLOR(0xEBECEF); //输入框边框颜色
    self.inputBackgroundColor = HEXCOLOR(0xFAFBFC); //输入框背景颜色
    self.inputDefaultTextColor = HEXCOLOR(0xD1D6E0); //输入框默认文字颜色
    
    //取消框
    self.cancelBtnBorderColor = HEXCOLOR(0xEEF0F5);
    self.cancelBtnBackgroundColor = HEXCOLOR(0xFFFFFF);
    self.cancelBtnTextColor = HEXCOLOR(0x8C9AB8);
    
    self.headViewCornerRadius = 5.0f;
    return self;
}

- (UIFont *)cancelBtnFont {
    if (!_cancelBtnFont) {
        _cancelBtnFont = [UIFont systemFontOfSize:12];
    }
    return _cancelBtnFont;
}
- (UIFont *)inputDefaultTextFont {
    if (!_inputDefaultTextFont) {
        _inputDefaultTextFont = [UIFont systemFontOfSize:13];
    }
    return _inputDefaultTextFont;
}
- (UIFont *)navigatorTitleFont {
    if (!_navigatorTitleFont) {
        _navigatorTitleFont = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    }
    return _navigatorTitleFont;
}

- (UIColor *)navigatorBgColor{
    return g_theme.themeIndex == 0 ? [UIColor whiteColor] : g_theme.themeColor;
}


/**
 设置view为卡片样式

 @param view 待设置的view
 */
- (void)setViewCardStyle:(UIView *)view{
    view.layer.cornerRadius = self.cardCornerRadius;
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = self.cardBorderWithd;
    view.layer.borderColor = self.cardBorderColor.CGColor;
    view.backgroundColor = self.cardBackgroundColor;
}


/**
 
 设置输入框输入长度限制
 @param textField 输入框
 */
- (void)setTextFieldInputLengthLimit:(UITextField *)textField maxLength:(NSUInteger)maxLength{
    if (textField.text.length > maxLength) {
        @try{
            textField.text = [textField.text substringToIndex:maxLength];
        }@catch(NSException *e){}
    }
}

+ (id)WH_create_WHTextFieldWith:(CGRect)frame
                 delegate:(id<UITextFieldDelegate>)delegate
            returnKeyType:(UIReturnKeyType)returnKeyType
          secureTextEntry:(BOOL)secureTextEntry
              placeholder:(NSString *)placeholder 
                     font:(UIFont *)font {
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    if (delegate != nil) {
        textField.delegate = delegate;
        textField.returnKeyType = returnKeyType;
        textField.secureTextEntry = secureTextEntry;
        textField.placeholder = placeholder;
        textField.font = font;
        textField.textColor = HEXCOLOR(0x333333);
        // Default property
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.enablesReturnKeyAutomatically = YES;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return textField;
}


+ (id)WH_create_WHLabelWith:(CGRect)frame text:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    return label;
}

+ (id)WH_create_WHLabelWith:(CGRect)frame
                 text:(NSString *)text 
       backgroundColor:(UIColor *)backgroundColor {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.backgroundColor = backgroundColor;
    return label;
}

+ (id)WH_create_WHClearBackgroundLabelWith:(CGRect)frame
                                text:(NSString *)text {
    return [UIFactory WH_create_WHLabelWith:frame
                                 text:text 
                      backgroundColor:[UIColor clearColor]];
}

+ (id)WH_create_WHLabelWith:(CGRect)frame
                text:(NSString *)text 
                 font:(UIFont *)font 
            textColor:(UIColor *)textColor 
      backgroundColor:(UIColor *)backgroundColor {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.font = font;
    label.textColor = textColor;
    if (backgroundColor != nil) {
      label.backgroundColor = backgroundColor;
    }
    return label ;
}

+ (UIImage*)resizableImageWithSize:(CGSize)size
                             image:(UIImage*)image {
    if (image == nil)
        return nil;
    
    if ([image respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        return [image resizableImageWithCapInsets:UIEdgeInsetsMake(size.height, size.width, size.height, size.width)];
    } else {
        return [image stretchableImageWithLeftCapWidth:size.width topCapHeight:size.height];
    }
}

//创建主题色文字的按钮
+ (UIButton *)WH_create_WHCommonButton:(NSString *)title target:(id)target action:(SEL)selector{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    [button setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [button.titleLabel setFont:sysFontWithSize(15)];
    
    UIImage* p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[g_theme themeTintImage:@"navBarBackground"]];
    [button setBackgroundImage:p forState:UIControlStateNormal];
    
    p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[g_theme themeTintImage:@"navBarBackground"]];
    [button setBackgroundImage:p forState:UIControlStateHighlighted];
    p = nil;
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

    return button;
}

//创建白色文字的按钮
+ (UIButton *)WH_create_WHLogOutButton:(NSString *)title target:(id)target action:(SEL)selector{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:sysFontWithSize(15)];
    
    //    UIImage* p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[g_theme themeTintImage:@"navBarBackground"]];
    //    [button setBackgroundImage:p forState:UIControlStateNormal];
    
    //    p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[g_theme themeTintImage:@"navBarBackground"]];
    //    [button setBackgroundImage:p forState:UIControlStateHighlighted];
    //    p = nil;
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


+ (UIButton *)WH_create_WHButtonWithTitle:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                          highlight:(NSString *)clickIamge
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    if (titleColor != nil)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    if (normalImage != nil){
        UIImage* p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[UIImage imageNamed:normalImage]];
        [button setBackgroundImage:p forState:UIControlStateNormal];
        p = nil;
    }
    
    if (clickIamge != nil){
        UIImage* p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[UIImage imageNamed:clickIamge]];
        [button setBackgroundImage:p forState:UIControlStateHighlighted];
        p = nil;
    }
    
    return button;
}

+ (UIButton *)WH_create_WHButtonWithTitle:(NSString *)title
                          titleFont:(UIFont *)font
                         titleColor:(UIColor *)titleColor
                             normal:(NSString *)normalImage
                          highlight:(NSString *)clickIamge
                          selected:(NSString *)selectIamge
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    if (titleColor != nil)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    if (normalImage != nil){
        UIImage* p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[UIImage imageNamed:normalImage]];
        [button setBackgroundImage:p forState:UIControlStateNormal];
        p = nil;
    }
    
    if (clickIamge != nil){
        UIImage* p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[UIImage imageNamed:clickIamge]];
        [button setBackgroundImage:p forState:UIControlStateHighlighted];
        p = nil;
    }
    
    if (clickIamge != nil){
        UIImage* p = [UIFactory resizableImageWithSize:CGSizeMake(10, 10) image:[UIImage imageNamed:selectIamge]];
        [button setBackgroundImage:p forState:UIControlStateSelected];
        p = nil;
    }
    
    return button;
}

+ (UIButton *)WH_create_WHButtonWithImage:(NSString *)normalImage
                          highlight:(NSString *)clickIamge
                            target:(id)target
                        selector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    
    button.custom_acceptEventInterval = 1.0f;
    if (normalImage != nil)
        [button setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    
    if (clickIamge != nil)
        [button setImage:[UIImage imageNamed:clickIamge] forState:UIControlStateHighlighted];
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


+ (UIButton *)WH_create_WHButtonWithImage:(NSString *)normalImage
                          selected:(NSString *)clickIamge
                             target:(id)target
                           selector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    if (normalImage != nil)
        [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    
    if (clickIamge != nil)
        [button setBackgroundImage:[UIImage imageNamed:clickIamge] forState:UIControlStateSelected];
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}



+ (UIButton *)WH_create_WHButtonWithRect:(CGRect)frame
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                          selected:(NSString *)clickIamge
                          selector:(SEL)selector
                            target:(id)target;
{    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = frame;
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    if (titleColor != nil)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    if (normalImage != nil)
        [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    
    if (clickIamge != nil)
        [button setBackgroundImage:[UIImage imageNamed:clickIamge] forState:UIControlStateSelected];
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (UIButton *)WH_create_WHButtonWithRect:(CGRect)frame
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                         highlight:(NSString *)clickIamge
                          selector:(SEL)selector
                            target:(id)target;
{    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = frame;
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    if (titleColor != nil)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    if (normalImage != nil)
        [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    
    if (clickIamge != nil)
        [button setBackgroundImage:[UIImage imageNamed:clickIamge] forState:UIControlStateHighlighted];
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (UIButton *)WH_create_WHButtonWithRect:(CGRect)frame
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                         highlight:(NSString *)clickIamge
                             fixed:(CGSize)fixedSize
                          selector:(SEL)selector
                            target:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = frame;
    
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    if (titleColor != nil)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    if (normalImage != nil) {
        [button setBackgroundImage:[UIFactory resizableImageWithSize:fixedSize image:[UIImage imageNamed:normalImage]]
                          forState:UIControlStateNormal];
    }
    
    if (clickIamge != nil) {
        [button setBackgroundImage:[UIFactory resizableImageWithSize:fixedSize image:[UIImage imageNamed:clickIamge]]
                          forState:UIControlStateHighlighted];
    }
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (UIButton *)WH_create_WHButtonWithRect:(CGRect)frame
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                         highlight:(NSString *)clickIamge
                          selected:(NSString *)selectedImage
                          selector:(SEL)selector
                            target:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = [UIColor clearColor];

    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    if (titleColor != nil)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    if (normalImage != nil)
        [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    
    if (clickIamge != nil)
        [button setBackgroundImage:[UIImage imageNamed:clickIamge] forState:UIControlStateHighlighted];
    
    if (selectedImage != nil)
        [button setBackgroundImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchDown];
    
    return button;
    
}

+ (UITextField *)WH_create_WHTextFieldWithRect:(CGRect)frame
                            keyboardType:(UIKeyboardType)keyboardType
                                  secure:(BOOL)secure
                             placeholder:(NSString *)placeholder
                                    font:(UIFont *)font
                                   color:(UIColor *)color
                                delegate:(id)delegate;
{
    UITextField *textField = [UIFactory WH_create_WHTextFieldWith:frame
                                                   delegate:delegate 
                                              returnKeyType:UIReturnKeyNext 
                                            secureTextEntry:secure 
                                                placeholder:placeholder
                                                       font:font];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.keyboardType = keyboardType;
    if (color != nil)
        [textField setTextColor:color];
    
    return textField;
}

+(UIButton*)WH_create_WHCheckButtonWithRect:(CGRect)frame
                             selector:(SEL)selector
                               target:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setBackgroundImage:[UIImage imageNamed:@"com_checkbox1_normal"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"com_checkbox1_select"] forState:UIControlStateSelected];
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+(UIButton*)WH_create_WHCheckButtonWithRect1:(CGRect)frame
                             selector:(SEL)selector
                               target:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setBackgroundImage:[UIImage imageNamed:@"select_none"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"select_default"] forState:UIControlStateSelected];
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *)WH_create_WHRadioButtonWithRect:(CGRect)frame
                            normalImage:(NSString *)normalImage
                          selectedImage:(NSString *)selectedImage
                              labelText:(NSString *)labelText
                              textColor:(UIColor*)textColor
                               selector:(SEL)selector
                                 target:(id)target
                               thisView:(UIView*)thisView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGRect frame1;
    frame1 = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 25,25);
    button.frame = frame1;
    [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [thisView addSubview:button];

    frame1 = CGRectMake(CGRectGetMinX(frame)+30, CGRectGetMinY(frame), CGRectGetWidth(frame)-30,CGRectGetHeight(frame));
    JXLabel* label = [[JXLabel alloc]initWithFrame:frame1];
    label.backgroundColor = [UIColor clearColor];
    label.text = labelText;
    label.userInteractionEnabled = YES;
    label.textColor = textColor;
    label.font = sysFontWithSize(16);
    label.didTouch = selector;
    label.wh_delegate = target;
    [thisView addSubview:label];
    
    return button;
}

+ (UIButton *)WH_create_WHRadioButtonWithRect:(CGRect)frame
                              labelText:(NSString *)labelText
                              textColor:(UIColor*)textColor
                               selector:(SEL)selector
                                 target:(id)target
                               thisView:(UIView*)thisView
{
    UIButton* button = [self WH_create_WHRadioButtonWithRect:frame
                                           normalImage:@"com_radiobox_normal" 
                                         selectedImage:@"com_radiobox_select" 
                                             labelText:labelText 
                                             textColor:textColor
                                              selector:selector 
                                                target:target 
                                              thisView:thisView];
    return button;
}

+(UIButton*)WH_create_WHTopButton:(NSString*)s action:(SEL)action target:(id)target{
    UIButton* btn = [UIFactory WH_create_WHButtonWithRect:CGRectMake(5, 5, 70, 30)
                              title:s
                          titleFont:sysFontWithSize(13)
                         titleColor:nil
                             normal:@"enter"
                          highlight:nil
                           selector:action
                             target:target
     ];
//    btn.showsTouchWhenHighlighted = YES;
    return btn;
}

+ (UINavigationBar *)createNavigationBarWithBackgroundImage:(UIImage *)backgroundImage title:(NSString *)title {
    UINavigationBar *customNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 44)];
    UIImageView *navigationBarBackgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [customNavigationBar addSubview:navigationBarBackgroundImageView];
//    [navigationBarBackgroundImageView release];
    UINavigationItem *navigationTitle = [[UINavigationItem alloc] initWithTitle:title];
    [customNavigationBar pushNavigationItem:navigationTitle animated:NO];
//    [navigationTitle release];
    return customNavigationBar;
}

+ (void)showAlert:(NSString *)message
{
    WH_AlertView *view = [[WH_AlertView alloc] initWithTitle:@""
                                               message:message
                                              delegate:nil
                                     cancelButtonTitle:[UIFactory localized:@"Ok"]
                                     otherButtonTitles:nil, nil];
    [view show];
}

+ (void)showAlert:(NSString *)message tag:(NSUInteger)tag delegate:(id)delegate
{
    WH_AlertView *view = [[WH_AlertView alloc] initWithTitle:@""
                                                message:message
                                               delegate:delegate
                                      cancelButtonTitle:[UIFactory localized:@"Ok"]
                                      otherButtonTitles:nil, nil];
    view.tag = tag;
    [view show];
}

+ (void)showConfirm:(NSString *)message tag:(NSUInteger)tag delegate:(id)delegate
{
    WH_ConfirmView *view = [[WH_ConfirmView alloc] initWithTitle:@""
                                               message:message
                                              delegate:delegate
                                     cancelButtonTitle:[UIFactory localized:@"Cancel"]
                                     otherButtonTitles:[UIFactory localized:@"Ok"], nil];
    view.tag = tag;
    [view show];
}

+ (NSString *)localized:(NSString *)key
{
    NSString *langCode = @"";
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:kDefaultIsFirstLaunch] == nil) {
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        NSArray *languages = [defs objectForKey:@"AppleLanguages"];
        langCode = [languages objectAtIndex:0];
        if ([langCode isEqualToString:@"zh-Hans"] == NO)
            langCode = @"en";
    } else {
        NSString *appLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultLanguage];
        if ([appLanguage isEqualToString:@"English"] == YES) {
            langCode = @"en";
        } else {
            langCode = @"zh-Hans";
        }
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:langCode ofType:@"lproj"];
    NSBundle *languageBundle = [NSBundle bundleWithPath:path];
    return [languageBundle localizedStringForKey:key value:@"" table:nil];
}

+ (BOOL)isValidIPAddress:(NSString *)address
{
    if ([address length] < 1)
        return NO;
    
    struct in_addr addr;
    return (inet_aton([address UTF8String], &addr) == 1);
}

+ (BOOL)isValidPortAddress:(NSString *)address
{
    return [UIFactory checkIntValueRange:address min:1 max:65535];
}

+ (BOOL)checkIntValueRange:(NSString *)value min:(int)min max:(int)max
{
    if ([value length] < 1)
        return NO;
    
    NSScanner * scanner = [NSScanner scannerWithString:value];
    if ([scanner scanInt:nil] && [scanner isAtEnd]) {
//        NSLog(@"min = %u, max = %u, value = %u %@", min, max, [value integerValue], value);
        return (min <= [value integerValue]) && ([value integerValue] <= max);
    }
    
    return NO;
}

+ (NSString *)checkValidName:(NSString *)value
{
    if ([value length] == 0) {
        [self showAlert:[self localized:@"ContactInputNamePrompt"]];
        return nil;
    }
        
    NSString *newString = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([newString length] > 0) {
        NSString *str = [newString stringByTrimmingCharactersInSet:[NSCharacterSet alphanumericCharacterSet]];
        if ([str length] == 0)
            return newString;
    }
    [self showAlert:[self localized:@"ContactInputValidNamePrompt"]];
    
    return nil;
}

+ (NSString *)checkValidPhoneNumber:(NSString *)value
{
    if ([value length] == 0) {
        [self showAlert:[self localized:@"ContactInputPhonePrompt"]];
        return nil;
    }
    
    NSString *newString = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([newString length] > 0) {
        NSString *str = [newString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        if ([str length] == 0)
            return newString;
    }
    [self showAlert:[self localized:@"ContactInputValidPhonePrompt"]];

    return nil;
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)formatStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:formatStr];

    NSLocale *timeLocale;
    NSString *appLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultLanguage];
    if ([appLanguage isEqualToString:@"English"] == YES) {
        timeLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
    } else {
        timeLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
    }
    [formatter setLocale:timeLocale];
    
    NSString *str = [formatter stringFromDate:date];

//    [timeLocale release];
//    [formatter release];

    return str;
}

+ (NSDate *)dateFromString:(NSString *)str format:(NSString *)formatStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:formatStr];
    
    NSLocale *timeLocale;
    NSString *appLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultLanguage];
    if ([appLanguage isEqualToString:@"English"] == YES) {
        timeLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
    } else {
        timeLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
    }
    [formatter setLocale:timeLocale];
    
    NSDate *date = [formatter dateFromString:str];
    
//    [timeLocale release];
//    [formatter release];

    return date;
}


+(void)freeTable:(NSMutableArray*)pool{
    if(pool==nil)
        return;
//    NSLog(@"App.freeTable.count=%d",[pool count]);
    for(NSInteger i=[pool count]-1;i>=0;i--){
        id p = [pool objectAtIndex:i];
		if([p isKindOfClass:[UIView class]]){
            for(NSInteger i=[[p subviews] count]-1;i>=0;i--)
                [[[p subviews] objectAtIndex:i] removeFromSuperview];
            [p removeFromSuperview];
        }        
		if([p isKindOfClass:[NSMutableArray class]]){
//            NSLog(@"array.count=%d",[p retainCount]);
            //[p removeAllObjects];
        }
		if([p isKindOfClass:[NSMutableDictionary class]]){
//            NSLog(@"dict.count=%d",[p retainCount]);
            //[p removeAllObjects];
        }
        [pool removeObjectAtIndex:i];
//        [p release];
    }
}

+(void)addToPool:(NSMutableArray*)pool object:(NSObject*)object{
    if(pool == nil || object==nil)
        return;
    [pool addObject:object];
}

+(void)onGotoBack:(UIViewController*)vc{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    
    vc.view.frame = CGRectMake (JX_SCREEN_WIDTH, 0, vc.view.frame.size.width, vc.view.frame.size.height);
    
    [UIView commitAnimations];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doQuit:) userInfo:vc repeats:NO];
}

+(void)doQuit:(NSTimer*)timer{
    UIViewController* vc = timer.userInfo;
    [vc.view removeFromSuperview];
//    [vc release];
    vc = nil;
}

-(void)removeAllChild:(UIView*)parent{
    for(NSInteger i=[[parent subviews] count]-1;i>=0;i--){
        [[[parent subviews] objectAtIndex:i] removeFromSuperview];
    }
}

+(UIView*)createLine:(UIColor*)color parent:(UIView*)parent{
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,0,parent.frame.size.width,0.5)];
    line.backgroundColor = color;
    [parent addSubview:line];
//    [line release];
    return line;
}

+(UIView*)createLine:(UIView*)parent{
    return [self createLine:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] parent:parent];
}

@end
