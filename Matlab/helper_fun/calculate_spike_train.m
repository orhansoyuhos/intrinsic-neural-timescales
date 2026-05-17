% =====================================================================================
% Author:       Orhan Soyuhos 
% Last Modified: 08/01/2025
% =====================================================================================

function spike_train_bin = calculate_spike_train(timestamps, bin_size, start_time_ms, end_time_ms)
    % Generates a binned spike train from spike timestamps.
    %
    % Parameters
    % ----------
    % timestamps : vector
    %     Spike timestamps in seconds.
    % bin_size : int
    %     Size of each time bin in milliseconds (ms).
    % start_time_ms : int
    %     Start time of the window in milliseconds (ms).
    % end_time_ms : int
    %     End time of the window in milliseconds (ms).
    %
    % Returns
    % -------
    % vector
    %     A binned spike train where each element is the spike count in that bin.

    timestampsms = round(timestamps * 1000);
    duration_ms = end_time_ms - start_time_ms;
    
    spike_train = zeros(1, duration_ms + 1);
    
    valid_spike_indices = (timestampsms >= start_time_ms) & (timestampsms <= end_time_ms);
    valid_spikes_ms = timestampsms(valid_spike_indices);
    
    % Convert to 1-based indices relative to the start time
    indices_in_train = valid_spikes_ms - start_time_ms + 1;
    spike_train(indices_in_train) = 1;
    
    % Bin the spike train
    num_bins = floor(length(spike_train) / bin_size);
    truncated_train = spike_train(1 : num_bins * bin_size);
    reshaped_train = reshape(truncated_train, bin_size, num_bins);
    spike_train_bin = sum(reshaped_train, 1);
end

%% Orhan Soyuhos, 2025