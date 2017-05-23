clear all; close all; clc;

%% To TikZ?
to_tikz = 1;

%% PLOT STARTUP

data = importdata('startup/C1startup-our-carrier00000.dat');
time = data(:,1);
C1_data = data(:,2);


data = importdata('startup/C2startup-our-carrier00000.dat');
C2_data = data(:,2);


data = importdata('startup/C3startup-our-carrier00000.dat');
C3_data = data(:,2);


data = importdata('startup/C4startup-our-carrier00000.dat');
C4_data = data(:,2);

time = data(:,1)+3*10^(-3); % offset data to make it look nice


figure
plot (time,C2_data,time,C1_data,time,C3_data,time,C4_data)
title('Startup sequence')
xlabel('Time [S]')
ylabel('Voltage [V]')

legend('VCC','2V5REF','VCCIO\_EN','VCCIO')
xlim([0*10^(-3) 9.4*10^(-3)])
ylim([0 6])
if to_tikz == 1
    cleanfigure()
    matlab2tikz('startup_graph.tex');
    matlab2tikz( 'test.tikz', 'height', '\fheight', 'width', '\fwidth' )

end

%Plot AVNET carrier card VCCIO_EN
data = importdata('startup/C3startup-zedcarrier00000.dat');
C4_data_AVNET = data(:,2);

time_AVNET = data(:,1)+6.6*10^(-3); % offset data to make it look nice

figure
plot (time,C3_data,time_AVNET,C4_data_AVNET)
title('Startup sequence, VCCIO\_EN')
xlabel('Time [S]')
ylabel('Voltage [V]')
legend('VCCIO\_EN, SWARM','VCCIO\_EN, AVNET')
ylim([0 6])
xlim([0*10^(-3) 9*10^(-3)])
if to_tikz == 1
    cleanfigure()
    matlab2tikz('startup_graph_vccioen.tex');
end

%% PLOT SHUTDOWN

data = importdata('shutdown/C1prel00000.dat');
time_sh = data(:,1);
C1_data_sh = data(:,2);


data = importdata('shutdown/C2prel00000.dat');
C2_data_sh = data(:,2);


data = importdata('shutdown/C3prel00000.dat');
C3_data_sh = data(:,2);


data = importdata('shutdown/C4prel00000.dat');
C4_data_sh = data(:,2);

time_sh = data(:,1)+20*10^(-6); % offset data to make it look nice

%Plot showing the correct shutdown
figure
plot (time_sh,C2_data_sh,time_sh,C1_data_sh,time_sh,C3_data_sh,time_sh,C4_data_sh)
title('Shutdown sequence')
xlabel('Time [S]')
ylabel('Voltage [V]')
legend('POWER\_EN','DCDC\_EN','VCCIO\_EN','V\_OFF')
xlim([0 2.14*10^(-5)])
if to_tikz == 1
    cleanfigure()
    matlab2tikz('shutdown_graph.tex');
end

%Plot showing the bouncing of V_OFF
figure
plot (time_sh,C2_data_sh,time_sh,C1_data_sh,time_sh,C3_data_sh,time_sh,C4_data_sh)
title('Shutdown sequence w. bouncing')
xlabel('Time [S]')
ylabel('Voltage [V]')
legend('POWER\_EN','DCDC\_EN','VCCIO\_EN','V\_OFF')
xlim([0*10^(-4) 10*10^(-4)])
if to_tikz == 1
    cleanfigure()
    matlab2tikz('shutdown_w_noise_graph.tex');
end