%Model checking
clc
clear
ts=600;
BilinearSSM=load('singleBilinearSSM.mat');
BilinearSSM=BilinearSSM.B.building_model.discrete_time_model;
A=BilinearSSM.A;
Bv=BilinearSSM.Bv;
Bu=BilinearSSM.Bu;
Bvu=BilinearSSM.Bvu;
Bxu=BilinearSSM.Bxu;

LinearSSM=load('singleLinearSSM.mat');
LinearSSM=LinearSSM.LinearSSM.continuous_time_model;
LinearSSM_d=c2d(ss(LinearSSM.A,LinearSSM.B,[],[]),ts);

ReducedLinearSSM=load('singlereduSSM.mat');
ReducedLinearSSM=ReducedLinearSSM.ReducedLinearSSM.SSM;
ReducedLinearSSM_d=c2d(ss(ReducedLinearSSM.A,ReducedLinearSSM.B,ReducedLinearSSM.C,ReducedLinearSSM.D),ts);

S=56.9; %area in m2
dis = xlsread('dist.xlsx');
dis=dis(1:289,:);
disNsol=dis(:,5);
disSsol=dis(:,7);
disWsol=dis(:,6);
disEsol=zeros(289,1);
disHsol=zeros(289,1);
disIG=(dis(:,3)./(60*10))./S;
disTam=dis(:,1);
disTgnd=dis(:,2);
disnew=[disIG disTam disTgnd disEsol disHsol disNsol disSsol disWsol];

N=1000;
N1=289;
u=[1;1;0;40];
u=repmat(u,1,N1);
v=disnew';
%v=[dis1 ;dis2 ;dis3;dis1 ;dis2 ;dis3;dis1 ;dis2];
%v=repmat(v,1,N);
u(:,N1:end)=u(:,N1:end)+[0;0;0;40];
u_new=[u(4,:);v];
x0=ones(19,1)*20;

%% sim
x1=zeros(19,N);
x2=zeros(19,N);
x3=zeros(10,N);
y3=zeros(19,N);

x1(:,1)=x0;
x2(:,1)=x0;
x3(:,1)=ones(10,1)*20;

 for i=1:1:N1
     x1(:,i+1)=A*x1(:,i)+Bv*v(:,i)+Bu*u(:,i);
     
     for j=1:1:4
         x1(:,i+1)=x1(:,i+1)+(Bvu(:,:,j)*v(:,i)+Bxu(:,:,j)*x1(:,i))*u(j,i);
     end
     
    x2(:,i+1)=LinearSSM_d.A*x2(:,i)+LinearSSM_d.B*u_new(:,i);
     y3(:,i+1)=ReducedLinearSSM_d.C*x3(:,i)+ReducedLinearSSM_d.D*u_new(:,i);
     x3(:,i+1)=ReducedLinearSSM_d.A*x3(:,i)+ReducedLinearSSM_d.B*u_new(:,i);
 end
 t=1:1:N1+1;
 t=(t*ts)/3600;
 %x3(:,1)=x3(:,290);
 y3(:,1)=ReducedLinearSSM_d.C*x3(:,289)+ReducedLinearSSM_d.D*u_new(:,289);
plot(t(1:N1),x1(1,1:N1),t(1:N1),x2(1,1:N1))%,t(1:N1),y3(1,1:N1));
legend('Bilinear','Linear','Reduced Linear');
grid on
xlabel('Time h(2 days)');
ylabel('Room temperature (C)');
title('Model Checking');
 