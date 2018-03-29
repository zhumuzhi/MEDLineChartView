//
//  MEDMonitorLineChart.m
//  HealthButlerDoctor
//
//  Created by 朱慕之 on 2017/10/18.
//  Copyright © 2017年 Meridian. All rights reserved.
//

#import "MEDMonitorLineChart.h"
/** 间隙 */
#define Gap 10.f
/** x坐标轴x值 */
//#define XLabelPointX(i) (self.xLabelsWidth/2+self.xLabelsWidth*i + Gap*(i+1))
#define XLabelPointX(i) (self.xLabelsWidth*i + Gap*3) //修改起始位置写死
/** y坐标轴y值 */
#define YLabelPointY(i) (self.topGap+self.sepYLength*i)
/** 圆点半径 */
#define CircleDotRadius 3.f
/** 动画时长 */
#define OneValueAniamtedTime 0.2f

#define YLabelHeight 20.f

#define legendH 20.0f

@interface MEDMonitorLineChart()

@property(nonatomic,assign) CGFloat sepYLength;   //y轴每一格长度
@property(nonatomic,assign) NSInteger maxYValue;  //y轴最大值

@property(nonatomic,assign) CGFloat maxXLength;   //x轴滚动最大长度

@end


@implementation MEDMonitorLineChart

#pragma mark - ***** init *****

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialBase];
    }
    return self;
}

