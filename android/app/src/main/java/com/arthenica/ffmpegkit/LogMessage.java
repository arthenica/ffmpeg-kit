/*
 * Copyright (c) 2018-2020 Taner Sener
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
 * <p>Logs for running executions.
 */
public class LogMessage {

    private final long executionId;
    private final Level level;
    private final String text;

    public LogMessage(final long executionId, final Level level, final String text) {
        this.executionId = executionId;
        this.level = level;
        this.text = text;
    }

    public long getExecutionId() {
        return executionId;
    }

    public Level getLevel() {
        return level;
    }

    public String getText() {
        return text;
    }

    @Override
    public String toString() {
        final StringBuilder stringBuilder = new StringBuilder();

        stringBuilder.append("LogMessage{");
        stringBuilder.append("executionId=");
        stringBuilder.append(executionId);
        stringBuilder.append(", level=");
        stringBuilder.append(level);
        stringBuilder.append(", text=");
        stringBuilder.append("\'");
        stringBuilder.append(text);
        stringBuilder.append('\'');
        stringBuilder.append('}');

        return stringBuilder.toString();
    }
}
