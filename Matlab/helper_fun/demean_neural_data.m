% =====================================================================================
% Author:       Orhan Soyuhos 
% Last Modified: 08/01/2025
% =====================================================================================

function demeaned_data = demean_neural_data(data, axis_str)
    % Demeans 3D neural data for each neuron.
    %
    % Args:
    %     data (double): Input data with shape (neurons, trials, time_points).
    %     axis_str (char): The axis to demean across.
    %                      'trials': Demean across trials (dim 2).
    %                      'time': Demean across time points (dim 3).
    %                      'none' or other: Return the original data.
    % Returns:
    %     double: The demeaned (or original) data.

    if nargin < 2 || isempty(axis_str) || strcmp(axis_str, 'none')
        demeaned_data = data;
        return;
    end

    if strcmp(axis_str, 'trials')
        axis_to_demean = 2;
    elseif strcmp(axis_str, 'time')
        axis_to_demean = 3;
    else
        error("Axis must be 'trials', 'time', or 'none'.");
    end
    
    mean_vals = mean(data, axis_to_demean);
    demeaned_data = data - mean_vals; 
end

%% Orhan Soyuhos, 2025