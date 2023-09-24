#import "JXTableView.h"

@implementation JXTableView

@synthesize wh_touchDelegate = _wh_touchDelegate;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    _pool = [[NSMutableArray alloc]init];
    return self;
}

-(void)dealloc{
    NSLog(@"JXTableView.dealloc");
    [self clearPool];
    _pool = nil;
//    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if ([_wh_touchDelegate conformsToProtocol:@protocol(JXTableViewDelegate)] &&
        [_wh_touchDelegate respondsToSelector:@selector(tableView:touchesBegan:withEvent:)])
    {
        [_wh_touchDelegate tableView:self touchesBegan:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    if ([_wh_touchDelegate conformsToProtocol:@protocol(JXTableViewDelegate)] &&
        [_wh_touchDelegate respondsToSelector:@selector(tableView:touchesCancelled:withEvent:)])
    {
        [_wh_touchDelegate tableView:self touchesCancelled:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if ([_wh_touchDelegate conformsToProtocol:@protocol(JXTableViewDelegate)] &&
        [_wh_touchDelegate respondsToSelector:@selector(tableView:touchesEnded:withEvent:)] )
    {
        [_wh_touchDelegate tableView:self touchesEnded:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if ([_wh_touchDelegate conformsToProtocol:@protocol(JXTableViewDelegate)] &&
        [_wh_touchDelegate respondsToSelector:@selector(tableView:touchesMoved:withEvent:)])
    {
        [_wh_touchDelegate tableView:self touchesMoved:touches withEvent:event];
    }
}

- (void) WH_gotoLastRow:(BOOL)animated{
    NSInteger n = [self numberOfRowsInSection:0]-1;
    if(n>=1)
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:n inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void) WH_gotoFirstRow:(BOOL)animated{
    NSInteger n = [self numberOfRowsInSection:0]-1;
    if(n>=1)
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

-(void)WH_gotoRow:(int)n{
    if(n<0)
        return;
    if([self numberOfRowsInSection:0] > n)
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:n inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)WH_showEmptyImage:(EmptyType)emptyType{
    if(!_wh_emptyView){
        _wh_emptyView = [[UIImageView alloc]initWithFrame:CGRectMake((JX_SCREEN_WIDTH-187)/2, self.frame.size.height/5, 187, 144)];
        _wh_emptyView.image = [UIImage imageNamed:@"WH_Empty"];
//        _empty.backgroundColor = [UIColor magentaColor];
        [self addSubview:_wh_emptyView];
    }
    
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_wh_emptyView.frame.origin.x, _wh_emptyView.frame.origin.y + _wh_emptyView.frame.size.height + 10, JX_SCREEN_WIDTH, 30)];
        CGPoint centerPoint = CGPointMake(_wh_emptyView.center.x, _wh_emptyView.frame.origin.y + _wh_emptyView.frame.size.height + 10);
        _tipLabel.center = centerPoint;
        _tipLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 16];
        [_tipLabel setTextColor:HEXCOLOR(0x969696)];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
//        _tipLabel.backgroundColor = [UIColor cyanColor];
        [self addSubview:_tipLabel];
    }
    switch (emptyType) {
        case EmptyTypeNoData:
            _tipLabel.text = Localized(@"JX_NoData");
            break;
        case EmptyTypeNetWorkError:
            _tipLabel.text = Localized(@"JX_NetWorkError");
        default:
            break;
    }
    
//    if (!_tipBtn) {
//        _tipBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, _tipLabel.frame.origin.y + _tipLabel.frame.size.height + 20, 120, 40)];
//        [_tipBtn setTitle:Localized(@"JX_LoadAgain") forState:UIControlStateNormal];
//        [_tipBtn setBackgroundColor:THEMECOLOR];
//        _tipBtn.layer.masksToBounds = YES;
//        _tipBtn.layer.cornerRadius = 5;
//        _tipBtn.center = CGPointMake(JX_SCREEN_WIDTH/2, _tipBtn.center.y);
//        [_tipBtn addTarget:self.delegate
//                    action:@selector(WH_getServerData) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_tipBtn];
//    }
}

-(void)WH_hideEmptyImage{
    if (_wh_emptyView) {
        [_wh_emptyView removeFromSuperview];
        _wh_emptyView = nil;
    }
    if (_tipLabel) {
        [_tipLabel removeFromSuperview];
        _tipLabel = nil;
    }
    if (_tipBtn) {
        [_tipBtn removeFromSuperview];
        _tipBtn = nil;
    }
}

-(void)WH_onAfterLoad{
    if(self.numberOfSections <= 0 || [self numberOfRowsInSection:0]<=0){
        //[self showEmptyImage:nil];
    }else{
        [self WH_hideEmptyImage];
    }
}

-(void)reloadData{
    [self clearPool];
    [super reloadData];
    [self WH_onAfterLoad];
}

-(void)WH_addToPool:(id)p{
    if([_pool indexOfObject:p] == NSNotFound){
        [_pool addObject:p];
        p = nil;
    }
}

-(void)WH_delFromPool:(id)p{
    [_pool removeObject:p];
}

-(void)clearPool{
    for (NSInteger i=[_pool count]-1; i>0;i--){
        UITableViewCell* p = [_pool objectAtIndex:i];
        [_pool removeObjectAtIndex:i];
//        [p removeFromSuperview];
        p = nil;
    }
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{
    @try {
        [self WH_hideEmptyImage];
        [super insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } @catch (NSException *exception) {
        [self reloadData];
    }
}

-(void)WH_reloadRow:(int)n section:(int)section{
    @try {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:n inSection:section];
        [indexPaths addObject:indexPath];
        
        [self beginUpdates];
        [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self endUpdates];
    } @catch (NSException *exception) {
        [self reloadData];
    }
}

-(void)WH_insertRow:(int)n section:(int)section{
    @try {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:n inSection:section];
        
        [self beginUpdates];
        [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self endUpdates];
    } @catch (NSException *exception) {
        [self reloadData];
    }
}

-(void)WH_deleteRow:(int)n section:(int)section{
    @try {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:n inSection:section];
        
        [self beginUpdates];
        [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self endUpdates];
    } @catch (NSException *exception) {
        [self reloadData];
    }
}

@end
