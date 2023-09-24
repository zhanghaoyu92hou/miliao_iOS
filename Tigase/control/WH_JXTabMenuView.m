//
//  WH_JXTabMenuView.m
//  sjvodios
//
//  Created by daxiong on 13-4-17.
//
//

#import "WH_JXTabMenuView.h"
#import "JXLabel.h"
#import "JXTabButton.h"

@implementation WH_JXTabMenuView
@synthesize wh_delegate,wh_items,wh_height,wh_selected,wh_imagesNormal,wh_imagesSelect,wh_onClick,wh_backgroundImageName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int width = JX_SCREEN_WIDTH/[wh_items count];
        wh_height    = 49;
        self.backgroundColor = [UIColor whiteColor];
        
        self.userInteractionEnabled = YES;
//        self.image = [UIImage imageNamed:backgroundImageName];

        _arrayBtns = [[NSMutableArray alloc]init];
        
        int i;
        for(i=0;i<[wh_items count];i++){
            CGRect r = CGRectMake(width*i, 7, width, wh_height);
            JXTabButton *btn = [JXTabButton buttonWithType:UIButtonTypeCustom];
            btn.wh_iconName = [wh_imagesNormal objectAtIndex:i];
            btn.wh_selectedIconName = [wh_imagesSelect objectAtIndex:i];
            btn.wh_text  = [wh_items objectAtIndex:i];
            [btn.titleLabel setFont:pingFangRegularFontWithSize(10)];
            btn.wh_textColor = HEXCOLOR(0xBAC3D5);
            btn.wh_selectedTextColor = HEXCOLOR(0x0093FF);
            btn.wh_delegate  = self.wh_delegate;
            btn.wh_onDragout = self.wh_onDragout;
//            if(i==1)
//                btn.bage = @"1";
            btn.frame = r;
            btn.tag = i;
            if ((wh_onClick != nil) && (wh_delegate != nil))
                [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn show];
            [self addSubview:btn];
            [_arrayBtns addObject:btn];
        }

        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [self addSubview:line];
//        [line release];
    }
    return self;
}

-(void)dealloc{
//    [_arrayBtns release];
//    [items release];
//    [super dealloc];
}

-(void)onClick:(JXTabButton*)sender{
    [self wh_unSelectAll];
    sender.selected = YES;
    self.wh_selected = sender.tag;
	if(self.wh_delegate != nil && [self.wh_delegate respondsToSelector:self.wh_onClick])
		[self.wh_delegate performSelectorOnMainThread:self.wh_onClick withObject:sender waitUntilDone:NO];
}

-(void)wh_unSelectAll{
    for(int i=0;i<[_arrayBtns count];i++){
        ((JXTabButton*)[_arrayBtns objectAtIndex:i]).selected = NO;
    }
    wh_selected = -1;
}

-(void)wh_selectOne:(int)n{
    [self wh_unSelectAll];
    if(n >= [_arrayBtns count])
        return;
    ((JXTabButton*)[_arrayBtns objectAtIndex:n]).selected=YES;
    wh_selected = n;
}

-(void)wh_setTitle:(int)n title:(NSString*)s{
    if(n >= [_arrayBtns count])
        return;
    [[_arrayBtns objectAtIndex:n] setTitle:s forState:UIControlStateNormal];
}

-(void)wh_setBadge:(int)n title:(NSString*)s{
    if(n >= [_arrayBtns count])
        return;
    JXTabButton *btn = [_arrayBtns objectAtIndex:n];
    btn.wh_bage = s;
    btn = nil;
}

@end
