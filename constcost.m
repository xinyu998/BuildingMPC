clc
clear all

%Load data
load singleLinearSSM.mat
load disturancesnew.mat
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

SimOptions=mpcsimopt;
mpcobj=mpc(plant,Ts);
mpcobj.PredictionHorizon = 20;
mpcobj.ControlHorizon=4;
mpcobj.Weights.MV = 1;
mpcobj.Weights.MVrate = 0.3;
mpcobj.Weights.OV = 200;
mpcobj.MV.ScaleFactor=0.17;

mpcobj.MV.Min = 0;
mpcobj.MV.Max = 90;
mpcobj.OV.Min = 20;
mpcobj.OV.Max = 24;
options=mpcmoveopt;
v=dd(1:500,:);
xmpc=mpcstate(mpcobj);
%SimOptions=mpcsimopt;
%Simulate close loop response
t=[0:Ts:Ts*499];
Nf=500;
r = 22;
% y=zeros(Nf,1);
% u=zeros(Nf,1);
% for i=1:Nf
%     y(i)=C*xmpc.Plant;
%     options.MVWeights= 1;
%     [u(i),info]=mpcmove(mpcobj,xmpc,y(i),r,v,options);
% end

[y,t,u]=sim(mpcobj,Nf,r,v,SimOptions);

figure
t_new=[1:48/295:48];
u_new=u(144:432);
y_new=y(144:432);
subplot(2,1,1)
plot(t_new,u_new,'LineWidth',1.5)
grid on
title('Inputs')
ylabel('Power input W/m2')
subplot(2,1,2)
plot(t_new,y_new,'LineWidth',1.5)
grid on
title('Outputs')
legend('Room Temperature')
xlabel('Time h')
ylabel('degree C')
S=56.9;

cost=zeros(1,289);
for i=1:289
    cost(i)=0.035*(u_new(i)*S)/6000;
end
totalcost=sum(cost)*16*15;

