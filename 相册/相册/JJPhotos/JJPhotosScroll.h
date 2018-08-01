//
//  JJPhotosScroll.h
//  相册
//
//  Created by 16 on 2018/8/1.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JJPhotosScrollDelegate<NSObject>


@end
@interface JJPhotosScroll : UIScrollView

@property (nonatomic , weak) id<JJPhotosScrollDelegate>jj_delegate;

/**
 * 显示图片浏览
 * @param items 图片数组
 * @param index 当前显示图片下标
 */
+ (void)showItmes:(NSArray *)items index:(NSInteger)index delegate:(id<JJPhotosScrollDelegate>)delegate;
@end
