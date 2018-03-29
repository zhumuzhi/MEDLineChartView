//
//  MEDMonitorLineChart.h
//  HealthButlerDoctor
//
//  Created by 朱慕之 on 2017/10/18.
//  Copyright © 2017年 Meridian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEDLineChartData.h"

typedef NS_ENUM(NSUInteger, MEDMonitorLineChartType) {
    MEDMonitorLineChartTypeBrokenLine,   //折线
    MEDMonitorLineChartTypeCurve,        //曲线
};


@interface MEDMonitorLineChart : UIView

@property(nonatomic,strong) UIScrollView *scrollView;

/** 图表值单位 */
@property (nonatomic, copy) NSString *unitName;
/** 图例数组 */
@property (nonatomic, strong) NSArray *legends;
/** 每个月的天数 */
@property (nonatomic, assign) NSUInteger daysOfMonth;

/** 上部空出高度，可设置标题和图例等，default to 20 */
@property(nonatomic,assign) CGFloat topGap;
/** 背景颜色，default to white color */
@property(nonatomic,strong) UIColor *chartBackgroundColor;
/** 折线类型，BrokenLine折线/Curve曲线 */
@property(nonatomic,assign) MEDMonitorLineChartType lineChartType;
/** 是否线条动画，default to yes */
@property(nonatomic,assign) BOOL isAnimatedDisplay;
/** 渐变图层，default to yes，lineColor with 0.5 alpha, 必须只有一条线，yValueLabels.count == 1 */
@property(nonatomic,assign) BOOL isShowGradientColor;
/** 是否隐藏y值。defalut to no */
@property(nonatomic,assign) BOOL isHideYValues;



#pragma mark - ******** X轴 ********
/** x轴坐标(个数)，!!必传!! */
@property(nonatomic,strong) NSArray<NSString *> *xLabels;

/** 是否显示X网格线，default NO, dotted line */
@property(nonatomic,assign) BOOL isShowXSepratorLine;

/** x坐标宽度，default to 50.f */
@property(nonatomic,assign) CGFloat xLabelsWidth;
/** x坐标高度，default to 50.f */
@property(nonatomic,assign) CGFloat xLabelsHeight;

/** x轴坐标颜色，default to gray color */
@property(nonatomic,strong) UIColor *xLabelsColor;
/** 隐藏X轴坐标，default to no */
@property(nonatomic,assign) BOOL isHideXLables;


#pragma mark - ******** Y轴 ********
/** y轴值(个数)，!!必传!! */
@property(nonatomic,strong) NSArray<MEDLineChartData *> *yValueLabels;

/** y轴最大值，default to  */
@property(nonatomic,assign) CGFloat yMaxValue;

/** 是否显示Y网格线，default NO, dotted line */
@property(nonatomic,assign) BOOL isShowYSepratorLine;
/** y坐标宽度，default to 30 */
@property(nonatomic,assign) CGFloat yLabelWidth;
/** y轴几个刻度坐标，default to 5 */
@property(nonatomic,assign) NSInteger ySepLabelCount;

/** y轴坐标颜色，default to gray color */
@property(nonatomic,strong) UIColor *yLablesColor;
/** 隐藏Y轴坐标，default to no */
@property(nonatomic,assign) BOOL isHideYLabels;

@property (nonatomic, assign) CGFloat exampleY1;
@property (nonatomic, assign) CGFloat exampleY2;

/** 绘制图表,最后调用 */
- (void)strokeStart;
/** 设置图例 */
//- (void)setupLegendWithlegends:(NSArray *)legends;

@end
