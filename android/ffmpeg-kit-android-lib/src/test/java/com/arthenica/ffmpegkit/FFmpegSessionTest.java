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

public class FFmpegSessionTest {

    static final String[] TEST_ARGUMENTS = new String[]{"argument1", "argument2"};

    @Test
    public void constructorTest() {
        FFmpegSession ffmpegSession = FFmpegSession.create(TEST_ARGUMENTS);

        // 1. getCompleteCallback
        Assert.assertNull(ffmpegSession.getCompleteCallback());

        // 2. getLogCallback
        Assert.assertNull(ffmpegSession.getLogCallback());

        // 3. getStatisticsCallback
        Assert.assertNull(ffmpegSession.getStatisticsCallback());

        // 4. getSessionId
        Assert.assertTrue(ffmpegSession.getSessionId() > 0);

        // 5. getCreateTime
        Assert.assertTrue(ffmpegSession.getCreateTime().getTime() <= System.currentTimeMillis());

        // 6. getStartTime
        Assert.assertNull(ffmpegSession.getStartTime());

        // 7. getEndTime
        Assert.assertNull(ffmpegSession.getEndTime());

        // 8. getDuration
        Assert.assertEquals(0, ffmpegSession.getDuration());

        // 9. getArguments
        Assert.assertArrayEquals(TEST_ARGUMENTS, ffmpegSession.getArguments());

        // 10. getCommand
        StringBuilder commandBuilder = new StringBuilder();
        for (int i = 0; i < TEST_ARGUMENTS.length; i++) {
            if (i > 0) {
                commandBuilder.append(" ");
            }
            commandBuilder.append(TEST_ARGUMENTS[i]);
        }
        Assert.assertEquals(commandBuilder.toString(), ffmpegSession.getCommand());

        // 11. getLogs
        Assert.assertEquals(0, ffmpegSession.getLogs().size());

        // 12. getLogsAsString
        Assert.assertEquals("", ffmpegSession.getLogsAsString());

        // 13. getState
        Assert.assertEquals(SessionState.CREATED, ffmpegSession.getState());

        // 14. getState
        Assert.assertNull(ffmpegSession.getReturnCode());

        // 15. getFailStackTrace
        Assert.assertNull(ffmpegSession.getFailStackTrace());

        // 16. getLogRedirectionStrategy
        Assert.assertEquals(FFmpegKitConfig.getLogRedirectionStrategy(), ffmpegSession.getLogRedirectionStrategy());

        // 17. getFuture
        Assert.assertNull(ffmpegSession.getFuture());
    }

    @Test
    public void constructorTest2() {
        FFmpegSessionCompleteCallback completeCallback = new FFmpegSessionCompleteCallback() {

            @Override
            public void apply(FFmpegSession session) {
            }
        };

        FFmpegSession ffmpegSession = FFmpegSession.create(TEST_ARGUMENTS, completeCallback);

        // 1. getCompleteCallback
        Assert.assertEquals(ffmpegSession.getCompleteCallback(), completeCallback);

        // 2. getLogCallback
        Assert.assertNull(ffmpegSession.getLogCallback());

        // 3. getStatisticsCallback
        Assert.assertNull(ffmpegSession.getStatisticsCallback());

        // 4. getSessionId
        Assert.assertTrue(ffmpegSession.getSessionId() > 0);

        // 5. getCreateTime
        Assert.assertTrue(ffmpegSession.getCreateTime().getTime() <= System.currentTimeMillis());

        // 6. getStartTime
        Assert.assertNull(ffmpegSession.getStartTime());

        // 7. getEndTime
        Assert.assertNull(ffmpegSession.getEndTime());

        // 8. getDuration
        Assert.assertEquals(0, ffmpegSession.getDuration());

        // 9. getArguments
        Assert.assertArrayEquals(TEST_ARGUMENTS, ffmpegSession.getArguments());

        // 10. getCommand
        StringBuilder commandBuilder = new StringBuilder();
        for (int i = 0; i < TEST_ARGUMENTS.length; i++) {
            if (i > 0) {
                commandBuilder.append(" ");
            }
            commandBuilder.append(TEST_ARGUMENTS[i]);
        }
        Assert.assertEquals(commandBuilder.toString(), ffmpegSession.getCommand());

        // 11. getLogs
        Assert.assertEquals(0, ffmpegSession.getLogs().size());

        // 12. getLogsAsString
        Assert.assertEquals("", ffmpegSession.getLogsAsString());

        // 13. getState
        Assert.assertEquals(SessionState.CREATED, ffmpegSession.getState());

        // 14. getState
        Assert.assertNull(ffmpegSession.getReturnCode());

        // 15. getFailStackTrace
        Assert.assertNull(ffmpegSession.getFailStackTrace());

        // 16. getLogRedirectionStrategy
        Assert.assertEquals(FFmpegKitConfig.getLogRedirectionStrategy(), ffmpegSession.getLogRedirectionStrategy());

        // 17. getFuture
        Assert.assertNull(ffmpegSession.getFuture());
    }

