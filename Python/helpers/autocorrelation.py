"""Trial-averaged autocorrelation of binned spike counts."""

import numpy as np


def comp_cc(x1, x2, maxTimeLag, method='Average_Across_Trials', lags='both'):
    """Compute cross- or auto-correlation from binned spike data.

    Follows a specific trial-averaging and normalization convention:
    correlations are summed across trials, then normalized by the total
    per-trial energy (sum of squared values), then by the zero-lag value
    when ``x1 is x2``.

    Parameters
    ----------
    x1, x2 : np.ndarray
        Time-series data, shaped (n_trials, n_bins). For autocorrelation,
        x1 and x2 should be identical.
    maxTimeLag : int
        Maximum time-lag in number of bins.
    method : {'Average_Across_Trials', 'Concatenate_Trials'}, optional
        Only 'Average_Across_Trials' is currently implemented.
    lags : {'both', 'positive', 'negative'}, optional
        Which lags to compute relative to zero. Defaults to 'both'.

    Returns
    -------
    np.ndarray
        1D array of the normalized cross- or auto-correlation.
    """
    if maxTimeLag < 0 or maxTimeLag > x1.shape[1]:
        raise ValueError(
            f"Invalid maxTimeLag value: {maxTimeLag}. Must be <= {x1.shape[1]}."
        )
    if method != 'Average_Across_Trials':
        raise ValueError("This implementation only supports 'Average_Across_Trials'.")

    correlations = []
    total_energy = 0
    for trial in range(x1.shape[0]):
        trial_correlation = np.correlate(x1[trial], x2[trial], mode='full')
        correlations.append(trial_correlation)
        norm_product = np.sum(x1[trial] ** 2) * np.sum(x2[trial] ** 2)
        total_energy += norm_product

    if total_energy == 0:
        if lags == 'both':
            return np.zeros(2 * maxTimeLag - 1)
        return np.zeros(maxTimeLag if lags == 'negative' else maxTimeLag + 1)

    corr_sum = np.sum(correlations, axis=0)
    corr_norm = corr_sum / total_energy

    zero_lag_index = x1.shape[1] - 1
    if lags == 'both':
        corr_results = corr_norm[zero_lag_index - maxTimeLag + 1: zero_lag_index + maxTimeLag]
    elif lags == 'positive':
        corr_results = corr_norm[zero_lag_index: zero_lag_index + maxTimeLag + 1]
    elif lags == 'negative':
        corr_results = corr_norm[zero_lag_index - maxTimeLag + 1: zero_lag_index + 1]
    else:
        raise ValueError("Invalid lags parameter. Must be 'both', 'positive', or 'negative'.")

    if np.array_equal(x1, x2):
        zero_lag_idx = maxTimeLag - 1 if lags in ['both', 'negative'] else 0
        if len(corr_results) > zero_lag_idx:
            zero_lag_value = corr_results[zero_lag_idx]
            if zero_lag_value == 0:
                raise ValueError("Zero-lag correlation is zero. Cannot normalize.")
            corr_results /= zero_lag_value

    return corr_results


def autocorr(data, maxTimeLag=None):
    """Compute the autocorrelation of neural activity for each neuron.

    Parameters
    ----------
    data : np.ndarray
        Neural activity data with shape (n_neurons, n_trials, n_timepoints).
    maxTimeLag : int, optional
        Maximum time lag in number of time points (bins). Defaults to the
        full duration of the time series.

    Returns
    -------
    dict
        ``'autocorr'`` : np.ndarray of shape (n_neurons, maxTimeLag + 1)
        ``'autocorr_log'`` : np.ndarray, log10 of the autocorrelation values.
    """
    if data.ndim != 3:
        raise ValueError("Input data must be a 3D array of shape (Neurons, Trials, Time points).")

    n_neurons, _, n_timepoints = data.shape

    if maxTimeLag is None:
        maxTimeLag = n_timepoints

    stat = {'autocorr': [], 'autocorr_log': []}
    for neuron_idx in range(n_neurons):
        X = data[neuron_idx, :, :]
        autocorr_perNeuron = comp_cc(X, X, maxTimeLag, lags='positive')

        with np.errstate(divide='ignore'):
            autocorr_perNeuron_log = np.log10(autocorr_perNeuron)

        stat['autocorr'].append(autocorr_perNeuron)
        stat['autocorr_log'].append(autocorr_perNeuron_log)

    stat['autocorr'] = np.array(stat['autocorr'])
    stat['autocorr_log'] = np.array(stat['autocorr_log'])
    return stat
