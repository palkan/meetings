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

        String[] opts = {"127.0.0.1","tbshare/1","443","test_share","flashv2","2","1024","768"};

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
