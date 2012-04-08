//
//  EntityManager.h
//  calendar
//
//  Created by Fravic Fernando on 12-04-04.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalendarDay.h"
#import "EventBlock.h"


@interface EntityManager : NSObject {
	id<CalendarViewDelegate> _delegate;
	UIView *_view;
	
	NSMutableDictionary *_entities;
}

@property (retain) NSMutableDictionary *entitiesByClass;

- (id)initWithView:(UIView*)view andDelegate:(id<CalendarViewDelegate>)delegate;

- (void)registerEntity:(CalendarEntity*)entity withKey:(NSObject*)key;
- (void)removeEntity:(CalendarEntity*)entity;
- (NSArray*)allEntities;
- (BOOL)entityExistsWithClass:(Class)type andKey:(NSObject*)key;

- (CalendarDay*)createCalendarDayWithStartTime:(NSTimeInterval)startTime;
- (EventBlock*)createEventBlockWithStartTime:(NSTimeInterval)startTime;

@end
