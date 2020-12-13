//
//  ComplicationController.m
//  Watch Extension
//
//  Created by WizJin on 2020/12/11.
//

#import "ComplicationController.h"
#import "Theme.h"

@implementation ComplicationController

#pragma mark - Complication Configuration

- (void)getComplicationDescriptorsWithHandler:(void (^)(NSArray<CLKComplicationDescriptor *> * _Nonnull))handler {
    NSMutableArray *families = [NSMutableArray arrayWithArray:CLKAllComplicationFamilies()];
    [families removeObject:@(CLKComplicationFamilyModularLarge)];
    [families removeObject:@(CLKComplicationFamilyUtilitarianLarge)];
    [families removeObject:@(CLKComplicationFamilyExtraLarge)];
    [families removeObject:@(CLKComplicationFamilyGraphicExtraLarge)];
    NSArray<CLKComplicationDescriptor *> *descriptors = @[
        [[CLKComplicationDescriptor alloc] initWithIdentifier:@"complication"
                                                  displayName:@"Argus"
                                            supportedFamilies:families]
        // Multiple complication support can be added here with more descriptors
    ];
    
    // Call the handler with the currently supported complication descriptors
    handler(descriptors);
}

- (void)handleSharedComplicationDescriptors:(NSArray<CLKComplicationDescriptor *> *)complicationDescriptors {
    // Do any necessary work to support these newly shared complication descriptors
}

#pragma mark - Timeline Configuration

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler(nil);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    // Call the handler with your desired behavior when the device is locked
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    [self getLocalizableSampleTemplateForComplication:complication withHandler:^(CLKComplicationTemplate *_Nullable complicationTemplate) {
        if (complicationTemplate == nil) {
            handler(nil);
        } else {
            CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry new];
            entry.complicationTemplate = complicationTemplate;
            entry.date = NSDate.now;
            handler(entry);
        }
    }];
}

//- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
//    // Call the handler with the timeline entries after the given date
//    handler(nil);
//}

#pragma mark - Sample Templates

- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    switch (complication.family) {
        case CLKComplicationFamilyModularSmall:
            handler([CLKComplicationTemplateModularSmallSimpleImage templateWithImageProvider:[self imageProvider:@"Modular"]]);
            break;
        case CLKComplicationFamilyModularLarge:
            handler(nil);
            break;
        case CLKComplicationFamilyUtilitarianSmall:
            handler([CLKComplicationTemplateUtilitarianSmallSquare templateWithImageProvider:[self imageProvider:@"Utilitarian"]]);
            break;
        case CLKComplicationFamilyUtilitarianSmallFlat:
            handler([CLKComplicationTemplateUtilitarianSmallFlat templateWithTextProvider:[CLKTextProvider textProviderWithFormat:@"Argus"] imageProvider:[self imageProvider:@"Utilitarian"]]);
            break;
        case CLKComplicationFamilyUtilitarianLarge:
            handler(nil);
            break;
        case CLKComplicationFamilyCircularSmall:
            handler([CLKComplicationTemplateCircularSmallSimpleImage templateWithImageProvider:[self imageProvider:@"Circular"]]);
            break;
        case CLKComplicationFamilyExtraLarge:
            handler(nil);
            break;
        case CLKComplicationFamilyGraphicCorner:
            handler([CLKComplicationTemplateGraphicCornerTextImage templateWithTextProvider:[CLKTextProvider textProviderWithFormat:@"Argus"] imageProvider:[self imageColorProvider:@"Graphic Corner"]]);
            break;
        case CLKComplicationFamilyGraphicBezel:
            handler([CLKComplicationTemplateGraphicBezelCircularText templateWithCircularTemplate:[CLKComplicationTemplateGraphicCircularImage templateWithImageProvider:[self imageColorProvider:@"Graphic Circular"]]]);
            break;
        case CLKComplicationFamilyGraphicCircular:
            handler([CLKComplicationTemplateGraphicCircularImage templateWithImageProvider:[self imageColorProvider:@"Graphic Circular"]]);
            break;
        case CLKComplicationFamilyGraphicRectangular:
            handler([CLKComplicationTemplateGraphicRectangularFullImage templateWithImageProvider:[self imageColorProvider:@"Graphic Circular"]]);
            break;
        case CLKComplicationFamilyGraphicExtraLarge:
            handler(nil);
            break;
    }
}

#pragma mark - Private Mehods
- (CLKImageProvider *)imageProvider:(NSString *)name {
    CLKImageProvider *provider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:[NSString stringWithFormat:@"Complication/%@", name]]];
    return provider;
}

- (CLKFullColorImageProvider *)imageColorProvider:(NSString *)name {
    return [CLKFullColorImageProvider providerWithFullColorImage:[UIImage imageNamed:[NSString stringWithFormat:@"Complication/%@", name]]];
}


@end
