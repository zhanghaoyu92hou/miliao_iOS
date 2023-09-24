//
//  emojiViewController.m
//
//  Created by daxiong on 13-11-27.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "emojiViewController.h"
#import "WH_menuImageView.h"
#import "WH_FaceView_WHController.h"
#import "WH_Gif_GHViewController.h"
#import "AppDelegate.h"

#import "UIImageView+WebCache.h"
#import "WWBiaoQingBottomToolBtn.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

// 单个表情尺寸大小
//#define kEmojiSize  CGSizeMake(50, 44)
#define kEmojiSize  CGSizeMake(32, 32)
// 内容面板与边界距离
#define kEmojiInset UIEdgeInsetsMake(8, 25, 5, 25)
// pageControl 距离底部的高度
#define kPageControlBottomInset 0
// 行距
#define kLineSpace 18
// 间距
#define kEmojiSpace 18
// 表情按钮基准 tag值
#define ButtonTag 1234
// 滚动视图高度
#define ScrollViewHeight 174 //218-44

// 底部工具栏高度
#define BottomToolBarHeight 44

#define BEGIN_FLAG @"["
#define END_FLAG @"]"
#define PAGE_COUNT 1

@interface emojiViewController ()
// 滚动视图
@property (nonatomic , strong) UIScrollView * mainScrollView;
// 滚动小圆点(pageControl)
@property (nonatomic , strong) UIPageControl * currentPageControl;


//按钮组存放数组
@property (nonatomic , strong) NSMutableArray * bottomBarToolBtnArray;

//小滚动视图存放数组
@property (nonatomic , strong) NSMutableArray * ScrollViewArray;

//分页控件数组
@property (nonatomic , strong) NSMutableArray * pageControlArray;

//当前选中的表情按钮
@property (nonatomic , strong) UIButton * bottomBarToolSelBtn;

//底部自定义组表情滚动视图
@property (nonatomic , strong) UIScrollView * biaoqingScrollView;

// 固定按键按钮
@property (nonatomic, strong) NSArray *bottomBarImgArr;

//底部工具条
@property (nonatomic, strong) UIView * bottomToolBar;
@end
@implementation emojiViewController
@synthesize delegate;
@synthesize faceView=_faceView;
@synthesize shortNameArrayC,shortNameArrayE;


- (NSMutableArray *)bottomBarToolBtnArray
{
    if (!_bottomBarToolBtnArray)
    {
        _bottomBarToolBtnArray = [NSMutableArray array];
    }
    return _bottomBarToolBtnArray;
}

- (NSMutableArray *)ScrollViewArray
{
    if (!_ScrollViewArray)
    {
        _ScrollViewArray = [NSMutableArray array];
    }
    return _ScrollViewArray;
}

- (NSMutableArray *)pageControlArray
{
    if (!_pageControlArray)
    {
        _pageControlArray = [NSMutableArray array];
    }
    return _pageControlArray;
}



- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HEXCOLOR(0xf0eff4);
        [self getLocalEmjioData];
        [self createSubViews];
        
        //加载自定义表情
        [g_server WH_userEmojiListWithPageIndex:0 toView:self];
        
        [g_notify addObserver:self selector:@selector(refreshMyEmoji) name:kFavoritesRefresh_WHNotification object:nil];
        
        [g_notify addObserver:self selector:@selector(refreshMyDownLoadGifEmoji) name:kUpdateMyDownloadEmjioNotification object:nil];
        [g_notify addObserver:self selector:@selector(refreshMyDownLoadGifEmoji) name:kUpdateMyDownloadEmjioAddNotification object:nil];
        
    }
    return self;
}

- (void)refreshMyEmoji
{
    //加载自定义表情
    [g_server WH_userEmojiListWithPageIndex:0 toView:self];
}

- (void)refreshMyDownLoadGifEmoji
{
    //加载已经下载的组动画表情
    [g_server getMyEmjioListWithPageIndex:0 toView:self];
}

