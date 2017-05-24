clc;clear;close all;

data = load('discharge_data');
t=(1:size(data,1)).*60;

figure();
plot(t(2:40),data(2:40,1),t(2:end),data(2:end,2));
legend('Discharge Current - 4A','Discharge Current - 3A')
title('Discharge Characteristics')
xlabel('Time [S]')
ylabel('Voltage [V]')
matlab2tikz('discharge.tex','showinfo',false);