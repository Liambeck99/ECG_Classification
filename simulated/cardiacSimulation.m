
% lags defined for system
lags = [0.8 0.1];

% time frame
tf = 3;

% solve differential equations
sol = dde23(@ddefunc, lags, @xhist, [0 tf]);

% define how many instances to plot for each x in given time frame
t = linspace(0, tf, 10000);
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
title('X = ECGp = b1x2 + b2x4 + b3x5')

% define the system of equations
function xp = ddefunc(~, x, XL)
    
    % initialise all constants needed for equations
    a.sa = 3;
    a.av = 3;
    a.hp = 7;

    v.sa1 = 1;
    v.sa2 = -1.9;
    v.av1 = 0.5;
    v.av2 = -0.5;
    v.hp1 = 1.65;
    v.hp2 = -2;

    d.sa = 1.9;
    d.av = 4;
    d.hp = 7;

    e.sa = 0.55;
    e.av = 0.67;
    e.hp = 0.67;

    k.saav = 3;
    k.avhp = 55;

    kt.saav = 3;
    kt.avhp = 55;
    
    % lagged versions of x
    XL1.saav = XL(:,1); % lag: 0.8
    XL3.avhp = XL(:,2); % lag: 0.1
    
    % defdine the system of equations
    xp = [x(2);
          -(a.sa * x(2) * (x(1)-v.sa1) * (x(1)-v.sa2)) + ((x(1) * (x(1)+d.sa) * (x(1)+e.sa))/(d.sa * e.sa)) - x(1) - x(1);
          x(4);
          -(a.av * x(4) * (x(3)-v.av1) * (x(3)-v.av2)) + ((x(3) * (x(3)+d.av) * (x(3)+e.av))/(d.av * e.av)) - k.saav*x(3) + kt.saav*XL1.saav(1) - x(3);
          x(6);
          -(a.hp * x(6) * (x(5)-v.hp1) * (x(5)-v.hp2)) + ((x(5) * (x(5)+d.hp) * (x(5)+e.hp))/(d.hp * e.hp)) - x(5) - k.avhp*x(5) + kt.avhp*XL3.avhp(3); ];
      
end

% history function
function x = xhist(~)

    x = [ -0.1; 0.025; -0.6; 0.1; -3.3; 0.66666];
    
end


