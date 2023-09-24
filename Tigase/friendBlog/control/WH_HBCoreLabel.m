//
//  WH_HBCoreLabel
//  CoreTextMagazine
//
//  Created by weqia on 13-10-27.
//  Copyright (c) 2013年 Marin Todorov. All rights reserved.
//

#import "WH_HBCoreLabel.h"
#import "NSStrUtil.h"
#import "WH_JXActionSheet_WHVC.h"

@interface WH_HBCoreLabel () <WH_JXActionSheet_WHVCDelegate>

@property (nonatomic, strong) WH_JXActionSheet_WHVC *actionVC;

@end

@implementation WH_HBCoreLabel
@synthesize wh_match=_wh_match,wh_linesLimit;

#pragma -mark 接口方法

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
 
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if(self){
        _copyEnableAlready=NO;
    }
    return self;
}

-(void)setAttributedText:(NSString *)attributedText
{
    WHLog(@"%@", attributedText);
    _attributed=YES;
    if([NSStrUtil isEmptyOrNull:attributedText ])
    {
        self.wh_match=nil;
        return;
    }
    MatchParser * parser=[[MatchParser alloc]init];
    parser.width=self.bounds.size.width;
    [parser match:attributedText];
    self.wh_match=parser;
    
    
    
}

-(void)setText:(NSString *)text
{
    _attributed=NO;
    [super setText:text];
}

-(void)setWh_match:(MatchParser *)match
{
    if(match==_wh_match)
        return;
    _attributed=YES;
    _wh_match=match;
    [self setNeedsDisplay];
}
-(void)WH_registerCopyAction
{
    if(_copyEnableAlready)
        return;
    _copyEnableAlready=YES;
    self.userInteractionEnabled=YES;
    NSArray * gestures=self.gestureRecognizers;
    for(UIGestureRecognizer * gesture in gestures){
        if([gestures isKindOfClass:[UILongPressGestureRecognizer class]]){
            UILongPressGestureRecognizer * longPress=(UILongPressGestureRecognizer*)gestures;
            [longPress addTarget:self action:@selector(longPressAction:)];
            return;
        }
    }
    UILongPressGestureRecognizer * longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [longPress setMinimumPressDuration:0.8];

    [self addGestureRecognizer:longPress];
}
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if(!_attributed){
        [super drawRect:rect];
        return;
    }
    if(self.wh_match!=nil&&[self.wh_match isKindOfClass:[MatchParser class]]){
        CGContextRef context = UIGraphicsGetCurrentContext();
        // Flip the coordinate system
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextSaveGState(context); 
        CGContextTranslateCTM(context, 0, 10000);
        CGContextScaleCTM(context, 1.0, -1.0);
        if(self.wh_match.numberOfLimitLines==0||(self.wh_match.numberOfLimitLines>=self.wh_match.numberOfTotalLines)||!self.wh_linesLimit){
            CTFrameDraw((__bridge CTFrameRef)(self.wh_match.ctFrame), context);
            for (NSDictionary* imageData in self.wh_match.images) {
                NSString* img = [imageData objectForKey:MatchParserImage];
                UIImage * image=[UIImage imageNamed:img];
                NSValue * value=[imageData objectForKey:MatchParserRects];
                CGRect imgBounds;
                if(![value isKindOfClass:[NSNull class]])
                    imgBounds=[[imageData objectForKey:MatchParserRects] CGRectValue];
                CGContextDrawImage(context, imgBounds, image.CGImage);
                
            }
        }
        else{
            NSArray *lines = (__bridge NSArray *)CTFrameGetLines((__bridge CTFrameRef)(self.wh_match.ctFrame));
            CGPoint origins[[lines count]];
            CTFrameGetLineOrigins((__bridge CTFrameRef)(self.wh_match.ctFrame), CFRangeMake(0, 0), origins); //2
            for(int lineIndex=0;lineIndex<self.wh_match.numberOfLimitLines;lineIndex++){
                CTLineRef line=(__bridge CTLineRef)(lines[lineIndex]);
                CGContextSetTextPosition(context,origins[lineIndex].x,origins[lineIndex].y);
             //   NSLog(@"%d: %f,%f",lineIndex,origins[lineIndex].x,origins[lineIndex].y);
                CTLineDraw(line, context);
            }
            for (NSDictionary* imageData in self.wh_match.images) {
                NSString* img = [imageData objectForKey:MatchParserImage];
                UIImage * image=[UIImage imageNamed:img];
                NSValue * value=[imageData objectForKey:MatchParserRects];
                CGRect imgBounds;
                if(![value isKindOfClass:[NSNull class]])
                {
                    imgBounds=[[imageData objectForKey:MatchParserRects] CGRectValue];
                    NSNumber * number=[imageData objectForKey:MatchParserLine];
                    int line=[number intValue];
                    if(line<self.wh_match.numberOfLimitLines){
                        CGContextDrawImage(context, imgBounds, image.CGImage);
                    }
                }
            }
        }
    }
}

