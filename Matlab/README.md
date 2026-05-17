# Intrinsic Neural Timescale Analysis — MATLAB

MATLAB implementation of the INT pipeline. See the
[top-level README](../README.md) for the parallel Python implementation
and overall project context.

## Requirements

- MATLAB (tested on R2023a and later)
- **Curve Fitting Toolbox** — required by `fit_exponential_decay.m`

## File structure

```
Matlab/
├── README.md
├── timescale_analysis.m                  # main script — run this
└── helper_fun/
    ├── autocorr.m                        # per-neuron autocorrelation
    ├── calculate_spike_train.m           # bin spike timestamps
    ├── demean_neural_data.m              # demean across trials
    ├── fit_exponential_decay.m           # single/double exp fit -> tau
    └── helper_plot/
        ├── default_fig_settings.m
        ├── each_neuron_autocorr.m
        ├── plot_autocorr_trials.m
        ├── plot_r_squared_values.m
        └── plot_tau_values.m
```

The example dataset (`example_spike_data.mat`) lives at the repo root
under [`../data/`](../data/) and is shared with the Python implementation.

## How to run

```matlab
cd Matlab
timescale_analysis
```

The main script resolves all paths relative to its own location, so it
works regardless of your current MATLAB working directory.

## Analysis overview

1. **Data loading** — load `../data/example_spike_data.mat`.
2. **Spike binning** — bin raw spike timestamps with
   `calculate_spike_train.m`.
3. **Demeaning** — `demean_neural_data.m` demean across trials.
4. **Autocorrelation** — per-neuron autocorrelation via `autocorr.m`.
5. **Exponential fitting** — `fit_exponential_decay.m` fits a
   single-exponential decay to each autocorrelation curve and extracts
   τ. It also generates per-neuron fit diagnostics.
6. **Visualization** — population R² and τ distributions.

---

## Citation

If you use this code in published work, please cite:

> Soyuhos, O., Zirnsak, M., Chaudhuri, R., & Chen, X. (2026). Selective
> control of prefrontal neural timescales by parietal cortex.
> *Nature Communications*. https://doi.org/10.1038/s41467-026-70326-1

BibTeX:

```bibtex
@article{soyuhos2026selective,
  author  = {Soyuhos, O. and Zirnsak, M. and Chaudhuri, R. and Chen, X.},
  title   = {Selective control of prefrontal neural timescales by parietal cortex},
  journal = {Nature Communications},
  year    = {2026},
  doi     = {10.1038/s41467-026-70326-1},
}
```

---

**Author:** Orhan Soyuhos
**Last modified:** 2026-05-16
