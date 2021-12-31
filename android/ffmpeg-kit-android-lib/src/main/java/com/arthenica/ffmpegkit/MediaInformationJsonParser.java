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

    public static final String KEY_STREAMS = "streams";
    public static final String KEY_CHAPTERS = "chapters";

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
        final JSONObject jsonObject = new JSONObject(ffprobeJsonOutput);
        final JSONArray streamArray = jsonObject.optJSONArray(KEY_STREAMS);
        final JSONArray chapterArray = jsonObject.optJSONArray(KEY_CHAPTERS);

        ArrayList<StreamInformation> streamList = new ArrayList<>();
        for (int i = 0; streamArray != null && i < streamArray.length(); i++) {
            JSONObject streamObject = streamArray.optJSONObject(i);
            if (streamObject != null) {
                streamList.add(new StreamInformation(streamObject));
            }
        }

        ArrayList<Chapter> chapterList = new ArrayList<>();
        for (int i = 0; chapterArray != null && i < chapterArray.length(); i++) {
            JSONObject chapterObject = chapterArray.optJSONObject(i);
            if (chapterObject != null) {
                chapterList.add(new Chapter(chapterObject));
            }
        }

        return new MediaInformation(jsonObject, streamList, chapterList);
    }

}
