//
//  StickyHeaderFlowLayout.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "StickyHeaderFlowLayout.h"

@implementation StickyHeaderFlowLayout

// sticky header flow layout from https://gist.github.com/toblerpwn/5393460

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    UICollectionView * const cv = self.collectionView;
    //CLS_LOG(@"Number of sections = %d", [cv numberOfSections]);
    CGPoint const contentOffset = cv.contentOffset;
    
    //CLS_LOG(@"Adding missing sections");
    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
            [missingSections addIndex:layoutAttributes.indexPath.section];
        }
    }
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [missingSections removeIndex:layoutAttributes.indexPath.section];
        }
    }
    
    [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        
        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        
        [answer addObject:layoutAttributes];
        
    }];
    
    NSInteger numberOfSections = [cv numberOfSections];
    
    //CLS_LOG(@"For loop");
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            
            NSInteger section = layoutAttributes.indexPath.section;
            //CLS_LOG(@"Customizing layout attribute for header in section %d with number of items = %d", section, [cv numberOfItemsInSection:section]);
            
            if (section < numberOfSections) {
                NSInteger numberOfItemsInSection = [cv numberOfItemsInSection:section];
                
                NSIndexPath *firstObjectIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
                NSIndexPath *lastObjectIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
                
                BOOL cellsExist;
                UICollectionViewLayoutAttributes *firstObjectAttrs;
                UICollectionViewLayoutAttributes *lastObjectAttrs;
                
                if (numberOfItemsInSection > 0) { // use cell data if items exist
                    cellsExist = YES;
                    firstObjectAttrs = [self layoutAttributesForItemAtIndexPath:firstObjectIndexPath];
                    lastObjectAttrs = [self layoutAttributesForItemAtIndexPath:lastObjectIndexPath];
                } else { // else use the header and footer
                    cellsExist = NO;
                    firstObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                            atIndexPath:firstObjectIndexPath];
                    lastObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                           atIndexPath:lastObjectIndexPath];
                    
                }
                
                CGFloat topHeaderHeight = (cellsExist) ? CGRectGetHeight(layoutAttributes.frame) : 0;
                CGFloat bottomHeaderHeight = CGRectGetHeight(layoutAttributes.frame);
                CGRect frameWithEdgeInsets = UIEdgeInsetsInsetRect(layoutAttributes.frame,
                                                                   cv.contentInset);
                
                CGPoint origin = frameWithEdgeInsets.origin;
                
                origin.y = MIN(
                               MAX(
                                   contentOffset.y + cv.contentInset.top,
                                   (CGRectGetMinY(firstObjectAttrs.frame) - topHeaderHeight)
                                   ),
                               (CGRectGetMaxY(lastObjectAttrs.frame) - bottomHeaderHeight)
                               );
                
                layoutAttributes.zIndex = 1024;
                layoutAttributes.frame = (CGRect){
                    .origin = origin,
                    .size = layoutAttributes.frame.size
                };
            }
        }
        
    }
    
    return answer;
    
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return YES;
}

@end
