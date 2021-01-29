% creation of simulated ECG signals from delay differential equations
% proposed equations from Cheffer and Savi, paper reference : 
% A. Cheffer and M. A. Savi. Random effects inducing heart pathological dynamics:
% An approach based on mathematical models. Biosystems, 196:104177, 2020.

% initialise parameters for equations
% SA oscillator
a.sa = 3.;
v.sa1 = [ 1., 1.65, 1., 1., 1., 1.];
v.sa2 = [-1.9, -4.2, -1.9, -1.9, -1.9, -1.9];
d.sa = 1.9;
e.sa = 0.55;

% AV oscilator
a.av = [3., 7., 7., 3., 3., 3.];
v.av1 = 0.5;
v.av2 = -0.5;
d.av = 4.;
e.av = 0.67;

% HP oscilator
a.hp = [7., 7., 7., 7., 0.5, 0.5];
v.hp1 = 1.65;
v.hp2 = -2.;
d.hp = 7.;
e.hp = 0.67;

% Couplings
k.saav =  [3., 0.66, 0.66, 3., 3., 3.];
k.avhp =  [55., 14., 14., 45., 30., 14.];
kt.saav = [3., 0.02, 0.09, 3., 3., 0.4];
kt.avhp = [55., 60., 38., 20., 30., 38.];

% Time delays
tsaav = [0.8, 0.66, 0.8, 0.8, 0.8, 0.8];
tavhp = 0.1;

% lags defined for system
lags = [tsaav tavhp];

% index for ECG type
normalCardiac = 1;
atrialFlutter = 2;
atrialFibrilation = 3;
ventricularFlutter = 4;
ventricularFibrillationWithStim = 5;
ventricularFibrillationNoStim = 6;

% time frame
ts = 0;
tf = 100;

% solve differential equations
sol = dde23(@(t, x, XL) ddefunc(t, x, XL, a, v, d, e, k, kt , normalCardiac), lags, @xhist, [ts tf]);

% define how many instances to plot for each x in given time frame
t = linspace(ts, tf, 1000);
y = deval(sol, t);

% plot all graphs
figure;
subplot(4,2,1);
plot(t, y(1,:));
title('X1 : SA Node')

subplot(4,2,2);
plot(t, y(2,:));
title('X2')

subplot(4,2,3);
plot(t, y(3,:));
title('X3: AV Node')

subplot(4,2,4);
plot(t, y(4,:));
title('X4')

subplot(4,2,5);
plot(t, y(5,:));
title('X5: HP Complex')

subplot(4,2,6);
plot(t, y(6,:));
title('X6')

% initialise constants for ECG calculation
beta0 = 1;
beta1 = 0.06;
beta2 = 0.1;
beta3 = 0.3;

% calculate ECG
ECG = beta0 + beta1 * y(1,:) + beta2 * y(3,:) + beta3 * y(5,:);
subplot(4,2,7);
plot(t, ECG);
title('X = ECG = b0 + b1x1 + b2x3 + b3x5')

% calculate ECG prime
ECGp = beta1 * y(2,:) + beta2 * y(4,:) + beta3 * y(6,:);
subplot(4,2,8);
plot(t, ECGp);
title('Xp = ECGp = b1x2 + b2x4 + b3x5')

% calculate plot own figure for ECG signal
ECG = beta0 + beta1 * y(1,:) + beta2 * y(3,:) + beta3 * y(5,:);
figure;
plot(t, ECG);
title('X = ECG = b0 + b1x1 + b2x3 + b3x5')

% define the system of equations
function xp = ddefunc(~, x, XL, a, v, d, e, k, kt , i)
    
    % lagged versions of x
    XL1.saav = XL(:,1); % lag: 0.8
    XL3.avhp = XL(:,2); % lag: 0.1
    
    x1 = x(1);
    x2 = x(2);
    x3 = x(3);
    x4 = x(4);
    x5 = x(5);
    x6 = x(6);
    
    x1lag = XL1.saav(1);
    x3lag = XL3.avhp(3);
    
    x2p = - (a.sa * x2 * (x1-v.sa1(i)) * (x1-v.sa2(i)))...
          - ( (x1 * (x1+d.sa) * (x1+e.sa)) / (d.sa * e.sa) );%...
          %- 2 * x1;
      
    x4p = - (a.av(i) * x4 * (x3-v.av1) * (x3-v.av2))...
          - ( (x3 * (x3+d.av) * (x3+e.av)) / (d.av * e.av) )...
          - k.saav(i)*x3...
          + kt.saav(i)*x1lag;%...
          %- x(3);
    
    x6p = - (a.hp(i) * x6 * (x5-v.hp1) * (x5-v.hp2))...
          - ( (x5 * (x5+d.hp) * (x5+e.hp)) / (d.hp * e.hp) )...
          - k.avhp(i)*x5...
          + kt.avhp(i)*x3lag;%...
          %- x5;
    
    
    % define the system of equations
    xp = [x2; x2p; x4; x4p; x6; x6p;];
      
end

% history function
function x = xhist(~)

    x = [ -0.1; 0.025; -0.6; 0.1; -3.3; 2/3;];
    
end


