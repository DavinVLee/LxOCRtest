//
//  ViewController.m
//  ORC-testProject
//
//  Created by 李翔 on 17/2/14.
//  Copyright © 2017年 李翔. All rights reserved.
//

#import "ViewController.h"
#import <TesseractOCR/TesseractOCR.h>
//#import <TesseractOCRiOS/TesseractOCR.h>
#import "UIImageCVMatConverter.h"
#import <GPUImage/GPUImage.h>
#import "core_func.h"
#import "LxCameraView.h"
#include "easypr.h"
#include "easypr/util/switch.hpp"
#include "GlobalData.hpp"
using namespace easypr;
CPlateRecognize pr;

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#endif

@interface ViewController ()<G8TesseractDelegate,
                            UITableViewDelegate,
                            UITableViewDataSource,
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate,
                            UIPopoverControllerDelegate
                            >
{
    cv::CascadeClassifier faceCascade;
    cv::Mat source_image;
    cv::Mat RGB;
}

@property (strong, nonatomic) NSMutableArray <UIImage *>*imageArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIPopoverController *popoverController;

@property (strong, nonatomic) NSOperationQueue *queue;
/**
 *旋转角度修正
 */
@property (assign, nonatomic) double angleFix;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = [[NSOperationQueue alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.imageArray = [NSMutableArray array];
    
    
    [self recognizeSetup];

}

- (void)recognizeSetup
{
    NSString* bundlePath=[[NSBundle mainBundle] bundlePath];
    std::string mainPath=[bundlePath UTF8String];
    GlobalData::mainBundle()=mainPath;
    
    cout << "test_plate_recognize" << endl;
    
    pr.setLifemode(true);
    pr.setDebug(false);
    pr.setMaxPlates(1);
    //pr.setDetectType(PR_DETECT_COLOR | PR_DETECT_SOBEL);
    pr.setDetectType(easypr::PR_DETECT_CMSER);
    
//    UIImage *temp = [UIImage imageNamed:@"images.jpeg"];
//    [self.imageArray addObject:temp];
//    UIImage *temp_image=[UIImageCVMatConverter scaleAndRotateImageBackCamera:temp];
//    [self.imageArray addObject:temp_image];
//    source_image = [UIImageCVMatConverter cvMatFromUIImage:temp_image];
//    [self.imageArray addObject:[UIImageCVMatConverter UIImageFromCVMat:source_image]];
//   CGRect scaleRect = [self plateRecognition:source_image withOriginalSize:temp_image.size];
//    [self.tableView reloadData];
//
//    
//    
//    if (scaleRect.size.width > 0) {
//        CGFloat imageOriginW = temp.size.width *temp.scale;
//        CGFloat imageOriginH = temp.size.height *temp.scale;
//        CGRect cutRect = CGRectMake(imageOriginW * scaleRect.origin.x * temp.scale, imageOriginH * scaleRect.origin.y * temp.scale, imageOriginW * scaleRect.size.width*temp.scale, imageOriginH * scaleRect.size.height * temp.scale);
//        CGImageRef imageRef = CGImageCreateWithImageInRect([temp CGImage], cutRect);
//        UIImage *cutResultImage = [UIImage imageWithCGImage:imageRef];
//        CGImageRelease(imageRef);
//        
//        
//        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, temp.size.height/temp.size.width * [UIScreen mainScreen].bounds.size.width)];
//        view.image = temp;
//        [(UIWindow *)[[UIApplication sharedApplication].windows lastObject] addSubview:view];
//        
//        UIView *a = [[UIView alloc] initWithFrame:CGRectMake(scaleRect.origin.x * view.frame.size.width, scaleRect.origin.y * view.frame.size.height, scaleRect.size.width * view.frame.size.width, scaleRect.size.height * view.frame.size.height)];
//        a.backgroundColor = [UIColor clearColor];
//        a.layer.borderColor = [UIColor redColor].CGColor;
//        a.layer.borderWidth = 1;
//        [view addSubview:a];
//        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
//        [view addGestureRecognizer:tap];
//        view.userInteractionEnabled = YES;
//        
//        [self.imageArray addObject:cutResultImage];
//        [self.tableView reloadData];
//        [self tesseractFunctionWithImage:cutResultImage];
//    }

//    NSString *nsstring=[[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
//    string image_path=[nsstring UTF8String];
    
//    source_image=imread(image_path);
//    resize(source_image, source_image,cv::Size(source_image.cols/2,source_image.rows/2));
//    [self.imageArray addObject:[UIImageCVMatConverter UIImageFromCVMat:source_image]];
//    [self plateRecognition:source_image];
//    [self.tableView reloadData];
}

#pragma mark -ClickAction
- (IBAction)AlbumClick:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary])
        return;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];

}