//获取本地emjio表情数据
- (void)getLocalEmjioData
{
    shortNameArrayC = [[NSMutableArray alloc] init];
    shortNameArrayE = [[NSMutableArray alloc] init];
    self.imageArray = [[NSMutableArray alloc] init];
    
    // 文件名
    for (NSInteger i = 0; i < g_constant.emojiArray.count; i ++) {
        NSDictionary *dic = g_constant.emojiArray[i];
        NSString *str = dic[@"filename"];
        [self.imageArray addObject:str];
        
        // 英文短名
        str = [NSString stringWithFormat:@"[%@]",dic[@"english"]];
        [shortNameArrayE addObject:str];
        
        // 中文短名
        str = [NSString stringWithFormat:@"[%@]",dic[@"chinese"]];
        [shortNameArrayC addObject:str];
    }
    
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([currentLanguage rangeOfString:@"zh-"].location == NSNotFound) {    //如果不是中文就返回
        self.shortNameArray = shortNameArrayE;
    }else{
        //        self.imageArray = imageArrayC;
        self.shortNameArray = shortNameArrayC;
    }
    
}

// 创建子视图
- (void)createSubViews
{
    self.backgroundColor = HEXCOLOR(0xebebeb);
    NSArray *bottomBarImgArr = @[@"biaoqing_emjio",@"biaoqing_shoucang"];
    self.bottomBarImgArr = bottomBarImgArr;
    
    // main滚动视图
    UIScrollView *mainScrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, ScrollViewHeight)];
    self.mainScrollView = mainScrollView;
    mainScrollView.backgroundColor = HEXCOLOR(0xf4f4f5);
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.pagingEnabled = YES;
    mainScrollView.delegate = self;
    [self addSubview:mainScrollView];
    mainScrollView.contentSize = CGSizeMake(self.width * bottomBarImgArr.count, ScrollViewHeight);
    //小滚动视图
    for (int i = 0; i < bottomBarImgArr.count; i ++) {
        UIScrollView * littleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(i * self.width, 0, self.width, ScrollViewHeight)];
        littleScrollView.tag = i;
        littleScrollView.pagingEnabled = YES;
        littleScrollView.showsVerticalScrollIndicator = NO;
        littleScrollView.showsHorizontalScrollIndicator = NO;
        [mainScrollView addSubview:littleScrollView];
        littleScrollView.delegate = self;
        [self.ScrollViewArray addObject:littleScrollView];
        
    }
    
    
    //emjio表情视图s处理
    [self dealWithEmjioScrollView];
    
    
    
    
    //创建底部表情视图
    UIView * faceView = [[UIView alloc] initWithFrame:CGRectMake(0, ScrollViewHeight, JX_SCREEN_WIDTH, self.height - ScrollViewHeight)];
    faceView.backgroundColor = [UIColor whiteColor];
    [self addSubview:faceView];
    self.bottomToolBar = faceView;
    
    //加号按钮
    CGFloat addBiaoQingBtnWH = BottomToolBarHeight;
    UIButton *addBiaoQingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBiaoQingBtn.frame = CGRectMake(0, 0, addBiaoQingBtnWH, addBiaoQingBtnWH);
    [addBiaoQingBtn setImage:[UIImage imageNamed:@"biaoqing_add"] forState:UIControlStateNormal];
    [addBiaoQingBtn setBackgroundImage:[UIImage imageNamed:@"biaoqing_btnbg1"] forState:UIControlStateNormal];
    [addBiaoQingBtn addTarget:self action:@selector(ww_addBiaoQingAction:) forControlEvents:UIControlEventTouchUpInside];
    [faceView addSubview:addBiaoQingBtn];
    
    
    // 其他选择表情组按钮滚动视图
    UIScrollView *biaoqingScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(addBiaoQingBtn.frame), addBiaoQingBtn.frame.origin.y, JX_SCREEN_WIDTH - addBiaoQingBtn.width, addBiaoQingBtn.height)];
    [faceView addSubview:biaoqingScrollView];
    biaoqingScrollView.contentSize = CGSizeMake(BottomToolBarHeight*3, BottomToolBarHeight);
    biaoqingScrollView.showsHorizontalScrollIndicator = NO;
    self.biaoqingScrollView = biaoqingScrollView;
    
    
    for (int i = 0; i < bottomBarImgArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [biaoqingScrollView addSubview:btn];
        btn.frame = CGRectMake(i * BottomToolBarHeight, addBiaoQingBtn.frame.origin.y, BottomToolBarHeight, BottomToolBarHeight);
        [btn setBackgroundImage:[UIImage imageNamed:@"biaoqing_btnbg1"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:bottomBarImgArr[i]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"biaoqing_btnbg_sel"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(bottomToolBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i+100;
        if (i == 0) {
            btn.selected = YES;
            self.bottomBarToolSelBtn = btn;
            self.selIndex = 0;
        }
        [self.bottomBarToolBtnArray addObject:btn];
    }
    
    
    //添加发送按钮
    UIButton * sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton = sendButton;
    sendButton.frame = CGRectMake(self.width - 55, 0, 55, BottomToolBarHeight);
    sendButton.backgroundColor = HEXCOLOR(0xffffff);//
    [sendButton setTitle:Localized(@"JX_Send") forState:UIControlStateNormal];
    [sendButton setTitleColor:RGB(25, 25, 25) forState:UIControlStateNormal];
    [sendButton setTitleColor:RGB(25, 25, 25) forState:UIControlStateHighlighted];
    sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    sendButton.titleLabel.font = sysFontWithSize(15);
    [sendButton addTarget:self action:@selector(ww_sendButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"biaoqing_btnbg2"] forState:UIControlStateNormal];
    [faceView addSubview:sendButton];
    
}

//count:添加几个  page:每个几页  index:索引
- (void)dealWithPageControlWithIndex:(NSInteger)index Count:(NSInteger)count Page:(NSInteger)page
{
    for (int i = 0;  i < count; i ++) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        
        pageControl.numberOfPages = page;
        pageControl.currentPage = 0;
        pageControl.currentPageIndicatorTintColor = HEXCOLOR(0x8c9094);
        pageControl.pageIndicatorTintColor = HEXCOLOR(0xcbcbcb);
        pageControl.hidesForSinglePage = YES;
        pageControl.center = CGPointMake((i+index) * self.width + self.width * 0.5, ScrollViewHeight - 18);
        [self.mainScrollView addSubview:pageControl];
        
        [self.pageControlArray addObject:pageControl];
    }
    
    
}


- (void)dealWithEmjioScrollView
{
    //emjio固定表情
    UIScrollView *scrollView = self.ScrollViewArray[0];
    
    CGSize contentSize = CGSizeMake(scrollView.width, scrollView.height);
    // 计算每行显示的最大表情数量
    int maxEmotionsNumberInRow = (contentSize.width - kEmojiInset.left - kEmojiInset.right + kEmojiSpace) / (kEmojiSize.width + kEmojiSpace);
    // 计算每列显示的最大表情数量
    int maxEmotionNumberInColumn = (contentSize.height - kEmojiInset.top - kEmojiInset.bottom + kLineSpace) / (kEmojiSize.height + kLineSpace);
    //计算每一行表情之间的实际距离
    float interEmotionSpacing = (contentSize.width - maxEmotionsNumberInRow * kEmojiSize.width - kEmojiInset.left - kEmojiInset.right) / (CGFloat)(maxEmotionsNumberInRow - 1);
    //计算每一列表情之间的实际距离
    float lineEmotionSpacing = (contentSize.height - 35 - maxEmotionNumberInColumn * kEmojiSize.height - kEmojiInset.top - kEmojiInset.bottom) / (CGFloat)(maxEmotionNumberInColumn - 1);
    
    //创建 表情面板
    int emotionCount = (int)self.imageArray.count;
    int currentEmotionLine = 0;
    int emotionIndexOffset = 0;
    for (int index = 0; index < emotionCount; index++)
    {
        currentEmotionLine = (index + emotionIndexOffset) / maxEmotionsNumberInRow;
        
        //当达到每页最后一排的最后一列时，增加偏移量以便空出位置放置删除按键
        if ((index + emotionIndexOffset) % (maxEmotionNumberInColumn * maxEmotionsNumberInRow) == maxEmotionsNumberInRow * maxEmotionNumberInColumn - 1)
        {
            //添加删除按键
            UIButton * deleteButton = [self createDeleteButton];
            CGRect deleteButtonRect = CGRectMake(0, 0, kEmojiSize.width, kEmojiSize.height);
            deleteButtonRect.origin.x = kEmojiInset.left + (index + emotionIndexOffset) % maxEmotionsNumberInRow * (interEmotionSpacing + kEmojiSize.width) + contentSize.width * (currentEmotionLine / maxEmotionNumberInColumn);
            deleteButtonRect.origin.y = kEmojiInset.top + currentEmotionLine % maxEmotionNumberInColumn * (kEmojiSize.height + lineEmotionSpacing);
            deleteButton.frame = deleteButtonRect;
            [scrollView addSubview:deleteButton];
            emotionIndexOffset++;
            currentEmotionLine = (index + emotionIndexOffset) / maxEmotionsNumberInRow;
        }
        
        UIButton * emojiButton = [self createEmojiButtonWithIndex:index];
        CGRect buttonFrame = CGRectMake(0, 0, kEmojiSize.width, kEmojiSize.height);
        buttonFrame.origin.x = kEmojiInset.left + (index + emotionIndexOffset) % maxEmotionsNumberInRow * (interEmotionSpacing + kEmojiSize.width) + contentSize.width * (currentEmotionLine / maxEmotionNumberInColumn);
        buttonFrame.origin.y = kEmojiInset.top + currentEmotionLine % maxEmotionNumberInColumn * (kEmojiSize.height + lineEmotionSpacing);
        emojiButton.frame = buttonFrame;
        [scrollView addSubview:emojiButton];
    }
    
    //如果最后一页未满屏，则在最后一页的最后一个表情后面加上删除键
    if ((emotionCount + emotionIndexOffset) % (maxEmotionNumberInColumn * maxEmotionsNumberInRow))
    {
        //添加删除按键
        UIButton * deleteButton = [self createDeleteButton];
        CGRect deleteButtonRect = CGRectMake(0, 0, kEmojiSize.width, kEmojiSize.height);
        deleteButtonRect.origin.x = kEmojiInset.left + (emotionCount + emotionIndexOffset) % maxEmotionsNumberInRow * (interEmotionSpacing + kEmojiSize.width) + contentSize.width * (currentEmotionLine / maxEmotionNumberInColumn);
        deleteButtonRect.origin.y = kEmojiInset.top + currentEmotionLine % maxEmotionNumberInColumn * (kEmojiSize.height + lineEmotionSpacing);
        deleteButton.frame = deleteButtonRect;
        [scrollView addSubview:deleteButton];
    }
    
    //计算并设置scrollview的contentSize
    scrollView.contentSize = CGSizeMake(contentSize.width * (currentEmotionLine / maxEmotionNumberInColumn + 1), 0);
    
    // 滚动小圆点(pageControl)
    UIPageControl * pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = currentEmotionLine / maxEmotionNumberInColumn + 1;
    pageControl.currentPage = 0;
    pageControl.currentPageIndicatorTintColor = HEXCOLOR(0x8c9094);
    pageControl.pageIndicatorTintColor = HEXCOLOR(0xcbcbcb);
    //    CGSize pageControlSize = [pageControl sizeForNumberOfPages:pageControl.numberOfPages];
    //    CGRect pageControlRect = CGRectMake((contentSize.width - pageControlSize.width) / 2.f,
    //                                        contentSize.height - pageControlSize.height - kPageControlBottomInset,
    //                                        pageControlSize.width,
    //                                        pageControlSize.height);
    pageControl.center = CGPointMake(self.centerX, ScrollViewHeight - 18);
    //    pageControl.frame = pageControlRect;
    
    [self.mainScrollView addSubview:pageControl];
    
    [self.pageControlArray addObject:pageControl];
    self.currentPageControl = pageControl;
}

//创建 表情按键
- (UIButton *)createEmojiButtonWithIndex:(NSInteger)index
{
    UIButton * emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    emojiButton.tag = ButtonTag + index;
    [emojiButton addTarget:self action:@selector(actionSelect:) forControlEvents:UIControlEventTouchUpInside];
    
    [emojiButton setBackgroundImage:[UIImage imageNamed:self.imageArray[index]] forState:UIControlStateNormal];
    [emojiButton setBackgroundImage:[UIImage imageNamed:self.imageArray[index]] forState:UIControlStateHighlighted];
    
    return emojiButton;
}

// 创建 删除按钮
- (UIButton *)createDeleteButton
{
    UIButton * deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton addTarget:self action:@selector(actionDelete:) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setImage:[UIImage imageNamed:@"icon_emoji_deleteBtn"] forState:UIControlStateNormal];
    [deleteButton setImage:[UIImage imageNamed:@"icon_emoji_deleteBtn"] forState:UIControlStateHighlighted];
    return deleteButton;
}

