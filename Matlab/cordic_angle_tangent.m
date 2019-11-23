clc;
clear all;
close all;

x=10;
y=20;
z=pi/4;

N=50;
n=1:1:N
x_n=zeros(50,1);
y_n=zeros(50,1);
z_n=zeros(50,1);
d=zeros(50,1);


x_n(1)=x;
y_n(1)=y;



for i=2:N
    
    if(y_n(i-1)>0)
       d(i-1)=1;
    else
       d(i-1)=-1;
    end 
    x_n(i)=(x_n(i-1) + d(i-1)* ((2^(2-i))*y_n(i-1)));
    y_n(i)=(y_n(i-1) - d(i-1)* ((2^(2-i))*x_n(i-1)));

    z_n(i)=z_n(i-1) + d(i-1)*atan((2^(2-i)));
    
    fprintf('shift %d result is \t %f ,%f\n',i,x_n(i),y_n(i));
end

subplot(2,1,1);
plot(x_n,y_n,'b');
grid;
title('二分法逼近');
xlabel('x');
ylabel('y');

subplot(2,1,2);
plot(z_n,'b');
grid;
title('角度');
xlabel('x');
ylabel('z_n');





