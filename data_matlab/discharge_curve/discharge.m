clc;clear;close all;

data = load('discharge_data');
t=(1:size(data,1)-1).*60;

figure('position',[100 100 1200 400]);
plot(t(1:39),data(2:40,1),t(1:51),data(2:52,2),t(1:72),data(2:73,3),t,data(2:end,4));
title('Discharge Characteristics')
xlabel('Time [S]')
ylabel('Voltage [V]')

hline = refline(0,6.1);
hline.Color = 'r';
hline.LineStyle = '--';
legend('Discharge Current - 4A','Discharge Current - 3A','Discharge Current - 2A','Discharge Current - 1A','DC/DC Cutout Voltage')
 
%matlab2tikz('discharge.tex','showinfo',false);
matlab2tikz( 'discharge.tex', 'width', '\linewidth','showinfo',false);

%'height', '\fheight', 