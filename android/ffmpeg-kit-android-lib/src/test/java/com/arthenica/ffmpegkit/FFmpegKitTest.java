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

import org.json.JSONException;
import org.json.JSONObject;
import org.junit.Assert;
import org.junit.Test;

/**
 * <p>Tests for {@link FFmpegKit} class.
 */
public class FFmpegKitTest {

    private static final String MEDIA_INFORMATION_MP3 =
            "{\n" +
                    "     \"streams\": [\n" +
                    "         {\n" +
                    "             \"index\": 0,\n" +
                    "             \"codec_name\": \"mp3\",\n" +
                    "             \"codec_long_name\": \"MP3 (MPEG audio layer 3)\",\n" +
                    "             \"codec_type\": \"audio\",\n" +
                    "             \"codec_time_base\": \"1/44100\",\n" +
                    "             \"codec_tag_string\": \"[0][0][0][0]\",\n" +
                    "             \"codec_tag\": \"0x0000\",\n" +
                    "             \"sample_fmt\": \"fltp\",\n" +
                    "             \"sample_rate\": \"44100\",\n" +
                    "             \"channels\": 2,\n" +
                    "             \"channel_layout\": \"stereo\",\n" +
                    "             \"bits_per_sample\": 0,\n" +
                    "             \"r_frame_rate\": \"0/0\",\n" +
                    "             \"avg_frame_rate\": \"0/0\",\n" +
                    "             \"time_base\": \"1/14112000\",\n" +
                    "             \"start_pts\": 169280,\n" +
                    "             \"start_time\": \"0.011995\",\n" +
                    "             \"duration_ts\": 4622376960,\n" +
                    "             \"duration\": \"327.549388\",\n" +
                    "             \"bit_rate\": \"320000\",\n" +
                    "             \"disposition\": {\n" +
                    "                 \"default\": 0,\n" +
                    "                 \"dub\": 0,\n" +
                    "                 \"original\": 0,\n" +
                    "                 \"comment\": 0,\n" +
                    "                 \"lyrics\": 0,\n" +
                    "                 \"karaoke\": 0,\n" +
                    "                 \"forced\": 0,\n" +
                    "                 \"hearing_impaired\": 0,\n" +
                    "                 \"visual_impaired\": 0,\n" +
                    "                 \"clean_effects\": 0,\n" +
                    "                 \"attached_pic\": 0,\n" +
                    "                 \"timed_thumbnails\": 0\n" +
                    "             },\n" +
                    "             \"tags\": {\n" +
                    "                 \"encoder\": \"Lavf\"\n" +
                    "             }\n" +
                    "         }\n" +
                    "     ],\n" +
                    "     \"chapters\": [\n" +
                    "         {\n" +
                    "             \"id\": 0,\n" +
                    "             \"time_base\": \"1/22050\",\n" +
                    "             \"start\": 0,\n" +
                    "             \"start_time\": \"0.000000\",\n" +
                    "             \"end\": 11158238,\n" +
                    "             \"end_time\": \"506.042540\",\n" +
                    "             \"tags\": {\n" +
                    "                \"title\": \"1 Laying Plans - 2 Waging War\"\n" +
                    "            }\n" +
                    "         },\n" +
                    "         {\n" +
                    "             \"id\": 1,\n" +
                    "             \"time_base\": \"1/22050\",\n" +
                    "             \"start\": 11158238,\n" +
                    "             \"start_time\": \"506.042540\",\n" +
                    "             \"end\": 21433051,\n" +
                    "             \"end_time\": \"972.020454\",\n" +
                    "             \"tags\": {\n" +
                    "                \"title\": \"3 Attack By Stratagem - 4 Tactical Dispositions\"\n" +
                    "            }\n" +
                    "         },\n" +
                    "         {\n" +
                    "             \"id\": 2,\n" +
                    "             \"time_base\": \"1/22050\",\n" +
                    "             \"start\": 21433051,\n" +
                    "             \"start_time\": \"972.020454\",\n" +
                    "             \"end\": 35478685,\n" +
                    "             \"end_time\": \"1609.010658\",\n" +
                    "             \"tags\": {\n" +
                    "                \"title\": \"5 Energy - 6 Weak Points and Strong\"\n" +
                    "            }\n" +
                    "         },\n" +
                    "         {\n" +
                    "             \"id\": 3,\n" +
                    "             \"time_base\": \"1/22050\",\n" +
                    "             \"start\": 35478685,\n" +
                    "             \"start_time\": \"1609.010658\",\n" +
                    "             \"end\": 47187043,\n" +
                    "             \"end_time\": \"2140.001950\",\n" +
                    "             \"tags\": {\n" +
                    "                \"title\": \"7 Maneuvering - 8 Variation in Tactics\"\n" +
                    "            }\n" +
                    "         },\n" +
                    "         {\n" +
                    "             \"id\": 4,\n" +
                    "             \"time_base\": \"1/22050\",\n" +
                    "             \"start\": 47187043,\n" +
                    "             \"start_time\": \"2140.001950\",\n" +
                    "             \"end\": 66635594,\n" +
                    "             \"end_time\": \"3022.022404\",\n" +
                    "             \"tags\": {\n" +
                    "                \"title\": \"9 The Army on the March - 10 Terrain\"\n" +
                    "            }\n" +
                    "         },\n" +
                    "         {\n" +
                    "             \"id\": 5,\n" +
                    "             \"time_base\": \"1/22050\",\n" +
                    "             \"start\": 66635594,\n" +
                    "             \"start_time\": \"3022.022404\",\n" +
                    "             \"end\": 83768105,\n" +
                    "             \"end_time\": \"3799.007029\",\n" +
                    "             \"tags\": {\n" +
                    "                \"title\": \"11 The Nine Situations\"\n" +
                    "            }\n" +
                    "         },\n" +
                    "         {\n" +
                    "             \"id\": 6,\n" +
                    "             \"time_base\": \"1/22050\",\n" +
                    "             \"start\": 83768105,\n" +
                    "             \"start_time\": \"3799.007029\",\n" +
                    "             \"end\": 95659008,\n" +
                    "             \"end_time\": \"4338.277007\",\n" +
                    "             \"tags\": {\n" +
                    "                \"title\": \"12 The Attack By Fire - 13 The Use of Spies\"\n" +
                    "            }\n" +
                    "         }\n" +
                    "     ],\n" +
                    "     \"format\": {\n" +
                    "         \"filename\": \"sample.mp3\",\n" +
                    "         \"nb_streams\": 1,\n" +
                    "         \"nb_programs\": 0,\n" +
                    "         \"format_name\": \"mp3\",\n" +
                    "         \"format_long_name\": \"MP2/3 (MPEG audio layer 2/3)\",\n" +
                    "         \"start_time\": \"0.011995\",\n" +
                    "         \"duration\": \"327.549388\",\n" +
                    "         \"size\": \"13103064\",\n" +
                    "         \"bit_rate\": \"320026\",\n" +
                    "         \"probe_score\": 51,\n" +
                    "         \"tags\": {\n" +
                    "             \"encoder\": \"Lavf58.20.100\",\n" +
                    "             \"album\": \"Impact\",\n" +
                    "             \"artist\": \"Kevin MacLeod\",\n" +
                    "             \"comment\": \"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit finito.\",\n" +
                    "             \"genre\": \"Cinematic\",\n" +
                    "             \"title\": \"Impact Moderato\"\n" +
                    "         }\n" +
                    "     }\n" +
                    "}";

