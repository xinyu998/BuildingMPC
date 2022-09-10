clc
clear all
%process raw disturances data from energyplus
dis=xlsread('dist.xlsx');
S=56.9;
dis=dis(1:1000,:);
disN=dis(:,5);
disS=dis(:,7);
disW=dis(:,6);
disE=zeros(1000,1);
disH=zeros(1000,1);
disIG=(dis(:,3)./(60*10))./S;
disTam=dis(:,1);
disTgnd=dis(:,2);
dd=[disIG disTam disTgnd disE disH disN disS disW];
totalsolargain=disE+disH+disN+disS+disW;
%plot
figure
t=[1:48/295:48];
subplot(2,2,1)
plot(t,disIG(1:289),'b','LineWidth',1.5);
xlabel('time h')
ylabel('Total Internal Gain W/m^2');
subplot(2,2,2);
plot(t,disTam(1:289),'g','LineWidth',1.5);
xlabel('time h')
ylabel('Outside Temperature C');
subplot(2,2,3);
plot(t,totalsolargain(1:289),'r','LineWidth',1.5);
xlabel('time h')
ylabel('Solar Gain W/m^2');
sgtitle('Disturbances Jan 1st & 2nd')

