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
 * You should have received a copy of the GNU Lesser General Public License
 * along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.arthenica.ffmpegkit;

import android.util.Log;

import com.arthenica.smartexception.java.Exceptions;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

/**
 * A parser that constructs {@link MediaInformation} from FFprobe's json output.
 */
public class MediaInformationJsonParser {

    /**
     * Extracts <code>MediaInformation</code> from the given FFprobe json output. Note that this
     * method does not throw {@link JSONException} as {@link #fromWithError(String)} does and
     * handles errors internally.
     *
     * @param ffprobeJsonOutput FFprobe json output
     * @return created {@link MediaInformation} instance of null if a parsing error occurs
     */
    public static MediaInformation from(final String ffprobeJsonOutput) {
        try {
            return fromWithError(ffprobeJsonOutput);
        } catch (JSONException e) {
            Log.e(FFmpegKitConfig.TAG, String.format("MediaInformation parsing failed.%s", Exceptions.getStackTraceString(e)));
            return null;
        }
    }

    /**
     * Extracts MediaInformation from the given FFprobe json output.
     *
     * @param ffprobeJsonOutput ffprobe json output
     * @return created {@link MediaInformation} instance
     * @throws JSONException if a parsing error occurs
     */
    public static MediaInformation fromWithError(final String ffprobeJsonOutput) throws JSONException {
        JSONObject jsonObject = new JSONObject(ffprobeJsonOutput);
        JSONArray streamArray = jsonObject.optJSONArray("streams");

        ArrayList<StreamInformation> arrayList = new ArrayList<>();
        for (int i = 0; streamArray != null && i < streamArray.length(); i++) {
            JSONObject streamObject = streamArray.optJSONObject(i);
            if (streamObject != null) {
                arrayList.add(new StreamInformation(streamObject));
            }
        }

        return new MediaInformation(jsonObject, arrayList);
    }

}
