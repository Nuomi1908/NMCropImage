//
//  ICImageCropViewController.m
//  NMCropImage
//
//  Created by Nuomi1908 on 2018/3/27.
//  Copyright © 2018年 Nuomi1908 All rights reserved.
//

#import "NMImageCropViewController.h"
#import "NMConstant.h"


@interface NMImageCropViewController (){
    CGRect oldCropRect;
    
    NMImageCropView * cropView;
    UIImageView * imageView;
}

@property (nonatomic, strong) UIImage * image;

@end

//裁剪框四周的圆点半径
static const CGFloat radius = 12.0f;
static const CGFloat minWidth = 174.f;

@implementation NMImageCropViewController

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.image = [self fixOrientation:image];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUIView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUIView
{
    self.view.backgroundColor = [UIColor blackColor];
    
    CGSize size = _image.size;
    CGFloat newHeight = CurrentScreenHeight-150;
    CGFloat newWidth = newHeight*size.width/size.height;

    imageView = [[UIImageView alloc] initWithImage:_image];
    imageView.frame = CGRectMake(0, 100, newWidth, newHeight);
    CGPoint center = imageView.center;
    center.x = self.view.center.x;
    imageView.center = center;
    [self.view addSubview:imageView];
    
    cropView = [[NMImageCropView alloc] initWithFrame:CGRectMake(imageView.frame.origin.x-radius, imageView.frame.origin.y-radius, imageView.frame.size.width+radius*2, imageView.frame.size.height+radius*2)];
    cropView.backgroundColor = [UIColor clearColor];
    [cropView addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)]];
    oldCropRect = cropView.frame;
    [self.view addSubview:cropView];
    
    UIButton * saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    saveBtn.titleLabel.textColor = [UIColor whiteColor];
    [saveBtn addTarget:self action:@selector(saveButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    
    UIButton * cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(CurrentScreenWidth-200, 0, 200, 100)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.textColor = [UIColor whiteColor];
    [cancelBtn addTarget:self action:@selector(cancelButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
}



- (void)saveButtonClickAction
{
    //裁剪图片
    CGRect rect = [cropView convertRect:cropView.bounds toView:imageView];
    CGFloat scale = _image.size.width/imageView.frame.size.width;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(_image.CGImage, CGRectMake(rect.origin.x*scale, rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale));
    UIImage *clipImage = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (_delegate && [_delegate respondsToSelector:@selector(didCropImage:)]) {
            [_delegate didCropImage:clipImage];
        }
    }];
}



- (void)cancelButtonClickAction
{
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}


- (void)pan:(UIPanGestureRecognizer*)panGestureRecognizer
{
    NMImageCropView *view = (NMImageCropView*)panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view];
        CGPoint location = [panGestureRecognizer locationInView:view];
        
        //裁剪框不能超出图片边界
        UIViewBoundType type = [view locationInBound:location];
        CGRect frame = view.frame;
        switch (type) {
            case UIViewBoundTypeLeft:{
                CGFloat newWidth = frame.size.width - translation.x;
                if (translation.x < 0) {//左移
                    newWidth = newWidth > CGRectGetMaxX(frame)-CGRectGetMinX(oldCropRect)?(CGRectGetMaxX(frame)-CGRectGetMinX(oldCropRect)):newWidth;
                } else {//右移
                    newWidth = newWidth < minWidth?minWidth:newWidth;
                }
                CGFloat newX = CGRectGetMaxX(frame)-newWidth;
                newX = newX < oldCropRect.origin.x?oldCropRect.origin.x:newX;
                frame.origin.x = newX;
                frame.size.width = newWidth;
                view.frame = frame;
                [view setNeedsDisplay];
            }
                break;
                
            case UIViewBoundTypeBottom:{
                CGFloat newHeight = frame.size.height + translation.y;
                if (translation.y > 0) {//下移
                    newHeight = newHeight > CGRectGetMaxY(oldCropRect)-CGRectGetMinY(frame)?(CGRectGetMaxY(oldCropRect)-CGRectGetMinY(frame)):newHeight;;
                } else {//上移
                    newHeight = newHeight < minWidth?minWidth:newHeight;
                }
                frame.size.height = newHeight;
                view.frame = frame;
                [view setNeedsDisplay];
            }
                break;
                
            case UIViewBoundTypeRight:{
                CGFloat newWidth = frame.size.width + translation.x;
                if (translation.x < 0) {//左移
                    newWidth = newWidth < minWidth?minWidth:newWidth;
                } else {//右移
                    newWidth = newWidth > CGRectGetMaxX(oldCropRect)-CGRectGetMinX(frame)?(CGRectGetMaxX(oldCropRect)-CGRectGetMinX(frame)):newWidth;
                }
                frame.size.width = newWidth;
                view.frame = frame;
                [view setNeedsDisplay];
            }
                break;
                
            case UIViewBoundTypeTop:{
                CGFloat newHeight = frame.size.height - translation.y;
                if (translation.y > 0) {//下移
                    newHeight = newHeight < minWidth?minWidth:newHeight;
                } else {//上移
                    newHeight = newHeight > CGRectGetMaxY(frame)-CGRectGetMinY(oldCropRect)?(CGRectGetMaxY(frame)-CGRectGetMinY(oldCropRect)):newHeight;;
                }
                CGFloat newY = CGRectGetMaxY(frame)-newHeight;
                newY = newY < oldCropRect.origin.y?oldCropRect.origin.y:newY;
                frame.size.height = newHeight;
                frame.origin.y = newY;
                view.frame = frame;
                [view setNeedsDisplay];
            }
                break;
                
            default:{//中心移动
                CGFloat newX = view.center.x + translation.x;
                CGFloat newY = view.center.y + translation.y;
                //修正中心点
                if (newX + CGRectGetWidth(frame)/2.0 > CGRectGetMaxX(oldCropRect)) {
                    newX = CGRectGetMaxX(oldCropRect) - CGRectGetWidth(frame)/2.0;
                } else if(newX - CGRectGetWidth(frame)/2.0 < CGRectGetMinX(oldCropRect)){
                    newX = CGRectGetMinX(oldCropRect) + CGRectGetWidth(frame)/2.0;
                }
                
                if (newY + CGRectGetHeight(frame)/2.0 > CGRectGetMaxY(oldCropRect)) {
                    newY = CGRectGetMaxY(oldCropRect) - CGRectGetHeight(frame)/2.0;
                } else if (newY - CGRectGetHeight(frame)/2.0 < CGRectGetMinY(oldCropRect)){
                    newY = CGRectGetMinY(oldCropRect) + CGRectGetHeight(frame)/2.0;
                }
                
                [view setCenter:(CGPoint){newX, newY}];
            }
                break;
        }
        [panGestureRecognizer setTranslation:CGPointZero inView:view];
    }
}