#pragma mark - 接收数据处理
-(void)setZuGifEmotDataArray:(NSArray *)ZuGifEmotDataArray
{
    _ZuGifEmotDataArray = ZuGifEmotDataArray;
    
    for (int i = 0; i <self.bottomBarToolBtnArray.count; i++) {
        if (i >= 2) {
            UIView *v = self.bottomBarToolBtnArray[i];
            [v removeFromSuperview];
        }
    }
    for (int i = 0; i <self.ScrollViewArray.count; i++) {
        if (i >= 2) {
            UIView *v = self.ScrollViewArray[i];
            [v removeFromSuperview];
        }
    }
    
    for (int i = 0; i <self.pageControlArray.count; i++) {
        if (i >= 2) {
            UIView *v = self.pageControlArray[i];
            [v removeFromSuperview];
        }
    }
    
    self.biaoqingScrollView.contentSize = CGSizeMake(BottomToolBarHeight*(ZuGifEmotDataArray.count + 3)+self.sendButton.width, BottomToolBarHeight);
    
    
    for (int i = 0; i < ZuGifEmotDataArray.count; i ++) {
        
        NSDictionary *tempDic = ZuGifEmotDataArray[i];
        NSArray *tempArr = tempDic[@"imEmojiStoreListInfo"];
        
        // 创建底部按钮
        WWBiaoQingBottomToolBtn *btn = [WWBiaoQingBottomToolBtn buttonWithType:UIButtonTypeCustom];
        [self.biaoqingScrollView addSubview:btn];
        btn.frame = CGRectMake((i+self.bottomBarImgArr.count) * BottomToolBarHeight, 0, BottomToolBarHeight, BottomToolBarHeight);
        [btn setBackgroundImage:[UIImage imageNamed:@"biaoqing_btnbg1"] forState:UIControlStateNormal];
        [btn sd_setImageWithURL:[NSURL URLWithString:tempDic[@"emoPackThumbnailUrl"]] forState:UIControlStateNormal placeholderImage:Message_PlaceholderImage];
        
        
        
        [btn setBackgroundImage:[UIImage imageNamed:@"biaoqing_btnbg_sel"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(bottomToolBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = (i+self.bottomBarImgArr.count)+100;
        
        [self.bottomBarToolBtnArray addObject:btn];
        
        //添加scrollview
        UIScrollView * littleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((i+self.bottomBarImgArr.count) * self.width, 0, self.width, ScrollViewHeight)];
        littleScrollView.tag = i+self.bottomBarImgArr.count;
        littleScrollView.pagingEnabled = YES;
        littleScrollView.showsVerticalScrollIndicator = NO;
        littleScrollView.showsHorizontalScrollIndicator = NO;
        [self.mainScrollView addSubview:littleScrollView];
        littleScrollView.delegate = self;
        [self.ScrollViewArray addObject:littleScrollView];
        NSInteger page = ceilf(tempArr.count/8.f);
        littleScrollView.contentSize = CGSizeMake(JX_SCREEN_WIDTH * page, 0);
        [self dealWithScrollView:littleScrollView dataArr:tempArr type:1];
        
        //添加pageControl
        
        [self dealWithPageControlWithIndex:i+self.bottomBarImgArr.count Count:1 Page:page];
    }
    
    self.mainScrollView.contentSize = CGSizeMake((self.width*(ZuGifEmotDataArray.count+self.bottomBarImgArr.count)), 0);
    //    UIScrollView * scrollView = self.ScrollViewArray[1];
    //    scrollView.contentSize = CGSizeMake(JX_SCREEN_WIDTH * 2, 0);
}

- (void)setMyEmotIconDataArray:(NSArray *)MyEmotIconDataArray
{
    _MyEmotIconDataArray = MyEmotIconDataArray;
    
    //重新初始化数据
    [self.bottomBarToolBtnArray removeAllObjects];
    [self.ScrollViewArray removeAllObjects];
    [self.pageControlArray removeAllObjects];
    [self.mainScrollView removeFromSuperview];
    [self.bottomToolBar removeFromSuperview];
    //    [self removeAllSubviews];
    
    [self createSubViews];
    
    
    UIScrollView * scrollView = self.ScrollViewArray[1];
    
    
    [self dealWithScrollView:scrollView dataArr:MyEmotIconDataArray type:0];
    
    
    
    //处理pageControl
    NSInteger page = ceilf(MyEmotIconDataArray.count/8.f);
    [self dealWithPageControlWithIndex:1 Count:1 Page:page];
    
    
    
    
}

- (void)dealWithScrollView:(UIScrollView *)scrollView dataArr:(NSArray *)dataArr type:(int)type
{
    NSInteger page = ceilf(dataArr.count/8.f);
    scrollView.contentSize = CGSizeMake(JX_SCREEN_WIDTH * page, 0);
    
    
    //    [scrollView removeFromSuperview];
    
    
    for (NSInteger k = 0; k< page; k++) {
        UIView *bgview = [[UIView alloc]initWithFrame:CGRectMake(0 +JX_SCREEN_WIDTH *k, 0, JX_SCREEN_WIDTH, self.height)];
        NSInteger num = 4;
        CGFloat viewWidth = 60;
        CGFloat viewHeight = viewWidth - 8 + 5 + 11;
        CGFloat viewX = (self.width - num * viewWidth) / (num + 1);
        CGFloat viewY = 8;
        CGFloat labelHeight = 22 / 2;
        NSInteger n = 0;
        for (NSInteger i = k*8; i < dataArr.count; i++)
        {
            n++;
            if (n > 8) {
                break;
            }
            NSInteger j = i%8;
            
            UIView * view = [[UIView alloc] initWithFrame:CGRectMake(viewX + (j % num) * (viewX + viewWidth), viewY + (viewY + viewHeight) * (j / num), viewWidth, viewHeight)];
            view.tag = 200 + i;
            view.userInteractionEnabled = YES;
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewOnTap:)]];
            
            //图片
            UIImageView * imageView;
            
            //名称
            UILabel * label;
            
            if (type) {
                NSDictionary *tempDic = dataArr[i];
                imageView = [[UIImageView alloc] init];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                imageView.frame = CGRectMake(4, 0, view.width-8, view.width-8);
                [view addSubview:imageView];
                [imageView sd_setImageWithURL:[NSURL URLWithString:tempDic[@"thumbnailUrl"]] placeholderImage:Message_PlaceholderImage];
                
                label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y + imageView.height + 5, imageView.width, labelHeight)];
                label.text = tempDic[@"emoMean"];
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:11];
                label.textColor = HEXCOLOR(0x6f7378);
                [view addSubview:label];
            }else{//收藏表情
                NSDictionary *tempDic = dataArr[i];
                imageView = [[UIImageView alloc] init];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                imageView.frame = CGRectMake(0, 0, view.width, view.width);
                [view addSubview:imageView];
                
                if ([checkNull(tempDic[@"url"]) isEqualToString:@"first_jian"]) {
                    imageView.image = [UIImage imageNamed:@"icon_emot_jian"];
                    
                }else{
                    [imageView sd_setImageWithURL:[NSURL URLWithString:tempDic[@"url"]] placeholderImage:Message_PlaceholderImage];
                }
                
                
            }
            
            
            [bgview addSubview:view];
        }
        [scrollView addSubview:bgview];
        
    }
    
    //自动调整宽高
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}


