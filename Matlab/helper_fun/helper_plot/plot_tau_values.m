% =====================================================================================
% Author:       Orhan Soyuhos 
% Last Modified: 08/01/2025
% =====================================================================================

function plot_tau_values(tau_control, title1, tau_inact, title2, bins)
    % Plot histograms of Tau values for one or two groups.
    
    if nargin < 5, bins = 50; end
    
    figure;
    
    % Case 1: Plot both control and inactivation data
    if nargin > 2 && ~isempty(tau_inact)
        subplot(1, 2, 1);
        histogram(tau_control, bins, 'Normalization', 'pdf', 'DisplayName', title1); 
        title(sprintf('%s Tau Distribution', title1));
        xlabel('Tau (ms)');
        ylabel('Density');
        legend('show');
        grid off;

        subplot(1, 2, 2);
        histogram(tau_inact, bins, 'Normalization', 'pdf', 'DisplayName', title2); 
        title(sprintf('%s Tau Distribution', title2));
        xlabel('Tau (ms)');
        legend('show');
        grid off;
        
    % Case 2: Plot only control data
    else
        histogram(tau_control, bins, 'Normalization', 'pdf', 'DisplayName', title1); 
        title(sprintf('%s Tau Distribution', title1));
        xlabel('Tau (ms)');
        ylabel('Density');
        legend('show');
        grid off;
    end
end

%% Orhan Soyuhos, 2025