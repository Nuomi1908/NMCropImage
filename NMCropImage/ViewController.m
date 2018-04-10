//
//  ViewController.m
//  NMCropImage
//
//  Created by Nuomi1908 on 2018/4/10.
//  Copyright © 2018年 Nuomi1908. All rights reserved.
//

#import "ViewController.h"
#import "NMConstant.h"
#import "NMImageCropViewController.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, NMImageCropDelegate>
{
    UIImagePickerController * imagePickerVC;
    
    UIImageView * imageView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initSubviews];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initSubviews
{
    UIButton * cameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 80, 120, 50)];
    cameraBtn.backgroundColor = [UIColor lightGrayColor];
    [cameraBtn setTitle:@"相机" forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraBtn];
    
    UIButton * albumBtn = [[UIButton alloc] initWithFrame:CGRectMake(250, 80, 120, 50)];
    albumBtn.backgroundColor = [UIColor lightGrayColor];
    [albumBtn setTitle:@"相册" forState:UIControlStateNormal];
    albumBtn.tag = 1;
    [albumBtn addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumBtn];
    
    imageView = [[UIImageView alloc] init];
    [self.view addSubview:imageView];
}


- (void)buttonClickAction:(UIButton*)btn
{
    if (btn.tag == 0) {//相机
        [self takePhotoFromCamera];
    } else {//相册
        [self takePhotoFromAlbum];
    }

}



#pragma mark ---- 选择图片

- (void)takePhotoFromAlbum
{
    NSLog(@"takePhotoFromAlbum");
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePickerVC = [[UIImagePickerController alloc] init];
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerVC.delegate = self;
        [self presentViewController:imagePickerVC animated:YES completion:^{
            
        }];
    }
}



- (void)takePhotoFromCamera
{
    NSLog(@"takePhotoFromCamera");
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        imagePickerVC = [[UIImagePickerController alloc] init];
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerVC.delegate = self;
        [self presentViewController:imagePickerVC animated:YES completion:^{
            
        }];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [imagePickerVC dismissViewControllerAnimated:YES completion:^{
        if(info && info[@"UIImagePickerControllerOriginalImage"]){
            UIImage * image = info[@"UIImagePickerControllerOriginalImage"];
            
            NMImageCropViewController * v = [[NMImageCropViewController alloc] initWithImage:image];
            v.delegate = self;
            [self presentViewController:v animated:YES completion:^{
                
            }];
        }
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagePickerVC dismissViewControllerAnimated:YES completion:^{
    }];
}


#pragma mark ---- 裁剪图片

- (void)didCropImage:(UIImage*)resultImage
{
    CGSize size = resultImage.size;
    CGFloat newHeight;
    CGFloat newWidth;
    if (size.height > size.width) {//竖图
        newHeight = CurrentScreenHeight/2.0f;
        newWidth = newHeight*size.width/size.height;
    } else {//横图
        newWidth = CurrentScreenWidth/2.0f;
        newHeight = newWidth*size.height/size.width;
    }
    
    imageView.frame = CGRectMake(0, 0, newWidth, newHeight);
    imageView.center = self.view.center;
    imageView.image = resultImage;
}


@end
