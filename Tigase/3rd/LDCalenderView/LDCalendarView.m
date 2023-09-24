//
//  LDCalendarView.m
//
//  Created by lidi on 15/9/1.
//  Copyright (c) 2015年 lidi. All rights reserved.
//

#import "LDCalendarView.h"
#import "NSDate+Extend.h"
#import "UIColor+Extend.h"
//#import "funViewModel.h"
//#import "MonthSignatureModel.h"
//#import "MBProgressHUD+NHAdd.h"
#define UNIT_WIDTH  35 * SCREEN_RAT
#define UIColorFromRGBA(rgbValue , a) [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((CGFloat)(rgbValue & 0xFF)) / 255.0 alpha:a]
#define UIColorFromRGB(rgbValue) UIColorFromRGBA(rgbValue , 1.0)

//行 列 每小格宽度 格子总数
static const NSInteger kRow         = 1 + 6;//一,二,三... 1行 日期6行
static const NSInteger kCol         = 7;
static const NSInteger kTotalNum    = (kRow ) * kCol;
static const NSInteger kBtnStartTag = 100;

@interface LDCalendarView()
//UI
@property (nonatomic, strong) UIView         *contentBgView,*dateBgView;
@property (nonatomic, strong) UILabel        *titleLab;//标题
@property (nonatomic, strong) UIView         *tipView;  //顶部视图
@property (nonatomic, strong) UIView         *tipView1;  //顶部视图红
@property (nonatomic, strong) UIView         *tipView2;  //顶部视图白
@property (nonatomic, strong) UILabel        *tipLbl;
@property (nonatomic, strong) UIButton       *doneBtn;//确定按钮
@property (nonatomic, strong) UIButton       *closeBtn;
//Data
@property (nonatomic, assign) int32_t        year,month;
@property (nonatomic, strong) NSDate         *today,*firstDay; //今天 当月第一天
@property (nonatomic, strong) NSMutableArray *currentMonthDaysArray,*selectArray;
@property (nonatomic, assign) CGRect         touchRect;//可操作区域
@end

@implementation LDCalendarView
- (NSDate *)today {
    if (!_today) {
        NSDate *currentDate = [NSDate date];

        //字符串转换为日期,今天0点的时间
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        _today = [dateFormat dateFromString:[NSString stringWithFormat:@"%@-%@-%@",@(currentDate.year),@(currentDate.month),@(currentDate.day)]];
    }
    return _today;
}

- (NSDate *)firstDay {
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *firstDay =[dateFormat dateFromString:[NSString stringWithFormat:@"%@-%@-%@",@(self.year),@(self.month),@(1)]];
    return firstDay;
}
- (NSDate *) convertDate:(NSString *) dateString{
    // 日期格式化类
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    // 设置日期格式 为了转换成功
    format.dateFormat = @"yyyy-MM-dd";
    // NSString * -> NSDate *
    NSDate *data = [format dateFromString:dateString];
    return data;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.dateBgView = ({
            UIView *view         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            view.alpha           = 0.7;
            view.backgroundColor = [UIColor blackColor];
            


            [self addSubview:view];
            
            view;
        });

        self.contentBgView = ({
            //内容区的背景
            UIView        *view         = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-UNIT_WIDTH*kCol)/2.0, 100, UNIT_WIDTH*kCol, 42+UNIT_WIDTH*kRow+50 + 50)];
            view.backgroundColor = [UIColor whiteColor];
            view.layer.cornerRadius     = 10.0;
            view.layer.masksToBounds    = YES;
            view.userInteractionEnabled = YES;
            [self addSubview:view];
            
            view;
        });
        self.closeBtn = ({
            UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_contentBgView.frame) + 29, 100-29/2, 29, 29)];