- (void)initialBase
{
    self.backgroundColor = self.chartBackgroundColor; //设置背景颜色
    self.topGap = Gap * 3;  //顶部空隙
    self.isHideYValues = YES; //隐藏监测值标签
    
    //是否显示网格线(X&Y)
    self.isShowXSepratorLine = YES;
    self.isShowYSepratorLine = YES;

    //设置高度、宽度
    // self.ySepLabelCount = 5;    //??
    self.xLabelsHeight = 40.0f;    //决定表格底部起点(底部空出的高度) ?？可能是数值颜色
    self.yLabelWidth   = 30.0f;    //决定表格左边起点(左侧空出的距离)
    
    //每条线的位置
    //XLabelPointX(i) (self.xLabelsWidth/2+self.xLabelsWidth*i + Gap*(i+1))
    CGFloat chartScreenW = self.med_width-self.yLabelWidth-Gap*2;
    CGFloat xLabelsWHalf = ((chartScreenW-(Gap*3))/7)*0.5;
    // CGFloat ChartLeftGap = SCREEN_WIDTH - (self.xLabelsWidth+ Gap);
    self.xLabelsWidth  = (chartScreenW-xLabelsWHalf)/7;
    
    MEDLog(@"SCREEN_WIDTH:%f", SCREEN_WIDTH);
    MEDLog(@"self.xLabelsWidth:%f", self.xLabelsWidth);
    
    self.yLablesColor = MEDRGB(158, 163, 171);
    self.xLabelsColor = MEDRGB(40, 40, 40);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

#pragma mark - ***** stroke *****
- (void)strokeStart
{
    // ******** 此处做为空判断，如果X或YLabel的个数为0 则return 不再绘制 ********
    
    // y轴总长度 (图表高度--顶部空隙--XLanbelHeight)
    CGFloat yLength = self.med_height - self.topGap - self.xLabelsHeight;
    
    // y轴每一格长度
    self.sepYLength = yLength/self.ySepLabelCount;
    
    // maxY--y轴最大值
    CGFloat maxY = 0.0;
    if (self.yMaxValue == 0) {
        maxY = 100;
    }else {
        maxY = self.yMaxValue;
    }
    //或者设置maxY-y轴最大值--根据传入的最大值数据设定
//    for (NSInteger i=0; i<self.yValueLabels.count; i++) {
//        HLLineChartData *data = self.yValueLabels[i];
//        for (int j= 0; j<data.valuesArray.count-1; j++) {
//            if ([data.valuesArray[j] floatValue] < [data.valuesArray[j+1] floatValue]) {
//                maxY = [data.valuesArray[j+1] floatValue];
//            }
//        }
//    }
    self.maxYValue = (ceil(maxY/self.ySepLabelCount))*self.ySepLabelCount;
    
    //********* ScrollViewContent *********
    [self addSubview:self.scrollView];
    //x轴滚动最大长度
    //self.maxXLength = (self.xLabelsWidth+Gap)*(self.xLabels.count)+self.xLabelsWidth/2;
    self.maxXLength = (self.xLabelsWidth)*(self.xLabels.count)+self.xLabelsWidth/2;
    self.scrollView.contentSize = CGSizeMake(self.maxXLength, 0);
    
    //********** 绘图 **********
    [self strokeYSepratorLine];  //画y轴分割线--竖线
    [self strokeXSepratorLine];  //画X轴分割线--横线
    if (!self.isHideYLabels) {   //绘制yLabels
        [self strokeYLabels];
    }
    if (!self.isHideXLables) {   //绘制xLabels
        [self strokeXLabels];
    }
    [self strokeYValues];        //绘制折线 yValues
    [self setupUnitLanbel];      //设置单位标签
    [self setupLegendWithlegends:self.legends];  //绘制图例
}

/** 画Y轴和分割线-竖线 */
- (void)strokeYSepratorLine
{
    //y轴 表格边缘线--第一根线
    UIBezierPath *firstPath = [UIBezierPath bezierPath];
    CGFloat startPointY = self.med_height-self.xLabelsHeight;
    [firstPath moveToPoint:CGPointMake(self.yLabelWidth, startPointY)];
    [firstPath addLineToPoint:CGPointMake(self.yLabelWidth, self.topGap)];
    firstPath.lineWidth = 1.f;
    CAShapeLayer *yShapeLayer = [CAShapeLayer layer];
    yShapeLayer.path = firstPath.CGPath;
    yShapeLayer.strokeColor = MEDGrayColor(232).CGColor;
    [self.layer addSublayer:yShapeLayer];
    
    if (!self.isShowYSepratorLine) { // 如果没有开启X分割线，则不进行绘制
        return;
    }
    
    //分割线
    for (int i = 0; i < self.xLabels.count; i ++) {
        /*
          Gap 10.f
          self.xLabelsWidth = (SCREEN_WIDTH - Gap*5)/2
          XLabelPointX(i) (self.xLabelsWidth/2+self.xLabelsWidth*i + Gap*(i+1))
         */
        //x点坐标
        CGFloat x =  XLabelPointX(i);
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(x, startPointY)];
        [path addLineToPoint:CGPointMake(x, self.topGap)];
        path.lineWidth = 1.f;
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.strokeColor = MEDGrayColor(232).CGColor;
        //设置为虚线
        //shapeLayer.lineDashPhase = 1;
        //shapeLayer.lineDashPattern = @[@3,@3];
        [self.scrollView.layer addSublayer:shapeLayer];
    }

    //最后一根竖线
    CGFloat x = self.maxXLength-0.5;
//    CGFloat x = self.med_width-self.yLabelWidth-Gap*2;
    UIBezierPath *LastPath = [UIBezierPath bezierPath];
    [LastPath moveToPoint:CGPointMake(x,startPointY)];
    [LastPath addLineToPoint:CGPointMake(x, self.topGap)];
    LastPath.lineWidth = 1.f;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = LastPath.CGPath;
    shapeLayer.strokeColor = MEDGrayColor(232).CGColor;
    [self.scrollView.layer addSublayer:shapeLayer];
}

/** 画X轴和分割线--横线*/
- (void)strokeXSepratorLine
{
    for (int i = 0; i < self.ySepLabelCount+1; i ++) {
        if (!self.isShowXSepratorLine && i != self.ySepLabelCount) { // 如果没有开启X分割线，则不进行绘制
            return;
        }
        /*
         self.topGap = 30 即 (Gap*3)
         YLabelPointY(i) (self.topGap+self.sepYLength*i)
         */
        //y点
        CGFloat y =  YLabelPointY(i);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0,y)];
        //[path addLineToPoint:CGPointMake(self.maxXLength-self.xLabelsWidth/2, y)];
        [path addLineToPoint:CGPointMake(self.maxXLength, y)];
        path.lineWidth = 1.f;
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;

        shapeLayer.strokeColor = MEDGrayColor(232).CGColor;
        if (i < self.ySepLabelCount) {
            //设置为虚线
            //shapeLayer.lineDashPhase = 1;
            //shapeLayer.lineDashPattern = @[@3,@3];
        }
        [self.scrollView.layer addSublayer:shapeLayer];
    }
}

