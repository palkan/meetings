/** 
* ===License Header===
*
* BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
*
* Copyright (c) 2010 BigBlueButton Inc. and by respective authors (see below).
*
* This program is free software; you can redistribute it and/or modify it under the
* terms of the GNU Lesser General Public License as published by the Free Software
* Foundation; either version 2.1 of the License, or (at your option) any later
* version.
*
* BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
* WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
* PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License along
* with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
* 
* ===License Header===
*/

package org.redfire.screen.frame;

import com.sun.awt.AWTUtilities;

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.peer.ComponentPeer;
import java.io.Serializable;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.concurrent.atomic.AtomicBoolean;

class WindowlessFrame implements Serializable {
	private static final long serialVersionUID = 1L;

	private CaptureRegionListener captureRegionListener;
	private MouseAdapter resizingAdapter;
	private MouseAdapter movingAdapter;
	
	private final BasicStroke borderSolidStroke = new BasicStroke(3);
	private final Paint blueColor = new Color(20,110,176,255);
	private final Paint blueTransparenColor = new Color(20,110,176,102);
	private final Color tColor = new Color(0,0,0,0);

    private Boolean isMac = true;
	
	private static interface PropertyChanger {
		void changeOn(Component component);
	}
	
	private static interface LocationAndSizeUpdateable {
		void updateLocationAndSize();
	}
	
	private static interface OffsetLocator {
		int getLeftOffset();
		int getTopOffset();
	}

	private static final PropertyChanger REPAINTER = new PropertyChanger() {
		@Override
		public void changeOn(Component component) {
			if (component instanceof LocationAndSizeUpdateable) {
				((LocationAndSizeUpdateable) component).updateLocationAndSize();
			}
			component.repaint();
		}
	};
	

	// properties that change during use
	private Point mTopLeft = new Point();
	private Dimension mOverallSize = new Dimension();
	
	private final int mBorderWidth;
	private final JWindow mWindowFrame;
	private final CaptureFrame cFrame;
	
	private ToolbarWindow mToolbarFrame;
	
	private MultiScreen mScreen = new MultiScreen();
	
	/*****************************************************************************
    ;  Class MultiScreen
    ;----------------------------------------------------------------------------
	; DESCRIPTION
	;   This class is used to detect if the system has more than one screen.
	******************************************************************************/
	private class MultiScreen {
		private int                 minX=0 ;              //minimum of x position
		private int                 totalWidth=0 ;        // total screen resolution
		private int                 curWidth=0 ;          // primary screen width
		private GraphicsEnvironment ge ;
		private GraphicsDevice[]    screenDevice ;
		private boolean             ismultiscreen=false ;
		
		/*****************************************************************************
	    ;  MultiScreen
	    ;----------------------------------------------------------------------------
		; DESCRIPTION
		;   This is the class constructor.
		;
		; RETURNS : N/A
		;
		; INTERFACE NOTES
		; 
		;       INPUT : N/A
		; 
		;       OUTPUT : N/A
		; 
		; IMPLEMENTATION
		;
		; HISTORY
		; __date__ :        PTS:  
		; 2010.11.16		problem 644 and 647
		;
		******************************************************************************/
		private MultiScreen(){
			int i ;
			
			ge = GraphicsEnvironment.getLocalGraphicsEnvironment() ;
			screenDevice = ge.getScreenDevices() ;
			
			if ( 1 < screenDevice.length ){
				// this is the case for multiple devices.
				// set the flag to indicate multiple devices on the system.
				ismultiscreen=true ;
				for ( i=0; i<screenDevice.length; i++){
					GraphicsConfiguration[] gc = screenDevice[i].getConfigurations() ;
					
					// determine the minimum x position for the main screen
					if ( gc[0].getBounds().x <= minX ){
						minX = gc[0].getBounds().x;
					}
					
					// determine the total screen size
					if ( gc[0].getBounds().x >= 0){
						totalWidth = totalWidth + gc[0].getBounds().width;
					}	
					
				}
			}else{
				// this is the case for one screen only.
				ismultiscreen = false ;
			}
			
			// set the main screen width
			curWidth = screenDevice[0].getConfigurations()[0].getBounds().width ;
			
		} // END FUNCTION MultiScreen
		
