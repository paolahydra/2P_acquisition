function plotData(src,event,handFig)
    figure(handFig); hold on
    plot(event.TimeStamps, event.Data)
end
