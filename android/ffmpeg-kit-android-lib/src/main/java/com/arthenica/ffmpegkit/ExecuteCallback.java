/*
 * Copyright (c) 2018-2021 Taner Sener
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
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.arthenica.ffmpegkit;

/**
 * <p>Callback function invoked when an asynchronous session ends running.
 * <p>Session has either {@link SessionState#COMPLETED} or {@link SessionState#FAILED} state when
 * the callback is invoked.
 * <p>If it has {@link SessionState#COMPLETED} state, <code>ReturnCode</code> should be checked to
 * see the execution result.
 * <p>If <code>getState</code> returns {@link SessionState#FAILED} then
 * <code>getFailStackTrace</code> should be used to get the failure reason.
 * <pre>
 *  switch (session.getState()) {
 *      case COMPLETED: {
 *          ReturnCode returnCode = session.getReturnCode();
 *      } break;
 *      case FAILED: {
 *          String failStackTrace = session.getFailStackTrace();
 *      } break;
 *  }
 * </pre>
 */
@FunctionalInterface
public interface ExecuteCallback {

    /**
     * <p>Called when an asynchronous session ends running.
     *
     * @param session session
     */
    void apply(final Session session);

}