//画Y轴坐标(yLabels)
- (void)strokeYLabels
{
    for (int i = 0; i < self.ySepLabelCount+1; i ++)
    {
        //y点
        CGFloat y =  YLabelPointY(i);
        CATextLayer *yText = [CATextLayer layer];
        yText.string = [NSString stringWithFormat:@"%ld",(long)(self.maxYValue - self.maxYValue/self.ySepLabelCount*i)];
        yText.fontSize = 12;
        yText.foregroundColor = self.yLablesColor.CGColor;
        yText.bounds = CGRectMake(0, 0, self.yLabelWidth-5, YLabelHeight);
        yText.position = CGPointMake(self.yLabelWidth/2, y);
        yText.alignmentMode = kCAAlignmentRight;
        yText.contentsScale = [UIScreen mainScreen].scale;//不设置会导致字体模糊
        yText.wrapped = YES;
        [self.layer addSublayer:yText];
    }
}

///画X轴坐标(xLabels)
- (void)strokeXLabels
{
    for (NSInteger i = 0; i < self.xLabels.count; i ++)
    {
        //x点坐标
        CGFloat x =  XLabelPointX(i);
        CATextLayer *xText = [CATextLayer layer];
        NSString *tempStr = self.xLabels[i];
        xText.string = [NSString stringWithFormat:@"%d" , [tempStr intValue]];
        xText.fontSize = 11;
        xText.alignmentMode = kCAAlignmentCenter;
        xText.foregroundColor = self.xLabelsColor.CGColor;
        xText.position = CGPointMake(x, self.med_height-self.xLabelsHeight/2);
        xText.bounds = CGRectMake(0, 0, self.xLabelsWidth, self.xLabelsHeight);
        xText.contentsScale = [UIScreen mainScreen].scale;//不设置会导致字体模糊
        xText.wrapped = YES;
        xText.truncationMode = kCATruncationEnd;
        [self.scrollView.layer addSublayer:xText];
    }
    self.scrollView.contentSize = CGSizeMake(self.maxXLength, 0);
}

