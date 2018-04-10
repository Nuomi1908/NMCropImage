//
//  ICImageCropViewController.h
//  NMCropImage
//
//  Created by Nuomi1908 on 2018/3/27.
//  Copyright © 2018年 Nuomi1908 All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol NMImageCropDelegate<NSObject>

- (void)didCropImage:(UIImage*)resultImage;

@end


@interface NMImageCropViewController : UIViewController

@property (nonatomic, weak) id <NMImageCropDelegate>delegate;
- (instancetype)initWithImage:(UIImage*)image;


@end



typedef NS_ENUM(NSInteger, UIViewBoundType) {
    UIViewBoundTypeLeft = 0,
    UIViewBoundTypeBottom,
    UIViewBoundTypeRight,
    UIViewBoundTypeTop,
    UIViewBoundTypeCenter,
};


@interface NMImageCropView: UIView

- (UIViewBoundType)locationInBound:(CGPoint)point;

@end
