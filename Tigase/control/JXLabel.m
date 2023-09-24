//
//  JXLabel.m
//  sjvodios
//
//  Created by  on 19-5-2-1.
//  Copyright (c) 2019年 __APP__. All rights reserved.
//

#import "JXLabel.h"

@interface JXLabel ()

@property (nonatomic, assign) BOOL isAction; // 防止重复点击

@end

@implementation JXLabel

@synthesize wh_delegate;
@synthesize didTouch;
@synthesize wh_changeAlpha,wh_line;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        wh_changeAlpha = NO;
        wh_line = 0;
        _isAction = NO;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //[super touchesBegan: touches withEvent: event];
    if(wh_changeAlpha)
        self.alpha = 0.5;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"touchesMoved");
    [super touchesMoved: touches withEvent: event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //[super touchesEnded: touches withEvent: event];
    if(wh_changeAlpha)
        self.alpha = 1;
    
    if (self.isAction) {
        return;
    }
    self.isAction = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isAction = NO;
    });
    
    BOOL inside = YES;
    for(int i=0;i<[touches count];i++){
        CGPoint p = [[[touches allObjects] objectAtIndex:i] locationInView:self];
//        NSLog(@"%d=%f,%f",i,p.x,p.y);
        if(p.x<0 || p.y <0){
            inside = NO;
            break;
        }
        if(p.x>self.frame.size.width || p.y>self.frame.size.height){
            inside = NO;
            break;
        }
    }
    if(!inside)
        return;
	if(self.wh_delegate != nil && [self.wh_delegate respondsToSelector:self.didTouch])
		[self.wh_delegate performSelectorOnMainThread:self.didTouch withObject:self waitUntilDone:NO];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    //[super touchesCancelled: touches withEvent: event];
    if(wh_changeAlpha)
        self.alpha = 1;
}

- (void)dealloc
{
    wh_delegate = nil;
    didTouch = nil;
    //[_wh_delegate release];
//    [super dealloc];
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if(wh_line>0){
        CGContextRef ctx = UIGraphicsGetCurrentContext();
//        CGSize fontSize =[self.text sizeWithFont:self.font
//                                        forWidth:self.bounds.size.width
//                                   wh_lineBreakMode:UIwh_lineBreakModeTailTruncation];
        CGSize fontSize = [self.text boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
        
        // Get the fonts color.
        const CGFloat * colors = CGColorGetComponents(self.textColor.CGColor);
        // Sets the color to draw the wh_line
        CGContextSetRGBStrokeColor(ctx, colors[0], colors[1], colors[2], wh_line); // Format : RGBA
        
        [self.textColor set];
        
        // wh_line Width : make thinner or bigger if you want
        CGContextSetLineWidth(ctx, wh_line);
        
        // Calculate the starting point (left) and target (right)
        CGPoint l,r;
        if (self.textAlignment == NSTextAlignmentLeft) {
            l = CGPointMake(0, self.frame.size.height/2.0 +fontSize.height/2.0);
            r = CGPointMake(fontSize.width/2.0, self.frame.size.height/2.0 + fontSize.height/2.0);
        }else if (self.textAlignment == NSTextAlignmentRight) {
            l = CGPointMake(self.frame.size.width - fontSize.width,
                            self.frame.size.height/2.0 +fontSize.height/2.0);
            r = CGPointMake(self.frame.size.width,
                            self.frame.size.height/2.0 + fontSize.height/2.0);
        }else if (self.textAlignment == NSTextAlignmentCenter) {
            l = CGPointMake(self.frame.size.width/2.0 - fontSize.width/2.0,
                            self.frame.size.height/2.0 + fontSize.height/2.0);
            r = CGPointMake(self.frame.size.width/2.0 + fontSize.width/2.0,
                            self.frame.size.height/2.0 + fontSize.height/2.0);
        }
        
        // Add Move Command to point the draw cursor to the starting point
        CGContextMoveToPoint(ctx, l.x, l.y);
        
        // Add Command to draw a wh_line
        CGContextAddLineToPoint(ctx, r.x, r.y);
        
        
        // Actually draw the wh_line.
        CGContextStrokePath(ctx);
        
        // should be nothing, but who knows...
//            [super drawRect:rect];
    }
}


- (void)setDidTouch:(SEL)value {
    if(value){
        didTouch = value;
        wh_changeAlpha = YES;
        self.userInteractionEnabled = YES;
    }
}

@end
