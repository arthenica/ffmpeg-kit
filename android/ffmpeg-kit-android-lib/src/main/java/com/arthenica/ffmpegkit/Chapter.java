/*
 * Copyright (c) 2021-2022 Taner Sener
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

import org.json.JSONObject;

public class Chapter {

    /* KEYS */
    public static final String KEY_ID = "id";
    public static final String KEY_TIME_BASE = "time_base";
    public static final String KEY_START = "start";
    public static final String KEY_START_TIME = "start_time";
    public static final String KEY_END = "end";
    public static final String KEY_END_TIME = "end_time";
    public static final String KEY_TAGS = "tags";

    private final JSONObject jsonObject;

    public Chapter(JSONObject jsonObject) {
        this.jsonObject = jsonObject;
    }

    public Long getId() {
        return getNumberProperty(KEY_ID);
    }

    public String getTimeBase() {
        return getStringProperty(KEY_TIME_BASE);
    }

    public Long getStart() {
        return getNumberProperty(KEY_START);
    }

    public String getStartTime() {
        return getStringProperty(KEY_START_TIME);
    }

    public Long getEnd() {
        return getNumberProperty(KEY_END);
    }

    public String getEndTime() {
        return getStringProperty(KEY_END_TIME);
    }

    public JSONObject getTags() {
        return getProperty(KEY_TAGS);
    }

    /**
     * Returns the chapter property associated with the key.
     *
     * @param key property key
     * @return chapter property as string or null if the key is not found
     */
    public String getStringProperty(final String key) {
        JSONObject allProperties = getAllProperties();
        if (allProperties == null) {
            return null;
        }

        if (allProperties.has(key)) {
            return allProperties.optString(key);
        } else {
            return null;
        }
    }

    /**
     * Returns the chapter property associated with the key.
     *
     * @param key property key
     * @return chapter property as Long or null if the key is not found
     */
    public Long getNumberProperty(String key) {
        JSONObject allProperties = getAllProperties();
        if (allProperties == null) {
            return null;
        }

        if (allProperties.has(key)) {
            return allProperties.optLong(key);
        } else {
            return null;
        }
    }

    /**
     * Returns the chapter property associated with the key.
     *
     * @param key property key
     * @return chapter property as a JSONObject or null if the key is not found
     */
    public JSONObject getProperty(String key) {
        JSONObject allProperties = getAllProperties();
        if (allProperties == null) {
            return null;
        }

        return allProperties.optJSONObject(key);
    }

    /**
     * Returns all chapter properties defined.
     *
     * @return all chapter properties as a JSONObject or null if no properties are defined
     */
    public JSONObject getAllProperties() {
        return jsonObject;
    }

}