#pragma mark - 我的表情收藏视图被敲击 手势 触发事件
- (void)viewOnTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UIView * view = tapGestureRecognizer.view;
    NSUInteger index = view.tag - 200;
    
    NSLog(@"%ld----%ld",self.selIndex,index);
    NSDictionary *tempDic;
    NSArray *tempArr;
    if (self.selIndex>=2) {
        tempDic = self.ZuGifEmotDataArray[self.selIndex-2];
        tempArr = tempDic[@"imEmojiStoreListInfo"];
    }else{
        tempArr = self.MyEmotIconDataArray;
    }
    
    
    if ([self.delegate respondsToSelector:@selector(emojiFaceView:didClickOnGifViewWithZuIndex:index:dataDic:)]) {
        [self.delegate emojiFaceView:self didClickOnGifViewWithZuIndex:self.selIndex index:index dataDic:tempArr[index]];
    }
    
    
}



#pragma mark - 按钮点击事件
- (void)bottomToolBtnAction:(UIButton *)button
{
    self.bottomBarToolSelBtn.selected = NO;
    button.selected = YES;
    self.bottomBarToolSelBtn = button;
    //滚动到指定区域
    NSInteger i = button.tag - 100;
    self.selIndex = i;
    [self.mainScrollView setContentOffset:CGPointMake(i * self.width, 0) animated:NO];
}
//emjio表情按钮点击
-(void)actionSelect:(UIView*)sender
{
    NSString *imageName = self.imageArray[sender.tag-ButtonTag];
    NSString* shortName = [self.shortNameArrayE objectAtIndex:sender.tag-ButtonTag];
    if ([self.delegate respondsToSelector:@selector(selectImageNameString:ShortName:isSelectImage:)]) {
        [self.delegate selectImageNameString:imageName ShortName:shortName isSelectImage:YES];
    }
    
}
//删除表情按钮点击
-(void)actionDelete:(UIView*)sender{
    if ([self.delegate respondsToSelector:@selector(faceViewDeleteAction)]) {
        [self.delegate faceViewDeleteAction];
    }
    
}

