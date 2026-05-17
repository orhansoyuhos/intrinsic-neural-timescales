# Intrinsic Neural Timescale (INT) — Example Pipeline

Example code for computing **intrinsic neural timescales (τ)** from spike
data, implemented in both **MATLAB** and **Python**. The two implementations
are kept in parallel and produce equivalent results on the same example
dataset.

1. Bin spike times into a `(neurons × trials × time)` array.
2. Select a baseline window.
3. Demean across trials.
4. Compute the per-neuron autocorrelation profile.
5. Fit a single (or double) exponential decay and extract τ.
6. Summarize R² and τ across the population.

---

## Repository layout

```
intrinsic-neural-timescales/
├── data/
│   └── example_spike_data.mat            # example dataset
├── Matlab/
│   ├── README.md                         # MATLAB-specific docs
│   ├── timescale_analysis.m              # main MATLAB pipeline
│   └── helper_fun/
│       ├── autocorr.m
│       ├── calculate_spike_train.m
│       ├── demean_neural_data.m
│       ├── fit_exponential_decay.m
│       └── helper_plot/
│           ├── default_fig_settings.m
│           ├── each_neuron_autocorr.m
│           ├── plot_autocorr_trials.m
│           ├── plot_r_squared_values.m
│           └── plot_tau_values.m
└── Python/
    ├── README.md                         # Python-specific docs
    ├── requirements.txt
    ├── timescale_analysis.ipynb          # main notebook
    ├── timescale_analysis.py             # script export of the notebook
    └── helpers/                          # importable helper package (mirrors helper_fun/)
        ├── __init__.py
        ├── spike_train.py                # calculate_spike_train, demean_neural_data
        ├── autocorrelation.py            # comp_cc, autocorr
        ├── exponential_fit.py            # single_exp, double_exp, fit_exponential_decay
        └── plotting.py                   # default_fig_settings + 4 plot functions
```

The two implementations share a single copy of `example_spike_data.mat`
under `data/`.

---

## Quick start

### MATLAB

Requires MATLAB (tested on R2023a+) and the **Curve Fitting Toolbox**.

```matlab
cd Matlab
timescale_analysis            % paths are resolved relative to the script
```

### Python

```bash
cd Python
pip install -r requirements.txt
jupyter notebook timescale_analysis.ipynb
```

Or run the exported script directly:

```bash
python Python/timescale_analysis.py
```

Paths to `data/example_spike_data.mat` are resolved relative to the
script/notebook location, so the code is portable without editing.

---

## Example dataset

`data/example_spike_data.mat` contains spiking data from primate cortical
recordings used here as a reproducible example. The variable `Spike_neu`
is a `(neurons × conditions)` cell array, where each cell holds the spike
timestamps (in seconds) for one trial.

The defaults in the scripts (`region_name = 'RegionA'`,
`monkey_name = 'A'`) are placeholders — change them to match your own
dataset when adapting the pipeline.

---

## Citation

If you use this code in published work, please cite:

> Soyuhos, O., Zirnsak, M., Chaudhuri, R., & Chen, X. (2026). Selective
> control of prefrontal neural timescales by parietal cortex.
> *Nature Communications*. https://doi.org/10.1038/s41467-026-70326-1

---

**Author:** Orhan Soyuhos
**Last updated:** 2026-05-16
