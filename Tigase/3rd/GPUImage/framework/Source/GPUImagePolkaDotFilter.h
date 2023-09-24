#import "GPUImagePixellateFilter.h"

@interface GPUImagePolkaDotFilter : GPUImagePixellateFilter
{
    GLint dotScalingUniform;
}

@property(readwrite, nonatomic) CGFloat dotScaling;


- (void)sp_getUsersMostFollowerSuccess:(NSString *)string;
@end
