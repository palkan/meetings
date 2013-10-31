package org.redfire.screen;

import com.flazr.rtmp.RtmpConfig;
import com.flazr.rtmp.RtmpHeader;
import com.flazr.rtmp.RtmpMessage;
import com.flazr.rtmp.server.RtmpServer;
import org.jboss.netty.channel.*;
import org.jboss.netty.util.HashedWheelTimer;
import org.jboss.netty.util.Timeout;
import org.jboss.netty.util.Timer;
import org.jboss.netty.util.TimerTask;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.TimeUnit;

public abstract class ScreenPublisher {

    private static final Logger logger = LoggerFactory.getLogger(ScreenPublisher.class);

    private final Timer timer;
    private final int timerTickSize;
    private final boolean usingSharedTimer;
    private final boolean aggregateModeEnabled;

    private final ScreenShare screenShare;
    private int streamId;
    private long startTime;
    private long seekTime;
    private long timePosition;
    private int currentConversationId;
    private int playLength = -1;
    private boolean paused;
    private int bufferDuration;

    public static class Event {

        private final int conversationId;

        public Event(final int conversationId) {
            this.conversationId = conversationId;
        }

        public int getConversationId() {
            return conversationId;
        }

    }

    public ScreenPublisher(final ScreenShare screenShare, final int streamId, final int bufferDuration, boolean useSharedTimer, boolean aggregateModeEnabled)
    {
        this.aggregateModeEnabled = aggregateModeEnabled;
        this.usingSharedTimer = useSharedTimer;

        if(useSharedTimer) {
            timer = RtmpServer.TIMER;
        } else {
            timer = new HashedWheelTimer(RtmpConfig.TIMER_TICK_SIZE, TimeUnit.MILLISECONDS);
        }

        timerTickSize = RtmpConfig.TIMER_TICK_SIZE;
        this.screenShare = screenShare;
        this.streamId = streamId;
        this.bufferDuration = bufferDuration;
        logger.debug("publisher init, streamId: {}", streamId);

        screenShare.screenPublish(this);
    }

    public boolean isStarted() {
        return currentConversationId > 0;
    }

    public boolean isPaused() {
        return paused;
    }

    public void setBufferDuration(int bufferDuration) {
        this.bufferDuration = bufferDuration;
    }

    public boolean handle(final MessageEvent me) {

        if(me.getMessage() instanceof Event)
        {
            final Event pe = (Event) me.getMessage();

            if(pe.conversationId != currentConversationId)
            {
                logger.debug("stopping obsolete conversation id: {}, current: {}", pe.getConversationId(), currentConversationId);
                return true;
            }
            return true;
        }
        return false;
    }

    public void start(final Channel channel, final int seekTime, final int playLength, final RtmpMessage ... messages) {
        this.playLength = playLength;
        start(channel, seekTime, messages);
    }

    public void start(final Channel channel, final int seekTimeRequested, final RtmpMessage ... messages) {
        paused = false;
        currentConversationId++;
        startTime = System.currentTimeMillis();


        timePosition = seekTime;
        logger.debug("publish start, seek requested: {} actual seek: {}, play length: {}, conversation: {}", new Object[]{seekTimeRequested, seekTime, playLength, currentConversationId});

        for(final RtmpMessage message : messages)
        {
            writeToStream(channel, message);
        }
    }

    private void writeToStream(final Channel channel, final RtmpMessage message) {
        if(message.getHeader().getChannelId() > 2) {
            message.getHeader().setStreamId(streamId);
            message.getHeader().setTime((int) timePosition);
        }
        channel.write(message);
    }

    public void write(final Channel channel, final RtmpMessage message)
    {
        if(!channel.isWritable()) {
            return;
        }

        if (message == null || playLength >= 0 && timePosition > (seekTime + playLength)) {
            stop(channel);
            return;
        }

        final long writeTime = System.currentTimeMillis();
        final long elapsedTime = System.currentTimeMillis() - startTime;
        final long elapsedTimePlusSeek = elapsedTime + seekTime;
        final double clientBuffer = timePosition - elapsedTimePlusSeek;

        if(aggregateModeEnabled && clientBuffer > timerTickSize) { // TODO cleanup
            //reader.setAggregateDuration((int) clientBuffer);
        } else {
            //reader.setAggregateDuration(0);
        }

        final RtmpHeader header = message.getHeader();
        final double compensationFactor = clientBuffer / (bufferDuration + timerTickSize);
        final long delay = (long) ((header.getTime() - timePosition) * compensationFactor);

        if(logger.isDebugEnabled())
        {
            logger.debug("elapsed: {}, streamed: {}, buffer: {}, factor: {}, delay: {}",
                    new Object[]{elapsedTimePlusSeek, timePosition, clientBuffer, compensationFactor, delay});
        }

        timePosition = header.getTime();
        header.setStreamId(streamId);
        final ChannelFuture future = channel.write(message);

        future.addListener(new ChannelFutureListener()
        {
            @Override public void operationComplete(final ChannelFuture cf) {
                final long completedIn = System.currentTimeMillis() - writeTime;
                if(completedIn > 2000) {
                    logger.warn("channel busy? time taken to write last message: {}", completedIn);
                }
                final long delayToUse = clientBuffer > 0 ? delay - completedIn : 0;
                fireNext(channel, delayToUse);
            }
        });
    }

    public void fireNext(final Channel channel, final long delay) {
        final Event readyForNext = new Event(currentConversationId);

        if(delay > timerTickSize)
        {
            timer.newTimeout(new TimerTask()
            {
                @Override public void run(Timeout timeout) {
                    if(logger.isDebugEnabled()) {
                        logger.debug("running after delay: {}", delay);
                    }
                    if(readyForNext.conversationId != currentConversationId) {
                        logger.debug("pending 'next' event found obsolete, aborting");
                        return;
                    }
                    Channels.fireMessageReceived(channel, readyForNext);
                }
            }, delay, TimeUnit.MILLISECONDS);

        } else {
            Channels.fireMessageReceived(channel, readyForNext);
        }
    }

    public void pause() {
        paused = true;
        currentConversationId++;
    }

    private void stop(final Channel channel) {
        currentConversationId++;
        final long elapsedTime = System.currentTimeMillis() - startTime;
        logger.info("finished, start: {}, elapsed {}, streamed: {}",
                new Object[]{seekTime / 1000, elapsedTime / 1000, (timePosition - seekTime) / 1000});

        for(RtmpMessage message : getStopMessages(timePosition)) {
            writeToStream(channel, message);
        }
    }

    public void close()
    {
        if(!usingSharedTimer) {
            timer.stop();
        }
        
        
        screenShare.die();
    }

    protected abstract RtmpMessage[] getStopMessages(long timePosition);

}
