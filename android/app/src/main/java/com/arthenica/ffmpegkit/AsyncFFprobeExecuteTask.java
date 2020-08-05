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
 * You should have received a copy of the GNU Lesser General Public License
 * along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.arthenica.ffmpegkit;

import android.os.AsyncTask;

/**
 * <p>Utility class to execute an FFprobe command asynchronously.
 */
public class AsyncFFprobeExecuteTask extends AsyncTask<Void, Integer, Integer> {
    private final String[] arguments;
    private final ExecuteCallback ExecuteCallback;

    public AsyncFFprobeExecuteTask(final String command, final ExecuteCallback executeCallback) {
        this.arguments = FFmpegKit.parseArguments(command);
        this.ExecuteCallback = executeCallback;
    }

    public AsyncFFprobeExecuteTask(final String[] arguments, final ExecuteCallback executeCallback) {
        this.arguments = arguments;
        ExecuteCallback = executeCallback;
    }

    @Override
    protected Integer doInBackground(final Void... unused) {
        return FFprobeKit.execute(this.arguments);
    }

    @Override
    protected void onPostExecute(final Integer rc) {
        if (ExecuteCallback != null) {
            ExecuteCallback.apply(FFmpegKit.DEFAULT_EXECUTION_ID, rc);
        }
    }

}