//修改拍摄照片的水平度不然会旋转90度
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end




@implementation NMImageCropView: UIView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 2.0);//线的宽度
    
    //画边框四个圆点
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextAddArc(context, radius, rect.size.height/2.0-radius/2, radius, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathFill);

    CGContextAddArc(context, rect.size.width-radius, rect.size.height/2.0-radius/2, radius, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathFill);

    CGContextAddArc(context, rect.size.width/2.0-radius/2, radius, radius, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathFill);

    CGContextAddArc(context, rect.size.width/2.0-radius/2, rect.size.height-radius, radius, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathFill);
    
    //画四条边框线
    CGPoint line1[2] = {CGPointMake(radius, radius/4*3), CGPointMake(radius, rect.size.height-radius/4*3)};//left
    CGPoint line2[2] = {CGPointMake(rect.size.width-radius, radius/4*3), CGPointMake(rect.size.width-radius, rect.size.height-radius/4*3)};//right
    CGPoint line3[2] = {CGPointMake(radius, radius), CGPointMake(rect.size.width-radius, radius)};//top
    CGPoint line4[2] = {CGPointMake(radius, rect.size.height-radius), CGPointMake(rect.size.width-radius, rect.size.height-radius)};//bottom
    
    CGContextAddLines(context, line1, 2);
    CGContextAddLines(context, line2, 2);
    CGContextAddLines(context, line3, 2);
    CGContextAddLines(context, line4, 2);
    CGContextSetLineWidth(context, radius/2);
    CGContextDrawPath(context, kCGPathStroke);
    
    //画九宫格
    CGPoint aPoints1[2] = {CGPointMake(rect.size.width/3, radius), CGPointMake(rect.size.width/3, rect.size.height-radius)};
    CGPoint aPoints2[2] = {CGPointMake(rect.size.width/3*2, radius), CGPointMake(rect.size.width/3*2, rect.size.height-radius)};
    CGPoint aPoints3[2] = {CGPointMake(radius, rect.size.height/3), CGPointMake(rect.size.width-radius, rect.size.height/3)};
    CGPoint aPoints4[2] = {CGPointMake(radius, rect.size.height/3*2), CGPointMake(rect.size.width-radius, rect.size.height/3*2)};
    
    CGContextAddLines(context, aPoints1, 2);
    CGContextAddLines(context, aPoints2, 2);
    CGContextAddLines(context, aPoints3, 2);
    CGContextAddLines(context, aPoints4, 2);
    CGContextSetLineWidth(context, 2.0);
    CGContextDrawPath(context, kCGPathStroke);
}


- (UIViewBoundType)locationInBound:(CGPoint)point
{
    CGRect rect = self.frame;
    CGFloat margin = minWidth/2;//裁剪框最小size 150x150
    if (point.x < margin) {
        return UIViewBoundTypeLeft;
    }
    
    if (point.x >= rect.size.width - margin) {
        return UIViewBoundTypeRight;
    }
    
    if (point.y < margin) {
        return  UIViewBoundTypeTop;
    }
    
    if (point.y >= rect.size.height - margin) {
        return UIViewBoundTypeBottom;
    }
    
    return UIViewBoundTypeCenter;
}


@end

