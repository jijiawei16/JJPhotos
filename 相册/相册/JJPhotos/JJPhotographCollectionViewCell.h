//
//  JJPhotographCollectionViewCell.h
//  相册
//
//  Created by 16 on 2018/7/25.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JJPhotographCollectionViewCellDelegate <NSObject>

///点击了拍照cell
- (void)JJPhotographCollectionViewCellDidSelect;
@end
@interface JJPhotographCollectionViewCell : UICollectionViewCell

@property (nonatomic , weak) id<JJPhotographCollectionViewCellDelegate>delegate;
///显示遮罩
- (void)showShade;
///隐藏遮罩
- (void)hiddenShade;
@end
