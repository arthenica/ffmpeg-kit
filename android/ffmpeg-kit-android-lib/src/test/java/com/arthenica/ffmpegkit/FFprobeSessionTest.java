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

import java.util.List;

public class FFprobeSessionTest {

    private static final String[] TEST_ARGUMENTS = new String[]{"argument1", "argument2"};

    @Test
    public void constructorTest() {
        FFprobeSession ffprobeSession = FFprobeSession.create(TEST_ARGUMENTS);

        // 1. getCompleteCallback
        Assert.assertNull(ffprobeSession.getCompleteCallback());

        // 2. getLogCallback
        Assert.assertNull(ffprobeSession.getLogCallback());

        // 3. getSessionId
        Assert.assertTrue(ffprobeSession.getSessionId() > 0);

        // 4. getCreateTime
        Assert.assertTrue(ffprobeSession.getCreateTime().getTime() <= System.currentTimeMillis());

        // 5. getStartTime
        Assert.assertNull(ffprobeSession.getStartTime());

        // 6. getEndTime
        Assert.assertNull(ffprobeSession.getEndTime());

        // 7. getDuration
        Assert.assertEquals(0, ffprobeSession.getDuration());

        // 8. getArguments
        Assert.assertArrayEquals(TEST_ARGUMENTS, ffprobeSession.getArguments());

        // 9. getCommand
        StringBuilder commandBuilder = new StringBuilder();
        for (int i = 0; i < TEST_ARGUMENTS.length; i++) {
            if (i > 0) {
                commandBuilder.append(" ");
            }
            commandBuilder.append(TEST_ARGUMENTS[i]);
        }
        Assert.assertEquals(commandBuilder.toString(), ffprobeSession.getCommand());

        // 10. getLogs
        Assert.assertEquals(0, ffprobeSession.getLogs().size());

        // 11. getLogsAsString
        Assert.assertEquals("", ffprobeSession.getLogsAsString());

        // 12. getState
        Assert.assertEquals(SessionState.CREATED, ffprobeSession.getState());

        // 13. getState
        Assert.assertNull(ffprobeSession.getReturnCode());

        // 14. getFailStackTrace
        Assert.assertNull(ffprobeSession.getFailStackTrace());

        // 15. getLogRedirectionStrategy
        Assert.assertEquals(FFmpegKitConfig.getLogRedirectionStrategy(), ffprobeSession.getLogRedirectionStrategy());

        // 16. getFuture
        Assert.assertNull(ffprobeSession.getFuture());
    }

    @Test
    public void constructorTest2() {
        FFprobeSessionCompleteCallback completeCallback = new FFprobeSessionCompleteCallback() {

            @Override
            public void apply(FFprobeSession session) {
            }
        };

        FFprobeSession ffprobeSession = FFprobeSession.create(TEST_ARGUMENTS, completeCallback);

        // 1. getCompleteCallback
        Assert.assertEquals(ffprobeSession.getCompleteCallback(), completeCallback);

        // 2. getLogCallback
        Assert.assertNull(ffprobeSession.getLogCallback());

        // 3. getSessionId
        Assert.assertTrue(ffprobeSession.getSessionId() > 0);

        // 4. getCreateTime
        Assert.assertTrue(ffprobeSession.getCreateTime().getTime() <= System.currentTimeMillis());

        // 5. getStartTime
        Assert.assertNull(ffprobeSession.getStartTime());

        // 6. getEndTime
        Assert.assertNull(ffprobeSession.getEndTime());

        // 7. getDuration
        Assert.assertEquals(0, ffprobeSession.getDuration());

        // 8. getArguments
        Assert.assertArrayEquals(TEST_ARGUMENTS, ffprobeSession.getArguments());

        // 9. getCommand
        StringBuilder commandBuilder = new StringBuilder();
        for (int i = 0; i < TEST_ARGUMENTS.length; i++) {
            if (i > 0) {
                commandBuilder.append(" ");
            }
            commandBuilder.append(TEST_ARGUMENTS[i]);
        }
        Assert.assertEquals(commandBuilder.toString(), ffprobeSession.getCommand());

        // 10. getLogs
        Assert.assertEquals(0, ffprobeSession.getLogs().size());

        // 11. getLogsAsString
        Assert.assertEquals("", ffprobeSession.getLogsAsString());

        // 12. getState
        Assert.assertEquals(SessionState.CREATED, ffprobeSession.getState());

        // 13. getState
        Assert.assertNull(ffprobeSession.getReturnCode());

        // 14. getFailStackTrace
        Assert.assertNull(ffprobeSession.getFailStackTrace());

        // 15. getLogRedirectionStrategy
        Assert.assertEquals(FFmpegKitConfig.getLogRedirectionStrategy(), ffprobeSession.getLogRedirectionStrategy());

        // 16. getFuture
        Assert.assertNull(ffprobeSession.getFuture());
    }

