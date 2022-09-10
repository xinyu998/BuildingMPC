%model reduction
clc
clear
order=10;
LinearSSM=load('singleLinearSSM.mat');
LinearSSM=LinearSSM.LinearSSM.continuous_time_model;
identifiers=LinearSSM.identifiers;
[lin_A,col_A]=size(LinearSSM.A);
[lin_B,col_B]=size(LinearSSM.B);
LinearSSM_c=ss(LinearSSM.A,LinearSSM.B,eye(lin_A),[]);
opts = balredOptions('StateElimMethod','Truncate');
ReducedLinearSSM_c = balred(LinearSSM_c,order,opts);
ReducedLinearSSM=struct;
ReducedLinearSSM.SSM=ReducedLinearSSM_c;
ReducedLinearSSM.identifiers=identifiers;
ReducedLinearSSM.identifiers.y=ReducedLinearSSM.identifiers.x;
index_x=1:1:order;
index_x=index_x';
ReducedLinearSSM.identifiers.x=cellstr(strings(order,1)+'x'+index_x);
%save('ReducedsingleLinearSSM.mat','ReducedsingleLinearSSM');