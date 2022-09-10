clc
clear
BilinearSSM=load('townhousemodel.mat');
BilinearSSM=BilinearSSM.B.building_model;
n_u=length(BilinearSSM.identifiers.u);
n_v=length(BilinearSSM.identifiers.v);
n_x=length(BilinearSSM.identifiers.x);
A=BilinearSSM.continuous_time_model.A;
Bv=BilinearSSM.continuous_time_model.Bv;
Bu=BilinearSSM.continuous_time_model.Bu;
Bvu=BilinearSSM.continuous_time_model.Bvu;
Bxu=BilinearSSM.continuous_time_model.Bxu;
n_u_new=8;% element number of u_new
index_u_new=[6,7,8,9,10,11,12,13];% location of u_new in u

u_syms = sym('u',[n_u,1]);
v_syms = sym('v',[n_v,1]);
x_syms = sym('x',[n_x,1]);
dx_syms = sym('dx',[n_x,1]);
Acoef_syms = sym('Acoef',[n_x,1]);
Bcoef_syms = sym('Bcoef',[n_x,1]);
Alin_syms = sym('Alin', [n_x n_x]);
Blin_syms = sym('Blin', [n_x (n_u_new+n_v)]);

%% Generate symbolic expression of dx
dx_syms(:,1)=A*x_syms(:,1)+Bv*v_syms(:,1)+Bu*u_syms(:,1);
for i=1:1:n_u
dx_syms(:,1)=dx_syms(:,1)+(Bvu(:,:,i)*v_syms(:,1)+Bxu(:,:,i)*x_syms(:,1))*u_syms(i);
end

%% Generate symbolic linear SSM
for i=1:1:n_x
Acoef_syms(i)=subs(dx_syms(i),[u_syms(index_u_new);v_syms],zeros(n_u_new+n_v,1));
Bcoef_syms(i)=subs(dx_syms(i),x_syms,zeros(n_x,1));
Alin_syms(i,:)=simplify(equationsToMatrix(Acoef_syms(i)==0, x_syms));
Blin_syms(i,:)=simplify(equationsToMatrix(Bcoef_syms(i)==0, [u_syms(index_u_new);v_syms]));
end

%% Generate numerical linear SSM
u1=1;u2=1;u3=1;u4=1;u5=0;%u6=0;
thLinearSSM=struct;
thLinearSSM.continuous_time_model.A=double(subs(Alin_syms));
thLinearSSM.continuous_time_model.B=double(subs(Blin_syms));
thLinearSSM.continuous_time_model.identifiers.x=BilinearSSM.identifiers.x;
thLinearSSM.continuous_time_model.identifiers.u=[BilinearSSM.identifiers.u(4)];
save('thLinearSSM.mat','thLinearSSM');