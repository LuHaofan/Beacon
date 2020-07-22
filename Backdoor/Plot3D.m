function Plot3D(fname,duration, scalelog)
    close all;
    keyset = {0.1,0.2,0.4,0.6,0.8,1,0.5};
    valset = {'d2:h57', 'd58:h113', 'd58:h113','d170:h225', 'd226:h281', 'd282:h337', 'd3:h137'};
    map = containers.Map(keyset, valset);
    data = xlsread(fname, map(duration));
    startFreq=data(:,1);bandwidth=data(:,2);crosscorr=data(:,5);
    %figure;scatter3(startFreq,bandwidth,crosscorr);%ɢ��ͼ
    [X,Y] = meshgrid(linspace(min(startFreq),max(startFreq)),linspace(min(bandwidth),max(bandwidth)));
    Z=griddata(startFreq,bandwidth,crosscorr,X,Y);%��ֵ
    figure;mesh(X,Y,Z);
    hold on
    plot3(startFreq, bandwidth, crosscorr, 'o');
    if (scalelog)
        set(gca,'xscale','log');
        set(gca,'yscale','log');
    end
    xlabel('start Frequency (kHz)');
    ylabel('Bandwidth (kHz)');
    zlabel('Cross-correlation');
    title('Cross-correlation w.r.t. start frequency and bandwidth');
    figure;pcolor(X,Y,Z);shading interp%α��ɫͼ
    xlabel('start Frequency (kHz)');
    ylabel('Bandwidth (kHz)');
    if (scalelog)
        set(gca,'xscale','log');
        set(gca,'yscale','log');
    end
    figure,contourf(X,Y,Z) %�ȸ���ͼ
    xlabel('start Frequency (kHz)');
    ylabel('Bandwidth (kHz)');
    if (scalelog)
        set(gca,'xscale','log');
        set(gca,'yscale','log');
    end
    figure,surf(X,Y,Z);%��ά����
    if (scalelog)
        set(gca,'xscale','log');
        set(gca,'yscale','log');
    end
    figure,meshc(X,Y,Z)%����ͼ
    if (scalelog)
        set(gca,'xscale','log');
        set(gca,'yscale','log');
    end
    view(0,0); 
    figure,meshc(X,Y,Z);%s��ά���棨ǳɫ��+�ȸ���
    if (scalelog)
        set(gca,'xscale','log');
        set(gca,'yscale','log');
    end
    hidden off;
end