/** 绘制折线 */
- (void)strokeYValues
{
    [self drawRectangleViewWithValue1:self.exampleY1 Value2:self.exampleY2];
    //收集所有的点
    NSMutableArray *pointsArray = @[].mutableCopy;
    
    for (int i = 0; i < self.yValueLabels.count; i ++)
    {
        NSMutableArray *arr = @[].mutableCopy;
        MEDLineChartData *data = self.yValueLabels[i];
        NSLog(@"转换的点的个数:%ld", data.valuesArray.count);
        for (int j = 0; j < data.valuesArray.count; j ++)
        {
            CGFloat yValues = [data.valuesArray[j] floatValue];
            //x点坐标
            CGFloat xPoint =  XLabelPointX(j);
            //y点坐标
            CGFloat yPoint = self.med_height-self.xLabelsHeight-(yValues/self.maxYValue * self.sepYLength*self.ySepLabelCount);
            CGPoint point = CGPointMake(xPoint, yPoint);
            NSLog(@"A第%d个血压值为:%f--转换完点为:%@", j, yValues, NSStringFromCGPoint(point));
            
//################## 如果不为0才添加点坐标 ##################
/**  HLLineChartData *data = self.yValueLabels[i];
     CGFloat yValues = [data.valuesArray[j] floatValue];
     if (yValues!=0) */
//################## 如果不为0才添加点坐标 ##################
            
            if (yValues!=0) {
                [arr addObject:[NSValue valueWithCGPoint:point]];
            }
        }
        [pointsArray addObject:arr];
    }
    
    //开始绘制
    for (int j = 0; j < pointsArray.count; j ++)
    {
        //path
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 1.f;
        NSArray *values = pointsArray[j];
        if (values.count == 0) {
            continue;
        }
        NSValue *value = values[0];
        [path moveToPoint:[value CGPointValue]];
        
        //NSLog(@"准备的数据数组:%@", values);
        
        for (NSInteger i = 0; i < values.count; i ++)
        {
            if (i == 0)
            {
                continue;
            }
            NSValue *pointValue = values[i];
            //当前点
            CGPoint currentPoint = [pointValue CGPointValue];
            
            //NSLog(@"B第%ld个血压的值为:%@<-->Y轴的坐标值:%@",(long)i, pointValue, NSStringFromCGPoint(currentPoint));
            
            if (self.lineChartType == MEDMonitorLineChartTypeBrokenLine)
            {
                //折线
                [path addLineToPoint:currentPoint];
            }
            else if (self.lineChartType == MEDMonitorLineChartTypeCurve)
            {
                //曲线
                //上一个点
                CGPoint lastPoint = [values[i-1] CGPointValue];
                
                [path addCurveToPoint:currentPoint controlPoint1:CGPointMake((currentPoint.x+lastPoint.x)/2, lastPoint.y) controlPoint2:CGPointMake((currentPoint.x+lastPoint.x)/2, currentPoint.y)];
            }
        }
        MEDLineChartData *data = self.yValueLabels[j];
        
        //layer
        CAShapeLayer *shaperLayer = [CAShapeLayer layer];
        shaperLayer.path = path.CGPath;
        shaperLayer.strokeColor = data.lineColor.CGColor;
        shaperLayer.fillColor = [UIColor clearColor].CGColor;
        shaperLayer.fillMode = kCAFillModeForwards;
        shaperLayer.lineWidth = data.lineWidth;
        [self.scrollView.layer addSublayer:shaperLayer];
        
        //动画
        if (self.isAnimatedDisplay) {
            CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation1.fromValue = @0;
            animation1.toValue = @1;
            animation1.duration = OneValueAniamtedTime*values.count;
            [shaperLayer addAnimation:animation1 forKey:nil];
        }

        //渐变
        //        if (self.isShowGradientColor) {
        //
        //            CGPoint startPoint = [values.firstObject CGPointValue];
        //            CGPoint endPoint = [values.lastObject CGPointValue];
        //            [path addLineToPoint:CGPointMake(endPoint.x, self.med_height-self.xLabelsHeight)];
        //            [path addLineToPoint:CGPointMake(startPoint.x, self.med_height-self.xLabelsHeight)];
        //            [path addLineToPoint:startPoint];
        //
        //            CAShapeLayer *maskLayer = [CAShapeLayer layer];
        //            maskLayer.path = path.CGPath;
        //
        //            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        //            gradientLayer.frame = CGRectMake(startPoint.x, 0, 0, self.med_height);
        //            gradientLayer.startPoint = CGPointMake(0, 0);
        //            gradientLayer.endPoint = CGPointMake(0, 1);
        //            gradientLayer.colors = @[(__bridge id)[data.lineColor colorWithAlphaComponent:0.5].CGColor,(__bridge id)[data.lineColor colorWithAlphaComponent:0].CGColor];
        //
        //            CALayer *layer = [CALayer layer];
        //            [layer addSublayer:gradientLayer];
        //            layer.mask = maskLayer;
        //
        //            [self.scrollView.layer addSublayer:layer];
        //
        //            CABasicAnimation *anmi1 = [CABasicAnimation animation];
        //            anmi1.keyPath = @"bounds.size.width";
        //            anmi1.duration = OneValueAniamtedTime*(values.count+1);
        //            anmi1.toValue = @(self.maxXLength*2-2*self.xLabelsWidth);
        //            anmi1.fillMode = kCAFillModeForwards;
        //            anmi1.removedOnCompletion = NO;
        //            if (self.isAnimatedDisplay) {
        //                [gradientLayer addAnimation:anmi1 forKey:nil];
        //            }
        //        }
    }
    //yValues圆点和值
    [self strokeCircleDotWithPointArray:pointsArray];
}

