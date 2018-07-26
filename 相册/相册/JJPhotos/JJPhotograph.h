//
//  JJPhotograph.h
//  JJPhotograph
//
//  Created by 16 on 2018/7/25.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JJPhotograph;

typedef NS_ENUM(NSInteger , JJ_PhotographType) {
    JJ_PhotographTypeNomal = 0, // 普通拍照
    JJ_PhotographTypeOnlyImage = 1, // 只有图像
};

@protocol JJPhotographDelegate <NSObject>

/**
 * 移除拍照界面
 */
- (void)JJPhotographDisappear:(JJPhotograph *)photograph save:(BOOL)save;
@end
@interface JJPhotograph : UIView

///代理
@property (nonatomic , weak) id<JJPhotographDelegate>delegate;

/**
 * 创建拍照界面
 * @param type 拍照界面类型
 */
- (instancetype)initWithFrame:(CGRect)frame type:(JJ_PhotographType)type;
@end
