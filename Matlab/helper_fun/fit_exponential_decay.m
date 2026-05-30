% =====================================================================================
% Author:       Orhan Soyuhos 
% Last Modified: 08/01/2025
% =====================================================================================

function [tau, r2, aics, bics] = fit_exponential_decay(ac, bin_size, varargin)
    % Fits an exponential decay model to autocorrelation data for multiple neurons.
    %
    % NOTE: This function requires the MATLAB Curve Fitting Toolbox.
    %
    % Parameters
    % ----------
    % ac : matrix
    %     A 2D array where each row is the autocorrelation data for a single neuron.
    % bin_size : double
    %     The time duration of each bin in the autocorrelation data (e.g., in ms).
    %
    % Optional Name-Value Pairs
    % -------------------------
    % 'r2_threshold' : double, R-squared threshold below which fitted plots are highlighted (default: 0.3).
    % 'show_fig'     : logical, If true, display the plots of the fits (default: true).
    % 'model_type'   : char, The type of exponential model to fit ('single' or 'double', default: 'single').
    %
    % Returns
    % -------
    % A tuple containing four lists:
    % - tau : Cell array of fitted time constant(s) for each neuron.
    % - r2  : Vector of the R-squared value for each fit.
    % - aics: Vector of the Akaike Information Criterion (AIC) for each fit.
    % - bics: Vector of the Bayesian Information Criterion (BIC) for each fit.
    
    % --- Input Parser for Optional Arguments ---
    p = inputParser;
    addParameter(p, 'r2_threshold', 0.3, @isnumeric);
    addParameter(p, 'show_fig', true, @islogical);
    addParameter(p, 'model_type', 'single', @(x) any(validatestring(x,{'single','double'})));
    parse(p, varargin{:});

    r2_threshold = p.Results.r2_threshold;
    show_fig = p.Results.show_fig;
    model_type = p.Results.model_type;

    % --- Model Setup ---
    ac_ = ac(:, 2:end); % Exclude zero-lag
    t_auto = (1:size(ac_, 2))' * bin_size; % Time vector in ms

    if strcmp(model_type, 'single')
        fit_func = @(a, tau, b, x) a * (exp(-x ./ tau) + b);
        fit_type = fittype(fit_func, 'independent', 'x', 'coefficients', {'a', 'tau', 'b'});
        p0 = [0.5, t_auto(end)/2, 0.25];
        bounds_lower = [0, 1, 0];
        bounds_upper = [1, t_auto(end), 0.5];
        num_params = 3;
    elseif strcmp(model_type, 'double')
        fit_func = @(a1, tau1, a2, tau2, b, x) a1 * exp(-x ./ tau1) + a2 * exp(-x ./ tau2) + b;
        fit_type = fittype(fit_func, 'independent', 'x', 'coefficients', {'a1', 'tau1', 'a2', 'tau2', 'b'});
        p0 = [0.5, t_auto(end)/2, 0.5, t_auto(end)/4, 0.25];
        bounds_lower = [0, 1, 0, 1, 0];
        bounds_upper = [1, t_auto(end), 1, t_auto(end), 0.5];
        num_params = 5;
    else
        error("Invalid model_type. Choose 'single' or 'double'.");
    end
    
    fit_opts = fitoptions('Method', 'NonlinearLeastSquares', 'StartPoint', p0, 'Lower', bounds_lower, 'Upper', bounds_upper, ...
        'TolFun', 1.49e-8, 'TolX', 1.49e-8, 'MaxFunEvals', 10000, 'MaxIter', 5000);

    % --- Initialization ---
    num_neurons = size(ac_, 1);
    tau = cell(num_neurons, 1);
    r2 = NaN(num_neurons, 1);
    aics = NaN(num_neurons, 1);
    bics = NaN(num_neurons, 1);

    % --- Plotting Setup ---
    nrows = 5;
    ncols = 4;
    nplots_per_fig = nrows * ncols;
    nfigs = ceil(num_neurons / nplots_per_fig);
    neuron_counter = 1;

    % --- Main Loop ---
    for i_fig = 1:nfigs
        if show_fig
            figure('Position', get(0, 'Screensize')); % Fullscreen figure
        end
        
        for i_plot = 1:nplots_per_fig
            if neuron_counter > num_neurons, break; end
            
            if show_fig
                subplot(nrows, ncols, i_plot);
            end

            neu_au = ac_(neuron_counter, :)';
            r2_each = NaN; % Default value

            try
                if ~any(isnan(neu_au))
                    % Find peak and fit from that point onwards
                    [~, ac_max_idx] = max(neu_au);
                    t_fit = t_auto(ac_max_idx:end);
                    neu_fit = neu_au(ac_max_idx:end);
                    
                    % Perform the fit
                    [fit_result, gof] = fit(t_fit, neu_fit, fit_type, fit_opts);
                    
                    % --- Extract Results ---
                    if strcmp(model_type, 'single')
                        tau_val = fit_result.tau;
                        tau{neuron_counter} = tau_val;
                        tau_str = sprintf('\\tau: %.1f', tau_val);
                    else % double
                        tau_vals = [fit_result.tau1, fit_result.tau2];
                        tau{neuron_counter} = tau_vals;
                        tau_str = sprintf('\\tau_1: %.1f, \\tau_2: %.1f', tau_vals(1), tau_vals(2));
                    end
                    
                    r2_each = gof.rsquare;
                    r2(neuron_counter) = r2_each;
                    
                    % --- Calculate AIC and BIC ---
                    rss = gof.sse; % Sum of squared errors
                    n_points = numel(neu_fit);
                    bics(neuron_counter) = n_points * log(rss / n_points) + num_params * log(n_points);
                    aics(neuron_counter) = 2 * num_params + n_points * log(rss / n_points);
                    
                    % --- Plotting ---
                    if show_fig
                        % Plot the original data points first
                        scatter(t_auto, neu_au, 36, 'MarkerEdgeColor', '#377eb8');
                        hold on;

                        % Now, plot the fitted line
                        plot(fit_result);

                        % Turn off the legend
                        legend off;

                        title(sprintf('Neuron %d', neuron_counter));
                        xlabel('Time (ms)');
                        ylabel('Autocorrelation');

                        % Manually set axis limits to ensure raw data is visible
                        xlim([0 t_auto(end)]);

                        data_min = min(neu_au);
                        data_max = max(neu_au);
                        range = data_max - data_min;
                        if range == 0; range = 1; end % Avoid zero range
                        padding = range * 0.1; % 10% padding
                        ylim([data_min - padding, data_max + padding]);

                        grid off;

                        % Add text for fit parameters
                        text(0.98, 0.98, {tau_str, sprintf('R^2: %.2f', r2_each)}, ...
                            'Units', 'normalized', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', ...
                            'BackgroundColor', 'w', 'EdgeColor', 'k');

                        if r2_each < r2_threshold
                            set(gca, 'Color', '#a6cee3'); % Highlight poor fits
                        end
                        hold off;
                    end
                end
            catch ME
                fprintf('Fitting failed for neuron %d: %s\n', neuron_counter, ME.message);
            end
            
            neuron_counter = neuron_counter + 1;
        end
        
        if show_fig
            sgtitle(sprintf('Exponential Fits (Figure %d of %d)', i_fig, nfigs), 'FontSize', 16, 'FontWeight', 'bold');
        end
    end
end

%% Orhan Soyuhos, 2025