    private static final String MEDIA_INFORMATION_JPG =
            "{\n" +
                    "     \"streams\": [\n" +
                    "         {\n" +
                    "             \"index\": 0,\n" +
                    "             \"codec_name\": \"mjpeg\",\n" +
                    "             \"codec_long_name\": \"Motion JPEG\",\n" +
                    "             \"profile\": \"Baseline\",\n" +
                    "             \"codec_type\": \"video\",\n" +
                    "             \"codec_time_base\": \"0/1\",\n" +
                    "             \"codec_tag_string\": \"[0][0][0][0]\",\n" +
                    "             \"codec_tag\": \"0x0000\",\n" +
                    "             \"width\": 1496,\n" +
                    "             \"height\": 1729,\n" +
                    "             \"coded_width\": 1496,\n" +
                    "             \"coded_height\": 1729,\n" +
                    "             \"has_b_frames\": 0,\n" +
                    "             \"sample_aspect_ratio\": \"1:1\",\n" +
                    "             \"display_aspect_ratio\": \"1496:1729\",\n" +
                    "             \"pix_fmt\": \"yuvj444p\",\n" +
                    "             \"level\": -99,\n" +
                    "             \"color_range\": \"pc\",\n" +
                    "             \"color_space\": \"bt470bg\",\n" +
                    "             \"chroma_location\": \"center\",\n" +
                    "             \"refs\": 1,\n" +
                    "             \"r_frame_rate\": \"25/1\",\n" +
                    "             \"avg_frame_rate\": \"0/0\",\n" +
                    "             \"time_base\": \"1/25\",\n" +
                    "             \"start_pts\": 0,\n" +
                    "             \"start_time\": \"0.000000\",\n" +
                    "             \"duration_ts\": 1,\n" +
                    "             \"duration\": \"0.040000\",\n" +
                    "             \"bits_per_raw_sample\": \"8\",\n" +
                    "             \"disposition\": {\n" +
                    "                 \"default\": 0,\n" +
                    "                 \"dub\": 0,\n" +
                    "                 \"original\": 0,\n" +
                    "                 \"comment\": 0,\n" +
                    "                 \"lyrics\": 0,\n" +
                    "                 \"karaoke\": 0,\n" +
                    "                 \"forced\": 0,\n" +
                    "                 \"hearing_impaired\": 0,\n" +
                    "                 \"visual_impaired\": 0,\n" +
                    "                 \"clean_effects\": 0,\n" +
                    "                 \"attached_pic\": 0,\n" +
                    "                 \"timed_thumbnails\": 0\n" +
                    "             }\n" +
                    "         }\n" +
                    "     ],\n" +
                    "     \"format\": {\n" +
                    "         \"filename\": \"sample.jpg\",\n" +
                    "         \"nb_streams\": 1,\n" +
                    "         \"nb_programs\": 0,\n" +
                    "         \"format_name\": \"image2\",\n" +
                    "         \"format_long_name\": \"image2 sequence\",\n" +
                    "         \"start_time\": \"0.000000\",\n" +
                    "         \"duration\": \"0.040000\",\n" +
                    "         \"size\": \"1659050\",\n" +
                    "         \"bit_rate\": \"331810000\",\n" +
                    "         \"probe_score\": 50\n" +
                    "     }\n" +
                    "}";

