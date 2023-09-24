//
//  JXTextView.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-24.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "JXTextView.h"

@interface JXTextView ()<UITextViewDelegate>

@property (nonatomic, copy) NSString *placeHolderStr;

@end

@implementation JXTextView
@synthesize wh_placeHolder;
@synthesize wh_previousTextViewContentHeight,wh_target,didTouch;
@synthesize wh_isEditing;

#pragma mark - Setters

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
        if(!self.wh_disableAutoSize){
            [self addObserver:self forKeyPath:@"contentSize"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
            
            [g_notify  addObserver:self selector:@selector(changeKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
        }
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"JXTextView.dealloc");
    if(!self.wh_disableAutoSize){
        [self removeObserver:self forKeyPath:@"contentSize"];
        [g_notify  removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    }
    self.wh_placeHolder = nil;
    _wh_placeHolderTextColor = nil;
//    [g_notify  removeObserver:self name:UITextViewTextDidChangeNotification object:self];
//    [super dealloc];
}


- (void)setWh_placeHolder:(NSString *)value {
    if([wh_placeHolder isEqualToString:value]) {
        return;
    }
    wh_placeHolder = [value copy];
    if (wh_placeHolder) {
        _placeHolderStr = wh_placeHolder;
    }
    
    NSUInteger maxChars = [JXTextView wh_maxCharactersPerLine];
    if([wh_placeHolder length] > maxChars) {
        wh_placeHolder = [wh_placeHolder substringToIndex:maxChars - 8];
        wh_placeHolder = [[wh_placeHolder stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAppendingFormat:@"..."];
    }
    
    [self setNeedsDisplay];
}

- (void)setWh_placeHolderTextColor:(UIColor *)placeHolderTextColor {
    if([placeHolderTextColor isEqual:_wh_placeHolderTextColor]) {
        return;
    }
    
    _wh_placeHolderTextColor = placeHolderTextColor;
    [self setNeedsDisplay];
}

#pragma mark - Message text view

- (NSUInteger)wh_numberOfLinesOfText {
    return [JXTextView wh_numberOfLinesForMessage:self.text];
}

+ (NSUInteger)wh_maxCharactersPerLine {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 33 : 109;
}

+ (NSUInteger)wh_numberOfLinesForMessage:(NSString *)text {
    return (text.length / [JXTextView wh_maxCharactersPerLine]) + 1;
}

#pragma mark - Text view overrides

- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    [super setContentInset:contentInset];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

#pragma mark - Notifications

- (void)didReceiveTextDidChangeNotification:(NSNotification *)notification {
//    [self setNeedsDisplay];
}

#pragma mark - Life cycle

- (void)setup {
//    [g_notify  addObserver:self
//                                             selector:@selector(didReceiveTextDidChangeNotification:)
//                                                 name:UITextViewTextDidChangeNotification
//                                               object:self];
    
    _wh_placeHolderTextColor = [UIColor lightGrayColor];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.scrollIndicatorInsets = UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 8.0f);
    self.contentInset = UIEdgeInsetsZero;
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    self.font = [UIFont systemFontOfSize:16.0f];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.textAlignment = NSTextAlignmentLeft;
    self.delegate = self;

    //重要，扁平
    self.backgroundColor = [UIColor clearColor];
//    self.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        self.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    self.layer.borderWidth = 0.65f;
    self.layer.cornerRadius = 6.0f;
    self.returnKeyType = UIReturnKeySend;
    wh_isEditing = NO;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if([self.text length] == 0 && self.wh_placeHolder) {
        CGRect placeHolderRect = CGRectMake(10.0f,
                                            (self.frame.size.height-self.font.pointSize)/2,
                                            rect.size.width,
                                            rect.size.height);
        
        [self.wh_placeHolderTextColor set];
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_0) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            paragraphStyle.alignment = self.textAlignment;
            
            [self.wh_placeHolder drawInRect:placeHolderRect
                          withAttributes:@{ NSFontAttributeName : self.font,
                                            NSForegroundColorAttributeName : self.wh_placeHolderTextColor,
                                            NSParagraphStyleAttributeName : paragraphStyle }];
        }
        else {
//            [self.placeHolder drawInRect:placeHolderRect
//                                withFont:self.font
//                           lineBreakMode:NSLineBreakByTruncatingTail
//                               alignment:self.textAlignment];
            [self.wh_placeHolder drawInRect:placeHolderRect withAttributes:@{NSFontAttributeName:self.font}];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    //    if (object == self && [keyPath isEqualToString:@"contentSize"]) {
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self layoutAndAnimateMessageInputTextView:object];
    }
}