// 发送按钮 被点击
- (void)ww_sendButtonOnClick:(UIButton *)button
{
    
    //发送全局通知
    [g_notify postNotificationName:kSendInput_WHNotifaction object:nil userInfo:nil];
    
}

//添加表情按钮点击
- (void)ww_addBiaoQingAction:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(emojiFaceView:didClickAddEmoticonButton:)]) {
        [self.delegate emojiFaceView:self didClickAddEmoticonButton:button];
    }
}


#pragma mark - 协议 UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger i =  self.mainScrollView.contentOffset.x/self.width;
    //安全判断
    if (i<self.pageControlArray.count) {
        UIPageControl *pageC = self.pageControlArray[i];
        UIScrollView *scrollV = self.ScrollViewArray[i];
        pageC.currentPage = scrollV.contentOffset.x / scrollView.width;
    }
    
    UIButton *btn = self.bottomBarToolBtnArray[i];
    [self bottomToolBtnAction:btn];
}


-(void) dealloc{
    //    [delegate release];
    //    [_tb release];
    //    [_faceView release];
    //    [_gifView release];
    //    [super dealloc];
}

-(void)actionSegment:(UIButton*)sender{
    switch (sender.tag){
        case 0:
            _faceView.hidden   = NO;
            _gifView.hidden   = YES;
            _favoritesVC.view.hidden = YES;
            break;
        case 1:
            _faceView.hidden   = YES;
            _gifView.hidden   = NO;
            _favoritesVC.view.hidden = YES;
            break;
        case 2:
            _faceView.hidden   = YES;
            _gifView.hidden   = YES;
            _favoritesVC.view.hidden = NO;
            break;
        case 3:
            //发送全局通知
            [g_notify postNotificationName:kSendInput_WHNotifaction object:nil userInfo:nil];
            break;
    }
}