    private static final String MEDIA_INFORMATION_GIF =
            "{\n" +
                    "     \"streams\": [\n" +
                    "         {\n" +
                    "             \"index\": 0,\n" +
                    "             \"codec_name\": \"gif\",\n" +
                    "             \"codec_long_name\": \"CompuServe GIF (Graphics Interchange Format)\",\n" +
                    "             \"codec_type\": \"video\",\n" +
                    "             \"codec_time_base\": \"12/133\",\n" +
                    "             \"codec_tag_string\": \"[0][0][0][0]\",\n" +
                    "             \"codec_tag\": \"0x0000\",\n" +
                    "             \"width\": 400,\n" +
                    "             \"height\": 400,\n" +
                    "             \"coded_width\": 400,\n" +
                    "             \"coded_height\": 400,\n" +
                    "             \"has_b_frames\": 0,\n" +
                    "             \"pix_fmt\": \"bgra\",\n" +
                    "             \"level\": -99,\n" +
                    "             \"refs\": 1,\n" +
                    "             \"r_frame_rate\": \"100/9\",\n" +
                    "             \"avg_frame_rate\": \"133/12\",\n" +
                    "             \"time_base\": \"1/100\",\n" +
                    "             \"start_pts\": 0,\n" +
                    "             \"start_time\": \"0.000000\",\n" +
                    "             \"duration_ts\": 396,\n" +
                    "             \"duration\": \"3.960000\",\n" +
                    "             \"nb_frames\": \"44\",\n" +
                    "             \"disposition\": {\n" +
                    "                 \"default\": 0,\n" +
                    "                 \"dub\": 0,\n" +
                    "                 \"original\": 0,\n" +
                    "                 \"comment\": 0,\n" +
                    "                 \"lyrics\": 0,\n" +
                    "                 \"karaoke\": 0,\n" +
                    "                 \"forced\": 0,\n" +
                    "                 \"hearing_impaired\": 0,\n" +
                    "                 \"visual_impaired\": 0,\n" +
                    "                 \"clean_effects\": 0,\n" +
                    "                 \"attached_pic\": 0,\n" +
                    "                 \"timed_thumbnails\": 0\n" +
                    "             }\n" +
                    "         }\n" +
                    "     ],\n" +
                    "     \"format\": {\n" +
                    "         \"filename\": \"sample.gif\",\n" +
                    "         \"nb_streams\": 1,\n" +
                    "         \"nb_programs\": 0,\n" +
                    "         \"format_name\": \"gif\",\n" +
                    "         \"format_long_name\": \"CompuServe Graphics Interchange Format (GIF)\",\n" +
                    "         \"start_time\": \"0.000000\",\n" +
                    "         \"duration\": \"3.960000\",\n" +
                    "         \"size\": \"1001718\",\n" +
                    "         \"bit_rate\": \"2023672\",\n" +
                    "         \"probe_score\": 100\n" +
                    "     }\n" +
                    "}";

    private static final String MEDIA_INFORMATION_MP4 =
            "{\n" +
                    " \"streams\": [\n" +
                    "      {\n" +
                    "          \"index\": 0,\n" +
                    "          \"codec_name\": \"h264\",\n" +
                    "          \"codec_long_name\": \"H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10\",\n" +
                    "          \"profile\": \"Main\",\n" +
                    "          \"codec_type\": \"video\",\n" +
                    "          \"codec_time_base\": \"1/60\",\n" +
                    "          \"codec_tag_string\": \"avc1\",\n" +
                    "          \"codec_tag\": \"0x31637661\",\n" +
                    "          \"width\": 1280,\n" +
                    "          \"height\": 720,\n" +
                    "          \"coded_width\": 1280,\n" +
                    "          \"coded_height\": 720,\n" +
                    "          \"has_b_frames\": 0,\n" +
                    "          \"sample_aspect_ratio\": \"1:1\",\n" +
                    "          \"display_aspect_ratio\": \"16:9\",\n" +
                    "          \"pix_fmt\": \"yuv420p\",\n" +
                    "          \"level\": 42,\n" +
                    "          \"chroma_location\": \"left\",\n" +
                    "          \"refs\": 1,\n" +
                    "          \"is_avc\": \"true\",\n" +
                    "          \"nal_length_size\": \"4\",\n" +
                    "          \"r_frame_rate\": \"30/1\",\n" +
                    "          \"avg_frame_rate\": \"30/1\",\n" +
                    "          \"time_base\": \"1/15360\",\n" +
                    "          \"start_pts\": 0,\n" +
                    "          \"start_time\": \"0.000000\",\n" +
                    "          \"duration_ts\": 215040,\n" +
                    "          \"duration\": \"14.000000\",\n" +
                    "          \"bit_rate\": \"9166570\",\n" +
                    "          \"bits_per_raw_sample\": \"8\",\n" +
                    "          \"nb_frames\": \"420\",\n" +
                    "          \"disposition\": {\n" +
                    "              \"default\": 1,\n" +
                    "              \"dub\": 0,\n" +
                    "              \"original\": 0,\n" +
                    "              \"comment\": 0,\n" +
                    "              \"lyrics\": 0,\n" +
                    "              \"karaoke\": 0,\n" +
                    "              \"forced\": 0,\n" +
                    "              \"hearing_impaired\": 0,\n" +
                    "              \"visual_impaired\": 0,\n" +
                    "              \"clean_effects\": 0,\n" +
                    "              \"attached_pic\": 0,\n" +
                    "              \"timed_thumbnails\": 0\n" +
                    "          },\n" +
                    "          \"tags\": {\n" +
                    "              \"language\": \"und\",\n" +
                    "              \"handler_name\": \"VideoHandler\"\n" +
                    "          }\n" +
                    "      }\n" +
                    "  ],\n" +
                    "  \"format\": {\n" +
                    "      \"filename\": \"sample.mp4\",\n" +
                    "      \"nb_streams\": 1,\n" +
                    "      \"nb_programs\": 0,\n" +
                    "      \"format_name\": \"mov,mp4,m4a,3gp,3g2,mj2\",\n" +
                    "      \"format_long_name\": \"QuickTime / MOV\",\n" +
                    "      \"start_time\": \"0.000000\",\n" +
                    "      \"duration\": \"14.000000\",\n" +
                    "      \"size\": \"16044159\",\n" +
                    "      \"bit_rate\": \"9168090\",\n" +
                    "      \"probe_score\": 100,\n" +
                    "      \"tags\": {\n" +
                    "          \"major_brand\": \"isom\",\n" +
                    "          \"minor_version\": \"512\",\n" +
                    "          \"compatible_brands\": \"isomiso2avc1mp41\",\n" +
                    "          \"encoder\": \"Lavf58.33.100\"\n" +
                    "      }\n" +
                    "  }\n" +
                    "}";

