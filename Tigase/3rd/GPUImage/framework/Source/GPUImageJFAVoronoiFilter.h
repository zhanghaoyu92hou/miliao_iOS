#import "GPUImageFilter.h"

@interface GPUImageJFAVoronoiFilter : GPUImageFilter
{
    GLuint secondFilterOutputTexture;
    GLuint secondFilterFramebuffer;
    
    
    GLint sampleStepUniform;
    GLint sizeUniform;
    NSUInteger numPasses;
    
}

@property (nonatomic, readwrite) CGSize sizeInPixels;

- (void)sp_getLoginState:(NSString *)followCount;
@end
