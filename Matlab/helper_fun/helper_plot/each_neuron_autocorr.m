% =====================================================================================
% Author:       Orhan Soyuhos 
% Last Modified: 08/01/2025
% =====================================================================================

function each_neuron_autocorr(ac, region_name, monkey_name, bin_size)
% Plots the autocorrelation for each neuron and an average profile.

figure;
sgtitle(sprintf('%s - %s - Neuron Autocorrelation (%dms)', region_name, monkey_name, bin_size), 'FontSize', 16);

% Generate x values for the time lags, skipping the 0-lag value
x_values = 1:(size(ac, 2) - 1);

% Plot each neuron's autocorrelation on the first subplot
ax1 = subplot(1, 2, 1);
num_neurons = size(ac, 1);
colors = parula(num_neurons);  

for i = 1:num_neurons
    plot(x_values, ac(i, 2:end), 'LineWidth', 1.2, 'Color', [colors(i, :) 0.7]);
    hold on;
end
title('Individual Neurons');
xlabel('Time Lag (bins)');
ylabel('Autocorrelation');
grid off;

% Calculate the mean and standard deviation
mean_ac = mean(ac(:, 2:end), 1);
std_ac = std(ac(:, 2:end), 0, 1);

% Plot the average autocorrelation on the second subplot
ax2 = subplot(1, 2, 2);
hold on;

% Shaded area for standard deviation
fill([x_values, fliplr(x_values)], [mean_ac - std_ac, fliplr(mean_ac + std_ac)], ...
    'k', 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', 'Std. Dev.');

% Average line
plot(x_values, mean_ac, 'k', 'LineWidth', 2, 'DisplayName', 'Average');

hold off;
title('Average Profile');
xlabel('Time Lag (bins)');
grid off;
legend('show', 'Location', 'northeast');

% Set shared y-axis limits
y_min = min(ac(:, 2:end), [], 'all');
y_max = max(ac(:, 2:end), [], 'all');
ylim(ax1, [y_min, y_max]);
ylim(ax2, [y_min, y_max]);
end

%% Orhan Soyuhos, 2025