//-(void)setDelegate:(id)value{
//    if(delegate != value){
//        delegate = value;
//        _faceView.delegate = delegate;
//        _gifView.delegate = delegate;
//        _favoritesVC.delegate = delegate;
//    }
//}

-(void)selectType:(int)n{
    [_tb selectOne:n];
    _faceView.hidden   = NO;
    _gifView.hidden   = YES;
    _favoritesVC.view.hidden = YES;
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    if ([aDownload.action isEqualToString:wh_act_userEmojiList]) {
        
        [g_myself.favorites removeAllObjects];
        [g_myself.favorites addObjectsFromArray:array1];
        
        NSMutableArray *myEmotArr = [NSMutableArray arrayWithArray:g_myself.favorites];
        [myEmotArr insertObject:@{@"url":@"first_jian"} atIndex:0];
        self.MyEmotIconDataArray = myEmotArr;
        
        //加载已经下载的组动画表情
        [g_server getMyEmjioListWithPageIndex:0 toView:self];
        
    }else if ([aDownload.action isEqualToString:wh_act_emojiMyDownListPage]) {
        
        NSDictionary *tempDic = [array1 firstObject];
        NSArray *imEmojiStoreArr = tempDic[@"imEmojiStore"];
        if (array1.count == 0) {
            self.ZuGifEmotDataArray = array1;
            return;
        }
        
        if ([imEmojiStoreArr isKindOfClass:[NSArray class]]) {
            //需要重新整体刷新界面
            self.MyEmotIconDataArray = self.MyEmotIconDataArray;
            self.ZuGifEmotDataArray = imEmojiStoreArr;
        }
        
    }
}


@end
