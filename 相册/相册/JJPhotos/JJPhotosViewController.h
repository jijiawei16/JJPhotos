//
//  JJPhotosViewController.h
//  封装一些小控件
//
//  Created by 16 on 2018/4/9.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^JJPhotosViewControllerCallBack)(NSArray *images);
@interface JJPhotosViewController : UIViewController

- (instancetype)initWithcallBack:(JJPhotosViewControllerCallBack)callBack;
// 图片最大数
@property (nonatomic , assign) NSInteger maxCount;
@end