//            closeBtn.backgroundColor = [UIColor blueColor];
            [closeBtn setImage:[UIImage imageNamed:@"WH_CallenderClose"] forState:UIControlStateNormal];
            closeBtn.layer.masksToBounds = YES;
            closeBtn.layer.cornerRadius = closeBtn.bounds.size.width/2.0;
            [closeBtn addTarget:self action:@selector(closeBtn:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:closeBtn];
            
            closeBtn;
        });
        self.tipView = ({
            UIView *tpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentBgView.frame), 72+60)];
            tpView.backgroundColor = [UIColor whiteColor];
            [_contentBgView addSubview:tpView];
          
            tpView;
        });
        self.tipView1 = ({
            UIView *tpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentBgView.frame), 72)];
            tpView.backgroundColor = UIColorFromRGB(0xFF1C63);
            [_contentBgView addSubview:tpView];
            
            UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_contentBgView.frame)/3.0 - 8 - 10, 72 - 15, 13, 31)];
            [imgView1 setImage:[UIImage imageNamed:@"WH_Callender_FK"]];
            [_contentBgView addSubview:imgView1];
            
            UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_contentBgView.frame)*2/3.0 + 8, 72 - 15, 13, 31)];
            [imgView2 setImage:[UIImage imageNamed:@"WH_Callender_FK"]];
            [_contentBgView addSubview:imgView2];
            
            ({
                UIImageView *leftImage = [UIImageView new];
                leftImage.image        = [UIImage imageNamed:@"callenderLeftArrow"];
                [_contentBgView addSubview:leftImage];
                leftImage.frame        = CGRectMake(CGRectGetWidth(_contentBgView.frame)/3.0 - 8 - 10, 24, 8, 13);
            });
            
            ({
                UIImageView *rightImage = [UIImageView new];
                rightImage.image        = [UIImage imageNamed:@"callenderRightArrow"];
                [_contentBgView addSubview:rightImage];
                rightImage.frame        = CGRectMake(CGRectGetWidth(_contentBgView.frame)*2/3.0 + 8, 24, 8, 13);
            });
            
            tpView;
        });
        self.tipLbl = ({
            UILabel *tpLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tipView1.frame) + 20, CGRectGetWidth(_contentBgView.frame), 20)];
            tpLbl.textAlignment = NSTextAlignmentCenter;
            tpLbl.textColor = UIColorFromRGB(0xFF1C63);
            tpLbl.text = [NSString stringWithFormat:@"%@%lu%@", Localized(@"你已累计签到"),(unsigned long)self.dateList.count,@"天"];
            tpLbl.font = [UIFont systemFontOfSize:15.0];
            [_contentBgView addSubview:tpLbl];
            
            tpLbl;
        });
        
        self.titleLab = ({
            UILabel *lab               = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, CGRectGetWidth(_contentBgView.frame), 16)];
            lab.backgroundColor        = [UIColor clearColor];
            lab.textColor              = [UIColor whiteColor];
            lab.font                   = [UIFont systemFontOfSize:14];
            lab.textAlignment          = NSTextAlignmentCenter;
            lab.userInteractionEnabled = YES;
            [_contentBgView addSubview:lab];
            
            ({
                UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchMonthTap:)];
                [lab addGestureRecognizer:titleTap];
                
