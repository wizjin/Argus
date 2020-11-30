//
//  AGScanViewController.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <PhotosUI/PHPicker.h>
#import <Toast/Toast.h>
#import "AGRouter.h"
#import "AGTheme.h"

@interface AGScanViewController () <AVCaptureMetadataOutputObjectsDelegate, PHPickerViewControllerDelegate>

@property (nonatomic, readonly, assign) BOOL isClosed;
@property (nonatomic, readonly, strong) AVCaptureSession *captureSession;
@property (nonatomic, readonly, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, readonly, strong) UIButton *photoButton;
@property (nonatomic, readonly, strong) dispatch_queue_t workrtQueue;
@property (nonatomic, nullable, strong) UINavigationBar *lastNavBar;
@property (nonatomic, nullable, strong) UIColor *navBGColor;
@property (nonatomic, nullable, strong) UIImage *navBGImage;
@property (nonatomic, nullable, strong) UIImage *navBackImage;
@property (nonatomic, nullable, strong) UIImage *navBackMaskImage;
@property (nonatomic, assign) BOOL navTranslucent;

@end

@implementation AGScanViewController

- (instancetype)init {
    if (self = [super init]) {
        _isClosed = NO;
        _captureSession = nil;
        _videoPreviewLayer = nil;
        _workrtQueue = dispatch_queue_create("com.wizjin.argus.scan", NULL);
    }
    return self;
}

- (void)dealloc {
    if (self.captureSession) {
        [self.captureSession stopRunning];
        _captureSession = nil;
    }
    if (self.videoPreviewLayer) {
        [self.videoPreviewLayer removeFromSuperlayer];
        _videoPreviewLayer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AGTheme *theme = AGTheme.shared;
    // Init capture
    NSError *error = nil;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (input != nil) {
        AVCaptureSession *captureSession = [AVCaptureSession new];
        _captureSession = captureSession;
        [captureSession addInput:input];
        AVCaptureMetadataOutput *captureMetadataOutput = [AVCaptureMetadataOutput new];
        [captureSession addOutput:captureMetadataOutput];
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:self.workrtQueue];
        [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];

        UIView *viewPreview = self.view;
        AVCaptureVideoPreviewLayer *videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        [viewPreview.layer addSublayer:(_videoPreviewLayer = videoPreviewLayer)];
        [videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [videoPreviewLayer setFrame:viewPreview.layer.bounds];
    }
    UIButton *photoButton = [UIButton systemButtonWithImage:[UIImage systemImageNamed:@"photo"] target:self action:@selector(actionSelectPhoto:)];
    [self.view addSubview:(_photoButton = photoButton)];
    photoButton.backgroundColor = [theme.labelColor colorWithAlphaComponent:0.8];
    photoButton.tintColor = theme.backgroundColor;
    CGFloat radius = 28;
    photoButton.layer.cornerRadius = radius;
    [photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(radius * 2, radius * 2));
        make.right.equalTo(self.view).offset(-24);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-64);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.lastNavBar == nil) {
        UINavigationBar *navigationBar = self.navigationController.navigationBar;

        self.lastNavBar = navigationBar;
        
        _navBGColor = navigationBar.backgroundColor;
        _navBGImage = [navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        _navTranslucent = navigationBar.translucent;
        _navBackImage = navigationBar.backIndicatorImage;
        _navBackMaskImage = navigationBar.backIndicatorTransitionMaskImage;

        [navigationBar setBackgroundImage:AGTheme.shared.clearImage forBarMetrics:UIBarMetricsDefault];
        navigationBar.backgroundColor = UIColor.clearColor;
        navigationBar.translucent = YES;
        
        UIImage *backImage = [UIImage systemImageNamed:@"chevron.backward.circle.fill"];
        navigationBar.backIndicatorImage = backImage;
        navigationBar.backIndicatorTransitionMaskImage = backImage;
    }
    [self startScan];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopScan];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.lastNavBar != nil) {
        UINavigationBar *navigationBar = self.lastNavBar;
        
        navigationBar.backIndicatorImage = self.navBackImage;
        navigationBar.backIndicatorTransitionMaskImage = self.navBackMaskImage;

        [navigationBar setBackgroundImage:self.navBGImage forBarMetrics:UIBarMetricsDefault];
        navigationBar.backgroundColor = self.navBGColor;
        navigationBar.translucent = self.navTranslucent;

        self.lastNavBar = nil;
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *qrCode = [metadataObj stringValue];
            if ([qrCode length] > 0) {
                @weakify(self);
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [self findQrCode:qrCode];
                });
            }
        }
    }
}

#pragma mark - PHPickerViewControllerDelegate
- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    @weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        if (results.count > 0) {
            NSItemProvider *itemProvider = results.firstObject.itemProvider;
            if ([itemProvider canLoadObjectOfClass:UIImage.class]) {
                [itemProvider loadObjectOfClass:UIImage.class completionHandler:^(__kindof id<NSItemProviderReading> _Nullable object, NSError * _Nullable error) {
                    if ([object isKindOfClass:UIImage.class]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @strongify(self);
                            [self scanImage:(UIImage *)object];
                        });
                    }
                }];
            }
        }
    }];
}

#pragma mark - Private Methods
- (void)actionSelectPhoto:(id)sender {
    PHPickerConfiguration *configuration = [PHPickerConfiguration new];
    configuration.filter = PHPickerFilter.imagesFilter;
    configuration.selectionLimit = 1;
    PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:configuration];
    pickerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    pickerViewController.delegate = self;
    [self presentViewController:pickerViewController animated:YES completion:nil];
}

- (void)startScan {
    if (self.captureSession != nil && !self.captureSession.isRunning) {
        [self.captureSession startRunning];
    }
}

- (void)stopScan {
    if (self.captureSession != nil && self.captureSession.isRunning) {
        [self.captureSession stopRunning];
    }
}

- (void)findQrCode:(NSString *)code {
    if (!self.isClosed) {
        _isClosed = YES;
        [self.navigationController popViewControllerAnimated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [AGRouter.shared handleURL:[NSURL URLWithString:code]];
        });
    }
}

- (void)scanImage:(UIImage *)image {
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSArray<CIFeature *> *features = [detector featuresInImage:[[CIImage alloc] initWithImage:image]];
    for (CIFeature *feature in features) {
        if ([feature isKindOfClass:CIQRCodeFeature.class]) {
            NSString *code = [(CIQRCodeFeature *)feature messageString];
            if (code.length > 0) {
                [self findQrCode:code];
            }
            return;
        }
    }
    [self.view makeToast:@"No QR code".localized];
}


@end
