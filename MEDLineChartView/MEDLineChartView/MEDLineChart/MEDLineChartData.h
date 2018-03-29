//
//  MEDLineChartData.h
//  AnimationDemo
//
//  Created by 朱慕之 on 2017/10/18.
//  Copyright © 2017年 Meridian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MEDLineDataCircleType) {
    MEDLineDataCircleTypeCircle,  //环
    MEDLineDataCircleTypePoint,   //点
};


@interface MEDLineChartData : NSObject

/**
 y值
 */
@property(nonatomic,strong) NSArray<NSString *> *valuesArray;

/**
 线条颜色
 */
@property(nonatomic,strong) UIColor *lineColor;

/**
 线条宽度，default to 1.f
 */
@property(nonatomic,assign) CGFloat lineWidth;

/**
 y值的颜色，default to lineColor
 */
@property(nonatomic,strong) UIColor *yValuesColor;

/**
 y值的大小。default to 10
 */
@property(nonatomic,assign) CGFloat yValueFont;

/**
 点的大小半径，default to 3
 */
@property(nonatomic,assign) CGFloat circleSize;

/**
 点的样式，default to MEDLineDataCircleTypePoint
 */
@property(nonatomic,assign) MEDLineDataCircleType circleType;



+ (instancetype)lineChartDataWithValuesArray:(NSArray *)valuesArray
                                   lineColor:(UIColor *)lineColor;



@end