    private static final String MEDIA_INFORMATION_PNG =
            "{\n" +
                    "     \"streams\": [\n" +
                    "         {\n" +
                    "             \"index\": 0,\n" +
                    "             \"codec_name\": \"png\",\n" +
                    "             \"codec_long_name\": \"PNG (Portable Network Graphics) image\",\n" +
                    "             \"codec_type\": \"video\",\n" +
                    "             \"codec_time_base\": \"0/1\",\n" +
                    "             \"codec_tag_string\": \"[0][0][0][0]\",\n" +
                    "             \"codec_tag\": \"0x0000\",\n" +
                    "             \"width\": 1198,\n" +
                    "             \"height\": 1198,\n" +
                    "             \"coded_width\": 1198,\n" +
                    "             \"coded_height\": 1198,\n" +
                    "             \"has_b_frames\": 0,\n" +
                    "             \"sample_aspect_ratio\": \"1:1\",\n" +
                    "             \"display_aspect_ratio\": \"1:1\",\n" +
                    "             \"pix_fmt\": \"pal8\",\n" +
                    "             \"level\": -99,\n" +
                    "             \"color_range\": \"pc\",\n" +
                    "             \"refs\": 1,\n" +
                    "             \"r_frame_rate\": \"25/1\",\n" +
                    "             \"avg_frame_rate\": \"0/0\",\n" +
                    "             \"time_base\": \"1/25\",\n" +
                    "             \"disposition\": {\n" +
                    "                 \"default\": 0,\n" +
                    "                 \"dub\": 0,\n" +
                    "                 \"original\": 0,\n" +
                    "                 \"comment\": 0,\n" +
                    "                 \"lyrics\": 0,\n" +
                    "                 \"karaoke\": 0,\n" +
                    "                 \"forced\": 0,\n" +
                    "                 \"hearing_impaired\": 0,\n" +
                    "                 \"visual_impaired\": 0,\n" +
                    "                 \"clean_effects\": 0,\n" +
                    "                 \"attached_pic\": 0,\n" +
                    "                 \"timed_thumbnails\": 0\n" +
                    "             }\n" +
                    "         }\n" +
                    "     ],\n" +
                    "     \"format\": {\n" +
                    "         \"filename\": \"sample.png\",\n" +
                    "         \"nb_streams\": 1,\n" +
                    "         \"nb_programs\": 0,\n" +
                    "         \"format_name\": \"png_pipe\",\n" +
                    "         \"format_long_name\": \"piped png sequence\",\n" +
                    "         \"size\": \"31533\",\n" +
                    "         \"probe_score\": 99\n" +
                    "     }\n" +
                    "}";