    @Test
    public void constructorTest3() {
        FFmpegSessionCompleteCallback completeCallback = new FFmpegSessionCompleteCallback() {

            @Override
            public void apply(FFmpegSession session) {
            }
        };

        LogCallback logCallback = new LogCallback() {
            @Override
            public void apply(Log log) {

            }
        };

        StatisticsCallback statisticsCallback = new StatisticsCallback() {
            @Override
            public void apply(Statistics statistics) {

            }
        };

        FFmpegSession ffmpegSession = FFmpegSession.create(TEST_ARGUMENTS, completeCallback, logCallback, statisticsCallback);

        // 1. getCompleteCallback
        Assert.assertEquals(ffmpegSession.getCompleteCallback(), completeCallback);

        // 2. getLogCallback
        Assert.assertEquals(ffmpegSession.getLogCallback(), logCallback);

        // 3. getStatisticsCallback
        Assert.assertEquals(ffmpegSession.getStatisticsCallback(), statisticsCallback);

        // 4. getSessionId
        Assert.assertTrue(ffmpegSession.getSessionId() > 0);

        // 5. getCreateTime
        Assert.assertTrue(ffmpegSession.getCreateTime().getTime() <= System.currentTimeMillis());

        // 6. getStartTime
        Assert.assertNull(ffmpegSession.getStartTime());

        // 7. getEndTime
        Assert.assertNull(ffmpegSession.getEndTime());

        // 8. getDuration
        Assert.assertEquals(0, ffmpegSession.getDuration());

        // 9. getArguments
        Assert.assertArrayEquals(TEST_ARGUMENTS, ffmpegSession.getArguments());

        // 10. getCommand
        StringBuilder commandBuilder = new StringBuilder();
        for (int i = 0; i < TEST_ARGUMENTS.length; i++) {
            if (i > 0) {
                commandBuilder.append(" ");
            }
            commandBuilder.append(TEST_ARGUMENTS[i]);
        }
        Assert.assertEquals(commandBuilder.toString(), ffmpegSession.getCommand());

        // 11. getLogs
        Assert.assertEquals(0, ffmpegSession.getLogs().size());

        // 12. getLogsAsString
        Assert.assertEquals("", ffmpegSession.getLogsAsString());

        // 13. getState
        Assert.assertEquals(SessionState.CREATED, ffmpegSession.getState());

        // 14. getState
        Assert.assertNull(ffmpegSession.getReturnCode());

        // 15. getFailStackTrace
        Assert.assertNull(ffmpegSession.getFailStackTrace());

        // 16. getLogRedirectionStrategy
        Assert.assertEquals(FFmpegKitConfig.getLogRedirectionStrategy(), ffmpegSession.getLogRedirectionStrategy());

        // 17. getFuture
        Assert.assertNull(ffmpegSession.getFuture());
    }

    @Test
    public void getSessionIdTest() {
        FFmpegSession ffmpegSession1 = FFmpegSession.create(TEST_ARGUMENTS);
        FFmpegSession ffmpegSession2 = FFmpegSession.create(TEST_ARGUMENTS);
        FFmpegSession ffmpegSession3 = FFmpegSession.create(TEST_ARGUMENTS);

        Assert.assertTrue(ffmpegSession3.getSessionId() > ffmpegSession2.getSessionId());
        Assert.assertTrue(ffmpegSession3.getSessionId() > ffmpegSession1.getSessionId());
        Assert.assertTrue(ffmpegSession2.getSessionId() > ffmpegSession1.getSessionId());

        Assert.assertTrue(ffmpegSession1.getSessionId() > 0);
        Assert.assertTrue(ffmpegSession2.getSessionId() > 0);
        Assert.assertTrue(ffmpegSession3.getSessionId() > 0);
    }

