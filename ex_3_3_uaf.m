%
% Example 3.3
% from Parameter Estimation and Inverse Problems, 2nd edition, 2013
% by R. Aster, B. Borchers, C. Thurber
%

clear
close all
clc
format compact

% add path to load data
addpath('/usr/local/matlab_toolboxes/aster/cd_5.2/Examples/chap3/ex_3_3/');

% acquire the G, m, and d originally generated using shaw.m for m = n = 20
% using Per Hansen's regularization tools (http://www2.imm.dtu.dk/~pch/Regutools/)
load shaw20.mat
whos

xlims = [-pi/2 pi/2];

% Compute the SVD.
[U,S,V] = svd(G);

% Create a spike model
spike = zeros(20,1);
spike(10) = 1;

% Get the ideal shaw spike data (dspike).
dspike = G*spike;

% Plot the singular values of G on a semi-log plot.
figure(1)
semilogy(diag(S),'ko');
ylim([10^-18 10^3])
xlabel('i');
ylabel('s_i');
disp('Displaying singular values of G (fig. 1)')
%print -deps2 c3fshawsing.eps

% Plot column 18 of V.
figure(2)
plotconst(V(:,18),-pi/2,pi/2);
xlabel('\theta (radians)'); xlim(xlims);
ylabel('Intensity')
disp('Displaying column 18 of matrix V (fig. 2)')
%print -deps2 c3fV_18.eps

% plot column 1 of V.
figure(3)
plotconst(V(:,1),-pi/2,pi/2);
xlabel('\theta (radians)'); xlim(xlims);
ylabel('Intensity')
disp('Displaying column 1 of matrix V (fig. 3)')
%print -deps2 c3fV_1.eps

% Plot the spike model in piecewise continuous form using plotconst.m.
figure(4);
plotconst(spike,-pi/2,pi/2);
axis([-2 2 -0.5 1.5]);
ylabel('Intensity')
xlabel('\theta (radians)'); xlim(xlims);
disp('Displaying spike model (fig. 4)') 
%print -deps2 c3fshawspike

% Plot the noise-free Shaw spike data.
figure(5)
plotconst(dspike,-pi/2,pi/2);
axis([-2 2 -0.25 .75]);
ylabel('Intensity')
xlabel('s (radians)'); xlim(xlims);

disp('Displaying noise-free data for Shaw spike model (fig. 5)')
%print -deps2 c3fshawspike_data_nonoise.eps

% Create slightly noisy data (dspiken) and see what happens.
dspiken = dspike+1.0e-6*randn(size(dspike));

% Generalized solution for noise-free data
spikemod = G\dspike;

% Find the pseudoinverse solution with noisy data for p = 18.
p = 18;
Up = U(:,1:p);
Vp = V(:,1:p);
Sp = S(1:p,1:p);
spikemod18n = Vp*inv(Sp)*Up'*dspiken;

% Plot generalized inverse solution for noise-free spike model data
figure(6)
plotconst(spikemod,-pi/2,pi/2);
axis([-2 2 -0.5 1.5]);
ylabel('Intensity')
xlabel('\theta (radians)'); xlim(xlims);
disp('Displaying recovered spike model for noise-free data (fig. 6)');
%print -deps2 c3fpinv_spike_nonoise.eps

% Plot recovered model for noisy data, p = 18
figure(7)
plotconst(spikemod18n,-pi/2,pi/2);
ylabel('Intensity')
xlabel('\theta (radians)'); xlim(xlims);
disp('Displaying recovered spike model for noisy data p = 18 (fig. 7)')
%print -deps2 c3fpinv_spike_noise_18.eps

% Find the pseudoinverse solution with noisy data for p = 10.
p = 10;
Up = U(:,1:p);
Vp = V(:,1:p);
Sp = S(1:p,1:p);

% recover the noise-free model
spikemod10 = Vp*inv(Sp)*Up'*dspike;
% recover the noisy model
spikemod10n = Vp*inv(Sp)*Up'*dspiken;

% Plot recovered model for noise-free data, p = 10 
figure(8)
plotconst(spikemod10,-pi/2,pi/2);
axis([-2 2 -0.2 0.5]);
ylabel('Intensity')
xlabel('\theta (radians)'); xlim(xlims);
disp('Displaying recovered spike model for noise-free data p = 10 (fig. 8)')

% Plot recovered model for noisy data, p = 10
figure(9)
plotconst(spikemod10n,-pi/2,pi/2);
axis([-2 2 -0.2 0.5]);
ylabel('Intensity')
xlabel('\theta (radians)'); xlim(xlims);
disp('Displaying recovered spike model for noisy data p = 10 (fig. 9)')
%print -deps2 c3fpinv_spike_noise_10.eps

%==========================================================================

% Load the data for n = m = 100
load shaw100.mat
% compute the svd
[U100,S100,V100] = svd(G100);

% Get spike for n = 100 case
spike100 = zeros(100,1);
spike100(46:50) = ones(5,1);

% Get spike date for n = 100 case without noise
spikedata100 = G100*spike100;
% Add noise to get noisy data
spikedata100n = spikedata100+1.0e-6*randn(100,1);

% get the matrices for p = 10
p = 10;
Up = U100(:,1:p);
Vp = V100(:,1:p);
Sp = S100(1:p,1:p);

% recover the model from noisy data
spikeinv100n = Vp*inv(Sp)*Up'*spikedata100n;

% Plot spectrum of singular values for n = 100 problem
figure(10)
semilogy(diag(S100),'ko');
xlabel('i')
ylabel('s_i')
ylim([1e-20 1e5])
disp('Singular values of G for Shaw problem (n = 100) (fig. 10)')
%print -deps2 c3fshawsing_100.eps

%Plot recovered model for noisy data with n = 100, p = 10
figure(11)
plotconst(spikeinv100n,-pi/2,pi/2);
axis([-2 2 -0.25 .75]);
ylabel('Intensity')
xlabel('\theta (radians)'); xlim(xlims);
disp(['Displaying recovered spike model for n = 100, p = 10 with noisy data'...
    ' (fig. 11)'])
%print -deps2 c3fpinv_spike_noise_100_10.eps

% Now try p = 18 case on n = 100 data
p = 18;
Up = U100(:,1:p);
Vp = V100(:,1:p);
Sp = S100(1:p,1:p);

% Get recovered model
spikeinv100n18 = Vp*inv(Sp)*Up'*spikedata100n;

%Plot recovered model for noisy data with n = 100, p = 18
figure(12)
plotconst(spikeinv100n18,-pi/2,pi/2);
ylabel('Intensity')
xlabel('\theta (radians)'); xlim(xlims);
disp(['Displaying recovered spike model for n = 100, p = 18 with noisy data'...
    ' (fig. 12)'])

% Now, the 6 element discretization.
% Get the singular values of G for n = 6
load shaw6.mat
[U6,S6,V6] = svd(G6);

% Plot singular values of G for n = 6
figure(13)
semilogy(diag(S6),'ko-','markersize',12);
xlabel('i'); ylabel('s_i');
xlim([0 length(U6)+1]);
disp('Displaying singular values of G for n = 6 (fig. 13)')
%print -deps2 c3fshawsing_6.eps

%==========================================================================
