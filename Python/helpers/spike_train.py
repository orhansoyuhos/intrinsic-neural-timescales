"""Spike-train preprocessing: binning and demeaning."""

import numpy as np


def calculate_spike_train(timestamps, bin_size, start_time_ms, end_time_ms):
    """Generate a binned spike train from spike timestamps.

    Parameters
    ----------
    timestamps : np.ndarray
        Spike timestamps in seconds.
    bin_size : int
        Size of each time bin in milliseconds (ms).
    start_time_ms : int
        Start time of the window in milliseconds (ms).
    end_time_ms : int
        End time of the window in milliseconds (ms).

    Returns
    -------
    np.ndarray
        A binned spike train where each element is the spike count in that bin.
    """
    timestampsms = np.rint(timestamps * 1000).astype(int)
    duration_ms = end_time_ms - start_time_ms
    spike_train = np.zeros(duration_ms + 1, dtype=int)
    valid_spike_indices = (timestampsms >= start_time_ms) & (timestampsms <= end_time_ms)
    spike_train[timestampsms[valid_spike_indices] - start_time_ms] = 1
    spike_train_bin = np.add.reduceat(spike_train, range(0, len(spike_train), bin_size))
    return spike_train_bin


def demean_neural_data(data, axis=None):
    """Demean 3D neural data for each neuron.

    Parameters
    ----------
    data : np.ndarray
        Input data with shape (neurons, trials, time_points).
    axis : {'trials', 'time', 1, 2, None}, optional
        The axis to demean across.
        - 'trials' or 1: subtract the trial mean at each time bin (recommended
          default for any baseline with task structure, e.g. pre-stimulus
          fixation).
        - 'time' or 2: subtract each trial's own DC; appropriate only for
          truly task-free / stationary spontaneous recordings.
        - None: return the original data (diagnostic only).

    Returns
    -------
    np.ndarray
        The demeaned (or original) data.
    """
    if axis is None:
        return data

    if axis == 'trials':
        axis_to_demean = 1
    elif axis == 'time':
        axis_to_demean = 2
    else:
        axis_to_demean = axis

    if axis_to_demean not in [1, 2]:
        raise ValueError("Axis must be 'trials' (1), 'time' (2), or None.")

    mean_vals = np.mean(data, axis=axis_to_demean, keepdims=True)
    return data - mean_vals
