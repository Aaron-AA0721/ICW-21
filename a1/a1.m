% A matlab program to plot the theoretical response of the building in the
% 1A vibration lab.
% Based on code written by Penny Cox, now maintained by Aidan Reilly.
%  Tidied up by Jim Woodhouse October 2012
%
close all
clear all

%  USER MUST SET TWO VALUES TO DETERMINE PLOT OPTIONS

% Set value for plottype as follows:
%       1 -> use 'ezplot' to plot a graph on normal axis (in rad/s)
%       2 -> produce a semilog plot (in Hz)
%       3 -> produce a graph on linear axis using 'plot' (in Hz)
plottype=2;

% Set value to be positive to produce plots of the modeshapes
modeshape_visualisation = 1;

m = 2; % mass of one floor
L = 0.2; % length
N = 3; % number of degrees of freedom
b = 0.08; % width
E = 210E9; % Young's Modulus
d = 0.001; % thickness
I = b*d*d*d/12; % second moment of area
k = (24*E*I)/(L*L*L); % static stiffness for each floor

ma = 0.5; % mass of the absorber
ka = 1000; % stiffness of the absorber spring

M = [2 0 0;0 2 0;0 0 2]; % create the mass matrix
K = k*[2 -1 0;-1 2 -1;0 -1 1]; % create the stiffness matrix
% Update the mass matrix
%M = [8 0 0 0; 
%     0 1 0 0; 
%     0 0 4 0; 
%     0 0 0 ma];

% Update the stiffness matrix
%K = k * [2 + ka/k, -1, 0, -ka/k; 
%         -1, 2, -1, 0; 
%         0, -1, 1, 0; 
%         -ka/k, 0, 0, ka/k];
% To include vibration absorbers, you will need to modify
%   the mass and stiffness matrices (above)

[V,D] = eig(K,M);
syms w;

for imode=1:N
  freqs(imode) = sqrt(D(imode,imode));
end

%  Print natural frequencies and mode vectors in command window
hertz = freqs/(2*pi)
modeshapes = V

B = K - ((w*w)*M); 
% harmonic solution for unit force at floor 1
disp = (inv(B))*[1;0;0];
%disp = (inv(B))*[1;0;0;0];
figure;
%start of ezplot section
if (plottype == 1)
  hold on
  
  ifloor=1;
  ezplot(disp(ifloor), [0, 130]);
  set(findobj('Type','line'),'Color','k')
  ifloor=2;
  ezplot(disp(ifloor), [0, 130]);
  set(findobj('Type','line','Color','b'),'Color','g')
  ifloor=3;
  ezplot(disp(ifloor), [0, 130]);
  set(findobj('Type','line','Color','b'),'Color','r')
  
  set(findobj('Type','line','Color','k'),'Color','b')
  
  set(findobj('Type','line'),'LineStyle','-')
end

% Calculate frequency response functions
all_disp = [];
for w = 1:130;
  B = K - ((w*w)*M); 
  % harmonic solution for unit force at floor 1
  disp = (inv(B))*[1;0;0];
  %disp = (inv(B))*[1;0;0;0];
  all_disp = [all_disp disp];
end
w = 1:130;




% Log plot
if (plottype == 2)
  semilogy((w./(2*pi)),abs(all_disp),'-');

% Linear plot
elseif (plottype == 3)
  plot((w./(2*pi)),(all_disp),'-');
end

figure;
hold on;
plot(w/(2*pi), abs(all_disp(1,:)), 'b', 'DisplayName', 'Floor 1');
plot(w/(2*pi), abs(all_disp(2,:)), 'r', 'DisplayName', 'Floor 2');
plot(w/(2*pi), abs(all_disp(3,:)), 'g', 'DisplayName', 'Floor 3');
xlabel('Frequency (Hz)');
ylabel('Displacement Amplitude');
legend;
title('Displacement of Each Floor vs. Frequency');
hold off;
% Plot modeshapes

if (modeshape_visualisation > 0 )
  V = [0 0 0; V];
  V_ = V + 0.25;
  V = V - 0.25;
  for imode=1:3
    figure
    axis([-5 5 0 3.5])
    title1 = ['Mode ' int2str(imode)];
    title(title1)
    hold on
    plot((V(:,imode)),([0 1 2 3]))
    plot([0 0 0 0],[0 1 2 3],'k')
    plot((V_(:,imode)),([0 1 2 3]))
    for jmode=1:3
      plot([V(jmode+1,imode) V_(jmode+1,imode)],[jmode jmode])
    end
  end
end