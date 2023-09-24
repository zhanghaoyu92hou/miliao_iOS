//
//  WH_RABatchChangesEntity.m
//  WH_RATreeView
//
//  Created by Rafal Augustyniak on 17/11/15.
//  Copyright © 2015 Rafal Augustyniak. All rights reserved.
//


#import "WH_RABatchChangeEntity.h"


@implementation WH_RABatchChangeEntity

+ (instancetype)batchChangeEntityWithBlock:(void (^)())updates type:(WH_RABatchChangeType)type ranking:(NSInteger)ranking
{
    NSParameterAssert(updates);
    WH_RABatchChangeEntity *entity = [WH_RABatchChangeEntity new];
    entity.type = type;
    entity.ranking = ranking;
    entity.updatesBlock = updates;

    return entity;
}

- (NSComparisonResult)compare:(WH_RABatchChangeEntity *)otherEntity
{
    if ([self destructiveOperation]) {
        if (![otherEntity destructiveOperation]) {
            return NSOrderedAscending;
        } else {
            return [@(otherEntity.ranking) compare:@(self.ranking)];
        }
    } else if (self.type == RABatchChangeTypeItemMove && otherEntity.type != RABatchChangeTypeItemMove) {
        return [otherEntity destructiveOperation] ? NSOrderedAscending : NSOrderedDescending;

    } else if ([self constructiveOperation]) {
        if (![otherEntity constructiveOperation]) {
            return NSOrderedDescending;
        } else {
            return [@(self.ranking) compare:@(otherEntity.ranking)];
        }

    } else {
        return NSOrderedSame;
    }
}

- (BOOL)constructiveOperation
{
    return self.type == RABatchChangeTypeItemRowExpansion
    || self.type == RABatchChangeTypeItemRowInsertion;
}

- (BOOL)destructiveOperation
{
    return self.type == RABatchChangeTypeItemRowCollapse
    || self.type == RABatchChangeTypeItemRowDeletion;
}

@end

