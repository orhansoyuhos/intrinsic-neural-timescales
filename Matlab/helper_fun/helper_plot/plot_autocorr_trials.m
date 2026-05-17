% =====================================================================================
% Author:       Orhan Soyuhos 
% Last Modified: 08/01/2025
% =====================================================================================

function plot_autocorr_trials(region_name, name, ac_log, condi, bin_size)
    % Plots the autocorrelation of trials using log-transformed data.
    
    figure;
    sgtitle(sprintf('%s - %s - %s Condition (%dms)', region_name, name, condi, bin_size), 'FontSize', 16);
    
    % Data for the two subplots
    data_list = {ac_log, ac_log(:, 2:end)};
    titles = {'Log of Autocorr Values', 'Log of Autocorr Values - Exclude Time 0'};

    for i = 1:2
        subplot(1, 2, i);
        data = data_list{i};
        imagesc(data);
        
        title(titles{i});
        ylabel('Neurons');
        xlabel('Time lag (bins)');
        colorbar;
        grid off;
        
        % Define the ticks on x-axis
        xticks(1:3:size(data, 2));
        if i == 2 % Second plot
            xticklabels(1:3:size(data, 2));
        else
            xticklabels(0:3:size(data, 2)-1);
        end
    end
end

%% Orhan Soyuhos, 2025