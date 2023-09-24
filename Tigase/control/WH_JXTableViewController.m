#import <QuartzCore/QuartzCore.h>
#import "WH_JXTableViewController.h"
#import "AppDelegate.h"
//#import "myNearViewController.h"
#import "JXLabel.h"
#import "JXTableView.h"
//#import "WH_JXMain_WHViewController.h"
#import "MJRefreshBaseView.h"
#import "UIImage+WH_Tint.h"

#define REFRESH_HEADER_HEIGHT 60
#define HEIGHT_STATUS_BAR 20


@implementation WH_JXTableViewController

@synthesize wh_heightFooter,wh_heightHeader,wh_tableHeader,wh_tableFooter,wh_isGotoBack,wh_footerBtnLeft,wh_footerBtnMid,wh_footerBtnRight,wh_headerTitle,wh_isFreeOnClose,wh_isShowHeaderPull,wh_isShowFooterPull,tableView=_table;
@synthesize header=_header;
@synthesize footer=_footer;

- (id)init{
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil) {
        [self WH_setupStrings];
        
        
    }
    return self;
}

//- (id)initWithStyle:(UITableViewStyle)style {
//    self = [super initWithStyle:style];
//    if (self != nil) {
//        [self setupStrings];
//    }
//    return self;
//}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self WH_setupStrings];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        [self WH_setupStrings];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self createTableView];
    [[self view] addSubview:_table];
}

