/*
 * Copyright (c) 2021 Taner Sener
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

import org.junit.Assert;
import org.junit.Test;

public class AbstractSessionTest {

    private static final String[] TEST_ARGUMENTS = new String[]{"argument1", "argument2"};

    @Test
    public void getLogsAsStringTest() {
        final FFprobeSession ffprobeSession = new FFprobeSession(TEST_ARGUMENTS, null, null, null, LogRedirectionStrategy.ALWAYS_PRINT_LOGS);

        String logMessage1 = "i am log one";
        String logMessage2 = "i am log two";

        ffprobeSession.addLog(new Log(ffprobeSession.getSessionId(), Level.AV_LOG_DEBUG, logMessage1));
        ffprobeSession.addLog(new Log(ffprobeSession.getSessionId(), Level.AV_LOG_DEBUG, logMessage2));

        String logsAsString = ffprobeSession.getLogsAsString();

        Assert.assertEquals(logMessage1 + logMessage2, logsAsString);
    }

}
