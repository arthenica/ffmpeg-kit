package com.sahib.pyff;

import com.arthenica.ffmpegkit.FFmpegSession;
import com.arthenica.ffmpegkit.FFmpegKit;
import com.arthenica.ffmpegkit.FFprobeKit;
import com.arthenica.ffmpegkit.FFprobeSession;
import com.arthenica.ffmpegkit.SessionState;

public class ffpy
{
    public static String Run(String command) {
        FFmpegSession esession = FFmpegKit.execute(command);
        SessionState state = esession.getState();

        while (state != SessionState.COMPLETED){}
        return esession.getOutput();


    }
    public static String RunProbe(String Command){
        FFprobeSession session = FFprobeKit.execute(Command);
        String soutput = session.getOutput();
        return soutput;

    };
    //FFprobe soon :)
}
