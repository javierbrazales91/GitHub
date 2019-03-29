%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Development Economics
% HWK 2, Question 1
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
figureFolder = '../Figures/';

%% Parameters
n = 1000;
T = 40;
sigma_sq_u = 0.2;
sigma_sq_epsilon = 0.2;
beta = 0.99^(1/12);
etas = [1 2 4];
seasonality = [1 2 3];

g = log([
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

sigma_sq_m = [ ...
     0.085, 0.171, 0.043,;
     0.068, 0.137, 0.034;
     0.290, 0.580, 0.145;
     0.283, 0.567, 0.142;
     0.273, 0.546, 0.137;
     0.273, 0.546, 0.137;
     0.239, 0.478, 0.119;
     0.205, 0.410, 0.102;
     0.188, 0.376, 0.094;
     0.188, 0.376, 0.094;
     0.171, 0.341, 0.085;
     0.137, 0.273, 0.068;
     ];


%% Part 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gRes = NaN(1000,3,size(etas,2),size(seasonality,2));

z = exp(-sigma_sq_u/2) * exp(sqrt(sigma_sq_u)*randn(n,1));

epsilon = repelem(exp(sqrt(sigma_sq_epsilon)*randn(n,T)),1,12);
epsilonTilde = exp(-sigma_sq_epsilon/2) * epsilon;
                
for i = 1:size(etas,2)
    
    for j = 1:size(seasonality,2)
        
        % Set current eta and degree of seasonality
        eta = etas(i);
        degOfSeas = seasonality(j); % 1: Middle, 2: High, 3: Low
        
        % Get the deterministic seasonal components per month and individual
        gm = repmat(g(:,degOfSeas)',n,T);
        
        % Compute the consumption for all individuals
        cons = repmat(z,1,T*12) .* exp(gm) .* epsilonTilde;
        consNoSeason = repmat(z,1,T*12) .* epsilonTilde;
        consNoShock = repmat(z,1,T*12) .* exp(gm);
        consNoSeasonNoShock = repmat(z,1,T*12);
        
        % Compute utility per periods for all individuals
        if eta == 1
            util = log(cons);
            utilNoSeason = log(consNoSeason);
            utilNoShock = log(consNoShock);
            utilNoSeasonNoShock = log(consNoSeasonNoShock);
        else
            util = cons.^(1-eta)/(1-eta);
            utilNoSeason = consNoSeason.^(1-eta)/(1-eta);
            utilNoShock = consNoShock.^(1-eta)/(1-eta);
            utilNoSeasonNoShock = consNoSeasonNoShock.^(1-eta)/(1-eta);
        end
        
        % Compute discount factors for each period and all individuals
        discountFactors = repmat(beta.^(12+(0:T*12-1)),n,1);
        
        % Compute lifetime utility
        W = sum(discountFactors.*util,2);
        WNoSeason = sum(discountFactors.*utilNoSeason,2);
        WNoShock = sum(discountFactors.*utilNoShock,2);
        WNoSeasonNoShock = sum(discountFactors.*utilNoSeasonNoShock,2);
        
        % Compute the welfare gains
        if eta == 1 % WX = W + log(1+g)*sum(discountFactors,2)
            discSum = sum(discountFactors,2);
            gNoSeason = exp((WNoSeason-W)./discSum)-1;
            gNoShock = exp((WNoShock-W)./discSum)-1;
            gNoSeasonNoShock = exp((WNoSeasonNoShock-W)./discSum)-1;
            gNoShockVsNoSeasonNoShock = exp((WNoSeasonNoShock-WNoShock)./discSum)-1;
        else % WX = (1+g)^(1-eta)*W
            gNoSeason = (WNoSeason./W).^(1/(1-eta))-1;
            gNoShock = (WNoShock./W).^(1/(1-eta))-1;
            gNoSeasonNoShock = (WNoSeasonNoShock./W).^(1/(1-eta))-1;
            gNoShockVsNoSeasonNoShock = (WNoSeasonNoShock./WNoShock).^(1/(1-eta))-1;
        end
        
        % Store the results
        gRes(:,:,i,j) = [gNoSeason gNoShock gNoSeasonNoShock];
        
    end
end


%% Part 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note that I use the same epsilon and z as in part 1

% Intialize results matrix
gRes2 = NaN(1000,4,size(etas,2),size(seasonality,2),size(seasonality,2));

% Draw standard normal shocks for the individual seasonal component
logEpsMStandard = randn(n,T*12);

for i = 1:size(etas,2)
    
    for j = 1:size(seasonality,2) % Deterministic degrees of seasonality
        
        for k = 1:size(seasonality,2) % Stochastic degrees of seasonality
            
            % Set current eta and degree of seasonality
            eta = etas(i);
            degOfSeas = seasonality(j); % 1: Middle, 2: High, 3: Low
            degOfSeasStoch = seasonality(k); % 1: Middle, 2: High, 3: Low
            
            % Compute the individual seasonal component
            sigm = repmat(sigma_sq_m(:,degOfSeasStoch)',n,T);
            epsilonTildeSeason = exp(-sigm/2) .* exp(sqrt(sigm).*logEpsMStandard);
            
            % Get the deterministic seasonal components per month and individual
            gm = repmat(g(:,degOfSeas)',n,T);
            
            % Compute the consumption for all individuals
            cons = repmat(z,1,T*12) .* exp(gm) .* epsilonTildeSeason .* epsilonTilde;
            consNoDet = repmat(z,1,T*12) .* epsilonTildeSeason .* epsilonTilde;
            consNoStoch = repmat(z,1,T*12) .* exp(gm) .* epsilonTilde;
            consNoDetNoStoch = repmat(z,1,T*12) .* epsilonTilde;
            consNoShock = repmat(z,1,T*12) .* exp(gm) .* epsilonTildeSeason;
            
            % Compute utility per periods for all individuals
            if eta == 1
                util = log(cons);
                utilNoDet = log(consNoDet);
                utilNoStoch = log(consNoStoch);
                utilNoDetNoStoch = log(consNoDetNoStoch);
                utilNoShock= log(consNoShock);
            else
                util = cons.^(1-eta)/(1-eta);
                utilNoDet = consNoDet.^(1-eta)/(1-eta);
                utilNoStoch = consNoStoch.^(1-eta)/(1-eta);
                utilNoDetNoStoch = consNoDetNoStoch.^(1-eta)/(1-eta);
                utilNoShock = consNoShock.^(1-eta)/(1-eta);
            end
            
            % Compute discount factors for each period and all individuals
            discountFactors = repmat(beta.^(12+(0:T*12-1)),n,1);
            
            % Compute lifetime utility
            W = sum(discountFactors.*util,2);
            WNoDet = sum(discountFactors.*utilNoDet,2);
            WNoStoch = sum(discountFactors.*utilNoStoch,2);
            WNoDetNoStoch = sum(discountFactors.*utilNoDetNoStoch,2);
            WNoShock = sum(discountFactors.*utilNoShock,2);
            
            % Compute the welfare gains
            if eta == 1 % WX = W + log(1+g)*sum(discountFactors,2)
                discSum = sum(discountFactors,2);
                gNoDet = exp((WNoDet-W)./discSum)-1;
                gNoStoch = exp((WNoStoch-W)./discSum)-1;
                gNoDetNoStoch = exp((WNoDetNoStoch-W)./discSum)-1;
                gNoShock = exp((WNoShock-W)./discSum)-1;
            else % WX = (1+g)^(1-eta)*W
                gNoDet = (WNoDet./W).^(1/(1-eta))-1;
                gNoStoch = (WNoStoch./W).^(1/(1-eta))-1;
                gNoDetNoStoch = (WNoDetNoStoch./W).^(1/(1-eta))-1;
                gNoShock = (WNoShock./W).^(1/(1-eta))-1;
            end
            
            % Store the results
            gRes2(:,:,i,j,k) = [gNoDet gNoStoch gNoDetNoStoch gNoShock];
            
        end
    end
end

% Save results
save('Question_1.mat')

load('Question_1.mat','gRes','gRes2','seasonality','etas')

% Generate Histograms
figure
plotIdx = 1;
minMax = [floor(100*min(gRes(:)))/100 ceil(100*max(gRes(:)))/100];

for i = 1:size(etas,2)
    
    for k = 1:size(gRes,2)
        
        subplot(size(etas,2),size(gRes,2),plotIdx)
        for j = 1:size(seasonality,2)
            edges = minMax(1):0.05:minMax(2);
            h = histogram(gRes(:,k,i,j),edges,'FaceAlpha',0.6,'Normalization','probability');
            hold on
        end
        lbls = {'No Season','No Shock','No Season + No Shock'};
        if plotIdx <=size(gRes,2) % Title only in first row
            title(lbls{k})
        end
        if mod(plotIdx,size(gRes,2)) == 1 % y label only for first column
            ylabel(['\eta=' num2str(etas(i))])
        end
        xlim(minMax)
        plotIdx = plotIdx +1;
        
    end
end

% Add the legend
legend('Middle','High','Low')
legend boxoff
legend1 = legend(gca,'show');
set(legend1,'Orientation','horizontal');
legPos = get(legend1,'Position');
set(legend1,'Position',[0.5-legPos(3)/2, 0.02, legPos(3), legPos(4)]);

% Save the histogram
set(gcf, 'Units', 'Inches');
pos = get(gcf, 'Position');
set(gcf, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)]);
print(gcf, [figureFolder 'histQ11'], '-dpdf', '-r0');


%% Question 1 - Part 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Histograms
for qq = 1:size(etas,2)
    figure
    plotIdx = 1;
    gRes2Tmp = gRes2(:,:,qq,:,:);
    minMax = [floor(100*min(gRes2Tmp(:)))/100 ceil(100*max(gRes2Tmp(:)))/100];

    for i = 1:size(gRes2,2)
        
        for k = 1:size(seasonality,2)
            
            subplot(size(gRes2,2),size(seasonality,2),plotIdx)
            for j = 1:size(seasonality,2)
                edges = linspace(minMax(1),minMax(2),50);
                h = histogram(gRes2(:,i,qq,k,j),edges,'FaceAlpha',0.6,'Normalization','probability');
                hold on
            end
            lbls = {'No Det. Seas.','No Stoch. Seas.','No Det. + No Stoch.', 'No nonseasonal cons. risk'};
            lbls2 = {'Middle (deterministic)','High (deterministic)','Low (deterministic)'};
            if plotIdx <= size(seasonality,2) % Title only in first row
                title(lbls2{k})
            end
            if mod(plotIdx,size(seasonality,2)) == 1 % y label only for first column
                ylabel(lbls{i})
            end
            xlim(minMax)
            plotIdx = plotIdx +1;
            
        end
        
    end
    
    % Add the legend
    legend('Middle (stochastic)','High (stochastic)','Low (stochastic)')
    legend boxoff
    legend1 = legend(gca,'show');
    set(legend1,'Orientation','horizontal');
    legPos = get(legend1,'Position');
    set(legend1,'Position',[0.5-legPos(3)/2, 0.02, legPos(3), legPos(4)]);

    % Save the histogram
    set(gcf, 'Units', 'Inches');
    pos = get(gcf, 'Position');
    set(gcf, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)]);
    print(gcf, [figureFolder 'histQ12_eta_' num2str(etas(qq))], '-dpdf', '-r0');
    
end