		/*****************************************************************************
	    ;  isMultiScreen
	    ;----------------------------------------------------------------------------
		; DESCRIPTION
		;   This routine returns if the system is multi-screen or not.
		;
		; RETURNS : true/false
		;
		; INTERFACE NOTES
		; 
		;       INPUT : N/A
		;
		; 
		; IMPLEMENTATION
		;  
		; HISTORY
		; __date__ :        PTS:  
		; 2010.11.16		problem 644 and 647
		;
		******************************************************************************/
		public boolean isMultiScreen(){
			
			return ismultiscreen ;
		} // END FUNCTION isMultiScreen 
		
	} // END CLASS MultiScreen 
	
	private class ToolbarWindow extends JWindow implements LocationAndSizeUpdateable {
		private static final long serialVersionUID = 1L;

		private final OffsetLocator mOffsetLocator;
		private Boolean _isOnLeft = false;
		
		public ToolbarWindow(JWindow frame, OffsetLocator ol, JPanel content) {
			super(frame);
			super.setAlwaysOnTop(true);
			mOffsetLocator = ol;
			add(content);
			pack();
		}
		
		public void setcapturing(Boolean bol) {
			_isOnLeft = bol;
		}

		public void updateLocationAndSize() {
			setLocation(getLocation());
		}
		
		@Override
		public Point getLocation() {
			if (_isOnLeft){
				return new Point(mTopLeft.x + mOverallSize.width - 268, mTopLeft.y + mOffsetLocator.getTopOffset()+10);
			}else{
				return new Point(mTopLeft.x + mOffsetLocator.getLeftOffset(), mTopLeft.y + mOffsetLocator.getTopOffset());
			}
		}
	}
	
	private class WindowlessFrameMovingMouseListener extends MouseAdapter {
		
		private AtomicBoolean mMoving = new AtomicBoolean(false);
		
		private Point mActionOffset = null;

		@Override
		public void mouseDragged(MouseEvent e) {
			int changeInX = e.getLocationOnScreen().x - mActionOffset.x - mTopLeft.x;
			int changeInY = e.getLocationOnScreen().y - mActionOffset.y - mTopLeft.y;
			Toolkit tk 	= Toolkit.getDefaultToolkit();
			Dimension d = tk.getScreenSize();
			
			// check if multiscreen
			if ( false == mScreen.isMultiScreen() ){
				// case one screen only
				if (mTopLeft.x < 1 && changeInX < 0) {
					mTopLeft.x = 0;
					changeInX = 0;				
				}
				if (mTopLeft.y < 1 && changeInY < 0) {
					mTopLeft.y = 0;
					changeInY = 0;
				}
				if (mTopLeft.x + mOverallSize.width > (d.width-6) && changeInX > 0) {
					mTopLeft.x = d.width - mOverallSize.width-5;
					changeInX = 0;
					
				}
				if (mTopLeft.y + mOverallSize.height > (d.height-6) && changeInY > 0) {
					mTopLeft.y = d.height - mOverallSize.height-5;
					changeInY = 0;
				}
			}else{
				// case multiple screen
				if (mTopLeft.x < mScreen.minX+1 && changeInX < 0) {
					mTopLeft.x = mScreen.minX;
					changeInX = 0;				
				}
				if (mTopLeft.y < 1 && changeInY < 0) {
					mTopLeft.y = 0;
					changeInY = 0;
				}
			
				if (mTopLeft.x + mOverallSize.width > (mScreen.totalWidth-6) && changeInX > 0) {
					mTopLeft.x = mScreen.totalWidth - mOverallSize.width-5;
					changeInX = 0;
				}
				if (mTopLeft.y + mOverallSize.height > (d.height-6) && changeInY > 0) {
					mTopLeft.y = d.height - mOverallSize.height-5;
					changeInY = 0;
				}
			}
			if (mMoving.get() && !e.isConsumed()) {
				WindowlessFrame.this.setLocation(changeInX + mTopLeft.x, changeInY + mTopLeft.y);
			}
		}
		
		@Override
		public void mousePressed(MouseEvent e) {
			final Point mouse = e.getLocationOnScreen();
			mActionOffset = new Point(mouse.x - mTopLeft.x, mouse.y - mTopLeft.y);
			mMoving.set(true);
			e.getComponent().setCursor(Cursor.getPredefinedCursor(Cursor.MOVE_CURSOR));
		}
		
		@Override
		public void mouseReleased(MouseEvent e) {
			mMoving.set(false);
			mActionOffset = null;
			e.getComponent().setCursor(Cursor.getDefaultCursor());
		}

	}
	
	private class WindowlessFrameResizingMouseListener extends MouseAdapter {
		
		private static final int CORNER_SIZE = 150;

		private AtomicBoolean mResizing = new AtomicBoolean(false);
		
