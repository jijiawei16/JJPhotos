//
//  UIButton+JJType.h
//  shanganju
//
//  Created by 冀佳伟 on 2018/4/16.
//  Copyright © 2018年 rick. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, JJButtonEdgeInsetsStyle) {
    JJButtonEdgeInsetsStyleTop, // image在上，label在下
    JJButtonEdgeInsetsStyleLeft, // image在左，label在右
    JJButtonEdgeInsetsStyleBottom, // image在下，label在上
    JJButtonEdgeInsetsStyleRight // image在右，label在左
};

@interface UIButton (JJType)

/**
 *  设置button的titleLabel和imageView的布局样式，及间距
 *
 *  @param style titleLabel和imageView的布局样式
 *  @param space titleLabel和imageView的间距
 */
- (void)layoutButtonWithEdgeInsetsStyle:(JJButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space;
@end