//CGPoint convertChartCoordinateToUIKitWith(CGPoint chartPoint,CGPoint chartOriginUIKitPoint) {
//    return CGPointMake(chartOriginUIKitPoint.x+chartPoint.x, chartOriginUIKitPoint.y-chartPoint.y);
//}
//CGPoint convertUIKitCoordinateToChartWith(CGPoint uiPoint,CGPoint chartOriginUIKitPoint) {
//    return CGPointMake(chartOriginUIKitPoint.x-chartOriginUIKitPoint.x, chartOriginUIKitPoint.y-uiPoint.y);
//}


/** 画矩形标识 */
- (void)drawRectangleViewWithValue1:(CGFloat)value1 Value2:(CGFloat)value2 {
    
//        CGFloat yEndP = self.med_height-self.xLabelsHeight-(80.0f/self.maxYValue * self.sepYLength*self.ySepLabelCount)
    
    //矩形起点
    CGFloat rectX = 0;
    CGFloat rectYValue = value1;
    CGFloat rectY = self.med_height-self.xLabelsHeight-(rectYValue/self.maxYValue * self.sepYLength*self.ySepLabelCount);
    CGFloat rectYValue2 = value2;
    CGFloat rectY2 = self.med_height-self.xLabelsHeight-(rectYValue2/self.maxYValue * self.sepYLength*self.ySepLabelCount);
    
    CGFloat rectW = self.maxXLength;           //宽度即为最大距离
    CGFloat rectH = rectY2-rectY;              //高度为设定的两个值的差值
    //NSLog(@"矩形的Y值--%f转换之后的值为:%f--%f转换之后的值为:%f", rectYValue, rectY, rectYValue2, rectY2);
    
    CGRect RectL = CGRectMake(rectX, rectY, rectW, rectH);
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:RectL];

    CAShapeLayer *rectLayer = [CAShapeLayer layer];
    rectLayer.path = rectPath.CGPath;
    UIColor *rectColor = [UIColor colorWithRed:63/255.0 green:187/255.0 blue:48/255.0 alpha:0.3];
    rectLayer.strokeColor = rectColor.CGColor;
    rectLayer.fillColor = rectColor.CGColor;

    rectLayer.fillMode = kCAFillModeForwards;
    [self.scrollView.layer addSublayer:rectLayer];
}


//yValues圆点和值
- (void)strokeCircleDotWithPointArray:(NSArray *)pointArray
{
    for (int j = 0; j <pointArray.count; j ++) {
        MEDLineChartData *data = self.yValueLabels[j];
        NSArray *arr = pointArray[j];

        for (int i = 0; i < arr.count; i ++) {
            CGPoint point = [arr[i] CGPointValue];
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path addArcWithCenter:point radius:data.circleSize startAngle:0 endAngle:M_PI*2 clockwise:YES];
            
            CAShapeLayer *shaperLayer = [CAShapeLayer layer];
            
            if (data.circleType == MEDLineDataCircleTypePoint) { //圆点
                shaperLayer.path = path.CGPath;
                shaperLayer.fillColor = data.lineColor.CGColor;
                shaperLayer.fillMode = kCAFillModeForwards;
            }else if (data.circleType == MEDLineDataCircleTypeCircle) {  //圆环
                shaperLayer.path = path.CGPath;
                shaperLayer.fillColor = [UIColor whiteColor].CGColor;
                shaperLayer.fillMode = kCAFillModeForwards;
                shaperLayer.lineWidth = data.lineWidth;
                shaperLayer.strokeColor = data.lineColor.CGColor;
            }
            
            [self.scrollView.layer addSublayer:shaperLayer];
            
            if (self.isHideYValues) {
                continue;
            }
            
            //****** 绘制文字 ******
            //增加筛选逻辑，如果为0则剔除标签文字
            MEDLineChartData *data = self.yValueLabels[j];
            NSMutableArray *tempArr = [NSMutableArray arrayWithArray:data.valuesArray];
            NSMutableArray *dataArr = [NSMutableArray array];
            for (int m=0; m<tempArr.count; m++) {
                NSString *str = data.valuesArray[m];
                if ([str intValue] != 0) {
                    [dataArr addObject:str];
                }
            }
            CATextLayer *yValue = [CATextLayer layer];
            yValue.string = [NSString stringWithFormat:@"%@",dataArr[i]];
            //增加筛选逻辑，如果为0则剔除标签文字
            
            //HLLineChartData *data = self.yValueLabels[j];
            //CATextLayer *yValue = [CATextLayer layer];
            //yValue.string = [NSString stringWithFormat:@"%@",data.valuesArray[i]];
            
            yValue.fontSize = data.yValueFont;
            yValue.foregroundColor = data.yValuesColor.CGColor;
            yValue.bounds = CGRectMake(0, 0, self.yLabelWidth-5, 16);
            yValue.position = CGPointMake(point.x, point.y-8);
            yValue.alignmentMode = kCAAlignmentCenter;
            yValue.contentsScale = [UIScreen mainScreen].scale;//不设置会导致字体模糊
            yValue.wrapped = YES;
            [self.scrollView.layer addSublayer:yValue];
            //****** 绘制文字 ******
        }
    }
}

