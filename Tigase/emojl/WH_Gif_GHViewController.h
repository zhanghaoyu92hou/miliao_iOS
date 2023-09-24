#import <UIKit/UIKit.h>

@class WH_SCGIFImageView;

@protocol WH_Gif_GHViewControllerDelegate <NSObject>

- (void) selectGifWithString:(NSString *) str;

@end

@interface WH_Gif_GHViewController : UIView <UIScrollViewDelegate>{
	NSMutableArray            *_phraseArray;
    UIScrollView              *_sv;
    UIPageControl* _pc;
    WH_SCGIFImageView* _gifIv;
    BOOL pageControlIsChanging;
    NSInteger maxPage;
    
    int tempN;
    int margin;
}

@property (nonatomic, weak) id <WH_Gif_GHViewControllerDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *wh_faceArray;
@property (nonatomic, strong) NSMutableArray *imageArray;

@end