- (IBAction)CameraClick:(id)sender {
    
    [self.imageArray removeAllObjects];
    LxCameraView *cameraView = [[LxCameraView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:cameraView];
    [cameraView setupDefaultWithBlock:^(UIImage *image) {
        [self translateTextWithImage:image];
    }];
    cameraView.alpha = 0;
    [UIView transitionWithView:cameraView duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        cameraView.alpha = 1;
    } completion:nil];
}

#pragma mark imagePickDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self.imageArray removeAllObjects];
    self.label.text = @"";
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *temp = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self translateTextWithImage:temp];
        //显示截取区域
//        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, temp.size.height/temp.size.width * [UIScreen mainScreen].bounds.size.width)];
//        view.image = temp;
//        [(UIWindow *)[[UIApplication sharedApplication].windows lastObject] addSubview:view];
//        
//        UIView *a = [[UIView alloc] initWithFrame:CGRectMake(scaleRect.origin.x * view.frame.size.width, scaleRect.origin.y * view.frame.size.height, scaleRect.size.width * view.frame.size.width, scaleRect.size.height * view.frame.size.height)];
//        a.backgroundColor = [UIColor clearColor];
//        a.layer.borderColor = [UIColor redColor].CGColor;
//        a.layer.borderWidth = 1;
//        [view addSubview:a];
//        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
//        [view addGestureRecognizer:tap];
//        view.userInteractionEnabled = YES;
        
       
        
        
        
       
   
   
  
    
}

- (void)translateTextWithImage:(UIImage *)image
{
    [self.imageArray addObject:image];
    UIImage *temp_image=[UIImageCVMatConverter scaleAndRotateImageBackCamera:image];
    [self.imageArray addObject:temp_image];
    source_image = [UIImageCVMatConverter cvMatFromUIImage:temp_image];
    //[self.imageArray addObject:[UIImageCVMatConverter UIImageFromCVMat:source_image]];
    
    CGRect scaleRect = [self plateRecognition:source_image withOriginalSize:temp_image.size];
    
    //scaleRect = CGRectMake(0, 0, 0.5, 0.5);
    if (scaleRect.size.width > 0) {
        
        
        CGFloat offset = 0;//截取图片框偏移大小
        CGRect cutRect =  CGRectMake(scaleRect.origin.x * image.size.width - offset, scaleRect.origin.y * image.size.height - offset, scaleRect.size.width * image.size.width + offset * 2, scaleRect.size.height * image.size.height + offset * 2);
        UIImage *originImage = [self RotateImageBackCamera:image];//图片方向导致截取方向出现问题，故选装方向为一致
        CGImageRef imageRef = CGImageCreateWithImageInRect([originImage CGImage], cutRect);
        UIImage *cutResultImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:UIImageOrientationUp];
        
        CGImageRelease(imageRef);
        [self.imageArray addObject:cutResultImage];
        
        //角度修正，
        cv::Mat resultMatImage = [UIImageCVMatConverter cvMatFromUIImage:cutResultImage];
        cv::Mat angleFixMat = rotateImg(resultMatImage, self.angleFix);
        UIImage *angleFixImage = [UIImageCVMatConverter imageWithMat:angleFixMat andImageOrientation:UIImageOrientationUp];
        [self.imageArray addObject:angleFixImage];
        
        [self tesseractFunctionWithImage:angleFixImage];
        }
    [self.tableView reloadData];
}


- (UIImage *)RotateImageBackCamera:(UIImage *)image
{
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = 1;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp:
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"resize w%f,H%f",returnImage.size.width,returnImage.size.height);
    return returnImage;

}
- (void)tapGesture:(UITapGestureRecognizer *)ges
{
    [ges.view removeFromSuperview];
}

