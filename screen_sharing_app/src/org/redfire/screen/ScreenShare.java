package org.redfire.screen;

import com.flazr.amf.Amf0Object;
import com.flazr.rtmp.RtmpMessage;
import com.flazr.rtmp.client.ClientOptions;
import com.flazr.rtmp.message.MetadataAmf0;
import com.flazr.rtmp.message.Video;
import com.flazr.util.Utils;
import org.jboss.netty.bootstrap.ClientBootstrap;
import org.jboss.netty.channel.Channel;
import org.jboss.netty.channel.ChannelFactory;
import org.jboss.netty.channel.ChannelFuture;
import org.jboss.netty.channel.socket.nio.NioClientSocketChannelFactory;
import org.redfire.screen.frame.CaptureRegionFrame;
import org.redfire.screen.frame.CaptureRegionListener;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.concurrent.Callable;
import java.util.concurrent.Executor;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class ScreenShare {

    public static ScreenShare instance = null;
	public static ClientOptions options;
	
	private static final int C_MOUSE_FREQUENCY = 500;
	private static final int C_MOUSE_POS_FREQUENCY = 500;
	
    public boolean startPublish = false;
  
    public int frameWidth = 0;
    public int frameHeight = 0;
    public int frameX = 0;
    public int frameY = 0;
    
    public boolean exitOnClose = true;
	public CaptureScreen capture = null;
	private Thread thread = null;
	private Thread mouseThread = null;
	public Robot robot;
	
	public String host = "btg199251";
	public String app = "oflaDemo";
	public int port = 1935;
    public String publishName;
    public String codec = "flashsv2";
    public int frameRate = 10;
    public int maxWidth = 1024;
    public int maxHeight = 768;
    
	private Channel clientChannel;
	private ScreenPublisher publisher;

	private long startTime;
    private int kt = 0;
	private CaptureRegionFrame frame;
	private static Logger logger = new Logger();
    // ------------------------------------------------------------------------
    //
    // Main
    //
    // ------------------------------------------------------------------------


	public static void main(String[] args)
	{
		ScreenShare.getInstance();
		instance.createRegion(10, 10);
		
		if (args.length == 8) {
			instance.host = args[0];
			instance.app = args[1];
			instance.port = Integer.parseInt(args[2]);
			instance.publishName = args[3];
			instance.codec = args[4];

			try {
				instance.frameRate = Integer.parseInt(args[5]);
				instance.maxWidth = Integer.parseInt(args[6]);
				instance.maxHeight = Integer.parseInt(args[7]);

			} catch (Exception e) {}

			System.out.println("User home " + System.getProperty("user.home"));
			System.out.println("User Dir " + System.getProperty("user.dir"));

		} else {
			logger.debug("cant get values from main params");
			//	System.exit(0);
		}

		logger.debug("host: " + instance.host + ", app: " + instance.app + ", port: " + instance.port + ", publish: " + instance.publishName + ", fps: " + instance.frameRate);

		if (options == null)
		{
			options = new ClientOptions(instance.host, instance.port, instance.app, instance.publishName, null, false, null);
			options.publishLive();
			options.setClientVersionToUse(Utils.fromHex("00000000"));
		}
	}

	private ScreenShare() {}

	public static ScreenShare getInstance()
	{
		if (instance == null) instance = new ScreenShare();

		return instance;
	}


    public void setup(String[] args){

        instance.createRegion(10, 10);

        if (args.length == 8) {
            instance.host = args[0];
            instance.app = args[1];
            instance.port = Integer.parseInt(args[2]);
            instance.publishName = args[3];
            instance.codec = args[4];

            try {
                instance.frameRate = Integer.parseInt(args[5]);
                instance.maxWidth = Integer.parseInt(args[6]);
                instance.maxHeight = Integer.parseInt(args[7]);

            } catch (Exception e) {}

            System.out.println("User home " + System.getProperty("user.home"));
            System.out.println("User Dir " + System.getProperty("user.dir"));

        } else {
            logger.debug("cant get values from main params");
            System.exit(0);
        }

        logger.debug("host: " + instance.host + ", app: " + instance.app + ", port: " + instance.port + ", publish: " + instance.publishName + ", fps: " + instance.frameRate);

        if (options == null)
        {
            options = new ClientOptions(instance.host, instance.port, instance.app, instance.publishName, null, false, null);
            options.publishLive();
            options.setClientVersionToUse(Utils.fromHex("00000000"));
        }

    }


    // ------------------------------------------------------------------------
    //
    // GUI
    //
    // ------------------------------------------------------------------------
	
	public void createRegion(int x, int y){
		try {

			Dimension screenSize = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
			CaptureRegionListener crl = new CaptureRegionListenerImp(this);
			frame = new CaptureRegionFrame(crl, 3);
			frame.setHeight(Double.valueOf(screenSize.getHeight()).intValue() - 20);
			frame.setWidth(Double.valueOf(screenSize.getWidth()).intValue() - 20);
			frame.setLocation(x, y);
			frame.setVisible(true);		
		}catch (Exception err)
		{
			System.out.println("createWindow Exception: ");
			err.printStackTrace();
			if (exitOnClose) System.exit(0);
		}
	}

	private void captureScreenStart()
	{
		try {
			startStream(host, app, port, publishName);
		} catch (Exception err) {
			System.out.println("captureScreenStart Exception: ");
			System.err.println(err);
			logger.info("Exception: "+err);
		}
	}

    // ------------------------------------------------------------------------
    //
    // Public
    //
    // ------------------------------------------------------------------------


    public void startStream( String host, String app, int port, String publishName) {

        this.publishName = publishName;

		startTime = System.currentTimeMillis();
		kt = 0;

		ExecutorService executor = Executors.newCachedThreadPool();

        executor.submit(new Callable<Boolean>()
        {
            public Boolean call() throws Exception
            {
                try {
            		connect(options);
                }
                catch (Exception e) {
            		logger.error( "ScreenShare startStream exception " + e );
                }

                return true;
            }
        });
    }


    public void stopStream() {

        try {
            thread = null;
            mouseThread = null;
            startPublish = false;

            disconnect();

           // capture.stop();
            capture.release();
            capture = null;
        }
        catch ( Exception e ) {

        }

    }
    
    public void die(){
    	logger.info("die");
    	if(exitOnClose)
    		System.exit(0);
    }
    
    // ------------------------------------------------------------------------
    //
    // Implementations
    //
    // ------------------------------------------------------------------------

    public void connect(final ClientOptions options)
    {
        final ClientBootstrap bootstrap = getBootstrap(Executors.newCachedThreadPool(), options);
        final ChannelFuture future = bootstrap.connect(new InetSocketAddress(options.getHost(), options.getPort()));
        future.awaitUninterruptibly();

        if(!future.isSuccess())
        {
            logger.error("error creating client connection: {}"+ future.getCause().getMessage());
            die();
        }

		clientChannel = future.getChannel();
        future.getChannel().getCloseFuture().awaitUninterruptibly();
        bootstrap.getFactory().releaseExternalResources();
    }

    public void disconnect()
    {
		final ChannelFuture future = clientChannel.disconnect();
        future.awaitUninterruptibly();
        clientChannel.getFactory().releaseExternalResources();
    }

    private ClientBootstrap getBootstrap(final Executor executor, final ClientOptions options)
    {
        final ChannelFactory factory = new NioClientSocketChannelFactory(executor, executor);
        final ClientBootstrap bootstrap = new ClientBootstrap(factory);
        bootstrap.setPipelineFactory(new ScreenClientPipelineFactory(options, this));
        bootstrap.setOption("tcpNoDelay" , true);
        bootstrap.setOption("keepAlive", true);
        return bootstrap;
    }

    public void screenPublish(ScreenPublisher publisher )
    {
		this.publisher = publisher;

		try {
			this.robot = new Robot();

			capture = new CaptureScreen(frameX>0 ? frameX : 0,
										frameY>0 ? frameY : 0,
										frameWidth > 0 ? frameWidth : maxWidth,
										frameHeight > 0 ? frameHeight : maxHeight);

			if (thread == null)
			{
				thread = new Thread(capture);
				thread.start();
			}
			
			SendMouseCoords smc = new SendMouseCoords();
			
			if (mouseThread == null) {
				mouseThread = new Thread(smc);
				mouseThread.start();
			}
			
			startPublish = true;

		} catch (Exception e) {

			logger.error("screenPublish error " + e);
			e.printStackTrace();
			logger.info("Internal error capturing screen, see log file");
		}
    }

    private void pushVideo(byte[] video, long ts) throws IOException {

		if (!startPublish) return;

		RtmpMessage rtmpMsg = new Video(video);
		rtmpMsg.getHeader().setTime((int)ts);
		publisher.write(clientChannel, rtmpMsg);

        kt++;

        if ( kt < 10 ) {
            System.out.println( "+++ " + rtmpMsg);
        }

    }
    
    private void pushMessage(String msg){
    	if (!startPublish) return;
    	Amf0Object ob = new Amf0Object();
    	ob.put("msgtype", msg);
		RtmpMessage rtmpMsg = new MetadataAmf0("onMetaData", ob);
		publisher.write(clientChannel, rtmpMsg);	
    }
    
    private void sendMousePos(double x, double y) {
    	if (!startPublish) 
    		return;
    	
    	//System.out.println("SendMousePos before point x = " + x + " point y =" + y);
    	
    	int posX = ((Double)(x*1000)).intValue();
    	int posY = ((Double)(y*1000)).intValue();
    	
    	//System.out.println(" SendMousePos after point x = " + posX + " point y =" + posY);
    	
    	Amf0Object ob = new Amf0Object();
    	ob.put("msgtype", "mouse");
    	ob.put("posx", posX);
    	ob.put("posy", posY);
		RtmpMessage rtmpMsg = new MetadataAmf0("onMetaData", ob);
		
		publisher.write(clientChannel, rtmpMsg);	
    }
    

	public void mousePress(double button)
	{
		//Calling from ScreenClientHandler
		/*if (capture != null && robot != null)
		{
			logger.info("mousePress " + button);

			if (button == 1) robot.mousePress(InputEvent.BUTTON1_MASK);
			if (button == 2) robot.mousePress(InputEvent.BUTTON2_MASK);
			if (button == 3) robot.mousePress(InputEvent.BUTTON3_MASK);
		}*/
	}

	public void mouseRelease(double button)
	{
		/*
		if (capture != null && robot != null)
		{
			logger.info("mouseRelease " + button);

			if (button == 1) robot.mouseRelease(InputEvent.BUTTON1_MASK);
			if (button == 2) robot.mouseRelease(InputEvent.BUTTON2_MASK);
			if (button == 3) robot.mouseRelease(InputEvent.BUTTON3_MASK);
		}*/
	}

	public void doubleClick(double x, double y, double width, double height)
	{
		/*if (capture != null && robot != null)
		{
			logger.info("doubleClick " + x + " " + y + " " + width + " " + height);

			int newX = (int)((x/width*capture.width) + capture.x);
			int newY = (int)((y/height*capture.height) + capture.y);

			robot.mouseMove(newX, newY);
			robot.mousePress(InputEvent.BUTTON1_MASK);
			robot.mouseRelease(InputEvent.BUTTON1_MASK);
			robot.mousePress(InputEvent.BUTTON1_MASK);
			robot.mouseRelease(InputEvent.BUTTON1_MASK);
		}*/
	}

	public void keyPress(double key)
	{
	/*	int newKey = translateKey(key);

		if (capture != null && robot != null)
		{
			logger.info("keyPress " + key);
			robot.keyPress(newKey);
		}*/
	}

	public void keyRelease(double key)
	{
		/*int newKey = translateKey(key);

		if (capture != null && robot != null)
		{
			logger.info("keyRelease " + key);
			robot.keyRelease(newKey);
		}*/
	}

	public void mouseMove(double x, double y, double width, double height)
	{
		/*if (capture != null && robot != null)
		{
			logger.info("mouseMove " + x + " " + y + " " + width + " " + height);

			int newX = (int)((x/width*capture.width) + capture.x);
			int newY = (int)((y/height*capture.height) + capture.y);

			robot.mouseMove(newX, newY);
		}*/
	}

	/*private int translateKey(double key)
	{
		if (key == 13)
			return 10;
		else
			return (int) key;
	}
	 */
	// ------------------------------------------------------------------------
	//
	// CaptureScreen
	//
	// ------------------------------------------------------------------------


	private final class CaptureScreen extends Object implements Runnable
	{
		public volatile int x = 0;
		public volatile int y = 0;
		public volatile int width = 320;
		public volatile int height = 240;

		private int mousePosX = 0;
		private int mousePosY = 0;
		
		private volatile long timestamp = 0;
		
		private volatile boolean rescale = false;
		
		private volatile boolean active = true;
		//private BufferedImage cursorImage;
		private GraphicsConfiguration configuration = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().getDefaultConfiguration();


		// ------------------------------------------------------------------------
		//
		// Constructor
		//
		// ------------------------------------------------------------------------


		public CaptureScreen(final int x, final int y, final int width, final int height)
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			
			if(width > maxWidth || height > maxHeight){
			
				
				this.rescale = true;
				
				double ratio = Double.valueOf(width) / Double.valueOf(height);
			
				maxWidth = Double.valueOf(ratio * Double.valueOf(maxHeight)).intValue();
				
			}

		   	logger.debug( "CaptureScreen: x=" + x + ", y=" + y + ", w=" + width + ", h=" + height );

		}


		// ------------------------------------------------------------------------
		//
		// Public
		//
		// ------------------------------------------------------------------------

		public void release()
		{
			active = false;
		}


		// ------------------------------------------------------------------------
		//
		// Thread loop
		//
		// ------------------------------------------------------------------------

		public void run()
		{
			final int timeBetweenFrames = 1000 / frameRate;
			
			try
			{
				ScreenCodec screenCodec;

				if ("flashsv1".equals(codec))
					screenCodec = new ScreenCodec1(rescale ? maxWidth : width, rescale ? maxHeight : height);
				else
					screenCodec = new ScreenCodec2(rescale ? maxWidth : width, rescale ? maxHeight : height);

				
				
				while (active)
				{
				
					if (mousePosX ==  MouseInfo.getPointerInfo().getLocation().x && 
							mousePosY == MouseInfo.getPointerInfo().getLocation().y && 
							kt  > 20 && (kt % 10) != 0) {
						//pushMessage("alive");
						kt++;
						
						Thread.sleep(C_MOUSE_POS_FREQUENCY);
						continue;
					}
					
					final long ctime = System.currentTimeMillis();
					
					mousePosX =  MouseInfo.getPointerInfo().getLocation().x;
					mousePosY = MouseInfo.getPointerInfo().getLocation().y;
					
					try
					{
						BufferedImage image = robot.createScreenCapture(new Rectangle(x, y, width, height));
						
						if (this.rescale)
						{
							image = scaleImage(image, maxWidth, maxHeight);
						}

						timestamp =  System.currentTimeMillis() - startTime;

						final byte[] screenBytes = screenCodec.encode(image);
						pushVideo(screenBytes, timestamp);

					}
					catch (Exception e)
					{
						e.printStackTrace();
					}

					final int spent = (int) (System.currentTimeMillis() - ctime);
					final int sleep = Math.max(0, timeBetweenFrames - spent);

        			if ( kt < 50 ) {					// lets see what frame rate performance is like for first 50 frames
            			System.out.println( "Sleep " + sleep);
					}

					Thread.sleep(sleep);
				}
			}
			catch (Exception e)
			{
				e.printStackTrace();
			}
		}

		/*private BufferedImage addCursor(int x, int y, BufferedImage image)
		{
			BufferedImage newImage = image;

			Point point = MouseInfo.getPointerInfo().getLocation();

			Graphics2D g2d = newImage.createGraphics();
			g2d.drawImage(cursorImage, new AffineTransform(1f,0f,0f,1f, point.x - x, point.y - y), null);
			g2d.dispose();

			return newImage;
		}*/

        private BufferedImage scaleImage(BufferedImage orig, int w, int h)
        {
           	BufferedImage tmp = configuration.createCompatibleImage(w, h, Transparency.TRANSLUCENT);
           	Graphics2D g2 = tmp.createGraphics();
 			g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        	g2.drawImage(orig, 0, 0, w, h, null);
            g2.dispose();

            return tmp;
        }
        
	}
	
	
	
	private class CaptureRegionListenerImp implements CaptureRegionListener {
		private final ScreenShare srs;
		
		public CaptureRegionListenerImp(ScreenShare srs) {
			this.srs = srs;
		}
		
		@Override
		public void onCaptureRegionMoved(int x, int y) {
			logger.debug( "Move frame: " + x +" " + y);
		}

		@Override
		public void onStartCapture(int x, int y, int width, int height) {
			logger.debug( "start share: " + x +" " + y+" " +width + " " + height);
			 srs.frameWidth = width;
			 srs.frameHeight = height;
			 srs.frameX = x;
			 srs.frameY = y;
			 
			 srs.captureScreenStart();
		}

		@Override
		public void onStopCapture() {
			logger.debug( "stop share");
			srs.stopStream();
			if (exitOnClose) System.exit(0);
		}
		
		
    }
	
	private class SendMouseCoords implements Runnable{

		@Override
		public void run() {
			while (true) {
				sendMousePos((double)(MouseInfo.getPointerInfo().getLocation().x - frameX)/frameWidth, 
						(double)(MouseInfo.getPointerInfo().getLocation().y - frameY)/frameHeight);
				try {
					Thread.sleep(C_MOUSE_FREQUENCY);
				}catch (Exception ex) {
					logger.info("error while sleeping send coordinate");
				}
			}
		}
		
	}
}

