//
//  JJAddPhotoCollectionViewCell.h
//  封装一些小控件
//
//  Created by 16 on 2018/4/25.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^JJAddPhotoCollectionViewCellCallBack)(void);
@interface JJAddPhotoCollectionViewCell : UICollectionViewCell

// 通过url设置图片
- (void)setUpImageUrl:(NSString *)imageUrl;
- (void)setUpImageUrl:(NSString *)imageUrl callBack:(JJAddPhotoCollectionViewCellCallBack)callBack;

// 直接设置图片
- (void)setUpImage:(UIImage*)image;
// 点击回调
- (void)setUpImage:(UIImage*)image callBack:(JJAddPhotoCollectionViewCellCallBack)callBack;
@end