-(CGRect)plateRecognition:(cv::Mat&)src withOriginalSize:(CGSize)originalSize
{
    UIImage *plateimage;
    
    vector<CPlate> plateVec;
    double t=cv::getTickCount();
    int result = pr.plateRecognize(src, plateVec);
    t=cv::getTickCount()-t;
    NSLog(@"time %f",t*1000/cv::getTickFrequency());
    if (result == 0) {
        size_t num = plateVec.size();
        for (size_t j = 0; j < num; j++) {
            cout << "plateRecognize: " << plateVec[j].getPlateStr() << endl;
        }
    }
    
    if (result != 0) cout << "result:" << result << endl;
    if(plateVec.size()==0){
       
        [self.label performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"No Plate"] waitUntilDone:NO];
        return CGRectZero;
//        return plateimage;
    }
    string name=plateVec[0].getPlateStr();
    NSString *resultMessage = [NSString stringWithCString:plateVec[0].getPlateStr().c_str()
                                                 encoding:NSUTF8StringEncoding];
    [self.label performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%@",resultMessage] waitUntilDone:NO];
    
    
    if (result != 0)
        cout << "result:" << result << endl;
    plateimage = [UIImageCVMatConverter UIImageFromCVMat:plateVec[0].getPlateMat()];

    //计算实际的大小
    //CGSize originalSize = CGSizeMake(src.rows, src.cols);
    CGRect cutRect = CGRectMake(plateVec[0].m_platePos.center.x - plateVec[0].m_platePos.size.width/2.f, plateVec[0].m_platePos.center.y - plateVec[0].m_platePos.size.height/2.f, plateVec[0].m_platePos.size.width, plateVec[0].m_platePos.size.height);
    
//     CGRect cutRect = CGRectMake(plateVec[0].m_mergeCharRect.x, plateVec[0].m_mergeCharRect.y , plateVec[0].m_mergeCharRect.width, plateVec[0].m_mergeCharRect.height);
    
    NSLog(@"得到的截取内容x = %f y = %f w = %f h = %f",CGRectGetWidth(cutRect),CGRectGetHeight(cutRect),CGRectGetMinX(cutRect),CGRectGetMinY(cutRect));
    
    CGFloat offset = 0;
    self.angleFix = plateVec[0].m_platePos.angle;
    
     [self.imageArray addObject:[UIImageCVMatConverter UIImageFromCVMat:plateVec[0].m_plateMat]];
    return  CGRectMake(CGRectGetMinX(cutRect)/originalSize.width - offset, CGRectGetMinY(cutRect)/originalSize.height - offset, CGRectGetWidth(cutRect)/originalSize.width + offset*2,CGRectGetHeight(cutRect)/originalSize.height+ offset*2) ;
}


#pragma mark - tesseractFunction

- (void)tesseractFunctionWithImage:(UIImage *)inputImage
{

    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"chi_sim+eng"];
    //获取去阈值图片
    //抓取要预处理的图像
    
    UIImage *grayImage = [inputImage g8_grayScale];
    [self.imageArray addObject:grayImage];
//
    UIImage *blackImage = [inputImage g8_blackAndWhite];
    [self.imageArray addObject:blackImage];
    
//        //初始化我们的自适应阈值过滤器
//        GPUImageAdaptiveThresholdFilter * stillImageFilter = [[GPUImageAdaptiveThresholdFilter alloc ] init ];
//        stillImageFilter.blurRadiusInPixels = 4.0;  //调整此设置以调整过滤器的模糊半径，默认为4.0
//        //从过滤器中检索过滤的图像
//        UIImage * filteredImage = [stillImageFilter imageByFilteringImage: blackImage];
//    
    //operation.tesseract.image = [[UIImage imageNamed:@"Lenore.png"] g8_blackAndWhite];
    operation.tesseract.image = blackImage;
    operation.tesseract.charWhitelist = @"川甘黑津辽闽琼晋新粤浙鄂贵沪京鲁宁陕皖豫云赣桂冀吉蒙青苏湘渝藏1234567890QWERTYUIOPASDFGHJKLZXCVBNM";
    [self.imageArray addObject:[operation.tesseract image]];
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeSingleColumn;
    operation.tesseract.delegate = self;
    
    
    operation.recognitionCompleteBlock = ^(G8Tesseract *recognizedTesseract) {
        NSLog(@"%@", [recognizedTesseract recognizedText]);
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString *str = self.label.text;
//            self.label.text = [NSString stringWithFormat:@"%@---%@",str,[recognizedTesseract recognizedText]];
            [self.tableView reloadData];
        });
        
    };
   
    [self.queue addOperation:operation];

}

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    
    if (![self.imageArray containsObject:[tesseract thresholdedImage]]) {
        [self.imageArray addObject:[tesseract thresholdedImage]];
    }
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}


- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark TableView_Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UIImageView *view = [cell viewWithTag:100];
    if (view) {
        if (self.imageArray.count > indexPath.row) {
              view.image = self.imageArray[indexPath.row];
        }
       
    }else
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 376, 120)];
        view.tag = 100;
        view.contentMode = UIViewContentModeScaleAspectFit;
        if (self.imageArray.count > indexPath.row) {
           view.image = self.imageArray[indexPath.row];
        }
       
        [cell addSubview:view];
    }
    
    return cell;
}


@end
