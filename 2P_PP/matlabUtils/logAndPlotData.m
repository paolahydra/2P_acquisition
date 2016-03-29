function logAndPlotData(src,event,fid,handFig)
    data = [event.TimeStamps, event.Data]' ;
    fwrite(fid,data,'double');
    figure(handFig)
    plot(event.TimeStamps, event.Data)
end
