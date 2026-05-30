% =====================================================================================
% Author:       Orhan Soyuhos 
% Last Modified: 08/01/2025
% =====================================================================================

function stat = autocorr(data, maxTimeLag)
    % Computes the autocorrelation of neural activity for each neuron.
    %
    % Parameters
    % ----------
    % data : double
    %     Neural activity data with shape (n_neurons, n_trials, n_timepoints).
    % maxTimeLag : int, optional
    %     Maximum time lag for autocorrelation in number of time points (bins).
    %     Defaults to the full duration of the time series.
    %
    % Returns
    % -------
    % struct
    %     A struct containing the results:
    %     'autocorr' : matrix of shape (n_neurons, maxTimeLag + 1)
    %     'autocorr_log' : matrix, log10 of the autocorrelation values.

    if ndims(data) ~= 3
        error('Input data must be a 3D array of shape (Neurons, Trials, Time points).');
    end

    [n_neurons, n_trials, n_timepoints] = size(data);
    
    if nargin < 2 || isempty(maxTimeLag)
        maxTimeLag = n_timepoints;
    end

    maxTimeLag = min(maxTimeLag, n_timepoints - 1);

    % Pre-allocate result matrices
    stat.autocorr = zeros(n_neurons, maxTimeLag + 1);
    stat.autocorr_log = zeros(n_neurons, maxTimeLag + 1);

    for i_neuron = 1:n_neurons
        % Extract data for one neuron: (trials x time)
        X = squeeze(data(i_neuron, :, :));
        
        correlations_sum = 0;
        total_energy = 0;

        for i_trial = 1:n_trials
            trial_data = X(i_trial, :);
            
            % Compute full autocorrelation for the trial
            trial_correlation = xcorr(trial_data, trial_data);
            correlations_sum = correlations_sum + trial_correlation;
            
            % Calculate the energy normalization term for this trial
            norm_product = sum(trial_data .^ 2) * sum(trial_data .^ 2);
            total_energy = total_energy + norm_product;
        end

        if total_energy > 0
            corr_norm = correlations_sum / total_energy;
            
            % In xcorr, the zero-lag is at the center index
            zero_lag_index = n_timepoints;
            
            % Extract positive lags, including the zero-lag
            positive_lags = corr_norm(zero_lag_index : zero_lag_index + maxTimeLag);
            
            % Normalize by the zero-lag value to ensure it starts at 1
            if positive_lags(1) == 0
                error('Zero-lag correlation is zero. Cannot normalize.');
            end
            autocorr_perNeuron = positive_lags / positive_lags(1);
        else
            % If total energy is zero, correlation is undefined.
            autocorr_perNeuron = zeros(1, maxTimeLag + 1);
        end

        % Store the results for the current neuron
        stat.autocorr(i_neuron, :) = autocorr_perNeuron;
        
        ac_real = real(autocorr_perNeuron);
        ac_real(ac_real < 0) = NaN;
        warning('off', 'MATLAB:log10:logOfZero');
        stat.autocorr_log(i_neuron, :) = log10(ac_real);
        warning('on', 'MATLAB:log10:logOfZero');
    end
end

%% Orhan Soyuhos, 2025