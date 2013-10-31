package org.redfire.screen;

import javax.swing.*;

/**
 * User: palkan
 * Date: 10/4/13
 * Time: 11:32 AM
 */
public class ScreenShareApplet extends JApplet {

    protected ScreenShare _instance;
    private static Logger logger = new Logger();

    /**
     */
    public ScreenShareApplet(){

    }


    /**
     *
     */

    @Override
    public void start(){

        logger.debug(System.getProperty("java.version"));

        String[] opts = {
                getParameter("host"),
                getParameter("app"),
                getParameter("port"),
                getParameter("stream_name"),
                "flashsv2",
                getParameter("fps"),
                getParameter("videoWidth"),
                getParameter("videoHeight")
        };

        _instance = ScreenShare.getInstance();

        _instance.setup(opts);

    }

    /**
     */
    @Override
    public void stop(){

        _instance.stopStream();

    }

}