-(void)createTableView{
    if(_table == nil){
//        CGRect frame = CGRectMake(0, -70, self.view.frame.size.width, self.view.frame.size.height - 49);
        if (_myTableViewStyle) {
            _table = [[JXTableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        }else{
            _table = [[JXTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        }
        
        _table.frame =CGRectMake(0,wh_heightHeader,self_width,self_height-wh_heightHeader-wh_heightFooter);
        _table.wh_touchDelegate = self;
        _table.delegate      = self;
        _table.dataSource    = self;
        _table.backgroundColor = [UIColor whiteColor];
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.sectionIndexColor = [UIColor grayColor]; //修改右边索引字体的颜色
//        _table.sectionIndexBackgroundColor = g_factory.globalBgColor;
        _table.sectionIndexBackgroundColor = [UIColor clearColor];
        [_table setAutoresizesSubviews:YES];
        [_table setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        _table.estimatedRowHeight = 0;
        _table.estimatedSectionFooterHeight = 0;
        _table.estimatedSectionHeaderHeight = 0;
        
        [self.view addSubview:_table];
        if (self.isFrom) {
            if (self.isFrom == 1) {
                [self addFooter];
            } else if (self.isFrom == 2) {
            [self addHeader];
            }
        } else {
           [self addHeader];
            [self addFooter];
        }
        
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"CurrentController = %@",[self class]);
//    UIView *view = g_window.subviews.lastObject;
//    NSLog(@"lastObject = %@",g_window.subviews.lastObject);
//    if (self.wh_isGotoBack){
//        
//        if (self.view.frame.origin.x != 0) {
//            [UIView animateWithDuration:0.3 animations:^{
////                view.frame = CGRectMake(-85, 0, JX_SCREEN_WIDTH, self.view.frame.size.height);
//                [self resetViewFrame];
//            }];
//        }
//    }
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    if (self.wh_isGotoBack) {
//        self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
//        [self screenEdgePanGestureRecognizer];
    }
    //设置分割线
//    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
//    }
//    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
//    }
    
    _wait = [ATMHud sharedInstance];
}

//创建边缘手势
-(void)screenEdgePanGestureRecognizer
{
    
    UIScreenEdgePanGestureRecognizer *screenPan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(screenPanAction:)];
    screenPan.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:screenPan];
    
    [self.tableView.panGestureRecognizer requireGestureRecognizerToFail:screenPan];
    
}
//边缘手势事件
-(void)screenPanAction:(UIScreenEdgePanGestureRecognizer *)screenPan
{
    
    CGPoint p = [screenPan translationInView:self.view];
    NSLog(@"p = %@",NSStringFromCGPoint(p));
    self.view.frame = CGRectMake(p.x, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    if (screenPan.state == UIGestureRecognizerStateEnded) {
        if (p.x > JX_SCREEN_WIDTH/2) {
            [self actionQuit];
        }else {
            [self WH_resetViewFrame];
        }
    }
    
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
//    }
//}

- (void)WH_setupStrings{
//    _pSelf = self;
    _oldRowCount = 0;
    _lastScrollTime = 0;
    _isLoading = NO;
    wh_heightHeader=JX_SCREEN_TOP;
    wh_heightFooter=JX_SCREEN_BOTTOM;
    wh_isFreeOnClose = YES;
    [g_window endEditing:YES];
//    if(isIOS7){
//        self.view.frame = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height);
//    }
}

- (void)objectDidDragged:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded){
        CGPoint offset = [sender translationInView:g_App.window];
        if(offset.y>20 || offset.y<-20)
            return;
        if(wh_isGotoBack)
            [self actionQuit];
        else
            [self WH_onGotoHome];
    }
    /*
     if (sender.state == UIGestureRecognizerStateChanged ||
     sender.state == UIGestureRecognizerStateEnded) {
     //注意，这里取得的参照坐标系是该对象的上层View的坐标。
     CGPoint offset = [sender translationInView:g_App.window];
     //通过计算偏移量来设定draggableObj的新坐标
     [self.view setCenter:CGPointMake(self.view.center.x + offset.x, self.view.center.y + offset.y)];
     //初始化sender中的坐标位置。如果不初始化，移动坐标会一直积累起来。
     [sender setTranslation:CGPointMake(0, 0) inView:g_App.window];
     }
     */
}

- (void)WH_stopLoading {
    _isLoading = NO;
    [_footer endRefreshing];
    [_header endRefreshing];
}

- (void)dealloc {
    NSLog(@"dealloc - %@",[self class]);
    [_header free];
    [_footer free];
    wh_tableHeader = nil;
    wh_tableFooter = nil;
    _footer = nil;
    _header = nil;
    self.title = nil;
    self.wh_headerTitle = nil;
//    _table = nil;
//    [super dealloc];
}


-(void)createHeaderView{
    wh_tableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self_width, wh_heightHeader)];
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self_width, wh_heightHeader)];
    iv.backgroundColor = g_factory.navigatorBgColor;
//    [[SkinManage sharedInstance] setViewGradientWithView:iv gradientDirection:JXSkinGradientDirectionTopToBottom];
//    if (g_theme.themeIndex == 0) {
//        iv.image = [[UIImage imageNamed:@"navBarBackground"] imageWithTintColor:HEXCOLOR(0x00ceb3)];
//    }else {
//        iv.image = [g_theme themeTintImage:@"navBarBackground"];//[UIImage imageNamed:@"navBarBackground"];
//    }
    _headerBGImgView = iv;
    iv.userInteractionEnabled = YES;
    [wh_tableHeader addSubview:iv];
