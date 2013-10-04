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
package  org.redfire.screen.frame;

import org.redfire.screen.ScreenShare;

import javax.imageio.ImageIO;
import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;

public class CaptureRegionFrame {
	
	private ButtonStart btnStart;
	private ButtonStop btnStop;
	private CaptureRegionListener client;
	private boolean capturing = false;
	private WindowlessFrame frame;
	
	public CaptureRegionFrame(CaptureRegionListener client, int borderWidth) {
		frame = new WindowlessFrame(borderWidth);
		this.client = client;
		frame.setCaptureRegionListener(client);
		frame.setToolbar(createToolbar());
	}
	
	public void setHeight(int h) {
		frame.setHeight(h);
	}
	
	public void setWidth(int w) {
		frame.setWidth(w);
	}
	
	public void setLocation(int x, int y) {
		frame.setLocation(x, y);
	}
	
	public void setVisible(boolean visible) {
		frame.setVisible(visible);	
	}
	
	public void setNotoficationText(String str){
		if (jl != null)
			jl.setText(str);
	}
	
	public void redraw(){
		frame.repaint();
	}
	
	private JLabel jl;
	
	private JPanel createToolbar() {
		final JPanel panel = new JPanel();
	    panel.setBackground( new Color(0, 0, 0, 0));
	   
		capturing = false;
		
		btnStart = new ButtonStart();
		btnStart.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				capturing = true;
				startCapture();								
			}
		});
		
		btnStop = new ButtonStop();
		btnStop.setVisible(false);
		btnStop.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				if (capturing){
					capturing = false;
					stopCapture();
				}							
			}
		});
		
		panel.add(btnStart);
		panel.add(btnStop);
		return panel;
	}
	
	private void startCapture() {
		frame.removeMouseListeners();
		btnStart.setVisible(false);
		btnStop.setVisible(true);
		frame.changeToPreCaptureState();
		Rectangle rect = frame.getFramedRectangle();
		client.onStartCapture(rect.x, rect.y, frame.getWidth(), frame.getHeight());
	}
	
	private void stopCapture() {	
		frame.changeToCaptureState();
		client.onStopCapture();
	}
	
	private class ButtonStart extends JButton {
		private static final long serialVersionUID = 1L;
		private final Dimension dem = new Dimension(288,38);
		
		public ButtonStart (){
			super();
			setOpaque(false);
		}

		@Override
		public void paint(Graphics g) {
			try{
				BufferedImage cursorImage = ImageIO.read(ScreenShare.class.getResource("/blueButton.png"));
				g.drawImage(cursorImage, 0, 0, dem.width, dem.height, null);
			} catch (Exception e) {}
			
		}
		
		@Override
		public Dimension getPreferredSize(){
			return dem;
		}
		
		@Override
		public Dimension getMinimumSize(){
			return dem;
		}
		
		@Override	
		public Dimension getMaximumSize(){
			return dem;
		}
	}
	
	private class ButtonStop extends JButton {
		private static final long serialVersionUID = 1L;
		private final Dimension dem = new Dimension(216,32);
		private BufferedImage cursorImageOver;
		private BufferedImage cursorImageOut;
		
		public ButtonStop (){
			super();
			setOpaque(false);
			try {
				cursorImageOver = ImageIO.read(ScreenShare.class.getResource("/redButton.png"));
				cursorImageOut = ImageIO.read(ScreenShare.class.getResource("/redButtonVeryTransperent.png"));
			}catch(Exception ex) {
				
			}
		}
		
		@Override
		public void paint(Graphics g) {
			g.clearRect(0, 0, dem.width, dem.height);
			g.setColor(new Color(0,0,0,0));
			g.fillRect(0, 0, dem.width, dem.height);
			
			redraw();
			
			if (model.isRollover()) {
				g.drawImage(cursorImageOver, 0, 0, dem.width, dem.height, null);
			}else{
				g.drawImage(cursorImageOut, 0, 0, dem.width, dem.height, null);
			}	
		}
		
		@Override
		public Dimension getPreferredSize(){
			return dem;
		}
		
		@Override
		public Dimension getMinimumSize(){
			return dem;
		}
		
		@Override	
		public Dimension getMaximumSize(){
			return dem;
		}
	}
}
