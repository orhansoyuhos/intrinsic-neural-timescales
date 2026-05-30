% =====================================================================================
% File:         timescale_analysis.m
% Author:       Orhan Soyuhos
% Last Modified: 05/16/2026
%
% Description:
%   Example code to calculate intrinsic neural timescales from example spiking data.
%
% =====================================================================================

%% Setup
clear; clc; close all;

% Resolve paths relative to this script so it runs from anywhere
script_dir = fileparts(mfilename('fullpath'));
repo_root  = fileparts(script_dir);

% Shared example data lives at <repo_root>/data
data_path = fullfile(repo_root, "data");
filename = 'example_spike_data.mat';

% Add helper functions to MATLAB path
helper_path = fullfile(script_dir, "helper_fun");
addpath(genpath(helper_path));

%% Define Parameters
region_name = 'RegionA';
bin_size = 10;          % in milliseconds
monkey_name = 'X';

% Set random seed for reproducibility
seed_n = 42;
rng(seed_n);

% Set default figure settings
default_fig_settings();

%% Import the dataset
data = load(fullfile(data_path, filename));

% Select spike counts (assuming it's a cell array in the .mat file)
neural_data = data.Spike_neu;
fprintf('(Neurons, Conditions) --> (%d, %d)\n', size(neural_data, 1), size(neural_data, 2));

%% Calculate spike counts for control condition
trial_start = -300; % ms
trial_end = 1000;   % ms

num_neurons = size(neural_data, 1);
num_total_conditions = size(neural_data, 2);
spike_counts_cell = cell(num_neurons, 1);

fprintf('Binning spike times for %d neurons...\n', num_neurons);
for i_neuron = 1:num_neurons
    % Use a dynamic cell array to gather all trials for one neuron
    each_neuron_spike_cell = {};
    
    % Iterate over all unique trial types (conditions)
    for i_cond = 1:num_total_conditions
        if i_cond > 96
            continue; % Skip conditions that are not control
        end
        
        condition_data = neural_data{i_neuron, i_cond}; 
        
        for i_trial = 1:numel(condition_data)
            timestamps = condition_data{i_trial}; 
            
            % Call the helper function to get the binned spike train
            spike_train = calculate_spike_train(timestamps, bin_size, trial_start, trial_end);
            each_neuron_spike_cell{end+1} = spike_train;
        end
    end
    
    % Vertically stack all trial vectors for the current neuron into a matrix
    spike_counts_cell{i_neuron} = vertcat(each_neuron_spike_cell{:});
end

% Check if all neurons have the same number of trials and time bins
sz = cellfun(@size, spike_counts_cell, 'UniformOutput', false);
if all(cellfun(@(s) isequal(s, sz{1}), sz))
    % Convert the cell array of matrices into a 3D matrix (neurons, trials, time)
    spike_counts = permute(cat(3, spike_counts_cell{:}), [3, 1, 2]);
else
    error('Inconsistent number of trials or time bins across neurons.');
end

fprintf('(Neurons, Trials, Time points) --> (%d, %d, %d)\n', ...
        size(spike_counts, 1), size(spike_counts, 2), size(spike_counts, 3));


%% Select baseline period
% Define the baseline period duration in milliseconds
baseline_duration_ms = 300; % The period from -300 ms to 0 ms
% Calculate the end bin dynamically based on the bin size
baseline_start_bin = 1; % The data starts at the beginning of the baseline
baseline_end_bin = round(baseline_duration_ms / bin_size);

baseline_spike = spike_counts(:, :, baseline_start_bin:baseline_end_bin);

fprintf('Baseline shape (Neurons, Trials, Time points) --> (%d, %d, %d)\n', ...
        size(baseline_spike, 1), size(baseline_spike, 2), size(baseline_spike, 3));

%% Demean data
% 'trials': Demean across trials
baseline_spike = demean_neural_data(baseline_spike, 'trials');
disp('Data demeaned across trials.');

%% Autocorrelation
% -------------------------------------------------------------------------
% Calculate the autocorrelation for the baseline spiking activity.
maxTimeLag_bins = size(baseline_spike, 3);

% Call the autocorrelation function
stat = autocorr(baseline_spike, maxTimeLag_bins);

% Extract results into separate variables
ac = stat.autocorr;
ac_log = stat.autocorr_log;

fprintf('Calculated autocorrelation. Matrix size: %d neurons x %d time lags\n', ...
        size(ac, 1), size(ac, 2));


%% Figures: Visualize Autocorrelation Profiles
% Plot the log-autocorrelation for all neurons
plot_autocorr_trials(region_name, monkey_name, ac_log, 'Control', bin_size);

% Plot individual and average autocorrelation profiles
each_neuron_autocorr(ac, region_name, monkey_name, bin_size);

%% Exponential Decay Fitting
% -------------------------------------------------------------------------
% Fit an exponential decay function to each neuron's autocorrelation profile
% to extract the intrinsic timescale (tau).
% NOTE: This requires the Curve Fitting Toolbox.

disp('Starting exponential decay fitting for each neuron...');

% R2 values for the plots with blue background are below the threshold.
r2_threshold = 0.3; % R2 should be >= 0.3. 
[tau_values, r2_control, aics_control, bics_control] = fit_exponential_decay(...
    ac, bin_size, 'r2_threshold', r2_threshold, 'show_fig', true, 'model_type', 'single');

disp('Fitting complete.');


%% R-squared Values
% -------------------------------------------------------------------------
% Plot the distribution of R-squared values from the fits to assess goodness-of-fit.

plot_r_squared_values(r2_control, 'Control', [], [], 50, r2_threshold);


%% Timescale (Tau) Values
% -------------------------------------------------------------------------
% Plot the distribution of the fitted timescale (tau) values.

% Convert cell array of taus to a numeric vector for plotting.
% This assumes a 'single' exponential fit was used.
tau_vector = cell2mat(tau_values);

% Remove any NaN values from failed fits before plotting
tau_vector = tau_vector(~isnan(tau_vector));

plot_tau_values(tau_vector, 'Control', [], [], 20);


%% Orhan Soyuhos, 2026