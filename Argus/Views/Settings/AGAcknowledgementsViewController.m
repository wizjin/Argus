//
//  AGAcknowledgementsViewController.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGAcknowledgementsViewController.h"
#import <sys/stat.h>
#import "AGTheme.h"

@implementation AGAcknowledgementsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Acknowledgements".localized;
        
    AGTheme *theme = AGTheme.shared;

    UIScrollView *view = [UIScrollView new];
    [self.view addSubview:view];
    view.alwaysBounceVertical = YES;
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIView *lastView = nil;
    UIFont *titleFont = [UIFont boldSystemFontOfSize:18];
    UIFont *contextFont = [UIFont systemFontOfSize:14];

    NSString *path = [[NSBundle.mainBundle pathForResource:@"Settings" ofType:@"bundle"] stringByAppendingPathComponent:@"Acknowledgements.plist"];
    NSDictionary *data = [self loadPlist:path];
    for (NSDictionary *item in [data valueForKey:@"PreferenceSpecifiers"]) {
        NSString *title = [item valueForKey:@"Title"];
        if (title.length > 0) {
            if (lastView == nil) {
                lastView = [UIView new];
                [view addSubview:lastView];
                [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.view).offset(20);
                    make.right.equalTo(self.view).offset(-20);
                    make.top.equalTo(view).offset(8);
                }];
            } else {
                UILabel *label = [UILabel new];
                [view addSubview:label];
                label.font = titleFont;
                label.text = title;
                label.textColor = theme.labelColor;
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.equalTo(lastView);
                    make.top.equalTo(lastView.mas_bottom).offset(20);
                }];
                lastView = label;
            }
        }
        NSString *context = [item valueForKey:@"FooterText"];
        if (context.length > 0) {
            UILabel *label = [UILabel new];
            [view addSubview:label];
            label.numberOfLines = 0;
            label.font = contextFont;
            label.textColor = theme.minorLabelColor;
            label.text = [context stringByAppendingString:@"\n"];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(lastView);
                make.top.equalTo(lastView.mas_bottom).offset(20);
            }];
            lastView = label;
        }
    }
    [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(view);
    }];
}

#pragma mark - Private Methods
- (NSDictionary *)loadPlist:(NSString *)path {
    NSData *data = nil;
    struct stat sb;
    bzero(&sb, sizeof(sb));
    const char *filepath = path.UTF8String;
    if (stat(filepath, &sb) == 0) {
        size_t len = sb.st_size;
        if (len > 0) {
            FILE *fp = fopen(filepath, "rb");
            if (fp != NULL) {
                uint8_t *pdata = malloc(len);
                if (pdata != NULL) {
                    if (fread(pdata, len, 1, fp) == 1) {
                        data = [NSData dataWithBytesNoCopy:pdata length:len]; // Note: NSData Will auto free
                    } else {
                        free(pdata);
                    }
                }
            }
        }
    }
    NSDictionary *result = nil;
    if (data.length > 0) {
        NSError *error = nil;
        NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:&error];
        if (error == nil) {
            result = plist;
        }
    }
    return result;
}


@end
