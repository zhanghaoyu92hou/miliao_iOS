#import "GPUImageGaussianBlurFilter.h"

/** A hardware-accelerated box blur of an image
 */
@interface GPUImageBoxBlurFilter : GPUImageGaussianBlurFilter


- (void)sp_getMediaData;
@end
