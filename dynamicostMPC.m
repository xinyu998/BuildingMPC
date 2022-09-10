clc
clear all

%Load data
load singleLinearSSM.mat
load disturancesnew.mat
dcost=xlsread('Dynamicprice.xlsx');
dcost=[dcost;dcost;dcost;dcost];
dcost=dcost./1000;%Mwh to Kwh
% dcost=[0.02*ones(1,80) 0.035*ones(1,80) 0.025*ones(1,80)];
% dcost=[dcost dcost dcost dcost];
A=LinearSSM.continuous_time_model.A;
B=LinearSSM.continuous_time_model.B;
C=zeros(1,19);
C(1,1)=1;
D=zeros(1,9);
Ts = 600;
plant=ss(A,B,C,D);
%x0 = 20*ones(size(plant.B,1),1);
plant=setmpcsignals(plant,'MV',1,'MD',[2 3 4 5 6 7 8 9]);%,'MD',[2,3,4,5,6,7,8,9]);
% damp(plant)
% step(plant)
plantdis=c2d(plant,Ts);
mpcobj=mpc(plant,Ts);
mpcobj.PredictionHorizon = 12;
mpcobj.ControlHorizon=12;
mpcobj.Weights.MV=1;
mpcobj.Weights.MVrate = 0.3;
mpcobj.Weights.OV = 200;

mpcobj.MV.Min = 0;
mpcobj.MV.Max = 90;
mpcobj.OV.Min = 20;
mpcobj.OV.Max = 24;
v=dd(1:500,:);
options=mpcmoveopt;
x0=22*ones(1,19);
xmpc=mpcstate(mpcobj,x0,-30,[],[],[]);
%xmpc.Disturbance=-10;
%SimOptions=mpcsimopt;
%Simulate close loop response
t=[0:Ts:Ts*499];
Nf=500;
r = 22;
y=zeros(Nf,1);
u=zeros(Nf,1);
t=zeros(Nf,1);
for i=1:Nf
    y(i)=C*xmpc.plant;%+B*[u(i) v(i,:)]';
    options.MVWeights= dcost(i)*100;
    mpcobj.MV.ScaleFactor=1/(dcost(i)*100);
    [u(i),info]=mpcmove(mpcobj,xmpc,y(i),r,v,options);
end
% for i=1:5:495
%     mpcobj.Weights.MV = dcost(i)*100;
%     [y(i:i+5),t(i:i+5),u(i:i+5)]=sim(mpcobj,6,r,v(i:i+5,:),SimOptions);
% end
figure
t_new=[1:48/295:48];
u_new=u(144:432);
y_new=y(144:432);
subplot(2,1,1)
yyaxis left
plot(t_new,u_new,'LineWidth',1.5)
ylabel('Power input W/m2')
yyaxis right
plot(t_new,dcost(144:432),'LineWidth',1.5)
ylabel('Electricity price $/Kwh')
grid on
title('Inputs')
subplot(2,1,2)
plot(t_new,y_new,'LineWidth',1.5)
grid on
title('Outputs')
legend('Room Temperature')
xlabel('Time h')
ylabel('degree C')

S=56.9;
dcost_new=dcost(144:432);
cost=zeros(1,289);
for i=1:289
    cost(i)=dcost_new(i).*((u_new(i)*S)/6000);
end
totalcost=sum(cost)*16*15;
%cost=sum(dcost_new(:).*((u_new(:)*S)/6000))*16*15;