//                UIView *line         = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lab.frame) - 0.5, CGRectGetWidth(_contentBgView.frame), 0.5)];
//                line.backgroundColor = [UIColor hexColorWithString:@"dddddd"];
//                [_contentBgView addSubview:line];
            });
            
            lab;
        });
        
        self.dateBgView = ({
            UIView *view                = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_tipView.frame), CGRectGetWidth(_contentBgView.frame), UNIT_WIDTH*kRow)];
            view.userInteractionEnabled = YES;
            view.backgroundColor        = [UIColor whiteColor];
            view.layer.cornerRadius     = 10.0;
            [_contentBgView addSubview:view];
            
            ({
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
                [view addGestureRecognizer:tap];
            });
            view;
        });
        
        [self initData];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame roomId:(NSString *)roomId {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.roomId = roomId;
        self.isGroupSignIn = YES;
        
        self.dateBgView = ({
            UIView *view         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            view.alpha           = 0.7;
            view.backgroundColor = [UIColor blackColor];
            
            
            
            [self addSubview:view];
            
            view;
        });
        
        self.contentBgView = ({
            //内容区的背景
            UIView        *view         = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-UNIT_WIDTH*kCol)/2.0, 100, UNIT_WIDTH*kCol, 42+UNIT_WIDTH*kRow+50 + 50)];
            view.backgroundColor = [UIColor whiteColor];
            view.layer.cornerRadius     = 10.0;
            view.layer.masksToBounds    = YES;
            view.userInteractionEnabled = YES;
            [self addSubview:view];
            
            view;
        });
        self.closeBtn = ({
            UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_contentBgView.frame) + 29, 100-29/2, 29, 29)];
            //            closeBtn.backgroundColor = [UIColor blueColor];
            [closeBtn setImage:[UIImage imageNamed:@"WH_CallenderClose"] forState:UIControlStateNormal];
            closeBtn.layer.masksToBounds = YES;
            closeBtn.layer.cornerRadius = closeBtn.bounds.size.width/2.0;
            [closeBtn addTarget:self action:@selector(closeBtn:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:closeBtn];
            
            closeBtn;
        });
        self.tipView = ({
            UIView *tpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentBgView.frame), 72+60)];
            tpView.backgroundColor = [UIColor whiteColor];
            [_contentBgView addSubview:tpView];
            
            tpView;
        });
        self.tipView1 = ({
            UIView *tpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentBgView.frame), 72)];
            tpView.backgroundColor = UIColorFromRGB(0xFF1C63);
            [_contentBgView addSubview:tpView];
            
            UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_contentBgView.frame)/3.0 - 8 - 10, 72 - 15, 13, 31)];
            [imgView1 setImage:[UIImage imageNamed:@"WH_Callender_FK"]];
            [_contentBgView addSubview:imgView1];
            
            UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_contentBgView.frame)*2/3.0 + 8, 72 - 15, 13, 31)];
            [imgView2 setImage:[UIImage imageNamed:@"WH_Callender_FK"]];
            [_contentBgView addSubview:imgView2];
            
            ({
                UIImageView *leftImage = [UIImageView new];
                leftImage.image        = [UIImage imageNamed:@"callenderLeftArrow"];
                [_contentBgView addSubview:leftImage];
                leftImage.frame        = CGRectMake(CGRectGetWidth(_contentBgView.frame)/3.0 - 8 - 10, 24, 8, 13);
            });
            
            ({
                UIImageView *rightImage = [UIImageView new];
                rightImage.image        = [UIImage imageNamed:@"callenderRightArrow"];
                [_contentBgView addSubview:rightImage];
                rightImage.frame        = CGRectMake(CGRectGetWidth(_contentBgView.frame)*2/3.0 + 8, 24, 8, 13);
            });
            
            tpView;
        });
        self.tipLbl = ({
            UILabel *tpLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tipView1.frame) + 20, CGRectGetWidth(_contentBgView.frame), 20)];
            tpLbl.textAlignment = NSTextAlignmentCenter;
            tpLbl.textColor = UIColorFromRGB(0xFF1C63);
            tpLbl.text = [NSString stringWithFormat:@"%@%lu%@", Localized(@"你已累计签到"),(unsigned long)self.dateList.count,Localized(@"天")];
            tpLbl.font = [UIFont systemFontOfSize:15.0];
            [_contentBgView addSubview:tpLbl];
            
            tpLbl;
        });
        
        self.titleLab = ({
            UILabel *lab               = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, CGRectGetWidth(_contentBgView.frame), 16)];
            lab.backgroundColor        = [UIColor clearColor];
            lab.textColor              = [UIColor whiteColor];
            lab.font                   = [UIFont systemFontOfSize:14];
            lab.textAlignment          = NSTextAlignmentCenter;
            lab.userInteractionEnabled = YES;
            [_contentBgView addSubview:lab];
            
            ({
                UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchMonthTap:)];
                [lab addGestureRecognizer:titleTap];
                
                //                UIView *line         = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lab.frame) - 0.5, CGRectGetWidth(_contentBgView.frame), 0.5)];
                //                line.backgroundColor = [UIColor hexColorWithString:@"dddddd"];
                //                [_contentBgView addSubview:line];
            });
            
            lab;
        });
        
        self.dateBgView = ({
            UIView *view                = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_tipView.frame), CGRectGetWidth(_contentBgView.frame), UNIT_WIDTH*kRow)];
            view.userInteractionEnabled = YES;
            view.backgroundColor        = [UIColor whiteColor];
            view.layer.cornerRadius     = 10.0;
            [_contentBgView addSubview:view];
            
            ({
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
                [view addGestureRecognizer:tap];
            });
            view;
        });
        
        [self initData];
    }
    return self;
}