    private static final String MEDIA_INFORMATION_OGG =
            "{\n" +
                    "    \"streams\": [\n" +
                    "        {\n" +
                    "            \"index\": 0,\n" +
                    "            \"codec_name\": \"theora\",\n" +
                    "            \"codec_long_name\": \"Theora\",\n" +
                    "            \"codec_type\": \"video\",\n" +
                    "            \"codec_time_base\": \"1/25\",\n" +
                    "            \"codec_tag_string\": \"[0][0][0][0]\",\n" +
                    "            \"codec_tag\": \"0x0000\",\n" +
                    "            \"width\": 1920,\n" +
                    "            \"height\": 1080,\n" +
                    "            \"coded_width\": 1920,\n" +
                    "            \"coded_height\": 1088,\n" +
                    "            \"has_b_frames\": 0,\n" +
                    "            \"pix_fmt\": \"yuv420p\",\n" +
                    "            \"level\": -99,\n" +
                    "            \"color_space\": \"bt470bg\",\n" +
                    "            \"color_transfer\": \"bt709\",\n" +
                    "            \"color_primaries\": \"bt470bg\",\n" +
                    "            \"chroma_location\": \"center\",\n" +
                    "            \"refs\": 1,\n" +
                    "            \"r_frame_rate\": \"25/1\",\n" +
                    "            \"avg_frame_rate\": \"25/1\",\n" +
                    "            \"time_base\": \"1/25\",\n" +
                    "            \"start_pts\": 0,\n" +
                    "            \"start_time\": \"0.000000\",\n" +
                    "            \"duration_ts\": 813,\n" +
                    "            \"duration\": \"32.520000\",\n" +
                    "            \"disposition\": {\n" +
                    "                \"default\": 0,\n" +
                    "                \"dub\": 0,\n" +
                    "                \"original\": 0,\n" +
                    "                \"comment\": 0,\n" +
                    "                \"lyrics\": 0,\n" +
                    "                \"karaoke\": 0,\n" +
                    "                \"forced\": 0,\n" +
                    "                \"hearing_impaired\": 0,\n" +
                    "                \"visual_impaired\": 0,\n" +
                    "                \"clean_effects\": 0,\n" +
                    "                \"attached_pic\": 0,\n" +
                    "                \"timed_thumbnails\": 0\n" +
                    "            },\n" +
                    "            \"tags\": {\n" +
                    "                \"ENCODER\": \"ffmpeg2theora 0.19\"\n" +
                    "            }\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"index\": 1,\n" +
                    "            \"codec_name\": \"vorbis\",\n" +
                    "            \"codec_long_name\": \"Vorbis\",\n" +
                    "            \"codec_type\": \"audio\",\n" +
                    "            \"codec_time_base\": \"1/48000\",\n" +
                    "            \"codec_tag_string\": \"[0][0][0][0]\",\n" +
                    "            \"codec_tag\": \"0x0000\",\n" +
                    "            \"sample_fmt\": \"fltp\",\n" +
                    "            \"sample_rate\": \"48000\",\n" +
                    "            \"channels\": 2,\n" +
                    "            \"channel_layout\": \"stereo\",\n" +
                    "            \"bits_per_sample\": 0,\n" +
                    "            \"r_frame_rate\": \"0/0\",\n" +
                    "            \"avg_frame_rate\": \"0/0\",\n" +
                    "            \"time_base\": \"1/48000\",\n" +
                    "            \"start_pts\": 0,\n" +
                    "            \"start_time\": \"0.000000\",\n" +
                    "            \"duration_ts\": 1583850,\n" +
                    "            \"duration\": \"32.996875\",\n" +
                    "            \"bit_rate\": \"80000\",\n" +
                    "            \"disposition\": {\n" +
                    "                \"default\": 0,\n" +
                    "                \"dub\": 0,\n" +
                    "                \"original\": 0,\n" +
                    "                \"comment\": 0,\n" +
                    "                \"lyrics\": 0,\n" +
                    "                \"karaoke\": 0,\n" +
                    "                \"forced\": 0,\n" +
                    "                \"hearing_impaired\": 0,\n" +
                    "                \"visual_impaired\": 0,\n" +
                    "                \"clean_effects\": 0,\n" +
                    "                \"attached_pic\": 0,\n" +
                    "                \"timed_thumbnails\": 0\n" +
                    "            },\n" +
                    "            \"tags\": {\n" +
                    "                \"ENCODER\": \"ffmpeg2theora 0.19\"\n" +
                    "            }\n" +
                    "        }\n" +
                    "    ],\n" +
                    "    \"format\": {\n" +
                    "        \"filename\": \"sample.ogg\",\n" +
                    "        \"nb_streams\": 2,\n" +
                    "        \"nb_programs\": 0,\n" +
                    "        \"format_name\": \"ogg\",\n" +
                    "        \"format_long_name\": \"Ogg\",\n" +
                    "        \"start_time\": \"0.000000\",\n" +
                    "        \"duration\": \"32.996875\",\n" +
                    "        \"size\": \"27873937\",\n" +
                    "        \"bit_rate\": \"6757958\",\n" +
                    "        \"probe_score\": 100\n" +
                    "    }\n" +
                    "}";

