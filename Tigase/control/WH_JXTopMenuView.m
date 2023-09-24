//
//  WH_JXTopMenuView.m
//  sjvodios
//
//  Created by daxiong on 13-4-17.
//
//

#import "WH_JXTopMenuView.h"
#import "WH_JXBadgeView.h"

@implementation WH_JXTopMenuView
@synthesize wh_delegate,wh_items,wh_arrayBtns,wh_selected;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        for(int i=0;i<MAX_MENU_ITEM;i++)
            _showMore[i] = 0;
        self.backgroundColor = [UIColor clearColor];
        int width=frame.size.width/[wh_items count];
        self.userInteractionEnabled = YES;
        
        wh_arrayBtns = [[NSMutableArray alloc]init];
        arrayBage = [[NSMutableArray alloc]init];
        UIButton* btn;
        
        int i;
        for(i=0;i<[wh_items count];i++){
            btn = [UIFactory WH_create_WHButtonWithTitle:[wh_items objectAtIndex:i]
                                         titleFont:sysFontWithSize(13)
                                        titleColor:HEXCOLOR(0x2d2f32)
                                            normal:@"menu_bg"
                                          highlight:@"menu_bg_press"
                                          selected:@"menu_bg_bingo"];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            btn.frame = CGRectMake(i*width, 0, width, frame.size.height);
            [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            [self addSubview:btn];
            [wh_arrayBtns addObject:btn];

            WH_JXBadgeView* p = [[WH_JXBadgeView alloc] initWithFrame:CGRectMake(btn.frame.size.width-16-2, 2, g_factory.badgeWidthHeight, g_factory.badgeWidthHeight)];
            p.wh_badgeString  = nil;
            p.userInteractionEnabled = NO;
            [btn addSubview:p];
//            [p release];
            
            [arrayBage addObject:p];
        }
    }
    return self;
}

-(void)dealloc{
    [arrayBage removeAllObjects];
    [wh_arrayBtns removeAllObjects];
//    [arrayBage release];
//    [arrayBtns release];
//    [items release];
//    [super dealloc];
}

-(void)onClick:(UIButton*)sender{
    [self WH_unSelectAll];
    sender.selected = YES;


//    NSLog(@"%d",sender.tag);
    wh_selected = (int)sender.tag;
	if(self.wh_delegate != nil && [self.wh_delegate respondsToSelector:self.wh_onClick])
		[self.wh_delegate performSelectorOnMainThread:self.wh_onClick withObject:sender waitUntilDone:NO];
}

-(void)WH_unSelectAll{
    for(int i=0;i<[wh_arrayBtns count];i++)
        ((UIButton*)[wh_arrayBtns objectAtIndex:i]).selected = NO;
    wh_selected = -1;
}

-(void)WH_selectOne:(int)n{
    [self WH_unSelectAll];
    if(n >= [self.wh_arrayBtns count]-1 || n<0)
        return;
    ((UIButton*)[self.wh_arrayBtns objectAtIndex:n]).selected=YES;
    wh_selected = n;
}

-(void)WH_setTitle:(int)n title:(NSString*)s{
    if(n >= [self.wh_arrayBtns count])
        return;
    [[self.wh_arrayBtns objectAtIndex:n] setTitle:s forState:UIControlStateNormal];
}

-(void)WH_setBadge:(int)n title:(NSString*)s{
    if(n >= [self.wh_arrayBtns count])
        return;
    [[arrayBage objectAtIndex:n] setWh_badgeString:s];
}

-(void)WH_showMore:(int)index onSelected:(SEL)onSelected{
    if(index >= [self.wh_arrayBtns count])
        return;
    _showMore[index] = 1;
    UIButton* more = [UIFactory WH_create_WHButtonWithImage:@"menu_normal"
                                 highlight:@"menu_press"
                                target:wh_delegate
                                  selector:onSelected];
    more.frame = CGRectMake(self.frame.size.width/[wh_items count]-25, 17, 10, 10);
    UIButton* btn = [self.wh_arrayBtns objectAtIndex:index];
    [btn addSubview:more];
}

@end