		private Point mActionOffset = null;
		private Dimension mOriginalSize = null;
		private Corner mCorner;

		@Override
		public void mouseDragged(MouseEvent e) {
		    int changeInX = e.getLocationOnScreen().x - mActionOffset.x - mTopLeft.x;
			final int changeInY = e.getLocationOnScreen().y - mActionOffset.y - mTopLeft.y;
			
			Toolkit tk = Toolkit.getDefaultToolkit();
			Dimension d = tk.getScreenSize();

			if (mResizing.get()) {
				int newH = mOriginalSize.height;
				int newW = mOriginalSize.width;
				if (Corner.SOUTHEAST == mCorner) {

					if (e.getLocationOnScreen().x < mTopLeft.x+5) {
						newW = 5;
					} else {
						newW += changeInX;				
					}
					if (e.getLocationOnScreen().y < mTopLeft.y+5) {
						newH = 5;
					} else {
						newH += changeInY;
					}
				} else if (mCorner == Corner.NORTHEAST) {
					mTopLeft.y = mTopLeft.y + changeInY;
					newH = mOverallSize.height + -changeInY;
					newW += changeInX;
				} else if (mCorner == Corner.NORTHWEST) {
					mTopLeft.y = mTopLeft.y + changeInY;
					newH = mOverallSize.height + -changeInY;
					mTopLeft.x = mTopLeft.x + changeInX;
					newW = mOverallSize.width + -changeInX;
				} else if (mCorner == Corner.SOUTHWEST) {
					newH += changeInY;
					mTopLeft.x = mTopLeft.x + changeInX;
					newW = mOverallSize.width + -changeInX;
				}
				
				if (newH + mTopLeft.y > d.height-5){
					newH = d.height - mTopLeft.y-5;
				}

				// check if multiple screen _PTS_644_   _PTS_647_
				if ( false == mScreen.isMultiScreen() ){
					// one screen only
					if (newW + mTopLeft.x > d.width-5){
						newW = d.width - mTopLeft.x-5;
					}
				}else{
					int mWidth=0 ;
					if ( mTopLeft.x > mScreen.curWidth ){
						mWidth = mScreen.totalWidth ;
					}else{
						mWidth = d.width ;
					}
					if (newW + mTopLeft.x > mWidth-5 && mTopLeft.x >= 0){
						newW = mWidth - mTopLeft.x-5;
					}else if (mTopLeft.x<0 && mTopLeft.x + newW > -5){
						 newW = - mTopLeft.x-5;
					}
				}
				
				WindowlessFrame.this.setSize(newH, newW);
				e.consume();
			}
		}
		
		@Override
		public void mousePressed(MouseEvent e) {
			final Point mouse = e.getLocationOnScreen();
			mActionOffset = new Point(mouse.x - mTopLeft.x, mouse.y - mTopLeft.y);
			mOriginalSize = new Dimension(mOverallSize);
			mCorner = nearCorner(mouse);
			if (mCorner != null) {
				mResizing.set(true);
			}
		}
		
		@Override
		public void mouseReleased(MouseEvent e) {
			mResizing.set(false);
			mActionOffset = null;
			mOriginalSize = null;
			mCorner = null;
		}

		private Corner nearCorner(Point mouse) {
			if (isNearBottomRightCorner(mouse)) {
				return Corner.SOUTHEAST;
			}   else if (isNearTopRightCorner(mouse)) {
				return Corner.NORTHEAST;
			} else if (isNearTopLeftCorner(mouse)) {
				return Corner.NORTHWEST;
			} else if (isNearBottomLeftCorner(mouse)) {
				return Corner.SOUTHWEST;
			}
			
			return null;
		}

		private boolean isNearBottomRightCorner(Point mouse) {
			int xToBotLeft = Math.abs(mTopLeft.x + (int) mOverallSize.getWidth() - mouse.x);
			int yToBotLeft = Math.abs(mTopLeft.y + (int) mOverallSize.getHeight() - mouse.y);
			return xToBotLeft < CORNER_SIZE && yToBotLeft < CORNER_SIZE;
		}

	    private boolean isNearTopRightCorner(Point mouse) {
			int xToTopRight = Math.abs(mTopLeft.x + (int) mOverallSize.getWidth() - mouse.x);
			int yToTopRight = Math.abs(mTopLeft.y - mouse.y);
			return xToTopRight < CORNER_SIZE && yToTopRight < CORNER_SIZE;
		}

