#import "EBGrid.h"

EBGridOptions EBGridOptionsMake(CGFloat leftBorder, CGFloat rightBorder, CGFloat topBorder, CGFloat bottomBorder, CGSize cellSize, CGSize cellSpacing)
{
    EBGridOptions result = {.leftBorder = leftBorder, .rightBorder = rightBorder, .topBorder = topBorder, .bottomBorder = bottomBorder, .cellSize = cellSize, .cellSpacing = cellSpacing};
    return result;
}

NSUInteger EBGridColumnCount(EBGridInfo gridInfo)
{
    CGFloat usableWidth = EBCapMin(0, gridInfo.containerWidth - gridInfo.gridOptions.leftBorder - gridInfo.gridOptions.rightBorder);
    NSUInteger columnCount = EBCapMin(1, (NSUInteger)(usableWidth / (gridInfo.gridOptions.cellSize.width + gridInfo.gridOptions.cellSpacing.width)));
    CGFloat minUsedWidth = (columnCount * gridInfo.gridOptions.cellSize.width) + ((columnCount - 1) * gridInfo.gridOptions.cellSpacing.width);
    
    /* The last cell doesn't have horizontal spacing, so it's possible that we miscalculated columnCount and
       it's 1 less than the correct value, so we'll correct that here. */
    if ((minUsedWidth + gridInfo.gridOptions.cellSize.width + gridInfo.gridOptions.cellSpacing.width) <= usableWidth)
        columnCount++;
    
    return columnCount;
}

NSUInteger EBGridRowCount(EBGridInfo gridInfo)
{
    NSUInteger columnCount = EBGridColumnCount(gridInfo);
    return EBCapMin(1, (gridInfo.elementCount / columnCount) + ((gridInfo.elementCount % columnCount) ? 1 : 0));
}

CGSize EBGridContainerSize(EBGridInfo gridInfo)
{
    NSUInteger rowCount = EBGridRowCount(gridInfo);
    return CGSizeMake(gridInfo.containerWidth, gridInfo.gridOptions.topBorder + gridInfo.gridOptions.bottomBorder + (rowCount * gridInfo.gridOptions.cellSize.height) + ((rowCount - 1) * gridInfo.gridOptions.cellSpacing.height));
}

static CGFloat calcAdditionalXSpacing(EBGridInfo gridInfo)
{
    NSUInteger columnCount = EBGridColumnCount(gridInfo);
    CGFloat minUsedWidth = gridInfo.gridOptions.leftBorder + gridInfo.gridOptions.rightBorder + (columnCount * gridInfo.gridOptions.cellSize.width) + ((columnCount - 1) * gridInfo.gridOptions.cellSpacing.width);
    return EBCapMin((gridInfo.containerWidth - minUsedWidth), 0) / (columnCount + 1);
}

CGRect EBGridRectForCellIndex(EBGridInfo gridInfo, NSUInteger cellIndex)
{
    NSUInteger columnCount = EBGridColumnCount(gridInfo);
    NSUInteger rowCount = EBGridRowCount(gridInfo);
    NSUInteger xIndex = cellIndex % columnCount;
    NSUInteger yIndex = cellIndex / columnCount;
    CGFloat additionalXSpacing = (rowCount > 1 ? calcAdditionalXSpacing(gridInfo) : 0);
    return CGRectMake(gridInfo.gridOptions.leftBorder + additionalXSpacing + (xIndex * (gridInfo.gridOptions.cellSize.width + gridInfo.gridOptions.cellSpacing.width + additionalXSpacing)),
        gridInfo.gridOptions.topBorder + (yIndex * (gridInfo.gridOptions.cellSize.height + gridInfo.gridOptions.cellSpacing.height)), gridInfo.gridOptions.cellSize.width, gridInfo.gridOptions.cellSize.height);
}

NSIndexSet *EBGridCellIndexesForRect(EBGridInfo gridInfo, CGRect rect)
{
    NSUInteger minXIndex, maxXIndex;
    NSUInteger minYIndex, maxYIndex;
    BOOL cellIndexesForRectResult = EBGridMinMaxCellIndexesForRect(gridInfo, rect, &minXIndex, &maxXIndex, &minYIndex, &maxYIndex);
        EBConfirmOrPerform(cellIndexesForRectResult, return [NSIndexSet new]);
    
    NSUInteger columnCount = EBGridColumnCount(gridInfo);
    NSMutableIndexSet *result = [NSMutableIndexSet new];
    for (NSUInteger currentYIndex = minYIndex;; currentYIndex++)
    {
        [result addIndexesInRange: NSMakeRange((currentYIndex * columnCount) + minXIndex, maxXIndex - minXIndex + 1)];
        if (currentYIndex == maxYIndex)
            break;
    }
    
    return result;
}

