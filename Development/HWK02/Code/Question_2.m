%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Development Economics
% HWK 2, Question 2
% 08/02/2019
% Hefang Deng
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all
close all
rng(1234)

% Path
tableFolder = '../Tables/';


%% Parameters
n = 1000;
T = 40;
cases = 3; % Consider three cases: 1. No Season; 2. No Shock; 3. No Season & No Shock
corr_M = [0.8 -0.8]; % corr = 0.8  positively correlated ; corr = -0.8  negatively correlated ; 
nu = 1;
beta = 0.99^(1/12); % monthly discount factor
seasonality =[1 2 3]; % 1: Mid ; 2: High; 3: Low
sigma_sq_u = 0.2;
sigma_sq_epsilon = 0.2;

% Calibration of kappa
theta = 0.66;
C_Y_Ratio = 0.5;
h = 28.5 *30/7;
kappa = theta/(C_Y_Ratio * h^(1/nu+1));

% utility function
util = @(x,y) log(x) - kappa * y.^(1+1/nu)/(1+1/nu);

G = log([
    0.8630    0.7270    0.9320
    0.6910    0.3810    0.8450
    1.1510    1.3030    1.0760
    1.1400    1.2800    1.0700
    1.0940    1.1880    1.0470
    1.0600    1.1190    1.0300
    1.0370    1.0730    1.0180
    1.0370    1.0730    1.0180
    1.0370    1.0730    1.0180
    1.0020    1.0040    1.0010
    0.9680    0.9350    0.9840
    0.9210    0.8430    0.9610]);


sigma_sq_m = [
    0.0850    0.1710    0.0430
    0.0680    0.1370    0.0340
    0.2900    0.5800    0.1450
    0.2830    0.5670    0.1420
    0.2730    0.5460    0.1370
    0.2730    0.5460    0.1370
    0.2390    0.4780    0.1190
    0.2050    0.4100    0.1020
    0.1880    0.3760    0.0940
    0.1880    0.3760    0.0940
    0.1710    0.3410    0.0850
    0.1370    0.2730    0.0680];


%% Draw shocks

Result = zeros(n, cases, size(corr_M, 2), 2, size(seasonality,2));

% draw types of individuals
z = exp(-sigma_sq_u/2) * exp(sqrt(sigma_sq_u)*randn(n,1));     %  Consumption
z_Labor = exp(-sigma_sq_u/2) * exp(sqrt(sigma_sq_u)*randn(n,1));  %  Labor 
% Notice here the shock of Labor and Comsuption is independent

%z = repmat(exp(-sigma_sq_u/2) * exp(sqrt(sigma_sq_u)*randn(n ,1)), 1, 12*T);

% draw the individual seasonal shock
% we can use it to generate the counterpart for labor by perfect corr
epsilon_seasonal = randn(n,T*12);               % For Consumption


% draw idiosyncratic nonseasonal stochastic component for consumption, it's yearly shock
% we could generate the counterpart for Labor if the nonseasonal stochastic component
% of consumption and leisure are correlated
epsilon = repelem(exp(sqrt(sigma_sq_epsilon)*randn(n,T)),1,12);
epsilon_hat = exp(-sigma_sq_epsilon/2) * epsilon; 

epsilon_Labor = repelem(exp(sqrt(sigma_sq_epsilon)*randn(n,T)),1,12);


%% Parts (a), (b) and (c) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:size(corr_M, 2)
    
    corr = corr_M(i);   
    epsilon_seasonal_Labor = epsilon_seasonal * corr; 

    for j = 1:2 % Non-seasonal stochastic components are correlated
        
        if j == 1 % Not correlated, i.e. redraw the shocks for Labor
            epsilon_hat_Labor = exp(-sigma_sq_epsilon/2) * epsilon_Labor; 
        else % Correlated, ether positive 0.8 or negative -0.8
            epsilon_hat_Labor = exp(-sigma_sq_epsilon/2) * (epsilon.^corr);
        end

        for k = 1:size(seasonality,2) 

            % Set current degree of seasonality
            season = seasonality(k); % 1: Middle, 2: High, 3: Low

            % Compute the individual seasonal component
            sigm = repmat(sigma_sq_m(:,season)',n,T);
            epsilon_hat_season = exp(-sigm/2) .* exp(sqrt(sigm).*epsilon_seasonal);
            epsilon_hat_season_Labor = exp(-sigm/2) .* exp(sqrt(sigm).*epsilon_seasonal_Labor);

            % Get the deterministic seasonal components per month and individual
            g_m = repmat(G(:,season)',n,T);

            % Compute the Consumption 
            C = repmat(z,1,T*12) .* exp(g_m) .* epsilon_hat_season .* epsilon_hat;
            C_NoSeason = repmat(z,1,T*12) .* epsilon_hat;

            % Compute the Labor supply 
            Labor_Supply = repmat(z_Labor,1,T*12) .* exp(corr*g_m) .* epsilon_hat_season_Labor .* epsilon_hat_Labor;
            Labor_SupplyNoSeason = repmat(z_Labor,1,T*12) .* epsilon_hat_Labor;
            
            % Rescale the Labor supply
            Labor_Supply = Labor_Supply * h;
            Labor_SupplyNoSeason = Labor_SupplyNoSeason * h;

            % Compute utility per period
            
            U = util(C,Labor_Supply);
            U_NoSeason = util(C_NoSeason,Labor_SupplyNoSeason); 
            U_NoConSeason = util(C_NoSeason,Labor_Supply); 

            % Compute discount factors 
            discount = repmat(beta.^(12+(0:T*12-1)),n,1);
            sum_discount = sum(discount, 2);
            
            % Compute lifetime utility
            W = sum(discount.*U,2);
            W_NoSeason = sum(discount.*U_NoSeason,2);
            W_NoConSeason = sum(discount.*U_NoConSeason,2);

            % Compute the welfare gains
            
            gc = exp((W_NoConSeason-W)./sum_discount)-1;
            gl = exp((W_NoSeason-W_NoConSeason)./sum_discount)-1;
            gtot = exp((W_NoSeason-W)./sum_discount)-1;
            
            % Store the results
            Result(:,:,i,j,k) = [gc gl gtot];

        end
    
    end
end

%%
% Load relevant variables from results of question 2
tableFolder = '/Tables/';
% Generate Latex output (only medians)
for i = 1:size(corr_M, 2) % Positively or negatively correlated consumption and labor supply
    for j = 1:2 % Non-seasonal stochastic components are correlated
        Corr_String = {'positive corr','negative corr'};
        SeasonCor_String = {'','_nonseasonal'};
        filename = [tableFolder  Corr_String{i}  SeasonCor_String{j} '.xlsx'];
        A = zeros(3, 3);
        for l = 1:size(Result,2)
            gMedianMid = median(Result(:,l,i,j,1));
            gMedianHigh = median(Result(:,l,i,j,2));
            gMedianLow = median(Result(:,l,i,j,3));
            A(l,:) = [gMedianMid, gMedianHigh, gMedianLow];
            xlswrite(filename, A);
        end
  end
end