		private boolean isNearBottomLeftCorner(Point mouse) {
			int xToBottomLeft = Math.abs(mTopLeft.x - mouse.x);
			int yToBottomLeft = Math.abs(mTopLeft.y + (int) mOverallSize.getHeight() - mouse.y);
			return xToBottomLeft < CORNER_SIZE && yToBottomLeft < CORNER_SIZE;
		}

		private boolean isNearTopLeftCorner(Point mouse) {
			int xToTopLeft = Math.abs(mTopLeft.x - mouse.x);
			int yToTopLeft = Math.abs(mTopLeft.y - mouse.y);
			return xToTopLeft < CORNER_SIZE && yToTopLeft < CORNER_SIZE;
		}

		@Override
		public void mouseMoved(MouseEvent e) {
			final Point mouse = e.getLocationOnScreen();
			
			if (isNearTopLeftCorner(mouse)) {
				e.getComponent().setCursor(Cursor.getPredefinedCursor(Cursor.NW_RESIZE_CURSOR));
			} else if (isNearBottomLeftCorner(mouse)) {
				e.getComponent().setCursor(Cursor.getPredefinedCursor(Cursor.SW_RESIZE_CURSOR));
			} else if (isNearTopRightCorner(mouse)) {
				e.getComponent().setCursor(Cursor.getPredefinedCursor(Cursor.NE_RESIZE_CURSOR));
			} else if (isNearBottomRightCorner(mouse)) {
				e.getComponent().setCursor(Cursor.getPredefinedCursor(Cursor.SE_RESIZE_CURSOR));
			} else {
				e.getComponent().setCursor(Cursor.getDefaultCursor());
			}
		}
	}


	private class CaptureFrame extends JWindow implements LocationAndSizeUpdateable, WindowListener {
		
		private static final long serialVersionUID = 1L;
		
		private JPanel capturePanel;
		private Boolean transparentFrame = false;
        private WindowlessFrame ownerFrame;
		
		public CaptureFrame (JWindow window, WindowlessFrame owner){
			super(window);
			super.setAlwaysOnTop(true);
            addWindowListener(this);
            ownerFrame = owner;
			
			capturePanel = new JPanel(){
				private static final long serialVersionUID = 1L;

				@Override
			    public void paintComponent(Graphics g){
			        super.paintComponent(g);

			        Graphics2D g2 = (Graphics2D) g;
					g2.setStroke(borderSolidStroke);

			        //if (!transparentFrame) {
						g2.setPaint(blueColor);
						// big frame
				        g2.drawRect(4, 4, getWidth()-9, getHeight()-9);
				        // top left
				        g2.fillRect(0, 0, 9, 9);
				        // top right
				        g2.fillRect(getWidth()-9, 0, 9, 9);
				        // bottom left
				        g2.fillRect(0, getHeight()-9, 9, 9);
				        // bottom right
				        g2.fillRect(getWidth()-9, getHeight()-9, 9, 9);
			        //}else{
				//		g2.setPaint(blueTransparenColor);
						// big frame
				//        g2.drawRect(4, 4, getWidth()-9, getHeight()-9);
			      //  }

                    super.setBackground(tColor);
                    if(isMac){
                        getRootPane().putClientProperty("Window.alpha", new Float(0.2f));
                    }
			    }
			};
			add(capturePanel);
		}
		
		public void setFrameTransparency(Boolean tr) {
			transparentFrame = tr;
		}



        public void windowActivated(WindowEvent e) {
            ownerFrame.repaint();
        }

        public void windowOpened(WindowEvent e) {
            ownerFrame.repaint();
        }
        public void windowDeactivated(WindowEvent e) {}
        public void windowIconified(WindowEvent e) {}
        public void windowClosing(WindowEvent e) {}
        public void windowClosed(WindowEvent e) {}
        public void windowDeiconified(WindowEvent e) {}

		public void updateLocationAndSize() {
			setSize(getWidth(), getHeight());
			setLocation(getLocation());
		}
		
		@Override
		public Point getLocation() {
			//return new Point(mTopLeft.x + mOffsetLocator.getLeftOffset(), mTopLeft.y + mOffsetLocator.getTopOffset());
			//System.out.println("update location and size in capture frame, x = " + mTopLeft.x + " y = "+ mTopLeft.y);
			return new Point(mTopLeft.x, mTopLeft.y);
		}
		
		@Override
		public int getHeight() {
			return mOverallSize.height;
		}
		
		@Override
		public int getWidth() {
			return mOverallSize.width;
		}
		
	}

