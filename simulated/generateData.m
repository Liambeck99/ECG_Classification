% Creation of simulated ECG signals from delay differential equations
% proposed equations from Cheffer and Savi, paper reference : 
% A. Cheffer and M. A. Savi. Random effects inducing heart pathological dynamics:
% An approach based on mathematical models. Biosystems, 196:104177, 2020.

% Ammened initial function to generate a large dataset with randomness

% Initialise the parameters
% SA oscillator
p.alphaSA = 3.0;
p.vSA1 = [ 1., 1.65, 1., 1., 1., 1.];
p.vSA2 = [-1.9, -4.2, -1.9, -1.9, -1.9, -1.9];
p.dSA = 1.9;
p.eSA = 0.55;

% AV oscillator
p.alphaAV = [3., 7., 7., 3., 3., 3.];
p.vAV1 = 0.5;
p.vAV2 = -0.5;
p.dAV = 4.0;
p.eAV = 0.67;

% HP oscillator
p.alphaHP = [7., 7., 7., 7., 0.5, 0.5];
p.vHP1 = 1.65;
p.vHP2 = -2.0;
p.dHP = 7;
p.eHP = 0.67;

% Couplings
p.kSAAV = [3., 0.66, 0.66, 3., 3., 3.];
p.kAVHP = [55., 14., 14., 45., 30., 14.];
p.ktSAAV = [3., 0.02, 0.09, 3., 3., 0.4];
p.ktAVHP = [55., 60., 38., 20., 30., 38.];

% Standard deviations for coupings
sd.saav = [0.0; 0.5; 1.5; 2.5; 3.5;];
sd.avhp = [1.0; 5.0; 30.0; 55.0; 110.0; 220.0; 440.0;];

% External stimuli
p.pSA = [0.; 0.; 8.; 0.; 0.; 0.;];
p.pAV = 0.0;
p.pHP = [0.; 0.; 0.; 0.; 30.; 0.;];
p.wSA = [0.; 0.; 2.1; 0.; 0.; 0.;];
p.wAV = 0.0;
p.wHP = [0.; 0.; 8.; 0.; 0.8; 0.;];

% Time delays
tSAAV = 0.8;
tAVHP = 0.1;

% Lags
lags = [tSAAV; tAVHP;];

% Index for ECG type
normalCardiac = 1;
atrialFlutter = 2;
atrialFibrilation = 3;
ventricularFlutter = 4;
ventricularFibrillationWithStim = 5;
ventricularFibrillationNoStim = 6;

% Create new folder if doesnt exist
if ~exist( 'simulatedData_temp' , 'dir' )
 
    mkdir( 'simulatedData_temp' );
    pdest = 'simulatedData_temp\';
    
else
    pdest = 'simulatedData_temp\';
end

s = 1000;
stay = false;
prev = 0;

for k=0:100
    
    if (stay)
        k = prev;
        stay = false;
    end
        
    
    p.kSAAV = [3., 0.66, 0.655, 3., 3., 3.];
    p.kAVHP = [55., 14., 13.914, 45., 30., 14.];
    p.ktSAAV = [3., 0.02, 0.09, 3., 3., 0.4];
    p.ktAVHP = [55., 60., 38., 20., 30., 38.];
    
    p.kSAAV = randomEffects(p.kSAAV, 0.01);
    
    % Time span
    ts = 0;
    tf = 470;
    tf = randomEffects(tf, 15);
    tsteps = 5000;
    
    % Initialise constants for ECG calculation
    beta0 = 1;
    beta1 = 0.06;
    beta2 = 0.1;
    beta3 = 0.3;
    
    % Solve the equations
    sol = dde23(@(t,y,Z) ddefun(t,y,Z,p, atrialFibrilation), lags, @history, [ts tf]);
    

    % define how many instances to plot for each x in given time frame
    t = linspace(100, tf, tsteps);
    y = deval(sol, t);
    
    % calculate ECG and plot
    ECG = beta0 + beta1 * y(1,:) + beta2 * y(3,:) + beta3 * y(5,:);
    
    % Shows ECG statistics
    fprintf("\nTimings = %02.03f  %02.03f  %02.03f\n", p.kSAAV(3), p.kAVHP(3), tf);
    [totalR, avgRR] = displayRRfunc(ECG);
    fprintf("Statist = %02.03f  %03.03f\n", totalR, avgRR);
    plot(ECG);    % Plot ECG diagram
    
    % Save ECG to file
    filename = sprintf('S%05.0f.csv',k);
    fileDest = fullfile( pdest, filename );
    writematrix( ECG, fileDest);
    
end

% returns an random number that conforms to the distribution provided
function normal = randomEffects( kbar, sigma )
    
    %normal = sigma.*randn(1,1) + kbar;
    
    normal = normrnd( kbar, sigma );
end

% Set of equations being solved
function xp = ddefun(t, y, Z, p, i)
    
    % Delayed versions
    ylag1 = Z(:,1); % Lag: 0.8
    ylag2 = Z(:,2); % Lag: 0.1
    
    x1SAAVlag = ylag1(1);
    x3AVHPlag = ylag2(3);
    
    x1 = y(1);
    x2 = y(2);
    x3 = y(3);
    x4 = y(4);
    x5 = y(5);
    x6 = y(6);
    
    % equations presented in Cheffer20
    x1p = x2;
    
    x2p = (p.pSA(i) * sin(p.wSA(i) * t)) - (p.alphaSA * x2 * (x1 - p.vSA1(i)) * (x1 - p.vSA2(i))) - ((x1 * (x1 + p.dSA) * (x1 + p.eSA))/(p.dSA * p.eSA));
    
    x3p = x4;
    
    x4p = (p.pAV * sin(p.wAV * t)) - (p.alphaAV(i) * x4 * (x3 - p.vAV1) * (x3 - p.vAV2)) - ((x3 * (x3 + p.dAV) * (x3 + p.eAV))/(p.dAV * p.eAV)) -(p.kSAAV(i) * x3) + (p.ktSAAV(i) * x1SAAVlag);
    
    x5p = x6;
    
    x6p = (p.pHP(i) * sin(p.wHP(i) * t)) - (p.alphaHP(i) * x6 * (x5 - p.vHP1) * (x5 - p.vHP2)) - ((x5 * (x5 + p.dHP) * (x5 + p.eHP))/(p.dHP * p.eHP)) -(p.kAVHP(i) * x5) + (p.ktAVHP(i) * x3AVHPlag);
    
    xp = [x1p; x2p; x3p; x4p; x5p; x6p;];
end

% History function for t <= 0
function s = history(~)
    s = [-0.1; 0.025; -0.6; 0.1; -3.3; 2/3;];
end

