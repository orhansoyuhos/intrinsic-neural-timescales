"""Helper functions for the intrinsic neural timescale (INT) pipeline.

Mirrors the MATLAB ``helper_fun/`` package. See the top-level README for
the analysis overview.
"""

from .spike_train import calculate_spike_train, demean_neural_data
from .autocorrelation import comp_cc, autocorr
from .exponential_fit import single_exp, double_exp, fit_exponential_decay
from .plotting import (
    default_fig_settings,
    plot_autocorr_trials,
    each_neuron_autocorr,
    plot_tau_values,
    plot_r_squared_values,
)

__all__ = [
    "calculate_spike_train",
    "demean_neural_data",
    "comp_cc",
    "autocorr",
    "single_exp",
    "double_exp",
    "fit_exponential_decay",
    "default_fig_settings",
    "plot_autocorr_trials",
    "each_neuron_autocorr",
    "plot_tau_values",
    "plot_r_squared_values",
]
