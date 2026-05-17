% =====================================================================================
% Author:       Orhan Soyuhos 
% Last Modified: 08/01/2025
% =====================================================================================

function plot_r_squared_values(r2_control, title1, r2_inact, title2, bins, r2_threshold)
    % Plot histograms of R-squared values for one or two groups.
    
    if nargin < 5, bins = 50; end
    if nargin < 6, r2_threshold = []; end

    figure;
    
    % Case 1: Plot both control and inactivation data
    if nargin > 2 && ~isempty(r2_inact)
        ax1 = subplot(1, 2, 1);
        histogram(r2_control, bins, 'Normalization', 'pdf', 'DisplayName', 'Control');
        title(sprintf('%s R^2 Distribution', title1));
        xlabel('R-squared');
        ylabel('Density');
        grid off;
        hold(ax1, 'on');

        ax2 = subplot(1, 2, 2);
        histogram(r2_inact, bins, 'Normalization', 'pdf', 'DisplayName', 'Inactivation', 'FaceColor', '#e41a1c'); 
        title(sprintf('%s R^2 Distribution', title2));
        xlabel('R-squared');
        grid off;
        hold(ax2, 'on');
        
        if ~isempty(r2_threshold)
            xline(ax1, r2_threshold, 'k--', 'DisplayName', 'Threshold', 'LineWidth', 1.5);
            xline(ax2, r2_threshold, 'k--', 'LineWidth', 1.5);
        end
        legend(ax1, 'show');
        legend(ax2, 'show');

    % Case 2: Plot only control data
    else
        ax1 = gca;
        histogram(r2_control, bins, 'Normalization', 'pdf', 'DisplayName', 'Control'); % Changed 'density' to 'pdf'
        title(sprintf('%s R^2 Distribution', title1));
        xlabel('R-squared');
        ylabel('Density');
        grid off;
        hold on;

        if ~isempty(r2_threshold)
            xline(r2_threshold, 'k--', 'DisplayName', 'Threshold', 'LineWidth', 1.5);
        end
        legend('show');
    end
end

%% Orhan Soyuhos, 2025