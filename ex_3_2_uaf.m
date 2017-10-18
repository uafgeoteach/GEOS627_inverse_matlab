%
% Example 3.2
% from Parameter Estimation and Inverse Problems, 2nd edition, 2013
% by R. Aster, B. Borchers, C. Thurber
%

clear
close all
clc
format compact

% Set constants
% The noise variance
noise = 0.05;
% Discretizing values for M & N (210 data points)
N = 211;
M = 211;

% Generate time vector
t = linspace(-5,100,N);

% Generate instrument impulse response as a critically-damped pulse
% note: this is for plotting purposes only (only sigi and gmax are used)
sigi = 10;
if 1==1
    for i = 1:N-1
      if (t(i)<0)
        g(i) = 0;
      else
        g(i) = t(i)*exp(-t(i)/sigi);
      end
    end

    % Normalize instrument response (i.e. max(g) = 1)
    gmax = max(g);
    g = g/gmax;

    % Plot of instrument response to unit area ground acceleration impulse.
    figure(2)
    plot(t(1:N-1),g,'k')
    axis tight
    xlabel('Time (s)')
    ylabel('V')
    disp('Instrument response to unit ground acceleration impulse (fig. 2)')
    %print -deps2 c3fimp_resp.eps
else
    gmax = 3.6788;
end

% Populate G matrix 
% First the numerator which varies
for i = 2:M
  for j = 1:N-1
    tp = t(j)-t(i);
    if (tp > 0)
      G(i-1,j) = 0;
    else
      G(i-1,j) = -tp*exp(tp/sigi);
    end
  end
end
% now divide everything by the denominator
deltat = t(2)-t(1);
G = G/gmax * deltat;

break

% Get SVD of G matrix
[U,S,V] = svd(G);

% Display image of G matrix with colorbar
figure(1)
colormap(gray)
imagesc(G)
H = colorbar;
set(H,'FontSize',18);
xlabel('j')
ylabel('i')
title('G matrix for convolution problem');
disp('Displaying image of G matrix (fig. 1)')

% True signal is two pulses of sig deviation
sig = 2;
% Find unscaled true signal model  
mtrue = exp(-(t(1:N-1)-8).^2/(sig^2*2))'... 
    + 0.5*exp(-(t(1:N-1)-25).^2/(sig^2*2))';
% Rescale true signal model to have a max of 1
mtrue = mtrue/max(mtrue);
% Get true data without noise
d = G*mtrue;
% Add random normal noise to the datadata
dn = G*mtrue + noise*randn(M-1,1);

% Using SVD with all 210 singular values
nkeep = N-1;
% Find Up, Vp, Sp
Up = U(:,1:nkeep);
Vp = V(:,1:nkeep);
Sp = S(1:nkeep,1:nkeep);

% Generalized inverse solutions for noisy data (mn) 
% and noise-free data (mperf)
mn = Vp*inv(Sp)*Up'*dn;
mperf = Vp*inv(Sp)*Up'*d;

% Display semilog plot of singular values
figure(3)
semilogy(diag(S),'ko')
axis tight
xlabel('i')
ylabel('s_i')
disp('Displaying semilog plot of singular values (fig. 3)')

% Plot true model
figure(4)
plot(t(1:N-1),mtrue,'k')
xlim([-5 100])
ylim([0 1])
axis tight
xlabel('Time (s)')
ylabel('Acceleration (m/s^2)');
disp('Displaying true model (fig. 4)')
%print -deps2 c3fm_true.eps

% Display predicted data using noise free model
figure(5)
plot(t(1:N-1),d,'k')
xlabel('Time (s)')
ylabel('V')
axis tight
disp('Displaying predicted data from true model (without noise) (fig. 5)')

% Display predicted data plus random independent noise
figure(6)
plot(t(1:N-1),dn,'k')
xlim([-5 100])
xlabel('Time (s)')
ylabel('V');
axis tight
disp(['Displaying predicted data from true model plus independent noise'...
    ' (fig. 6)'])
%print -deps2 c3fd_pred_noise.eps

% Display generalized inverse solution for noise-free data
figure(7)
plot(t(1:N-1),mperf,'k')
xlim([-5 100])
ylim([0 1])
xlabel('Time (s)')
ylabel('Acceleration (m/s^2)');
disp(['Displaying generalized inverse solution for noise-free data'...
    ' (210 singular values) (fig. 7)'])
%print -deps2 c3fpinv_solution_nonoise

% Display generalized inverse solution for noisy data
figure(8)
plot(t(1:N-1),mn,'k')
xlabel('Time (s)')
axis tight
ylabel('Acceleration (m/s^2)');
disp(['Displaying generalized inverse solution for noisy data'...
    ' (210 singular values) (fig. 8)'])
%print -deps2 c3fpinv_solution_noise

%--------------------------------------------------------------------------

% Truncate SVD to 26 singular values
nkeep = 26;
Up = U(:,1:nkeep);
Vp = V(:,1:nkeep);
Sp = S(1:nkeep,1:nkeep);

% Get model for truncated SVD (m2) with noisy data
m2 = Vp*inv(Sp)*Up'*dn;

% Display generalized inverse solution for noisy data
figure(9)
plot(t(1:N-1),m2,'k')
xlabel('Time (s)')
ylabel('Acceleration (m/s^2)');
axis tight
disp(['Displaying generalized inverse solution for noisy data'...
    ' (26 singular values) (fig. 9)'])
%print -deps2 c3fpinv_solution_noise_26

% Get resolution matrix
Rm = Vp*Vp';

% Display image of resolution matrix for truncated solution with colorbar
figure(10)
colormap(gray)
% use tight bounds on the colorbar instead of automatically expanded bounds
imagesc(Rm,[min(min(Rm)),max(max(Rm))])
xlabel('j')
ylabel('i')
H = colorbar;
set(H,'FontSize',18);
disp(['Displaying image of resolution matrix for truncated SVD solution'...
    ' (26 singular values) (fig. 10)'])
%print -deps2 c3fR_solution_26

% Display a column from the model resolution matrix for truncated SVD solution
figure(11)
plot(t(1:N-1), Rm(80,:),'k')
axis tight
xlabel('Time (s)')
ylabel('Element Value')
disp(['Displaying column of model resolution matrix for'...
    ' truncated SVD solution (fig. 11)'])
%print -deps2 c3fR_column_26

%show successive TSVD solutions
disp('Animating TSVD solutions as p increases (fig. 12)')

% the maximum p to use, the fit model and the diagonal elements
p = rank(G);
m = zeros(N-1,1);
ss = diag(S);

figure(12)
for i = 1:p
  % adjust the predicted model to have p singular values
  m = m+(U(:,i)'*dn/ss(i))*V(:,i);
  % keep track of the residuals for each p
  r(i) = norm(G*m-dn);
  % keep track of the model norm for each p
  mnorm(i) = norm(m);
  % plot the newly fit model
  plot(m)
  xlabel('Time (s)')
  ylabel('Acceleration (m/s^2)');
  axis([0 p+1 -1 1.5]);
  hold on
  % plot the true model
  plot(mtrue,'r-.','linewidth',2);
  hold off
  title(num2str(i));
  pause(0.1)
end

%Examine the trade-off curve (collected in the loop above)
% (The L curve is introduced in Chapter 4.)
figure(13)
plot(r,mnorm)
hold on
plot(r(26),mnorm(26),'ro')
hold off
ylabel('||m||_2')
xlabel('||Gm-d||_2')
text(r(26),mnorm(26),'   26 singular values in TSVD');
disp('Displaying TSVD trade-off curve (fig. 13)')

%==========================================================================
