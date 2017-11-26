//
//  OCKTimedSymptomTrackerTableViewCellViewModel.m
//  CareKit
//
//  Created by Ryan Demo on 11/25/17.
//  Copyright © 2017 carekit.org. All rights reserved.
//

#import "OCKTimedSymptomTrackerTableViewCellViewModel.h"
#import "OCKTimedSymptomTrackerViewController.h"
#import "OCKHelpers.h"


@implementation OCKTimedSymptomTrackerTableViewCellViewModel {
    NSDateComponents *_selectedDate;
    NSDate *_earliestEventDate;
}

- (instancetype)init {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithTime:(OCKTimedSymptomTrackerTime)time andEvents:(NSArray<OCKCarePlanEvent *> *)events onSelectedDate:(NSDateComponents *)selectedDate {
    self = [super init];
    if (!self) return nil;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm a"];
    
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:[events count]];
    int completionCount = 0;
    
    for (OCKCarePlanEvent *event in events) {
        [titles addObject:[self shortenedTitleFrom:event]];
        completionCount += event.state == OCKCarePlanEventStateCompleted ? 1 : 0;
        NSDate *eventDate = [dateFormat dateFromString:event.activity.text];
        if (!_earliestEventDate || [_earliestEventDate timeIntervalSinceDate:_earliestEventDate] < 0) {
            _earliestEventDate = eventDate;
        }
    }
    
    _title = [self titleFor:time];
    _subtitle = [titles componentsJoinedByString:@", "];
    _valueText = [NSString stringWithFormat:@"%i/%lu", completionCount, (unsigned long)[events count]];
    
    _selectedDate = selectedDate;
    
    _events = events;
    
    return self;
}

- (NSString *) titleFor:(OCKTimedSymptomTrackerTime)time {
    switch (time) {
        case OCKTimedSymptomTrackerTimeMorning:
            return @"Morning";
        case OCKTimedSymptomTrackerTimeNoon:
            return @"Noon";
        case OCKTimedSymptomTrackerTimeAfternoon:
            return @"Afternoon";
        case OCKTimedSymptomTrackerTimeEvening:
            return @"Evening";
    }
}

- (int) hourComponentFor:(OCKTimedSymptomTrackerTime)time {
    switch (time) {
        case OCKTimedSymptomTrackerTimeMorning:
            return 8;
        case OCKTimedSymptomTrackerTimeNoon:
            return 12;
        case OCKTimedSymptomTrackerTimeAfternoon:
            return 16;
        case OCKTimedSymptomTrackerTimeEvening:
            return 20;
    }
}

- (NSString *) shortenedTitleFrom:(OCKCarePlanEvent *)event {
    if ([event.activity.title isEqualToString:@"Blood Pressure"]) {
        return @"BP";
    } else if ([event.activity.title isEqualToString:@"Heart Rate"]) {
        return @"HR";
    }
    return event.activity.title;
}

/// Used to disable any rows that are too far into the future (>1 hour).
- (BOOL) shouldBeEnabledOnDate:(NSDateComponents *)dateComponents {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *eventComponents = [_selectedDate copy];
    
    if (![eventComponents isEqual:dateComponents]) {
        return false;  // Return false if the date isn't the same
    }
    
    // If the date is today, limit the time at which you can take a measurement so people don't do it too early

    // Fix the task date to keep the time, but match the date of the current date
    eventComponents.year = dateComponents.year;
    eventComponents.month = dateComponents.month;
    eventComponents.day = dateComponents.day;
    eventComponents.hour = [self hourComponentFor:self.time] - 1;
    if (eventComponents.hour < 0) { eventComponents.hour = 23; eventComponents.day -= 1; }
    NSDate *comparisonDate = [calendar dateFromComponents:dateComponents];
    NSDate *fixedEventDate = [calendar dateFromComponents:eventComponents];
    
    // Disable any tasks that are in the future
    NSComparisonResult result = [comparisonDate compare:fixedEventDate];
    return result != NSOrderedAscending;
}

@end
