"""Exponential-decay fitting of autocorrelation profiles -> intrinsic timescale tau."""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit


def single_exp(x, a, tau, b):
    """Single exponential decay: a * (exp(-x/tau) + b)."""
    return a * (np.exp(-x / tau) + b)


def double_exp(x, a1, tau1, a2, tau2, b):
    """Double exponential decay: a1*exp(-x/tau1) + a2*exp(-x/tau2) + b."""
    return a1 * np.exp(-x / tau1) + a2 * np.exp(-x / tau2) + b


def fit_exponential_decay(ac, bin_size, r2_threshold=0.3,
                          show_fig=True, model_type='single'):
    """Fit an exponential decay to per-neuron autocorrelation profiles.

    Parameters
    ----------
    ac : np.ndarray
        2D array (n_neurons x n_lags) of autocorrelation values.
    bin_size : float
        Time duration of each bin (e.g. in ms).
    r2_threshold : float, optional
        R-squared below which fitted plots are highlighted, by default 0.3.
    show_fig : bool, optional
        If True, display per-neuron fit panels, by default True.
    model_type : {'single', 'double'}, optional
        Exponential model to fit, by default 'single'.

    Returns
    -------
    tau : list
        Fitted time constant(s) per neuron. For 'double' fits each element
        is a tuple ``(tau1, tau2)``.
    r2 : list
        R-squared of each fit.
    aics : list
        Akaike Information Criterion per fit.
    bics : list
        Bayesian Information Criterion per fit.
    """
    ac_ = ac[:, 1:]
    t_auto = np.arange(1, ac_.shape[1] + 1) * bin_size

    if model_type == 'single':
        func = single_exp
        p0 = [0.5, t_auto[-1] / 2, 0.25]
        bounds = ([0, 1, 0], [1, t_auto[-1], 0.5])
    elif model_type == 'double':
        func = double_exp
        p0 = [0.5, t_auto[-1] / 2, 0.5, t_auto[-1] / 4, 0.25]
        bounds = ([0, 1, 0, 1, 0], [1, t_auto[-1], 1, t_auto[-1], 0.5])
    else:
        raise ValueError("Invalid model_type. Choose 'single' or 'double'.")

    tau, bics, aics, r2 = [], [], [], []

    nrows = 6
    ncols = 4
    nplots_per_fig = nrows * ncols
    nfigs = int(np.ceil(ac_.shape[0] / nplots_per_fig))

    for i in range(nfigs):
        start_index = i * nplots_per_fig
        end_index = min((i + 1) * nplots_per_fig, ac_.shape[0])
        remaining_neurons = ac_.shape[0] - start_index

        current_ncols = min(ncols, remaining_neurons)
        current_nrows = (
            (remaining_neurons + ncols - 1) // ncols
            if remaining_neurons < nplots_per_fig
            else nrows
        )

        if remaining_neurons > 0:
            fig, axs = plt.subplots(current_nrows, current_ncols, figsize=(20, 20), squeeze=False)
            axs = axs.flatten()

            for j, neu in enumerate(range(start_index, end_index)):
                neu_au = ac_[neu, :]
                r2_each = np.nan

                try:
                    if not np.isnan(neu_au.sum()):
                        ac_max = np.argmax(neu_au)
                        popt, _ = curve_fit(
                            func, t_auto[ac_max:], neu_au[ac_max:], p0,
                            bounds=bounds, method='trf', max_nfev=10000,
                        )

                        if model_type == 'single':
                            tau_val = popt[1]
                            tau.append(tau_val)
                            tau_str = f'τ: {tau_val:.1f}'
                        else:
                            tau_vals = (popt[1], popt[3])
                            tau.append(tau_vals)
                            tau_str = f'τ1: {popt[1]:.1f}, τ2: {popt[3]:.1f}'

                        fit_data = func(t_auto[ac_max:], *popt)
                        rss = np.sum((neu_au[ac_max:] - fit_data) ** 2)
                        n_points = len(neu_au[ac_max:])

                        bics.append(n_points * np.log(rss / n_points) + len(p0) * np.log(n_points))
                        aics.append(2 * len(p0) + n_points * np.log(rss / n_points))

                        tss = np.sum((neu_au[ac_max:] - np.mean(neu_au[ac_max:])) ** 2)
                        r2_each = 1 - (rss / tss) if tss > 0 else 0
                        r2.append(r2_each)

                        axs[j].plot(
                            t_auto[ac_max:], fit_data, '#377eb8',
                            label=f'Neuron {neu + 1}\n{tau_str}\nR²: {r2_each:.2f}',
                        )
                        axs[j].scatter(t_auto, neu_au, color='#377eb8')

                except RuntimeError:
                    tau.append(np.nan)
                    r2.append(np.nan)
                    aics.append(np.nan)
                    bics.append(np.nan)
                    print(f"Fitting failed to converge for neuron {neu + 1}")

                tick_positions = np.linspace(0, 300, num=4)
                axs[j].set_xticks(tick_positions)
                axs[j].set_xticklabels([f"{int(x)}" for x in tick_positions])
                axs[j].set_xlabel("Time (ms)")

                if r2_each < r2_threshold:
                    axs[j].set_facecolor('#a6cee3')
                axs[j].legend()

            for k in range(j + 1, len(axs)):
                axs[k].set_visible(False)

            fig.tight_layout()

            if show_fig:
                plt.show()
            plt.close(fig)

    return tau, r2, aics, bics