	public WindowlessFrame(int borderWidth) {

        GraphicsEnvironment ge =
                GraphicsEnvironment.getLocalGraphicsEnvironment();
        GraphicsDevice gd = ge.getDefaultScreenDevice();

		mBorderWidth = borderWidth;

		mWindowFrame = new JWindow();


        if ("Mac OS X".equals(System.getProperty("os.name"))){
            isMac = true;
        }

        cFrame = new CaptureFrame(mWindowFrame, this);

        mWindowFrame.setBackground(new Color(0,0,0,0));

        if(isMac){
            mWindowFrame.getRootPane().putClientProperty("Window.alpha", new Float(0.2f));
        }

		movingAdapter = createMovingMouseListener();
		resizingAdapter = createResizingMouseListener();
		changeBarFrames(new PropertyChanger() {
			@Override
			public void changeOn(Component component) {
				component.addMouseListener(resizingAdapter);
				component.addMouseMotionListener(resizingAdapter);
				component.addMouseListener(movingAdapter);
				component.addMouseMotionListener(movingAdapter);
			}
		}, false);

        repaint();
	}

	public final MouseAdapter createMovingMouseListener() {
		return new WindowlessFrameMovingMouseListener();
	}

	public final MouseAdapter createResizingMouseListener() {
		return new WindowlessFrameResizingMouseListener();
	}

	public void setToolbar(JPanel toolbar) {
		
		final JPanel _toolbar = toolbar;
		
		final OffsetLocator toolbarOffsetLocator = new OffsetLocator() {
			@Override
			public int getTopOffset() {
				return mOverallSize.height + 10; // -_toolbar.getHeight() - 10;
			}
			
			@Override
			public int getLeftOffset() {
				return (mOverallSize.width /2) - (_toolbar.getWidth()/2);
			}
		};
		mToolbarFrame = new ToolbarWindow(mWindowFrame, toolbarOffsetLocator, toolbar);
	}
	
	public final void setSize(int height, int width) {
		setHeight(height);
		setWidth(width);
		repaint();
	}

	public final void setWidth(int width) {
		mOverallSize.width = width;
	}
	
	public final void setHeight(int height) {
		mOverallSize.height = height;
	}
	
	public final void setLocation(int x, int y) {
		mTopLeft.x = x;
		mTopLeft.y = y;
		repaint();
		
		if (captureRegionListener != null) {
			Rectangle rect  = getFramedRectangle();
			captureRegionListener.onCaptureRegionMoved(rect.x, rect.y);
		}
	}
	
	public final int getX(){
		return mTopLeft.x;
	}
	
	public final int getY(){
		return mTopLeft.y;
	}
	
	public final int getWidth(){
		return mOverallSize.width - mBorderWidth;
	}
	
	public final int getHeight(){
		return mOverallSize.height - mBorderWidth;
	}
	
	public final Rectangle getFramedRectangle() {
		return new Rectangle(mTopLeft.x + mBorderWidth, mTopLeft.y + mBorderWidth, mOverallSize.width - mBorderWidth, mOverallSize.height - mBorderWidth);
	}

	public final void setVisible(final boolean b) {
		changeAll(new PropertyChanger() {
			@Override
			public void changeOn(Component component) {
				component.setVisible(b);
			}
		}, true);
	}
	
	private void changeBarFrames(PropertyChanger pc, boolean repaint) {
		pc.changeOn(cFrame);
		
		if (repaint) {
			repaint();
		}
	}

	private void changeAll(PropertyChanger pc, boolean repaint) {
		if (mToolbarFrame != null) pc.changeOn(mToolbarFrame);
		changeBarFrames(pc, repaint);
	}

	public final void repaint() {
		changeAll(REPAINTER, false);
	}


    public void setTransparency(Boolean flag){
        cFrame.setFrameTransparency(flag);
    }


	public void changeToPreCaptureState() {
		cFrame.setFrameTransparency(true);
		mToolbarFrame.setcapturing(true);
		repaint();
	}
	
	public void changeToCaptureState() {
		cFrame.setFrameTransparency(false);
		repaint();
	}
	
	public void setCaptureRegionListener(CaptureRegionListener listener){
		this.captureRegionListener = listener;
	}
	
	public void removeMouseListeners() {
		cFrame.removeMouseListener(resizingAdapter);
		cFrame.removeMouseMotionListener(resizingAdapter);
		cFrame.removeMouseListener(movingAdapter);
		cFrame.removeMouseMotionListener(movingAdapter);
	}
	
}