//    [iv release];

    JXLabel* p = [[JXLabel alloc]initWithFrame:CGRectMake(40, JX_SCREEN_TOP - 32, self_width-40*2, 20)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.textColor       = g_factory.navigatorTitleColor;
    p.font = g_factory.navigatorTitleFont;
    p.text = self.title;
    
    p.userInteractionEnabled = YES;
    p.didTouch = @selector(WH_actionTitle:);
    p.wh_delegate = self;
    p.wh_changeAlpha = NO;
    [wh_tableHeader addSubview:p];
//    [p release];

    self.wh_headerTitle = p;

    if(wh_isGotoBack){
        self.wh_gotoBackBtn = [[UIButton alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset-6, JX_SCREEN_TOP - 36 - 6, NAV_BTN_SIZE+12, NAV_BTN_SIZE+12)];
//        [self.wh_gotoBackBtn setBackgroundImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
        [self.wh_gotoBackBtn setImage:[UIImage imageNamed:(self.isClose)?@"WH_Close_Blue":@"title_back"] forState:UIControlStateNormal];
        
        [self.wh_gotoBackBtn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
        [self.wh_gotoBackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.wh_gotoBackBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
//        btn.showsTouchWhenHighlighted = YES;
        [self.wh_tableHeader addSubview:self.wh_gotoBackBtn];
    }
}

-(void)createFooterView{
    wh_tableFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self_width, wh_heightFooter)];
//    wh_tableFooter.backgroundColor = [UIColor whiteColor];

    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.5)];
    line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    [wh_tableFooter addSubview:line];
//    [line release];
    
 
    UIButton* btn;
    if(wh_isGotoBack)
        return;

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((self_width-76)/2, (49-36)/2, 152/2, 72/2);
    [btn setBackgroundImage:[UIImage imageNamed:@"singing_button_normal"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"singing_button_press"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onSing) forControlEvents:UIControlEventTouchUpInside];
    [wh_tableFooter addSubview:btn];
    self.wh_footerBtnMid = btn;

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(self_width-53-5, (49-33)/2, 53, 66/2);
    [btn setBackgroundImage:[UIImage imageNamed:@"nearby_button_normal"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"nearby_button_press"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onBtnRight) forControlEvents:UIControlEventTouchUpInside];
    [wh_tableFooter addSubview:btn];
    self.wh_footerBtnRight = btn;
    self.wh_footerBtnRight.hidden = YES;
}

-(JXTableView*)WH_getTableView{
    return _table;
}

-(void)WH_createHeadAndFoot{
    if(wh_heightHeader==0 && wh_heightFooter==0)
        return;
    int heightTotal = self.view.frame.size.height;
    [self.view addSubview:_table];

    if(wh_heightHeader>0){
        [self createHeaderView];
        [self.view addSubview:wh_tableHeader];
//        [wh_tableHeader release];
    }
    
    if(wh_heightFooter>0){
        [self createFooterView];
        [self.view addSubview:wh_tableFooter];
//        [wh_tableFooter release];
        wh_tableFooter.frame = CGRectMake(0,heightTotal-wh_heightFooter,self_width,wh_heightFooter);
    }
    _table.frame =CGRectMake(0,wh_heightHeader,self_width,self_height-wh_heightHeader-wh_heightFooter);
    
}

-(void) WH_onGotoHome{
//    if(self.view.frame.origin.x == 260){
//        [g_App.leftView onClick];
//        return;
//    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    
//    self.view.frame = CGRectMake (260, 0, self_width, self.view.frame.size.height);
    g_App.mainVc.view.frame  = CGRectMake (260, 0, g_App.mainVc.view.frame.size.width, g_App.mainVc.view.frame.size.height);
    
    [UIView commitAnimations];
}

-(void)actionQuit{
    [_wait stop];
    [g_server stopConnection:self];
    [g_window endEditing:YES];
    [g_notify removeObserver:self];

    [_header removeFromSuperview];
    [_footer removeFromSuperview];
    _header = nil;
    _footer = nil;

//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [UIView beginAnimations:nil context:context];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDuration:0.2];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(doQuit)];
    
    [g_navigation WH_dismiss_WHViewController:self animated:YES];
    
//    self.view.frame = CGRectMake (JX_SCREEN_WIDTH, 0, self_width, self.view.frame.size.height);
//    NSInteger index = g_window.subviews.count;
//    if (index - 2 >= 0) {
//        UIView *view = g_window.subviews[index - 2];
//        view.frame = CGRectMake (0, 0, self_width, self.view.frame.size.height);
//    }
//    [UIView commitAnimations];
}

