//
//  WH_RABatchChangesEntity.h
//  WH_RATreeView
//
//  Created by Rafal Augustyniak on 17/11/15.
//  Copyright © 2015 Rafal Augustyniak. All rights reserved.
//


#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, WH_RABatchChangeType) {
    RABatchChangeTypeItemRowInsertion = 0,
    RABatchChangeTypeItemRowExpansion,
    RABatchChangeTypeItemRowDeletion,
    RABatchChangeTypeItemRowCollapse,
    RABatchChangeTypeItemMove
};


@interface WH_RABatchChangeEntity : NSObject

@property (nonatomic) WH_RABatchChangeType type;
@property (nonatomic) NSInteger ranking;
@property (nonatomic, copy) void(^updatesBlock)();

+ (instancetype)batchChangeEntityWithBlock:(void(^)())updates type:(WH_RABatchChangeType)type ranking:(NSInteger)ranking;

@end