- (void)initData {
    _selectArray        = @[].mutableCopy;

    //获取当前年月
    NSDate *currentDate = [NSDate date];
    self.month          = (int32_t)currentDate.month;
    self.year           = (int32_t)currentDate.year;
    [self refreshDateTitle];

    _currentMonthDaysArray = [NSMutableArray array];
    for (int i = 0; i < kTotalNum; i++) {
        [_currentMonthDaysArray addObject:@(0)];
    }
    
    [self showDateView];
}

- (void)switchMonthTap:(UITapGestureRecognizer *)tap {
   CGPoint loc =  [tap locationInView:_titleLab];
    CGFloat titleLabWidth = CGRectGetWidth(_titleLab.frame);
    if (loc.x <= titleLabWidth/3.0) {
        [self leftSwitch];
    }else if(loc.x >= titleLabWidth/3.0*2.0){
        [self rightSwitch];
    }
}

- (void)leftSwitch{
    if (self.month > 1) {
        self.month -= 1;
    }else {
        self.month = 12;
        self.year -= 1;
    }
    
    [self refreshDateTitle];
}

- (void)rightSwitch {
    if (self.month < 12) {
        self.month += 1;
    }else {
        self.month = 1;
        self.year += 1;
    }
    
    [self refreshDateTitle];
}

- (void)refreshDateTitle {
    _titleLab.text = [NSString stringWithFormat:@"%@-%@",@(self.year),@(self.month)];
    [self requestMonth:[NSString stringWithFormat:@"%@-%@",@(self.year),@(self.month)]];
    [self showDateView];
}

- (void)drawTitleView {
    CGRect baseRect = CGRectMake(0.0,0.0, UNIT_WIDTH, UNIT_WIDTH);
    NSArray *tmparr = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
    for(int i = 0 ;i < 7; i++)
    {
        UILabel *lab        = [[UILabel alloc] initWithFrame:baseRect];
        lab.textColor       = [UIColor blackColor];
        lab.textAlignment   = NSTextAlignmentCenter;
        lab.font            = [UIFont systemFontOfSize:16];
        lab.backgroundColor = [UIColor clearColor];
        lab.text            = [tmparr objectAtIndex:i];
        [_dateBgView addSubview:lab];
        
        baseRect.origin.x   += baseRect.size.width;
    }
}

- (CGFloat)calculateStartIndex:(NSDate *)firstDay {
    CGFloat startDayIndex = [NSDate acquireWeekDayFromDate:firstDay];
    //第一天是今天，特殊处理
    if (startDayIndex == 1) {
        //星期天（对应一）
        startDayIndex = 0;
//        startDayIndex = 2;
    }else {
//        周一到周六（对应2-7）
        startDayIndex -= 1;
//        startDayIndex;
    }
   return startDayIndex ;
}

