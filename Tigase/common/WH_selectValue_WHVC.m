//
//  WH_selectValue_WHVC.m
//  sjvodios
//
//  Created by  on 19-5-5-29.
//  Copyright (c) 2019年 __APP__. All rights reserved.
//

#import "WH_selectValue_WHVC.h"


@implementation WH_selectValue_WHVC

@synthesize values;
@synthesize selected;
@synthesize delegate;
@synthesize didSelect;
@synthesize selValue;
@synthesize numbers;
@synthesize selNumber;

- (id)init
{
    self = [super init];
    if (self) {
        if(numbers)
            selected = (int)[numbers indexOfObject:[NSNumber numberWithInt:selNumber]];

        self.title = Localized(@"WaHu_selectValue_WaHuVC_SelOne");
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        //self.view.frame = g_window.bounds;
        self.wh_isGotoBack = YES;
        [self createHeadAndFoot];
        self.wh_tableBody.backgroundColor = [UIColor whiteColor];
        
        UIButton* btn;
        int h=9;h1=38;
        int w=JX_SCREEN_WIDTH-9*2;
        
        NSString* s;
        for(int i=0;i<[values count];i++){
            if(i==[values count]-1)
                s = @"set_list_down";
            else
                s = @"set_list_up";
            
            btn = [self WH_createMiXinButton:i bkImg:s];
            btn.frame = CGRectMake(9, h, w, h1);
            h+=btn.frame.size.height;
        }

        h+=9;
        if(!self.quickSelect){
            btn = [UIFactory WH_create_WHButtonWithTitle:Localized(@"JX_Finish")
                                         titleFont:sysFontWithSize(15)
                                        titleColor:[UIColor whiteColor]
                                            normal:@"button_orange"
                                         highlight:@"button_orange_press" ];
            [btn addTarget:self action:@selector(onFinish) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake(9, h, w, h1);
            [self.wh_tableBody addSubview:btn];
            h+=btn.frame.size.height;
        }
        if (self.wh_tableBody.frame.size.height < h) {
            self.wh_tableBody.contentSize = CGSizeMake(self_width, h);
        }
        if(h>JX_SCREEN_HEIGHT-JX_SCREEN_TOP)
            self.wh_tableBody.scrollEnabled = YES;
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"WH_selectValue_WHVC.dealloc");
    self.values = nil;
    self.selValue = nil;
    self.numbers = nil;
//    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(UIButton*)WH_createMiXinButton:(int)n bkImg:(NSString*)bkImg{
    NSString* s= [bkImg stringByAppendingString:@"_press"];
    
    UIButton* btn = [UIFactory WH_create_WHButtonWithTitle:nil titleFont:nil titleColor:nil normal:bkImg highlight:s selected:s];
    [btn addTarget:self action:@selector(onSelect:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = n;
    [self.wh_tableBody addSubview:btn];
    
    UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, JX_SCREEN_WIDTH-9*2-8*2-20, h1)];
    p.text = [values objectAtIndex:n];
    p.font = sysFontWithSize(15);
    p.textColor = [UIColor blackColor];
    [btn addSubview:p];
//    [p release];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, p.frame.size.height - .5, JX_SCREEN_WIDTH, .5)];
    line.backgroundColor = HEXCOLOR(0xdcdcdc);
    [btn addSubview:line];
    
    
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-9*2-5-20, 9, 20, 20)];
    iv.image = [UIImage imageNamed:@"icon_selected"];
    iv.tag = -n-1;
    [btn addSubview:iv];
//    [iv release];
        iv.hidden = n != selected;
    return btn;
}

-(void)onSelect:(UIButton*)sender{
    UIView* p = [self.wh_tableBody viewWithTag:-selected-1];
    p.hidden = YES;
    p = nil;

    [sender viewWithTag:-sender.tag-1].hidden = NO;
    selected = (int)sender.tag;

    if(self.quickSelect)
        [self onFinish];
}

-(void)getValuesfromArray:(NSArray*)a name:(NSString*)name{
    self.values = [[NSMutableArray alloc]init];
    for(int i=0;i<[a count];i++){
        NSDictionary* p = [a objectAtIndex:i];
        [values addObject:[p objectForKey:name]];
        p = nil;
    }
}

-(void)onFinish{
    if(selected>=[self.values count] || selected == NSNotFound)
        return;
    self.selNumber = [[numbers objectAtIndex:selected] intValue];
    self.selValue = [values objectAtIndex:selected];
    if (delegate && [delegate respondsToSelector:didSelect]) {
//		[delegate performSelector:didSelect withObject:self];
        [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
	}
    [self actionQuit];
}

@end