    @Test
    public void getLogs() {
        final FFmpegSession ffmpegSession = FFmpegSession.create(TEST_ARGUMENTS);

        String logMessage1 = "i am log one";
        String logMessage2 = "i am log two";
        String logMessage3 = "i am log three";

        ffmpegSession.addLog(new Log(ffmpegSession.getSessionId(), Level.AV_LOG_INFO, logMessage1));
        ffmpegSession.addLog(new Log(ffmpegSession.getSessionId(), Level.AV_LOG_DEBUG, logMessage2));
        ffmpegSession.addLog(new Log(ffmpegSession.getSessionId(), Level.AV_LOG_TRACE, logMessage3));

        List<Log> logs = ffmpegSession.getLogs();

        Assert.assertEquals(3, logs.size());
    }

    @Test
    public void getLogsAsStringTest() {
        final FFmpegSession ffmpegSession = FFmpegSession.create(TEST_ARGUMENTS);

        String logMessage1 = "i am log one";
        String logMessage2 = "i am log two";

        ffmpegSession.addLog(new Log(ffmpegSession.getSessionId(), Level.AV_LOG_DEBUG, logMessage1));
        ffmpegSession.addLog(new Log(ffmpegSession.getSessionId(), Level.AV_LOG_DEBUG, logMessage2));

        String logsAsString = ffmpegSession.getLogsAsString();

        Assert.assertEquals(logMessage1 + logMessage2, logsAsString);
    }

    @Test
    public void getLogRedirectionStrategy() {
        FFmpegKitConfig.setLogRedirectionStrategy(LogRedirectionStrategy.NEVER_PRINT_LOGS);

        final FFmpegSession ffmpegSession1 = FFmpegSession.create(TEST_ARGUMENTS);
        Assert.assertEquals(FFmpegKitConfig.getLogRedirectionStrategy(), ffmpegSession1.getLogRedirectionStrategy());

        FFmpegKitConfig.setLogRedirectionStrategy(LogRedirectionStrategy.PRINT_LOGS_WHEN_SESSION_CALLBACK_NOT_DEFINED);

        final FFmpegSession ffmpegSession2 = FFmpegSession.create(TEST_ARGUMENTS);
        Assert.assertEquals(FFmpegKitConfig.getLogRedirectionStrategy(), ffmpegSession2.getLogRedirectionStrategy());
    }

    @Test
    public void startRunningTest() {
        FFmpegSession ffmpegSession = FFmpegSession.create(TEST_ARGUMENTS);

        ffmpegSession.startRunning();

        Assert.assertEquals(SessionState.RUNNING, ffmpegSession.getState());
        Assert.assertTrue(ffmpegSession.getStartTime().getTime() <= System.currentTimeMillis());
        Assert.assertTrue(ffmpegSession.getCreateTime().getTime() <= ffmpegSession.getStartTime().getTime());
    }

    @Test
    public void completeTest() {
        FFmpegSession ffmpegSession = FFmpegSession.create(TEST_ARGUMENTS);

        ffmpegSession.startRunning();
        ffmpegSession.complete(new ReturnCode(100));

        Assert.assertEquals(SessionState.COMPLETED, ffmpegSession.getState());
        Assert.assertEquals(100, ffmpegSession.getReturnCode().getValue());
        Assert.assertTrue(ffmpegSession.getStartTime().getTime() <= ffmpegSession.getEndTime().getTime());
        Assert.assertTrue(ffmpegSession.getDuration() >= 0);
    }

    @Test
    public void failTest() {
        FFmpegSession ffmpegSession = FFmpegSession.create(TEST_ARGUMENTS);

        ffmpegSession.startRunning();
        ffmpegSession.fail(new Exception(""));

        Assert.assertEquals(SessionState.FAILED, ffmpegSession.getState());
        Assert.assertNull(ffmpegSession.getReturnCode());
        Assert.assertTrue(ffmpegSession.getStartTime().getTime() <= ffmpegSession.getEndTime().getTime());
        Assert.assertTrue(ffmpegSession.getDuration() >= 0);
        Assert.assertNotNull(ffmpegSession.getFailStackTrace());
    }

}
