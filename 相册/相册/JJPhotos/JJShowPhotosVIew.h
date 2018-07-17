//
//  JJShowPhotosVIew.h
//  封装一些小控件
//
//  Created by 16 on 2018/4/26.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJShowPhotosVIew : UIScrollView

///是否显示保存按钮
@property (nonatomic , assign) BOOL showSave;

///设置数据源
- (void)setUpItems:(NSArray *)items current:(NSInteger)current;
@end
