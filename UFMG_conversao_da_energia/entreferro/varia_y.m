%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%    Analise de um atuador EI para o trabalho
%  de conversao da energia 2017-2
%
%    Pedro Blanc Arabe - 31/10/2017
%    pedrob6893@gmail.com
%
%   Based on the woofer example by David Meeker
%   available at the femm website
%
%   More info on how to make octaveFEMM run on linux: http://www.femm.info/wiki/linuxsupport
%   This script has been developed and tested on ubuntu
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Usage
%
% This script assumes an EI core inductor (where the I part has its
% points belonging o group 1) and varies the position of the I part along
% the y axis
%
% The magnetic flux density (|B|) is computed along the line from P1 to P2
% and the maximum value for each y is stores (B_max)
%
% In the end a plot of B_max vs. y is generated
%
% Modify the 'Design - specific parameters' below to your desired values

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Design - Specific Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Model Name
ModelName = 'TP1_y0.05.fem';

%define displacement of mobile part
y_file = -0.05;  %position on the provided file

y0    = -3;   %simulation start position
ylim  = -80;  %simulation end position
steps = 10;

dY = (ylim-y0)/(steps-1);

%Get the maximum flux density along the line P1-P2
P1 = [120, 140];
P2 = [120, -40+ylim];
B_points = 200;

flag_show_simulation = 0;  %displays or hide femm window

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Analysis Routines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open an instance of FEMM
openfemm;

%open model and apply offset to take the moving piece from
%y_file to y0
opendocument(ModelName);
mi_saveas('temp.fem');

mi_selectgroup(1);
mi_movetranslate(0, y0-y_file);
mi_clearselected;

%prepare vars
B_max = NaN(steps, 1);

%run simulation loop
disp('Starting analysis...')
for n = 1:steps
    fprintf('Running simulation %i/%i... \n', n, steps);
    
    %run simulation
    mi_analyze(flag_show_simulation);
    mi_loadsolution();
    
    %take the B field over a straight line
    B_abs = zeros(B_points, 1);
    for i = 1:B_points
        P = P1+(P2-P1)*i/B_points;
        B = mo_getb(P);  %B is in the format [Bx By]
        B_abs(i) = norm(B);
    end
    B_max(n) = max(B_abs);
    
    %move group 1 (I part)
    mi_selectgroup(1);
    mi_movetranslate(0, dY);
end

mi_close;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Plot Analysis Results
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure()
plot(y0:dY:ylim, B_max, '.-');
title('maximum |B| vs y');
set(gca, 'xdir', 'reverse');
ylabel('|B|  (T)');
xlabel('y   (mm)');