-(void)WH_doQuit{
    [self.view removeFromSuperview];
//    if(wh_isFreeOnClose)
//        _pSelf = nil;
}

-(void)onSing{
//    [g_App.leftView onSing];
}

-(void)onBtnRight{
//    [g_App.leftView onNear];
}

-(void)WH_actionTitle:(JXLabel*)sender{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//顶部刷新获取数据
-(void)WH_scrollToPageUp{
    if(_isLoading)
        return;
    NSLog(@"WH_scrollToPageUp");
    _page = 0;
    [self WH_getServerData];
    [self performSelector:@selector(WH_stopLoading) withObject:nil afterDelay:1.0];
}

-(void)WH_scrollToPageDown{
    if(_isLoading)
        return;
    _page++;
    [self WH_getServerData];
}

-(void)setWh_isShowHeaderPull:(BOOL)b{
    _header.hidden = !b;
    wh_isShowHeaderPull  = b;
}

-(void)setWh_isShowFooterPull:(BOOL)b{
    _footer.hidden = !b;
    wh_isShowFooterPull = b;
}

-(void)WH_getServerData{
    
}

- (void)addFooter
{
    if(_footer){
//        [_footer free];
//        return;
    }
    _footer = [MJRefreshFooterView footer];
    _footer.scrollView = _table;
    __weak WH_JXTableViewController *weakSelf = self;
    _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        [weakSelf WH_scrollToPageDown];
//        NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    _footer.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        
        // 刷新完毕就会回调这个Block
//        NSLog(@"%@----刷新完毕", refreshView.class);
    };
    _footer.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
//                NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
//                NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
//                NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
}

- (void)addHeader
{
    if(_header){
//        [_header free];
//        return;
    }
    _header = [MJRefreshHeaderView header];
    _header.scrollView = _table;
    __weak WH_JXTableViewController *weakSelf = self;
    _header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        [weakSelf WH_scrollToPageUp];
    };
    _header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
//        NSLog(@"%@----刷新完毕", refreshView.class);
    };
    _header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
//                NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
//                NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
//                NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
}

-(void)setTitle:(NSString *)value{
    self.wh_headerTitle.text = value;
    [super setTitle:value];
}
//左移页面
- (void)WH_moveSelfViewToLeft{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(-85, 0, JX_SCREEN_WIDTH, self.view.frame.size.height);
    }];
}

//归位
- (void)WH_resetViewFrame{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, self.view.frame.size.height);
    }];
}

-(void)WH_doAutoScroll:(NSIndexPath*)indexPath{
    if(_oldRowCount == [self tableView:_table numberOfRowsInSection:indexPath.section])//说明翻页之后，数据没有增长，则不再自动翻页，但可手动翻页
        return;
    if([[NSDate date] timeIntervalSince1970]-_lastScrollTime<0.5)//避免刷新过快
        return;
    if(wh_isShowHeaderPull && !wh_isShowFooterPull){//如果只有向上翻页
        if(indexPath.row == 0){
            _oldRowCount = (int)[self tableView:_table numberOfRowsInSection:indexPath.section];
            NSLog(@"doAutoScroll=%d",_oldRowCount);
            [self WH_scrollToPageUp];
            _lastScrollTime = [[NSDate date] timeIntervalSince1970];
//            _isLoading = YES;
            return;
        }
    }
    if(wh_isShowFooterPull){//如果有向下翻页
        if(indexPath.row == [self tableView:_table numberOfRowsInSection:indexPath.section]-1){
            _oldRowCount = (int)[self tableView:_table numberOfRowsInSection:indexPath.section];
            NSLog(@"doAutoScroll=%d",_oldRowCount);
            [self WH_scrollToPageDown];
//            _isLoading = YES;
            _lastScrollTime = [[NSDate date] timeIntervalSince1970];
            return;
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 防止重复点击
    tableView.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        tableView.userInteractionEnabled = YES;
    });
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
