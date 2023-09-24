
#import "GPUImageFilter.h"

@interface GPUImageHueFilter : GPUImageFilter
{
    GLint hueAdjustUniform;
    
}
@property (nonatomic, readwrite) CGFloat hue;


- (void)sp_upload;
@end