NSRange EBGridCellIndexRangeForRect(EBGridInfo gridInfo, CGRect rect)
{
    NSUInteger minXIndex, maxXIndex;
    NSUInteger minYIndex, maxYIndex;
    BOOL cellIndexesForRectResult = EBGridMinMaxCellIndexesForRect(gridInfo, rect, &minXIndex, &maxXIndex, &minYIndex, &maxYIndex);
        EBConfirmOrPerform(cellIndexesForRectResult, return NSMakeRange(0, 0));
    
    NSUInteger columnCount = EBGridColumnCount(gridInfo);
    NSUInteger firstIndex = (minYIndex * columnCount) + minXIndex;
    NSUInteger lastIndex = (maxYIndex * columnCount) + maxXIndex;
        EBAssertOrRecover(lastIndex >= firstIndex, return NSMakeRange(0, 0));
    
//    #warning debug
//    NSLog(@"visible range: %ju-%ju", (uintmax_t)firstIndex, (uintmax_t)lastIndex);
    
    return NSMakeRange(firstIndex, lastIndex - firstIndex + 1);
}

BOOL EBGridMinMaxCellIndexesForRect(EBGridInfo gridInfo, CGRect rect, NSUInteger *outMinXIndex, NSUInteger *outMaxXIndex, NSUInteger *outMinYIndex, NSUInteger *outMaxYIndex)
{
        NSCParameterAssert(outMinXIndex);
        NSCParameterAssert(outMaxXIndex);
        NSCParameterAssert(outMinYIndex);
        NSCParameterAssert(outMaxYIndex);
    
    NSUInteger columnCount = EBGridColumnCount(gridInfo);
    NSUInteger rowCount = EBGridRowCount(gridInfo);
    
    CGFloat additionalXSpacing = (rowCount > 1 ? calcAdditionalXSpacing(gridInfo) : 0);
    CGFloat combinedCellWidth = (gridInfo.gridOptions.cellSize.width + gridInfo.gridOptions.cellSpacing.width + additionalXSpacing);
    CGFloat combinedCellHeight = (gridInfo.gridOptions.cellSize.height + gridInfo.gridOptions.cellSpacing.height);
    
    CGFloat minX = CGRectGetMinX(rect) - gridInfo.gridOptions.leftBorder - additionalXSpacing;
    CGFloat maxX = CGRectGetMaxX(rect) - gridInfo.gridOptions.leftBorder - additionalXSpacing - 1;
    CGFloat minY = CGRectGetMinY(rect) - gridInfo.gridOptions.topBorder;
    CGFloat maxY = CGRectGetMaxY(rect) - gridInfo.gridOptions.topBorder - 1;
    
    NSInteger minXIndex = floor(minX / combinedCellWidth);
    NSInteger maxXIndex = floor(maxX / combinedCellWidth);
    NSInteger minYIndex = floor(minY / combinedCellHeight);
    NSInteger maxYIndex = floor(maxY / combinedCellHeight);
    
    BOOL minXInCell = EBValueInRangeExclusive(0, gridInfo.gridOptions.cellSize.width, fmod(minX, combinedCellWidth)) && EBValueInRange(0, columnCount - 1, minXIndex);
    BOOL maxXInCell = EBValueInRangeExclusive(0, gridInfo.gridOptions.cellSize.width, fmod(maxX, combinedCellWidth)) && EBValueInRange(0, columnCount - 1, maxXIndex);
    BOOL minYInCell = EBValueInRangeExclusive(0, gridInfo.gridOptions.cellSize.height, fmod(minY, combinedCellHeight)) && EBValueInRange(0, rowCount - 1, minYIndex);
    BOOL maxYInCell = EBValueInRangeExclusive(0, gridInfo.gridOptions.cellSize.height, fmod(maxY, combinedCellHeight)) && EBValueInRange(0, rowCount - 1, maxYIndex);
    
    /* Check if we're entirely within spacing */
    if ((!minXInCell && !maxXInCell && minXIndex == maxXIndex) || (!minYInCell && !maxYInCell && minYIndex == maxYIndex))
        return NO;
    
    if (!minXInCell)
        minXIndex++;
    
    if (!minYInCell)
        minYIndex++;
    
    minXIndex = EBCapRange(0, columnCount - 1, minXIndex);
    maxXIndex = EBCapRange(0, columnCount - 1, maxXIndex);
    minYIndex = EBCapRange(0, rowCount - 1, minYIndex);
    maxYIndex = EBCapRange(0, rowCount - 1, maxYIndex);
    
        /* Sanity-check our result */
        EBAssertOrRecover(minXIndex <= maxXIndex, return NO);
        EBAssertOrRecover(minYIndex <= maxYIndex, return NO);
    
    *outMinXIndex = minXIndex;
    *outMaxXIndex = maxXIndex;
    *outMinYIndex = minYIndex;
    *outMaxYIndex = maxYIndex;
    return YES;
}
