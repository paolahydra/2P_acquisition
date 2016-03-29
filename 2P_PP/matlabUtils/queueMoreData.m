function queueMoreData(src,event)
fs = 1e4;
data = zeros(fs,10); %10 seconds, almost
data(round(fs/3):round(fs/2),2:end) = 4;
data = data(:);
queueOutputData(src, data);
end