    @Test
    public void constructorTest3() {
        FFprobeSessionCompleteCallback completeCallback = new FFprobeSessionCompleteCallback() {

            @Override
            public void apply(FFprobeSession session) {
            }
        };

        LogCallback logCallback = new LogCallback() {
            @Override
            public void apply(Log log) {

            }
        };

        FFprobeSession ffprobeSession = FFprobeSession.create(TEST_ARGUMENTS, completeCallback, logCallback);

        // 1. getCompleteCallback
        Assert.assertEquals(ffprobeSession.getCompleteCallback(), completeCallback);

        // 2. getLogCallback
        Assert.assertEquals(ffprobeSession.getLogCallback(), logCallback);

        // 3. getSessionId
        Assert.assertTrue(ffprobeSession.getSessionId() > 0);

        // 4. getCreateTime
        Assert.assertTrue(ffprobeSession.getCreateTime().getTime() <= System.currentTimeMillis());

        // 5. getStartTime
        Assert.assertNull(ffprobeSession.getStartTime());

        // 6. getEndTime
        Assert.assertNull(ffprobeSession.getEndTime());

        // 7. getDuration
        Assert.assertEquals(0, ffprobeSession.getDuration());

        // 8. getArguments
        Assert.assertArrayEquals(TEST_ARGUMENTS, ffprobeSession.getArguments());

        // 9. getCommand
        StringBuilder commandBuilder = new StringBuilder();
        for (int i = 0; i < TEST_ARGUMENTS.length; i++) {
            if (i > 0) {
                commandBuilder.append(" ");
            }
            commandBuilder.append(TEST_ARGUMENTS[i]);
        }
        Assert.assertEquals(commandBuilder.toString(), ffprobeSession.getCommand());

        // 10. getLogs
        Assert.assertEquals(0, ffprobeSession.getLogs().size());

        // 11. getLogsAsString
        Assert.assertEquals("", ffprobeSession.getLogsAsString());

        // 12. getState
        Assert.assertEquals(SessionState.CREATED, ffprobeSession.getState());

        // 13. getState
        Assert.assertNull(ffprobeSession.getReturnCode());

        // 14. getFailStackTrace
        Assert.assertNull(ffprobeSession.getFailStackTrace());

        // 15. getLogRedirectionStrategy
        Assert.assertEquals(FFmpegKitConfig.getLogRedirectionStrategy(), ffprobeSession.getLogRedirectionStrategy());

        // 16. getFuture
        Assert.assertNull(ffprobeSession.getFuture());
    }

    @Test
    public void getSessionIdTest() {
        FFprobeSession ffprobeSession1 = FFprobeSession.create(TEST_ARGUMENTS);
        FFprobeSession ffprobeSession2 = FFprobeSession.create(TEST_ARGUMENTS);
        FFprobeSession ffprobeSession3 = FFprobeSession.create(TEST_ARGUMENTS);

        Assert.assertTrue(ffprobeSession3.getSessionId() > ffprobeSession2.getSessionId());
        Assert.assertTrue(ffprobeSession3.getSessionId() > ffprobeSession1.getSessionId());
        Assert.assertTrue(ffprobeSession2.getSessionId() > ffprobeSession1.getSessionId());

        Assert.assertTrue(ffprobeSession1.getSessionId() > 0);
        Assert.assertTrue(ffprobeSession2.getSessionId() > 0);
        Assert.assertTrue(ffprobeSession3.getSessionId() > 0);
    }