    @Test
    public void mediaInformationMp3() {
        MediaInformation mediaInformation = MediaInformationJsonParser.from(MEDIA_INFORMATION_MP3);

        Assert.assertNotNull(mediaInformation);
        assertMediaInput(mediaInformation, "mp3", "sample.mp3");
        assertMediaDuration(mediaInformation, "327.549388", "0.011995", "320026");

        assertTag(mediaInformation, "comment", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit finito.");
        assertTag(mediaInformation, "album", "Impact");
        assertTag(mediaInformation, "title", "Impact Moderato");
        assertTag(mediaInformation, "artist", "Kevin MacLeod");

        Assert.assertNotNull(mediaInformation.getStreams());
        Assert.assertEquals(1, mediaInformation.getStreams().size());
        assertAudioStream(mediaInformation.getStreams().get(0), 0L, "mp3", "MP3 (MPEG audio layer 3)", "44100", "stereo", "fltp", "320000");

        Assert.assertNotNull(mediaInformation.getChapters());
        Assert.assertEquals(7, mediaInformation.getChapters().size());
        assertChapter(mediaInformation.getChapters().get(0), 0L, "1/22050", 0L, "0.000000", 11158238L, "506.042540");
        assertChapter(mediaInformation.getChapters().get(1), 1L, "1/22050", 11158238L, "506.042540", 21433051L, "972.020454");
    }

    @Test
    public void mediaInformationJpg() {
        MediaInformation mediaInformation = MediaInformationJsonParser.from(MEDIA_INFORMATION_JPG);

        Assert.assertNotNull(mediaInformation);
        assertMediaInput(mediaInformation, "image2", "sample.jpg");
        assertMediaDuration(mediaInformation, "0.040000", "0.000000", "331810000");
        Assert.assertNotNull(mediaInformation.getStreams());
        Assert.assertEquals(1, mediaInformation.getStreams().size());
        assertVideoStream(mediaInformation.getStreams().get(0), 0L, "mjpeg", "Motion JPEG", "yuvj444p", 1496L, 1729L, "1:1", "1496:1729", null, "0/0", "25/1", "1/25", "0/1");
    }

    @Test
    public void mediaInformationGif() {
        MediaInformation mediaInformation = MediaInformationJsonParser.from(MEDIA_INFORMATION_GIF);

        Assert.assertNotNull(mediaInformation);
        assertMediaInput(mediaInformation, "gif", "sample.gif");
        assertMediaDuration(mediaInformation, "3.960000", "0.000000", "2023672");
        Assert.assertNotNull(mediaInformation.getStreams());
        Assert.assertEquals(1, mediaInformation.getStreams().size());
        assertVideoStream(mediaInformation.getStreams().get(0), 0L, "gif", "CompuServe GIF (Graphics Interchange Format)", "bgra", 400L, 400L, null, null, null, "133/12", "100/9", "1/100", "12/133");
    }

    @Test
    public void mediaInformationMp4() {
        MediaInformation mediaInformation = MediaInformationJsonParser.from(MEDIA_INFORMATION_MP4);

        Assert.assertNotNull(mediaInformation);
        assertMediaInput(mediaInformation, "mov,mp4,m4a,3gp,3g2,mj2", "sample.mp4");
        assertMediaDuration(mediaInformation, "14.000000", "0.000000", "9168090");

        assertTag(mediaInformation, "major_brand", "isom");
        assertTag(mediaInformation, "minor_version", "512");
        assertTag(mediaInformation, "compatible_brands", "isomiso2avc1mp41");
        assertTag(mediaInformation, "encoder", "Lavf58.33.100");

        Assert.assertNotNull(mediaInformation.getStreams());
        Assert.assertEquals(1, mediaInformation.getStreams().size());
        assertVideoStream(mediaInformation.getStreams().get(0), 0L, "h264", "H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10", "yuv420p", 1280L, 720L, "1:1", "16:9", "9166570", "30/1", "30/1", "1/15360", "1/60");

        assertStreamTag(mediaInformation.getStreams().get(0), "language", "und");
        assertStreamTag(mediaInformation.getStreams().get(0), "handler_name", "VideoHandler");
    }

    @Test
    public void mediaInformationPng() {
        MediaInformation mediaInformation = MediaInformationJsonParser.from(MEDIA_INFORMATION_PNG);

        Assert.assertNotNull(mediaInformation);
        assertMediaInput(mediaInformation, "png_pipe", "sample.png");
        assertMediaDuration(mediaInformation, null, null, null);
        Assert.assertNotNull(mediaInformation.getStreams());
        Assert.assertEquals(1, mediaInformation.getStreams().size());
        assertVideoStream(mediaInformation.getStreams().get(0), 0L, "png", "PNG (Portable Network Graphics) image", "pal8", 1198L, 1198L, "1:1", "1:1", null, "0/0", "25/1", "1/25", "0/1");
    }

    @Test
    public void mediaInformationOgg() {
        MediaInformation mediaInformation = MediaInformationJsonParser.from(MEDIA_INFORMATION_OGG);

        Assert.assertNotNull(mediaInformation);
        assertMediaInput(mediaInformation, "ogg", "sample.ogg");
        assertMediaDuration(mediaInformation, "32.996875", "0.000000", "6757958");
        Assert.assertNotNull(mediaInformation.getStreams());
        Assert.assertEquals(2, mediaInformation.getStreams().size());
        assertVideoStream(mediaInformation.getStreams().get(0), 0L, "theora", "Theora", "yuv420p", 1920L, 1080L, null, null, null, "25/1", "25/1", "1/25", "1/25");
        assertAudioStream(mediaInformation.getStreams().get(1), 1L, "vorbis", "Vorbis", "48000", "stereo", "fltp", "80000");

        assertStreamTag(mediaInformation.getStreams().get(0), "ENCODER", "ffmpeg2theora 0.19");
        assertStreamTag(mediaInformation.getStreams().get(1), "ENCODER", "ffmpeg2theora 0.19");
    }

    @Test
    public void parseSimpleCommand() {
        final String[] argumentArray = FFmpegKitConfig.parseArguments("-hide_banner -loop 1 -i file.jpg -filter_complex [0:v]setpts=PTS-STARTPTS[video] -map [video] -vsync 2 -async 1 video.mp4");

        Assert.assertNotNull(argumentArray);
        Assert.assertEquals(14, argumentArray.length);

        Assert.assertEquals("-hide_banner", argumentArray[0]);
        Assert.assertEquals("-loop", argumentArray[1]);
        Assert.assertEquals("1", argumentArray[2]);
        Assert.assertEquals("-i", argumentArray[3]);
        Assert.assertEquals("file.jpg", argumentArray[4]);
        Assert.assertEquals("-filter_complex", argumentArray[5]);
        Assert.assertEquals("[0:v]setpts=PTS-STARTPTS[video]", argumentArray[6]);
        Assert.assertEquals("-map", argumentArray[7]);
        Assert.assertEquals("[video]", argumentArray[8]);
        Assert.assertEquals("-vsync", argumentArray[9]);
        Assert.assertEquals("2", argumentArray[10]);
        Assert.assertEquals("-async", argumentArray[11]);
        Assert.assertEquals("1", argumentArray[12]);
        Assert.assertEquals("video.mp4", argumentArray[13]);
    }

    @Test
    public void parseSingleQuotesInCommand() {
        String[] argumentArray = FFmpegKitConfig.parseArguments("-loop 1 'file one.jpg'  -filter_complex  '[0:v]setpts=PTS-STARTPTS[video]'  -map  [video]  video.mp4 ");

        Assert.assertNotNull(argumentArray);
        Assert.assertEquals(8, argumentArray.length);

        Assert.assertEquals("-loop", argumentArray[0]);
        Assert.assertEquals("1", argumentArray[1]);
        Assert.assertEquals("file one.jpg", argumentArray[2]);
        Assert.assertEquals("-filter_complex", argumentArray[3]);
        Assert.assertEquals("[0:v]setpts=PTS-STARTPTS[video]", argumentArray[4]);
        Assert.assertEquals("-map", argumentArray[5]);
        Assert.assertEquals("[video]", argumentArray[6]);
        Assert.assertEquals("video.mp4", argumentArray[7]);
    }

    @Test
    public void parseDoubleQuotesInCommand() {
        String[] argumentArray = FFmpegKitConfig.parseArguments("-loop  1 \"file one.jpg\"   -filter_complex \"[0:v]setpts=PTS-STARTPTS[video]\"  -map  [video]  video.mp4 ");

        Assert.assertNotNull(argumentArray);
        Assert.assertEquals(8, argumentArray.length);

        Assert.assertEquals("-loop", argumentArray[0]);
        Assert.assertEquals("1", argumentArray[1]);
        Assert.assertEquals("file one.jpg", argumentArray[2]);
        Assert.assertEquals("-filter_complex", argumentArray[3]);
        Assert.assertEquals("[0:v]setpts=PTS-STARTPTS[video]", argumentArray[4]);
        Assert.assertEquals("-map", argumentArray[5]);
        Assert.assertEquals("[video]", argumentArray[6]);
        Assert.assertEquals("video.mp4", argumentArray[7]);

        argumentArray = FFmpegKitConfig.parseArguments(" -i   file:///tmp/input.mp4 -vcodec libx264 -vf \"scale=1024:1024,pad=width=1024:height=1024:x=0:y=0:color=black\"  -acodec copy  -q:v 0  -q:a   0 video.mp4");

        Assert.assertNotNull(argumentArray);
        Assert.assertEquals(13, argumentArray.length);

        Assert.assertEquals("-i", argumentArray[0]);
        Assert.assertEquals("file:///tmp/input.mp4", argumentArray[1]);
        Assert.assertEquals("-vcodec", argumentArray[2]);
        Assert.assertEquals("libx264", argumentArray[3]);
        Assert.assertEquals("-vf", argumentArray[4]);
        Assert.assertEquals("scale=1024:1024,pad=width=1024:height=1024:x=0:y=0:color=black", argumentArray[5]);
        Assert.assertEquals("-acodec", argumentArray[6]);
        Assert.assertEquals("copy", argumentArray[7]);
        Assert.assertEquals("-q:v", argumentArray[8]);
        Assert.assertEquals("0", argumentArray[9]);
        Assert.assertEquals("-q:a", argumentArray[10]);
        Assert.assertEquals("0", argumentArray[11]);
        Assert.assertEquals("video.mp4", argumentArray[12]);
    }

    @Test
    public void parseDoubleQuotesAndEscapesInCommand() {
        String[] argumentArray = FFmpegKitConfig.parseArguments("  -i   file:///tmp/input.mp4 -vf \"subtitles=file:///tmp/subtitles.srt:force_style=\'FontSize=16,PrimaryColour=&HFFFFFF&\'\" -vcodec libx264   -acodec copy  -q:v 0 -q:a  0  video.mp4");

        Assert.assertNotNull(argumentArray);
        Assert.assertEquals(13, argumentArray.length);

        Assert.assertEquals("-i", argumentArray[0]);
        Assert.assertEquals("file:///tmp/input.mp4", argumentArray[1]);
        Assert.assertEquals("-vf", argumentArray[2]);
        Assert.assertEquals("subtitles=file:///tmp/subtitles.srt:force_style='FontSize=16,PrimaryColour=&HFFFFFF&'", argumentArray[3]);
        Assert.assertEquals("-vcodec", argumentArray[4]);
        Assert.assertEquals("libx264", argumentArray[5]);
        Assert.assertEquals("-acodec", argumentArray[6]);
        Assert.assertEquals("copy", argumentArray[7]);
        Assert.assertEquals("-q:v", argumentArray[8]);
        Assert.assertEquals("0", argumentArray[9]);
        Assert.assertEquals("-q:a", argumentArray[10]);
        Assert.assertEquals("0", argumentArray[11]);
        Assert.assertEquals("video.mp4", argumentArray[12]);

        argumentArray = FFmpegKitConfig.parseArguments("  -i   file:///tmp/input.mp4 -vf \"subtitles=file:///tmp/subtitles.srt:force_style=\\\"FontSize=16,PrimaryColour=&HFFFFFF&\\\"\" -vcodec libx264   -acodec copy  -q:v 0 -q:a  0  video.mp4");

        Assert.assertNotNull(argumentArray);
        Assert.assertEquals(13, argumentArray.length);

        Assert.assertEquals("-i", argumentArray[0]);
        Assert.assertEquals("file:///tmp/input.mp4", argumentArray[1]);
        Assert.assertEquals("-vf", argumentArray[2]);
        Assert.assertEquals("subtitles=file:///tmp/subtitles.srt:force_style=\\\"FontSize=16,PrimaryColour=&HFFFFFF&\\\"", argumentArray[3]);
        Assert.assertEquals("-vcodec", argumentArray[4]);
        Assert.assertEquals("libx264", argumentArray[5]);
        Assert.assertEquals("-acodec", argumentArray[6]);
        Assert.assertEquals("copy", argumentArray[7]);
        Assert.assertEquals("-q:v", argumentArray[8]);
        Assert.assertEquals("0", argumentArray[9]);
        Assert.assertEquals("-q:a", argumentArray[10]);
        Assert.assertEquals("0", argumentArray[11]);
        Assert.assertEquals("video.mp4", argumentArray[12]);
    }

    @Test
    public void argumentsToString() {
        Assert.assertEquals("null", argumentsToString(null));
        Assert.assertEquals("-i input.mp4 -vf filter -c:v mpeg4 output.mp4", argumentsToString(new String[]{"-i", "input.mp4", "-vf", "filter", "-c:v", "mpeg4", "output.mp4"}));
    }

    public String argumentsToString(final String[] arguments) {
        return FFmpegKitConfig.argumentsToString(arguments);
    }

    private void assertMediaInput(MediaInformation mediaInformation, String format, String filename) {
        Assert.assertEquals(format, mediaInformation.getFormat());
        Assert.assertEquals(filename, mediaInformation.getFilename());
    }

    private void assertMediaDuration(MediaInformation mediaInformation, String duration, String startTime, String bitrate) {
        Assert.assertEquals(duration, mediaInformation.getDuration());
        Assert.assertEquals(startTime, mediaInformation.getStartTime());
        Assert.assertEquals(bitrate, mediaInformation.getBitrate());
    }

    private void assertTag(MediaInformation mediaInformation, String expectedKey, String expectedValue) {
        JSONObject tags = mediaInformation.getTags();
        Assert.assertNotNull(tags);

        try {
            String value = tags.getString(expectedKey);
            Assert.assertEquals(expectedValue, value);
        } catch (JSONException e) {
            e.printStackTrace();
            Assert.fail(expectedKey + " not found");
        }
    }

    private void assertStreamTag(StreamInformation streamInformation, String expectedKey, String expectedValue) {
        JSONObject tags = streamInformation.getTags();
        Assert.assertNotNull(tags);

        try {
            String value = tags.getString(expectedKey);
            Assert.assertEquals(expectedValue, value);
        } catch (JSONException e) {
            e.printStackTrace();
            Assert.fail(expectedKey + " not found");
        }
    }

    private void assertStream(StreamInformation streamInformation, Long index, String type, String codec, String fullCodec, String bitrate) {
        Assert.assertEquals(index, streamInformation.getIndex());
        Assert.assertEquals(type, streamInformation.getType());

        Assert.assertEquals(codec, streamInformation.getCodec());
        Assert.assertEquals(fullCodec, streamInformation.getCodecLong());

        Assert.assertEquals(bitrate, streamInformation.getBitrate());
    }

    private void assertAudioStream(StreamInformation streamInformation, Long index, String codec, String fullCodec, String sampleRate, String channelLayout, String sampleFormat, String bitrate) {
        Assert.assertEquals(index, streamInformation.getIndex());
        Assert.assertEquals("audio", streamInformation.getType());

        Assert.assertEquals(codec, streamInformation.getCodec());
        Assert.assertEquals(fullCodec, streamInformation.getCodecLong());

        Assert.assertEquals(sampleRate, streamInformation.getSampleRate());
        Assert.assertEquals(channelLayout, streamInformation.getChannelLayout());
        Assert.assertEquals(sampleFormat, streamInformation.getSampleFormat());
        Assert.assertEquals(bitrate, streamInformation.getBitrate());
    }

    private void assertVideoStream(StreamInformation streamInformation, Long index, String codec, String fullCodec, String format, Long width, Long height, String sar, String dar, String bitrate, String averageFrameRate, String realFrameRate, String timeBase, String codecTimeBase) {
        Assert.assertEquals(index, streamInformation.getIndex());
        Assert.assertEquals("video", streamInformation.getType());

        Assert.assertEquals(codec, streamInformation.getCodec());
        Assert.assertEquals(fullCodec, streamInformation.getCodecLong());

        Assert.assertEquals(format, streamInformation.getFormat());

        Assert.assertEquals(width, streamInformation.getWidth());
        Assert.assertEquals(height, streamInformation.getHeight());
        Assert.assertEquals(sar, streamInformation.getSampleAspectRatio());
        Assert.assertEquals(dar, streamInformation.getDisplayAspectRatio());

        Assert.assertEquals(bitrate, streamInformation.getBitrate());

        Assert.assertEquals(averageFrameRate, streamInformation.getAverageFrameRate());
        Assert.assertEquals(realFrameRate, streamInformation.getRealFrameRate());
        Assert.assertEquals(timeBase, streamInformation.getTimeBase());
        Assert.assertEquals(codecTimeBase, streamInformation.getCodecTimeBase());
    }

    private void assertChapter(Chapter chapter, Long id, String timeBase, Long start, String startTime, Long end, String endTime) {
        Assert.assertEquals(id, chapter.getId());
        Assert.assertEquals(timeBase, chapter.getTimeBase());

        Assert.assertEquals(start, chapter.getStart());
        Assert.assertEquals(startTime, chapter.getStartTime());

        Assert.assertEquals(end, chapter.getEnd());
        Assert.assertEquals(endTime, chapter.getEndTime());

        Assert.assertNotNull(chapter.getTags());
        Assert.assertEquals(1, chapter.getTags().length());
    }

}
