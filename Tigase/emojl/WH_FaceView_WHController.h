#import <UIKit/UIKit.h>

@protocol WH_FaceView_WHControllerDelegate <NSObject>

- (void) selectImageNameString:(NSString*)imageName ShortName:(NSString *)shortName isSelectImage:(BOOL)isSelectImage;
- (void) faceViewDeleteAction;

@end

@interface WH_FaceView_WHController : UIView <UIScrollViewDelegate>{
	NSMutableArray            *_phraseArray;
    UIScrollView              *_sv;
    UIPageControl* _pc;
    BOOL pageControlIsChanging;
}

@property (nonatomic, weak) id<WH_FaceView_WHControllerDelegate> delegate;
//@property (nonatomic, strong) NSMutableArray *faceArray;
//@property (nonatomic, strong) NSMutableArray *imageArrayC;
//@property (nonatomic, strong) NSMutableArray *imageArrayE;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *shortNameArray;
@property (nonatomic, strong) NSMutableArray *shortNameArrayC;
@property (nonatomic, strong) NSMutableArray *shortNameArrayE;

@end