/** 设置图例 */
- (void)setupLegendWithlegends:(NSArray *)legends{
    
    UIView *legendView = [[UIView alloc] initWithFrame:CGRectMake(0, self.med_height-25, SCREEN_WIDTH, 20)];
    legendView.backgroundColor = [UIColor whiteColor];
    [self addSubview:legendView];
    
    NSInteger gapCount = legends.count-1;
    if (gapCount<0) {
        gapCount = 0;
    }
    CGFloat gapW = 0;
    CGFloat firstX = ((self.med_width-(legends.count*70)-gapW*gapCount)/2); //(图例宽-图例个数-i*图例间距)/2
    CGFloat itemY = 3;
    CGFloat itemWidth = 14;
    
    for (int i=0; i<legends.count; i++) {
        NSDictionary *itemDict = legends[i];
        
        CGFloat itemX = firstX + 70*i + gapW*i;
        UIView *legendItem = [[UIView alloc] init];
        legendItem.layer.cornerRadius = itemWidth*0.5;
        legendItem.backgroundColor = itemDict[@"color"];
        legendItem.frame = CGRectMake(itemX, itemY, itemWidth, itemWidth);
        [legendView addSubview:legendItem];
        
        UILabel *legendLbl = [[UILabel alloc] initWithFrame:CGRectMake(legendItem.med_right , 0, 50, 20)];
        legendLbl.text = itemDict[@"title"];
        legendLbl.font = [UIFont systemFontOfSize:12];
        legendLbl.textAlignment = NSTextAlignmentCenter;
        [legendView addSubview:legendLbl];
    }
}

/** 设置单位&时间 */
- (void)setupUnitLanbel {
    //检测值单位
    UILabel *unitLbl = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 40, 20)];
    unitLbl.text = self.unitName;
    unitLbl.textColor = MEDRGB(158, 163, 171);
    unitLbl.textAlignment = NSTextAlignmentLeft;
    unitLbl.font = [UIFont systemFontOfSize:12];
    //******* 设置属性来接收 *******
    [self addSubview:unitLbl];
    
    //时间单位
    UILabel *dateLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.med_width-20, self.med_height-(self.xLabelsHeight+2.5), 20, 20)];
    dateLbl.text = @"日";
    dateLbl.textColor = MEDRGB(40, 40, 40);
    dateLbl.textAlignment = NSTextAlignmentLeft;
    dateLbl.font = [UIFont systemFontOfSize:12];
    [self addSubview:dateLbl];
}

#pragma mark ------------------------setter
- (void)setChartBackgroundColor:(UIColor *)chartBackgroundColor
{
    _chartBackgroundColor = chartBackgroundColor;
    self.backgroundColor = _chartBackgroundColor;
}

#pragma mark ------------------------getter
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(self.yLabelWidth, 0, self.med_width-self.yLabelWidth-Gap*2, self.med_height)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

@end
