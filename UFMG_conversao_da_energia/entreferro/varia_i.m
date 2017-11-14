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
ModelName = 'TP1_y0.fem';

%define displacement of mobile part
i0    = 0; %simulation start position
ilim  = 20;   %simulation end position
steps = 15;

di = (ilim-i0)/(steps-1);

%Get the maximum flux density along the line P1-P2
P1 = [120, 140];
P2 = [120, -40+ilim];
B_points = 200;

flag_hide_simulation = 1;  %displays or hide femm window

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Analysis Routines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open an instance of FEMM
openfemm;

%open model
opendocument(ModelName);
mi_saveas('temp.fem');

%prepare vars
B_max = NaN(steps, 1);

%run simulation loop
disp('Starting analysis...')
for n = 1:steps
    fprintf('Running simulation %i/%i... \n', n, steps);
    
    %set current on coil
    i_cur = i0 + (n-1)/steps*di;
    mi_modifycircprop('Coil', 1, i_cur);  %1 -> property is I value
    
    %run simulation
    mi_analyze(flag_hide_simulation);
    mi_loadsolution();
    
    %take the B field over a straight line
    B_abs = zeros(B_points, 1);
    for i = 1:B_points
        P = P1+(P2-P1)*i/B_points;
        B = mo_getb(P);  %B is in the format [Bx By]
        B_abs(i) = norm(B);
    end
    B_max(n) = max(B_abs);
 end

mi_close;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Plot Analysis Results
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure()
plot(i0:di:ilim, B_max, '.-');