#pragma -mark 事件响应方法

-(void)longPressAction:(UIGestureRecognizer*)gesture
{
    if (gesture.view!=self) {
        return;
    }
    self.backgroundColor=[UIColor lightGrayColor];
    if(gesture.state==UIGestureRecognizerStateBegan){
        self.actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JX_Copy")]];
        self.actionVC.delegate = self;
        [g_App.window addSubview:self.actionVC.view];
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch1=[touches anyObject];
    CGPoint point=[touch1 locationInView:self];
    for(NSDictionary * dic in self.wh_match.links){
        NSArray * rects=[dic objectForKey:MatchParserRects];
        for(NSValue * value in rects){
            CGRect rect= [value CGRectValue];
            if(point.x>rect.origin.x&&point.y>rect.origin.y&&point.x<(rect.origin.x+rect.size.width)&&point.y<(rect.origin.y+rect.size.height)){
                NSValue * rangeValue=[dic objectForKey:MatchParserRange];
                NSRange range1=[rangeValue rangeValue];
                id<MatchParserDelegate> data=self.wh_match.data;
                _data=data;
                [data updateMatch:^(NSMutableAttributedString *string, NSRange range) {
                        CTFontRef fontRef=CTFontCreateWithName((__bridge CFStringRef)(self.font.fontName),self.font.pointSize,NULL);
                    if(range.location==range1.location){
                        NSDictionary *attribute=[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef,kCTFontAttributeName,(id)self.wh_match.keyWorkColor.CGColor,kCTForegroundColorAttributeName,[NSNumber numberWithFloat:1],kCTStrokeWidthAttributeName,nil];
                        [string addAttributes:attribute range:range];
                    }else{
                        NSDictionary *attribute=[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef,kCTFontAttributeName,(id)self.wh_match.keyWorkColor.CGColor,kCTForegroundColorAttributeName,nil];
                        [string addAttributes:attribute range:range];
                    }
                    CFRelease(fontRef);
                }];
                NSArray * ges = [self.superview gestureRecognizers];
                for(UIGestureRecognizer * recognizer in ges){
                    recognizer.enabled = NO;
                }
                ges=[self gestureRecognizers];
                for(UIGestureRecognizer * recognizer in ges){
                    recognizer.enabled = NO;
                }
                _linkStr=[self.wh_match.attrString.string substringWithRange:range1];
                _linkType=[dic objectForKey:MatchParserLinkType];
                [self setNeedsDisplay];
                touch=YES;
                return;
            }
        }
    }
    [super touchesBegan:touches withEvent:event];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touch) {
        touch=NO;
        if(_data){
            [_data updateMatch:^(NSMutableAttributedString *string, NSRange range) {
                CTFontRef fontRef=CTFontCreateWithName((__bridge CFStringRef)(self.font.fontName),self.font.pointSize,NULL);
                NSDictionary *attribute=[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef,kCTFontAttributeName,(id)self.wh_match.keyWorkColor.CGColor,kCTForegroundColorAttributeName,nil];
                [string addAttributes:attribute range:range];
            }];
            NSArray * ges=[self.superview gestureRecognizers];
            for(UIGestureRecognizer * recognizer in ges){
                recognizer.enabled=YES;
            }
            ges=[self gestureRecognizers];
            for(UIGestureRecognizer * recognizer in ges){
                recognizer.enabled=YES;
            }
            [self setNeedsDisplay];
            if([_linkType isEqualToString:MatchParserLinkTypeUrl]){
                if(self.wh_delegate&&[self.wh_delegate respondsToSelector:@selector(coreLabel:linkClick:)]){
                    [self.wh_delegate coreLabel:self linkClick:_linkStr];
                }
            }else if ([_linkType isEqualToString:MatchParserLinkTypePhone]){
                if(self.wh_delegate&&[self.wh_delegate respondsToSelector:@selector(coreLabel:phoneClick:)]){
                    [self.wh_delegate coreLabel:self phoneClick:_linkStr];
                }
            }else if ([_linkType isEqualToString:MatchParserLinkTypeMobie]){
                if(self.wh_delegate&&[self.wh_delegate respondsToSelector:@selector(coreLabel:mobieClick:)]){
                    [self.wh_delegate coreLabel:self mobieClick:_linkStr];
                }
            }
            return;
        }
    }
    [super touchesCancelled:touches withEvent:event];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touch){
        touch=NO;
        if(_data){
            [_data updateMatch:^(NSMutableAttributedString *string, NSRange range) {
                CTFontRef fontRef=CTFontCreateWithName((__bridge CFStringRef)(self.font.fontName),self.font.pointSize,NULL);
                NSDictionary *attribute=[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef,kCTFontAttributeName,(id)self.wh_match.keyWorkColor.CGColor,kCTForegroundColorAttributeName,nil];
                [string addAttributes:attribute range:range];
                CFRelease(fontRef);
            }];
            NSArray * ges=[self.superview gestureRecognizers];
            for(UIGestureRecognizer * recognizer in ges){
                recognizer.enabled=YES;
            }
            ges=[self gestureRecognizers];
            for(UIGestureRecognizer * recognizer in ges){
                recognizer.enabled=YES;
            }
            [self setNeedsDisplay];
            if([_linkType isEqualToString:MatchParserLinkTypeUrl]){
                if(self.wh_delegate&&[self.wh_delegate respondsToSelector:@selector(coreLabel:linkClick:)]){
                    [self.wh_delegate coreLabel:self linkClick:_linkStr];
                }
            }else if ([_linkType isEqualToString:MatchParserLinkTypePhone]){
                if(self.wh_delegate&&[self.wh_delegate respondsToSelector:@selector(coreLabel:phoneClick:)]){
                    [self.wh_delegate coreLabel:self phoneClick:_linkStr];
                }
            }else if ([_linkType isEqualToString:MatchParserLinkTypeMobie]){
                if(self.wh_delegate&&[self.wh_delegate respondsToSelector:@selector(coreLabel:phoneClick:)]){
                    [self.wh_delegate coreLabel:self phoneClick:_linkStr];
                }
            }
            return;
        }
    }
    [super touchesEnded:touches withEvent:event];
}


#pragma -mark 回调方法

- (void)actionSheet:(WH_JXActionSheet_WHVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    self.backgroundColor=[UIColor clearColor];
    if(index==0){
        if([self.wh_match.source isKindOfClass:[NSString  class]]){
            [UIPasteboard generalPasteboard].string=self.wh_match.source;
        }
    }
}


- (void)sp_getMediaData {
    NSLog(@"Get User Succrss");
}
-(void)setAText:(NSAttributedString *)text
{
    [super setAttributedText:text];
}
@end
