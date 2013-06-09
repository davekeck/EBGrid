#import <Foundation/Foundation.h>
#import <EchoBravo/EBFoundation.h>
#if EBTargetOSX
#import <ApplicationServices/ApplicationServices.h>
#elif EBTargetIOS
#import <CoreGraphics/CoreGraphics.h>
#endif

typedef struct
{
    CGFloat leftBorder;
    CGFloat rightBorder;
    CGFloat topBorder;
    CGFloat bottomBorder;
    
    CGSize cellSize;
    CGSize cellSpacing;
} EBGridOptions;

typedef struct
{
    EBGridOptions gridOptions;
    CGFloat containerWidth;
    NSUInteger elementCount;
} EBGridInfo;

EBGridOptions EBGridOptionsMake(CGFloat leftBorder, CGFloat rightBorder, CGFloat topBorder, CGFloat bottomBorder, CGSize cellSize, CGSize cellSpacing);

NSUInteger EBGridColumnCount(EBGridInfo gridInfo);
NSUInteger EBGridRowCount(EBGridInfo gridInfo);
CGSize EBGridContainerSize(EBGridInfo gridInfo);
CGRect EBGridRectForCellIndex(EBGridInfo gridInfo, NSUInteger cellIndex);

/* Returned cell indexes are not bounded by elementCount! */
NSIndexSet *EBGridCellIndexesForRect(EBGridInfo gridInfo, CGRect rect);
NSRange EBGridCellIndexRangeForRect(EBGridInfo gridInfo, CGRect rect);
BOOL EBGridMinMaxCellIndexesForRect(EBGridInfo gridInfo, CGRect rect, NSUInteger *outMinXIndex, NSUInteger *outMaxXIndex, NSUInteger *outMinYIndex, NSUInteger *outMaxYIndex);