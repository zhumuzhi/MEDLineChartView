//
//  MEDLineChartData.m
//  AnimationDemo
//
//  Created by 朱慕之 on 2017/10/18.
//  Copyright © 2017年 Meridian. All rights reserved.
//

#import "MEDLineChartData.h"

@implementation MEDLineChartData


+ (instancetype)lineChartDataWithValuesArray:(NSArray *)valuesArray lineColor:(UIColor *)lineColor
{
    MEDLineChartData *data = [[MEDLineChartData alloc]init];
    data.valuesArray = valuesArray;
    data.lineColor = lineColor;
    data.yValuesColor = lineColor;
    data.lineWidth = 1.0f;
    data.yValueFont = 10.0f;
    data.circleSize = 3;
    data.circleType = MEDLineDataCircleTypePoint;
    return data;
}


@end
