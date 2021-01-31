/*
 * Copyright (c) 2020-2021 Taner Sener
 *
 * This file is part of FFmpegKit.
 *
 * FFmpegKit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FFmpegKit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef FFMPEG_KIT_EXECUTE_DELEGATE_H
#define FFMPEG_KIT_EXECUTE_DELEGATE_H

#import <Foundation/Foundation.h>
#import "Session.h"

@protocol Session;

/**
 * <p>Delegate invoked when an asynchronous session ends running.
 * <p>Session has either SessionStateCompleted or SessionStateFailed state when
 * the delegate is invoked.
 * <p>If it has SessionStateCompleted state, <code>ReturnCode</code> should be checked to
 * see the execution result.
 * <p>If <code>getState</code> returns SessionStateFailed then
 * <code>getFailStackTrace</code> should be used to get the failure reason.
 * <pre>
 *  switch ([session getState]) {
 *      case SessionStateCompleted:
 *          ReturnCode *returnCode = [session getReturnCode];
 *          break;
 *      case SessionStateFailed:
 *          NSString *failStackTrace = [session getFailStackTrace];
 *          break;
 *  }
 * </pre>
 */
@protocol ExecuteDelegate<NSObject>
@required

/**
 * Called when an execution is completed.
 *
 * @param session session of the completed execution
 */
- (void)executeCallback:(id<Session>)session;

@end

#endif // FFMPEG_KIT_EXECUTE_DELEGATE_H