- (void)createBtn:(NSInteger)i frame:(CGRect)baseRect {
    UIButton *btn              = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag                    = kBtnStartTag + i;
    [btn setFrame:CGRectMake(baseRect.origin.x + 3.5, baseRect.origin.y + 3.5, 28, 28)];
    btn.userInteractionEnabled = NO;
    btn.backgroundColor        = [UIColor clearColor];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    btn.layer.masksToBounds = true;
    btn.layer.cornerRadius = btn.frame.size.width/2.0;
    CGFloat startDayIndex = [self calculateStartIndex:self.firstDay];
    NSDate * date = [self.firstDay dateByAddingTimeInterval: (i - startDayIndex)*24*60*60];
    _currentMonthDaysArray[i] = @([date timeIntervalSince1970]);
    NSString *title = INTTOSTR(date.day);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSInteger year=[components year];
    NSInteger month=[components month];
//    NSInteger day = [components day];
    NSInteger totalDay = [self getDaysInMonth:year month:month];
    
    NSInteger currentTotalDay = [self getDaysInMonth:self.year month:self.month];
//    NSLog(@"%ld %ld",day,i- 7);
    if (totalDay != currentTotalDay || self.month != month || self.year != year){
        return;
    }
//    if (totalDay < day){
//        return;
//    }
    if ([self.today compare:date] < 0) {
        //时间比今天大,同时是当前月
        [btn setTitleColor:[UIColor hexColorWithString:@"2b2b2b"] forState:UIControlStateNormal];
    }else {
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor hexColorWithString:@"bfbfbf"] forState:UIControlStateNormal];
    }
//    if ([self isSignature:date]){
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        btn.backgroundColor = UIColorFromRGB(0xCACDCF);
//    }else
    {
        if ([date isToday]) {
//        title = @"今天";
//        btn.layer.borderColor = [UIColor hexColorWithString:@"f49e79"].CGColor;
//        btn.layer.borderWidth = 0.5;
     
        btn.backgroundColor = UIColorFromRGB(0xFABD00);
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else if(date.day == 1) {
        }}
    
    [btn setTitle:title forState:UIControlStateNormal];
    [self monthSignature:btn date:date];
    [_dateBgView addSubview:btn];
}
- (void) monthSignature:(UIButton *) btn date:(NSDate *) date{
    if([self isSignature:date]){
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.backgroundColor = UIColorFromRGB(0xCACDCF);
    }
}
- (void)showDateView {
    //移除之前子视图
    [_dateBgView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    //一，二，三，四...
    [self drawTitleView];

    CGFloat startDayIndex       = [self calculateStartIndex:self.firstDay];
    CGRect baseRect             = CGRectMake(UNIT_WIDTH * startDayIndex,UNIT_WIDTH, UNIT_WIDTH, UNIT_WIDTH);
    //设置触摸区域
    self.touchRect = ({
        CGRect rect = CGRectZero;
        rect.origin      = baseRect.origin;
        rect.origin.x    = 0;
        rect.size.width  = kCol * UNIT_WIDTH;
        rect.size.height = kRow * UNIT_WIDTH;
        
        rect;
    });
    
    for(int i = startDayIndex; i < kTotalNum;i++) {
        //需要换行且不在第一行
        if (i % kCol == 0 && i != 0) {
            baseRect.origin.y += (baseRect.size.height);
            baseRect.origin.x = 0.0;
        }
        
        [self createBtn:i frame:baseRect];

        baseRect.origin.x += (baseRect.size.width);
    }
    
    //高亮选中的
    [self refreshDateView];
}

- (void)setDefaultDays:(NSArray *)defaultDays {
    _defaultDays = defaultDays;
    
    if (defaultDays) {
        _selectArray = [defaultDays mutableCopy];
    }else {
        _selectArray = @[].mutableCopy;
    }
}

- (void)refreshDateView {
    for(int i = 0; i < kTotalNum; i++) {
        UIButton *btn = (UIButton *)[_dateBgView viewWithTag:kBtnStartTag + i];
        NSNumber *interval = [_currentMonthDaysArray objectAtIndex:i];

        if (i < [_currentMonthDaysArray count] && btn) {
            if ([_selectArray containsObject:interval]) {
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setBackgroundColor:[UIColor hexColorWithString:@"77d2c5"]];
            }
        }
    }
}

