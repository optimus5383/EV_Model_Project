clear all
close all
clc

%% MCT 주행 사이클 호출
opts = detectImportOptions('MCT.csv','NumHeaderLines',0,'PreserveVariableNames',true);

Raw_Data = readtable('MCT.csv',opts) ;

%% 데이터 호출
electric_consumption = table2array(readtable('electric_consumption.csv'));
motor_torque = readtable('motor_torque.csv') ;
motor_efficiency = readtable('motor_efficiency.csv') ;
battery_SOC = table2array(readtable('battery_SOC.csv'));


battery_SOC_SOC = battery_SOC(:,1);
battery_SOC_voltage = battery_SOC(:,2);

electric_consumption_voltage = electric_consumption(:,1);
electric_consumption_ressistancce = electric_consumption(:,2);


motor_efficiency_RPM = table2array(motor_efficiency(2:height(motor_efficiency),1));
motor_efficiency_torque = table2array(motor_efficiency(1,2:width(motor_efficiency)));
motor_efficiency_efficiency = table2array(motor_efficiency(2:height(motor_efficiency),2:width(motor_efficiency)));
motor_efficiency_torque = transpose(motor_efficiency_torque);


Cycle_Speed = table2array(Raw_Data(:,:));
motor_torque_RPM = table2array(motor_torque(1:14,2));
motor_RPM_torque = table2array(motor_torque(1:14,1));
%% simulation 환경 변수
slope = [1,0];
Tire_Inertia_Moment = [1,0.1431];
Brake_Inertia_Moment = [1,0.02];
Differential_Inertia_Moment_In = [1,0.015];
Differential_Inertia_Moment_Out1 = [1,0.015];
Differential_Inertia_Moment_Out2 = [1,0.015];
Final_Drive_Inertia_Moment_In = [1,0.01];
Final_Drive_Inertia_Moment_Out = [1,0.015];
Motor_Inertia_Moment_In = [1,0.0226];
Vehicle_Weight = [1,1644.3];
Amb_Temp = [1,25];
Amb_Press = [1,101.325];
Wheel_Radius = [1,0.316];
Differential_Efficiency = [1,0.96];
Final_Drive_Efficiency = [1,0.96];
Final_Gear_Ratio = [1,7.4];
Resistance_F0 = [1,53.905];
Resistance_F1 = [1,0.21857];
Resistance_F2 = [1,0.029304];
Regenerative_percent = [1,0.3];
Battery_Capacity = [1,118];

Total_time = [1,length(Cycle_Speed)];

%% extra_data, for using extra calculation
% Eff 호출
Diff_Eff=Differential_Efficiency;
Final_Eff=Final_Drive_Efficiency;
%각각의 inertia 계산
% inertia of motor
I_m=Motor_Inertia_Moment_In;

% inertia of gear:
I_g=Final_Drive_Inertia_Moment_In+1./(power(Final_Gear_Ratio,2)).*...
Final_Drive_Inertia_Moment_Out;

% inertia of Differential
I_d=Differential_Inertia_Moment_Out1+Differential_Inertia_Moment_In;

% inertia of wheel
I_w=Tire_Inertia_Moment;

% BATTERY INIT
% Initial value 100%
BATTERY_INIT=[1,100];


%% out data
simulation_time = 23612 ;
load('EV_Modeling.mat');
sim_outputs = sim('EV_Modeling',simulation_time);

output_data = sim_outputs.yout(1);

R_Out_Time_sec = output_data{1}.Values.Time;
R_Out_Distance_km = output_data{1}.Values.Data;
R_Out_Battery_SOC_perc = output_data{2}.Values.Data;
R_Out_Motor_RPS = output_data{3}.Values.Data;
R_Out_Motor_RPM = output_data{4}.Values.Data;
R_Out_Current_Speed = output_data{5}.Values.Data;
R_Out_Motor_Torque = output_data{7}.Values.Data;
R_Out_SOC_Voltage = output_data{8}.Values.Data;
R_Out_Electric_consumption_Current = output_data{9}.Values.Data;
R_Out_Electric_Power = output_data{10}.Values.Data;
R_Out_Motor_Power = output_data{11}.Values.Data;

% R_Output_table = {Out_Time_sec,Out_Distance_km};


n = 1;
for i = 1:length(R_Out_Time_sec)
    if fix(R_Out_Time_sec(i)) - R_Out_Time_sec(i) == 0
       Out_Time_sec(n,1) = R_Out_Time_sec(i);
       Out_Battery_SOC_perc(n,1) = R_Out_Battery_SOC_perc(i);
       Out_Current_Speed(n,1) = R_Out_Current_Speed(i);
       Out_Distance_km(n,1) = R_Out_Distance_km(i);
       Out_Electric_consumption_Current(n,1) = R_Out_Electric_consumption_Current(i);
       Out_Electric_Power(n,1) = R_Out_Electric_Power(i);
       Out_Motor_RPM(n,1) = R_Out_Motor_RPM(i);
       Out_Motor_RPS(n,1) = R_Out_Motor_RPS(i);
       Out_Motor_Torque(n,1) = R_Out_Motor_Torque(i);
       Out_SOC_Voltage(n,1) = R_Out_SOC_Voltage(i);
       Out_Motor_Power(n,1) = R_Out_Motor_Power(i);

         n = n + 1; 
    end
 
