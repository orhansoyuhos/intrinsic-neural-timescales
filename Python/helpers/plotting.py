"""Plotting helpers: default style, autocorrelation views, tau/R² distributions."""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import seaborn as sns


def default_fig_settings():
    """Apply default figure size and seaborn-like styling for the notebook."""
    scale_factor = 12 / 16  # desired_width / original_width

    plt.rcParams['figure.figsize'] = [12, 12 / 16 * 9]
    plt.rcParams['axes.labelsize'] = 20 * scale_factor
    plt.rcParams['axes.titlesize'] = 22 * scale_factor
    plt.rcParams['xtick.labelsize'] = 18 * scale_factor
    plt.rcParams['ytick.labelsize'] = 18 * scale_factor
    plt.rcParams['legend.fontsize'] = 16 * scale_factor
    plt.rcParams['figure.titlesize'] = 24 * scale_factor

    sns.set_style("white")
    sns.set_palette("muted")


def plot_autocorr_trials(region_name, monkey_name, ac_log, condi, bin_size):
    """Plot log-autocorrelation across neurons as a heatmap (raw and excluding lag 0).

    Parameters
    ----------
    region_name : str
        Brain region label for the figure title.
    monkey_name : str
        Subject label for the figure title.
    ac_log : np.ndarray
        Log-transformed autocorrelation matrix (n_neurons x n_lags).
    condi : str
        Condition label for the figure title.
    bin_size : int
        Bin size in ms (for the title).
    """
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    fig.suptitle(f'{region_name} - {monkey_name} - {condi} Condition ({bin_size}ms)', y=1)

    data_list = [ac_log[:, :], ac_log[:, 1:]]
    titles = [
        'Log of Autocorr Values',
        'Log of Autocorr Values - Exclude Time 0',
    ]

    for i, (ax, data, title) in enumerate(zip(axes, data_list, titles)):
        im = ax.imshow(data, cmap=cm.viridis, aspect='auto', interpolation='none')
        ax.set_title(title)
        ax.axis('on')
        ax.set_ylabel('Neurons')
        ax.set_xlabel('Time lag')

        fig.colorbar(im, ax=ax, shrink=0.6)
        ax.grid(False)

        ax.set_xticks(np.arange(0, data.shape[1], 3))
        if i == 1:
            ax.set_xticklabels(np.arange(1, 1 + data.shape[1], 3))
        else:
            ax.set_xticklabels(np.arange(0, data.shape[1], 3))

    plt.tight_layout()
    plt.show()


def each_neuron_autocorr(ac, region_name, monkey_name, bin_size):
    """Plot per-neuron autocorrelation traces and the population average.

    Parameters
    ----------
    ac : np.ndarray
        Autocorrelation matrix (n_neurons x n_lags).
    region_name : str
        Brain region label for the figure title.
    monkey_name : str
        Subject label for the figure title.
    bin_size : int
        Bin size in ms (for the title).
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6), sharey=False)
    fig.suptitle(f"{region_name} - {monkey_name} - Neuron Autocorrelation ({bin_size}ms)")

    x_values = np.arange(1, ac.shape[1])

    for idx in range(ac.shape[0]):
        ax1.plot(x_values, ac[idx, 1:], alpha=0.4)

    ax1.set_title("Individual Neurons")
    ax1.set_xlabel('Time Lag')
    ax1.set_ylabel('Autocorrelation')
    ax1.grid(False)

    mean_ac = np.mean(ac[:, 1:], axis=0)
    std_ac = np.std(ac[:, 1:], axis=0)

    ax2.plot(x_values, mean_ac, color='black', linewidth=2, label='Average')
    ax2.fill_between(
        x_values,
        mean_ac - std_ac,
        mean_ac + std_ac,
        color='gray', alpha=0.5, label='Std. Dev.',
    )

    ax2.set_title("Average Profile")
    ax2.set_xlabel('Time Lag')
    ax2.grid(False)
    ax2.legend()

    y_min = np.min(ac[:, 1:])
    y_max = np.max(ac[:, 1:])
    ax1.set_ylim([y_min, y_max])

    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    plt.show()


def plot_tau_values(tau_control, title1, tau_inact=None, title2=None,
                    figsize=(12, 5), bins=50):
    """Plot histograms of tau values for one or two groups."""
    sns.set_style("white")

    if tau_inact is not None and len(tau_inact) > 0:
        if title2 is None:
            raise ValueError("Argument 'title2' must be provided when 'tau_inact' is given.")

        fig, axs = plt.subplots(1, 2, figsize=figsize, sharey=True)

        sns.histplot(tau_control, bins=bins, kde=True, color='#377eb8',
                     label=title1, ax=axs[0], stat="density")
        axs[0].set_title(f'{title1} Tau Distribution')
        axs[0].set_xlabel('Tau')
        axs[0].set_ylabel('Density')
        axs[0].legend()

        sns.histplot(tau_inact, bins=bins, kde=True, color='#e41a1c',
                     label=title2, ax=axs[1], stat="density")
        axs[1].set_title(f'{title2} Tau Distribution')
        axs[1].set_xlabel('Tau')
        axs[1].legend()
    else:
        single_figsize = (figsize[0] / 2, figsize[1])
        fig, ax = plt.subplots(1, 1, figsize=single_figsize)

        sns.histplot(tau_control, bins=bins, kde=True, color='#377eb8',
                     label=title1, ax=ax, stat="density")
        ax.set_title(f'{title1} Tau Distribution')
        ax.set_xlabel('Tau')
        ax.set_ylabel('Density')
        ax.legend()

    plt.tight_layout()
    plt.show()


def plot_r_squared_values(r2_control, title1, r2_inact=None, title2=None,
                          figsize=(12, 5), bins=50, r2_threshold=None):
    """Plot histograms of R-squared values for one or two groups.

    Pass ``r2_threshold`` to draw a vertical dashed reference line.
    """
    sns.set_style("white")

    if r2_inact is not None:
        if title2 is None:
            raise ValueError("Argument 'title2' must be provided when 'r2_inact' is given.")

        fig, axs = plt.subplots(1, 2, figsize=figsize, sharey=True)

        sns.histplot(r2_control, bins=bins, kde=True, color='#377eb8',
                     label='Control', ax=axs[0], stat="density")
        axs[0].set_title(f'{title1} R² Distribution')
        axs[0].set_xlabel('R-squared')
        axs[0].set_ylabel('Density')

        sns.histplot(r2_inact, bins=bins, kde=True, color='#e41a1c',
                     label='Inactivation', ax=axs[1], stat="density")
        axs[1].set_title(f'{title2} R² Distribution')
        axs[1].set_xlabel('R-squared')

        if r2_threshold is not None:
            axs[0].axvline(r2_threshold, color='black', linestyle='--', label='Threshold')
            axs[1].axvline(r2_threshold, color='black', linestyle='--')

        axs[0].legend()
        axs[1].legend()
    else:
        single_figsize = (figsize[0] / 2, figsize[1])
        fig, ax = plt.subplots(1, 1, figsize=single_figsize)

        sns.histplot(r2_control, bins=bins, kde=True, color='#377eb8',
                     label='Control', ax=ax, stat="density")
        ax.set_title(f'{title1} R² Distribution')
        ax.set_xlabel('R-squared')
        ax.set_ylabel('Density')

        if r2_threshold is not None:
            ax.axvline(r2_threshold, color='black', linestyle='--', label='Threshold')

        ax.legend()

    plt.tight_layout()
    plt.show()