    @Test
    public void getLogs() {
        final FFprobeSession ffprobeSession = FFprobeSession.create(TEST_ARGUMENTS);

        String logMessage1 = "i am log one";
        String logMessage2 = "i am log two";
        String logMessage3 = "i am log three";

        ffprobeSession.addLog(new Log(ffprobeSession.getSessionId(), Level.AV_LOG_INFO, logMessage1));
        ffprobeSession.addLog(new Log(ffprobeSession.getSessionId(), Level.AV_LOG_DEBUG, logMessage2));
        ffprobeSession.addLog(new Log(ffprobeSession.getSessionId(), Level.AV_LOG_TRACE, logMessage3));

        List<Log> logs = ffprobeSession.getLogs();

        Assert.assertEquals(3, logs.size());
    }

    @Test
    public void getLogsAsStringTest() {
        final FFprobeSession ffprobeSession = FFprobeSession.create(TEST_ARGUMENTS);

        String logMessage1 = "i am log one";
        String logMessage2 = "i am log two";

        ffprobeSession.addLog(new Log(ffprobeSession.getSessionId(), Level.AV_LOG_DEBUG, logMessage1));
        ffprobeSession.addLog(new Log(ffprobeSession.getSessionId(), Level.AV_LOG_DEBUG, logMessage2));

        String logsAsString = ffprobeSession.getLogsAsString();

        Assert.assertEquals(logMessage1 + logMessage2, logsAsString);
    }

    @Test
    public void getLogRedirectionStrategy() {
        FFmpegKitConfig.setLogRedirectionStrategy(LogRedirectionStrategy.NEVER_PRINT_LOGS);

        final FFprobeSession ffprobeSession1 = FFprobeSession.create(TEST_ARGUMENTS);
        Assert.assertEquals(FFmpegKitConfig.getLogRedirectionStrategy(), ffprobeSession1.getLogRedirectionStrategy());

        FFmpegKitConfig.setLogRedirectionStrategy(LogRedirectionStrategy.PRINT_LOGS_WHEN_SESSION_CALLBACK_NOT_DEFINED);

        final FFprobeSession ffprobeSession2 = FFprobeSession.create(TEST_ARGUMENTS);
        Assert.assertEquals(FFmpegKitConfig.getLogRedirectionStrategy(), ffprobeSession2.getLogRedirectionStrategy());
    }

    @Test
    public void startRunningTest() {
        FFprobeSession ffprobeSession = FFprobeSession.create(TEST_ARGUMENTS);

        ffprobeSession.startRunning();

        Assert.assertEquals(SessionState.RUNNING, ffprobeSession.getState());
        Assert.assertTrue(ffprobeSession.getStartTime().getTime() <= System.currentTimeMillis());
        Assert.assertTrue(ffprobeSession.getCreateTime().getTime() <= ffprobeSession.getStartTime().getTime());
    }

    @Test
    public void completeTest() {
        FFprobeSession ffprobeSession = FFprobeSession.create(TEST_ARGUMENTS);

        ffprobeSession.startRunning();
        ffprobeSession.complete(new ReturnCode(100));

        Assert.assertEquals(SessionState.COMPLETED, ffprobeSession.getState());
        Assert.assertEquals(100, ffprobeSession.getReturnCode().getValue());
        Assert.assertTrue(ffprobeSession.getStartTime().getTime() <= ffprobeSession.getEndTime().getTime());
        Assert.assertTrue(ffprobeSession.getDuration() >= 0);
    }

    @Test
    public void failTest() {
        FFprobeSession ffprobeSession = FFprobeSession.create(TEST_ARGUMENTS);

        ffprobeSession.startRunning();
        ffprobeSession.fail(new Exception(""));

        Assert.assertEquals(SessionState.FAILED, ffprobeSession.getState());
        Assert.assertNull(ffprobeSession.getReturnCode());
        Assert.assertTrue(ffprobeSession.getStartTime().getTime() <= ffprobeSession.getEndTime().getTime());
        Assert.assertTrue(ffprobeSession.getDuration() >= 0);
        Assert.assertNotNull(ffprobeSession.getFailStackTrace());
    }

}