end


a = horzcat(Out_Time_sec,Out_Distance_km,Out_Battery_SOC_perc,Out_Motor_RPS,Out_Motor_RPM,Out_Current_Speed,Out_Motor_Torque,Out_SOC_Voltage,Out_Electric_consumption_Current,Out_Electric_Power,Out_Motor_Power);

Name = ["Time","Distance[km]","Battery SOC[%]","Motor RPS","Motor RPM","Speed[km/h]","Motor Torque","SOC Voltage[V]","Electric_consumption_current[A]","Electirc Power[W]","Motor Power[W]"];

datasheet = vertcat(Name,a);

 
writematrix(datasheet,'data.csv');

%% cycle data
%(1) KWh, (2) KWh, (3) KM
UDDS1(1)=sum(Out_Motor_Power(1:1376))/(1000*3600);
UDDS1(2)=sum(Out_Electric_Power(1:1376))/(1000*3600);
UDDS1(3)=Out_Distance_km(1376)-Out_Distance_km(1);

HWFET1(1)=sum(Out_Motor_Power(1387:2150))/(1000*3600);
HWFET1(2)=sum(Out_Electric_Power(1387:2150))/(1000*3600);
HWFET1(3)=Out_Distance_km(2150)-Out_Distance_km(1387);


UDDS2(1)=sum(Out_Motor_Power(2770:4120))/(1000*3600);
UDDS2(2)=sum(Out_Electric_Power(2770:4120))/(1000*3600);
UDDS2(3)=Out_Distance_km(4120)-Out_Distance_km(2770);

CSC1(1)=sum(Out_Motor_Power(5920:11781))/(1000*3600);
CSC1(2)=sum(Out_Electric_Power(5920:11781))/(1000*3600);
CSC1(3)=Out_Distance_km(11781)-Out_Distance_km(5920);


UDDS3(1)=sum(Out_Motor_Power(13600:14950))/(1000*3600);
UDDS3(2)=sum(Out_Electric_Power(13600:14950))/(1000*3600);
UDDS3(3)=Out_Distance_km(14950)-Out_Distance_km(13600);

HWFET2(1)=sum(Out_Motor_Power(14970:15740))/(1000*3600);
HWFET2(2)=sum(Out_Electric_Power(14970:15740))/(1000*3600);
HWFET2(3)=Out_Distance_km(15740)-Out_Distance_km(14970);


UDDS4(1)=sum(Out_Motor_Power(16340:17700))/(1000*3600);
UDDS4(2)=sum(Out_Electric_Power(16340:17700))/(1000*3600);
UDDS4(3)=Out_Distance_km(17700)-Out_Distance_km(16340);

CSC2(1)=sum(Out_Motor_Power(17717:19055))/(1000*3600);
CSC2(2)=sum(Out_Electric_Power(17717:19055))/(1000*3600);
CSC2(3)=Out_Distance_km(19055)-Out_Distance_km(17717);

%% 효율 계산
% 도시 주행 계산
EDC_UDDS1=UDDS1(1);
K_UDDS1=EDC_UDDS1/(UDDS1(1)+UDDS2(1)+UDDS3(1)+UDDS4(1)+HWFET1(1)+HWFET2(1)+CSC1(1)+CSC2(1));
ECDC=(K_UDDS1*UDDS1(1)/UDDS1(3))+(1-K_UDDS1)*(UDDS3(1)/UDDS3(3)+UDDS4(1)/UDDS4(3)+UDDS2(1)/UDDS2(3))/3;

City_EFF=(UDDS1(1)+UDDS2(1)+UDDS3(1)+UDDS4(1)+HWFET1(1)+HWFET2(1)+CSC1(1)+CSC2(1))/((UDDS1(2)+UDDS2(2)+UDDS3(2)+UDDS4(2)+HWFET1(2)+HWFET2(2)+CSC1(2)+CSC2(2))*ECDC)
City_range=(UDDS1(1)+UDDS2(1)+UDDS3(1)+UDDS4(1)+HWFET1(1)+HWFET2(1)+CSC1(1)+CSC2(1))/ECDC

ECDC2=(HWFET1(1)/HWFET1(3)+HWFET2(1)/HWFET2(3))/2;
HighyWay_EFF=(UDDS1(1)+UDDS2(1)+UDDS3(1)+UDDS4(1)+HWFET1(1)+HWFET2(1)+CSC1(1)+CSC2(1))/((UDDS1(2)+UDDS2(2)+UDDS3(2)+UDDS4(2)+HWFET1(2)+HWFET2(2)+CSC1(2)+CSC2(2))*ECDC2)
HighyWay_range=(UDDS1(1)+UDDS2(1)+UDDS3(1)+UDDS4(1)+HWFET1(1)+HWFET2(1)+CSC1(1)+CSC2(1))/ECDC2

