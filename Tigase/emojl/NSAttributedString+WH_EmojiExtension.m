//
// Created by zorro on 15/3/7.
// Copyright (c) 2015 tutuge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSAttributedString+WH_EmojiExtension.h"
#import "WH_EmojiTextAttachment.h"

@implementation NSAttributedString (WH_EmojiExtension)

- (NSString *)getPlainString {
    NSMutableString *plainString = [NSMutableString stringWithString:self.string];
    __block NSUInteger base = 0;
    
    [self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length)
                     options:0
                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                      if (value && [value isKindOfClass:[WH_EmojiTextAttachment class]]) {
                          [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length)
                                                     withString:((WH_EmojiTextAttachment *) value).emojiTag];
                          base += ((WH_EmojiTextAttachment *) value).emojiTag.length - 1;
                      }
                  }];
    
    return plainString;
}

@end