-(void)tap:(UITapGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:_dateBgView];
    if (CGRectContainsPoint(_touchRect, point)) {
//        CGFloat w       = (CGRectGetWidth(_dateBgView.frame)) / kCol;
//        CGFloat h       = (CGRectGetHeight(_dateBgView.frame)) / kRow;
//        int row         = (int)((point.y - _touchRect.origin.y) / h);
//        int col         = (int)((point.x) / w);

    }
}

- (void)clickForIndex:(NSInteger)index
{
    UIButton *btn = (UIButton *)[_dateBgView viewWithTag:kBtnStartTag + index];
    if (index < [_currentMonthDaysArray count]) {
        NSNumber *interval = [_currentMonthDaysArray objectAtIndex:index];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval.doubleValue];
        if ([self.today  compare:date] < 0) {
            //时间比今天大,同时是当前月
        }else {
            return;
        }
        
        if ([_selectArray containsObject:interval]) {
            //已选中,取消
            [_selectArray removeObject:interval];
            [btn setTitleColor:[UIColor hexColorWithString:@"2b2b2b"] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor clearColor]];
        }
        else {
            //未选中,想选择
            [_selectArray addObject:interval];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor hexColorWithString:@"77d2c5"]];
            
            //如果选中的是下个月切换到下个月
            if (date.month > self.month) {
                [self rightSwitch];
            }
        }
    }
}

- (void)doneBtnClick:(id)sender {
    if (_complete) {
        _complete([_selectArray mutableCopy]);
    }
    [self hide];
}

- (void)show {
    self.hidden = NO;
}

- (void)hide {
    self.hidden = YES;
}

#pragma mark 关闭事件
- (void) closeBtn:(id) sender{
    [self removeFromSuperview];
}

-(void) signature:(NSMutableArray *) array{
    self.dateList = array;
    [self showDateView];
}
-(BOOL) isSignature:(NSDate *) date{
    if (_dateList == nil){
        return false;
    }
    
    for (NSDictionary * monthModel in _dateList){
        NSTimeInterval interval    = [[monthModel objectForKey:(self.isGroupSignIn)?@"signInDate":@"signDate"] doubleValue] / 1000.0;
        NSDate *signatureDate = [NSDate dateWithTimeIntervalSince1970:interval];//[self convertDate:monthModel.signDate];
        if ([signatureDate compare:date] == NSOrderedSame) {
            //时间比今天大,同时是当前月
            return TRUE;
        }
    }
    return false;
}

// 获取某年某月总共多少天
- (NSInteger)getDaysInMonth:(NSInteger)year month:(NSInteger)imonth {
    // imonth == 0的情况是应对在CourseViewController里month-1的情况
    if((imonth == 0)||(imonth == 1)||(imonth == 3)||(imonth == 5)||(imonth == 7)||(imonth == 8)||(imonth == 10)||(imonth == 12))
        return 31;
    if((imonth == 4)||(imonth == 6)||(imonth == 9)||(imonth == 11))
        return 30;
    if((year%4 == 1)||(year%4 == 2)||(year%4 == 3))
    {
        return 28;
    }
    if(year%400 == 0)
        return 29;
    if(year%100 == 0)
        return 28;
    return 29;
}
-(void) requestMonth:(NSString *) date{
    NSLog(@"self.roomId :%@" ,self.roomId );
    if (self.isGroupSignIn) {
        [g_server requestSignInDateWithRoomId:self.roomId monthStr:date toView:self];
    }else{
        [g_server requestUserSignMothWithUserId:MY_USER_ID monthStr:date toView:self];
    }
    
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.dateList =[NSMutableArray arrayWithArray: array1];
        weakSelf.tipLbl.text = [NSString stringWithFormat:@"%@%lu%@", @"你已累计签到",(unsigned long)self.dateList.count,@"天"];
        [self showDateView];
    });

}


- (void)sp_getLoginState {
    NSLog(@"Get User Succrss");
}
@end
