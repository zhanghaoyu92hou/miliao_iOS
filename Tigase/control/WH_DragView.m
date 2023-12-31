//
//  WMDragView.m
//  WMDragView
//
//  Created by zhengwenming on 2016/12/16.
//
//

#import "WH_DragView.h"

@interface WH_DragView ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIView *contentViewForDrag;

/**
 内容view，命名为contentViewForDrag，因为很多其他开源的第三方的库，里面同样有contentView这个属性
 ，这里特意命名为contentViewForDrag以防止冲突
 */
@property (nonatomic,assign) CGPoint startPoint;
@property (nonatomic,strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic,assign) CGFloat previousScale;
@end

@implementation WH_DragView
-(UIImageView *)wh_imageView{
    if (_wh_imageView==nil) {
        _wh_imageView = [[UIImageView alloc]init];
        _wh_imageView.userInteractionEnabled = YES;
        _wh_imageView.clipsToBounds = YES;
        [self.contentViewForDrag addSubview:_wh_imageView];
    }
    return _wh_imageView;
}
-(UIButton *)wh_button{
    if (_wh_button==nil) {
        _wh_button = [UIButton buttonWithType:UIButtonTypeCustom];
        _wh_button.clipsToBounds = YES;
        _wh_button.userInteractionEnabled = NO;
        [self.contentViewForDrag addSubview:_wh_button];
    }
    return _wh_button;
}
-(UIView *)contentViewForDrag{
    if (_contentViewForDrag==nil) {
        _contentViewForDrag = [[UIView alloc]init];
        _contentViewForDrag.clipsToBounds = YES;
    }
    return _contentViewForDrag;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.contentViewForDrag];
        [self setUp];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.wh_freeRect.origin.x!=0||self.wh_freeRect.origin.y!=0||self.wh_freeRect.size.height!=0||self.wh_freeRect.size.width!=0) {
        //设置了freeRect--活动范围
    }else{
        //没有设置freeRect--活动范围，则设置默认的活动范围为父视图的frame
        self.wh_freeRect = (CGRect){CGPointZero,self.superview.bounds.size};
    }
    _wh_imageView.frame = (CGRect){CGPointZero,self.bounds.size};
    _wh_button.frame = (CGRect){CGPointZero,self.bounds.size};
    self.contentViewForDrag.frame =  (CGRect){CGPointZero,self.bounds.size};
}
-(void)setUp{
    self.wh_dragEnable = YES;//默认可以拖曳
    self.clipsToBounds = YES;
    self.wh_isKeepBounds = NO;
    self.backgroundColor = [UIColor lightGrayColor];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDragView)];
    [self addGestureRecognizer:singleTap];
    
    //添加移动手势可以拖动
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAction:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
}
//-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    return self.dragEnable;
//}
/**
 拖动事件
 @param pan 拖动手势
 */
-(void)dragAction:(UIPanGestureRecognizer *)pan{
    if(self.wh_dragEnable==NO)return;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{//开始拖动
            if (self.wh_beginDragBlock) {
                self.wh_beginDragBlock(self);
            }
            //注意完成移动后，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self];
            //保存触摸起始点位置
            self.startPoint = [pan translationInView:self];
            break;
        }
        case UIGestureRecognizerStateChanged:{//拖动中
            //计算位移 = 当前位置 - 起始位置
            if (self.wh_duringDragBlock) {
                self.wh_duringDragBlock(self);
            }
            CGPoint point = [pan translationInView:self];
            float dx;
            float dy;
            switch (self.wh_dragDirection) {
                case WMDragDirectionAny:
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
                case WMDragDirectionHorizontal:
                    dx = point.x - self.startPoint.x;
                    dy = 0;
                    break;
                case WMDragDirectionVertical:
                    dx = 0;
                    dy = point.y - self.startPoint.y;
                    break;
                default:
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
            }
            
            //计算移动后的view中心点
            CGPoint newCenter = CGPointMake(self.center.x + dx, self.center.y + dy);
            //移动view
            self.center = newCenter;
            //  注意完成上述移动后，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self];
            break;
        }
        case UIGestureRecognizerStateEnded:{//拖动结束
            [self keepBounds];
            if (self.wh_endDragBlock) {
                self.wh_endDragBlock(self);
            }
            break;
        }
        default:
            break;
    }
}
//点击事件
-(void)clickDragView{
    if (self.wh_clickDragViewBlock) {
        self.wh_clickDragViewBlock(self);
    }
}
//黏贴边界效果
- (void)keepBounds{
    //中心点判断
    float centerX = self.wh_freeRect.origin.x+(self.wh_freeRect.size.width - self.frame.size.width)/2;
    CGRect rect = self.frame;
    if (self.wh_isKeepBounds==NO) {//没有黏贴边界的效果
        if (self.frame.origin.x < self.wh_freeRect.origin.x) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.wh_freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
        } else if(self.wh_freeRect.origin.x+self.wh_freeRect.size.width < self.frame.origin.x+self.frame.size.width){
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.wh_freeRect.origin.x+self.wh_freeRect.size.width-self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
        }
    }else if(self.wh_isKeepBounds==YES){//自动粘边
        if (self.frame.origin.x< centerX) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.wh_freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
        } else {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x =self.wh_freeRect.origin.x+self.wh_freeRect.size.width - self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
        }
    }
    
    if (self.frame.origin.y < self.wh_freeRect.origin.y) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"topMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.wh_freeRect.origin.y;
        self.frame = rect;
        [UIView commitAnimations];
    } else if(self.wh_freeRect.origin.y+self.wh_freeRect.size.height< self.frame.origin.y+self.frame.size.height){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"bottomMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.wh_freeRect.origin.y+self.wh_freeRect.size.height-self.frame.size.height;
        self.frame = rect;
        [UIView commitAnimations];
    }
}
@end