- (CGFloat)getTextViewContentH{
    //    return textView.contentSize.height;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return ceilf([self sizeThatFits:self.frame.size].height);
    } else {
        return self.contentSize.height;
    }
}

- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView {
    CGFloat maxHeight = 80;
    
    CGFloat contentH = [self getTextViewContentH];
    
    BOOL isShrinking = contentH < self.wh_previousTextViewContentHeight;
    CGFloat changeInHeight = contentH - self.wh_previousTextViewContentHeight;
    
    if (!isShrinking && (self.wh_previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.wh_previousTextViewContentHeight);
    }
    
    
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             if (isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.wh_previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                             }
                             
                             self.frame = CGRectMake(self.frame.origin.x,
                                                       self.frame.origin.y,
                                                       self.frame.size.width,
                                                       self.frame.size.height + changeInHeight);
                             self.superview.frame = CGRectMake(self.superview.frame.origin.x,
                                                  self.superview.frame.origin.y - changeInHeight,
                                                  self.superview.frame.size.width,
                                                  self.superview.frame.size.height + changeInHeight);
                             if (!isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.wh_previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // growing the view, animate the text view frame AFTER input view frame
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        
        self.wh_previousTextViewContentHeight = MIN(contentH, maxHeight);
    }
    
    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.wh_previousTextViewContentHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                       dispatch_get_main_queue(),
                       ^(void) {
                           CGPoint bottomOffset = CGPointMake(0.0f, contentH - textView.bounds.size.height);
                           [textView setContentOffset:bottomOffset animated:YES];
                       });
    }
}

-(void)changeKeyBoard:(NSNotification *)aNotifacation
{
    return;
//    //获取到键盘frame 变化之前的frame
//    NSValue *keyboardBeginBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
//    CGRect beginRect=[keyboardBeginBounds CGRectValue];
//    
//    //获取到键盘frame变化之后的frame
//    NSValue *keyboardEndBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
//    
//    CGRect endRect=[keyboardEndBounds CGRectValue];
//    
//    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
//    //拿frame变化之后的origin.y-变化之前的origin.y，其差值(带正负号)就是我们self.view的y方向上的增量
//    deltaY=-endRect.size.height;
//    
////    NSLog(@"deltaY:%f",deltaY);
//    
//    [self.superview setFrame:CGRectMake(0, JX_SCREEN_HEIGHT+deltaY-self.superview.frame.size.height, self.superview.frame.size.width, self.superview.frame.size.height)];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    wh_isEditing = YES;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    self.wh_previousTextViewContentHeight = [self getTextViewContentH];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    wh_isEditing = NO;
}

- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length == 0) {
        return;
    }
    NSString* s = textView.text;
    unichar c = [s characterAtIndex:s.length-1];
    if (c == '\n'){
        [self sendToTarget];
//        textView.hidden = YES;
    }
    if (s.length <= 0) {
        self.wh_placeHolder = _placeHolderStr;
    }else {
        self.wh_placeHolder = nil;
    }
}

-(void)sendToTarget{
	if(self.wh_target != nil && [self.wh_target respondsToSelector:self.didTouch]){
        NSString* s = self.text;
        unichar c = [s characterAtIndex:s.length-1];
        if (c == '\n')
            s = [s substringToIndex:s.length-1];
		[self.wh_target performSelectorOnMainThread:self.didTouch withObject:s waitUntilDone:YES];
    }
}

@end
