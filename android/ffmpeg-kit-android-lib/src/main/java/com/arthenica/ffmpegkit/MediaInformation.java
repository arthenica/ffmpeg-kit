/*
 * Copyright (c) 2018-2022 Taner Sener
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

import org.json.JSONObject;

import java.util.List;

/**
 * Media information class.
 */
public class MediaInformation {

    /* COMMON KEYS */
    public static final String KEY_FORMAT_PROPERTIES = "format";
    public static final String KEY_FILENAME = "filename";
    public static final String KEY_FORMAT = "format_name";
    public static final String KEY_FORMAT_LONG = "format_long_name";
    public static final String KEY_START_TIME = "start_time";
    public static final String KEY_DURATION = "duration";
    public static final String KEY_SIZE = "size";
    public static final String KEY_BIT_RATE = "bit_rate";
    public static final String KEY_TAGS = "tags";

    /**
     * Stores all properties.
     */
    private final JSONObject jsonObject;

    /**
     * Stores streams.
     */
    private final List<StreamInformation> streams;

    /**
     * Stores chapters.
     */
    private final List<Chapter> chapters;

    public MediaInformation(final JSONObject jsonObject, final List<StreamInformation> streams, final List<Chapter> chapters) {
        this.jsonObject = jsonObject;
        this.streams = streams;
        this.chapters = chapters;
    }

    /**
     * Returns file name.
     *
     * @return media file name
     */
    public String getFilename() {
        return getStringFormatProperty(KEY_FILENAME);
    }

    /**
     * Returns format.
     *
     * @return media format
     */
    public String getFormat() {
        return getStringFormatProperty(KEY_FORMAT);
    }

    /**
     * Returns long format.
     *
     * @return media long format
     */
    public String getLongFormat() {
        return getStringFormatProperty(KEY_FORMAT_LONG);
    }

    /**
     * Returns duration.
     *
     * @return media duration in "seconds.microseconds" format
     */
    public String getDuration() {
        return getStringFormatProperty(KEY_DURATION);
    }

    /**
     * Returns start time.
     *
     * @return media start time in milliseconds
     */
    public String getStartTime() {
        return getStringFormatProperty(KEY_START_TIME);
    }

    /**
     * Returns size.
     *
     * @return media size in bytes
     */
    public String getSize() {
        return getStringFormatProperty(KEY_SIZE);
    }

    /**
     * Returns bitrate.
     *
     * @return media bitrate in kb/s
     */
    public String getBitrate() {
        return getStringFormatProperty(KEY_BIT_RATE);
    }

    /**
     * Returns all tags.
     *
     * @return tags as a JSONObject
     */
    public JSONObject getTags() {
        return getFormatProperty(KEY_TAGS);
    }

    /**
     * Returns all streams.
     *
     * @return list of streams
     */
    public List<StreamInformation> getStreams() {
        return streams;
    }

    /**
     * Returns all chapters.
     *
     * @return list of chapters
     */
    public List<Chapter> getChapters() {
        return chapters;
    }

    /**
     * Returns the property associated with the key.
     *
     * @param key property key
     * @return property as string or null if the key is not found
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
     * Returns the property associated with the key.
     *
     * @param key property key
     * @return property as Long or null if the key is not found
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
     * Returns the property associated with the key.
     *
     * @param key property key
     * @return property as a JSONObject or null if the key is not found
     */
    public JSONObject getProperty(String key) {
        JSONObject allProperties = getAllProperties();
        if (allProperties == null) {
            return null;
        }

        return allProperties.optJSONObject(key);
    }

    /**
     * Returns the format property associated with the key.
     *
     * @param key property key
     * @return format property as string or null if the key is not found
     */
    public String getStringFormatProperty(final String key) {
        JSONObject formatProperties = getFormatProperties();
        if (formatProperties == null) {
            return null;
        }

        if (formatProperties.has(key)) {
            return formatProperties.optString(key);
        } else {
            return null;
        }
    }

    /**
     * Returns the format property associated with the key.
     *
     * @param key property key
     * @return format property as Long or null if the key is not found
     */
    public Long getNumberFormatProperty(String key) {
        JSONObject formatProperties = getFormatProperties();
        if (formatProperties == null) {
            return null;
        }

        if (formatProperties.has(key)) {
            return formatProperties.optLong(key);
        } else {
            return null;
        }
    }

    /**
     * Returns the format property associated with the key.
     *
     * @param key property key
     * @return format property as a JSONObject or null if the key is not found
     */
    public JSONObject getFormatProperty(String key) {
        JSONObject formatProperties = getFormatProperties();
        if (formatProperties == null) {
            return null;
        }

        return formatProperties.optJSONObject(key);
    }

    /**
     * Returns all format properties defined.
     *
     * @return all format properties as a JSONObject or null if no format properties are defined
     */
    public JSONObject getFormatProperties() {
        return jsonObject.optJSONObject(KEY_FORMAT_PROPERTIES);
    }

    /**
     * Returns all properties defined.
     *
     * @return all properties as a JSONObject or null if no properties are defined
     */
    public JSONObject getAllProperties() {
        return jsonObject;
    }

}
