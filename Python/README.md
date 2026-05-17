# Intrinsic Neural Timescale Analysis — Python

Python implementation of the INT pipeline. See the
[top-level README](../README.md) for the parallel MATLAB implementation
and overall project context.

## Requirements

```bash
pip install -r requirements.txt
```

## File structure

```
Python/
├── README.md
├── requirements.txt
├── timescale_analysis.ipynb              # main notebook — run this
├── timescale_analysis.py                 # script export of the notebook
└── helpers/                              # importable helper package
    ├── __init__.py                       
    ├── spike_train.py                    # calculate_spike_train, demean_neural_data
    ├── autocorrelation.py                # comp_cc, autocorr
    ├── exponential_fit.py                # single_exp, double_exp, fit_exponential_decay
    └── plotting.py                       # default_fig_settings + 4 plot functions
```

The example dataset (`example_spike_data.mat`) lives at the repo root
under [`../data/`](../data/) and is shared with the MATLAB implementation.

## How to run

From the `Python/` directory (so `helpers` is on the path):

```bash
jupyter notebook timescale_analysis.ipynb
```

Or run the exported script:

```bash
python timescale_analysis.py
```

The data path is resolved relative to the notebook/script location, so
you don't need to edit anything.

## Importing the helpers from your own code

```python
from helpers import (
    calculate_spike_train,
    demean_neural_data,
    autocorr,
    fit_exponential_decay,
    default_fig_settings,
    plot_autocorr_trials,
    each_neuron_autocorr,
    plot_tau_values,
    plot_r_squared_values,
)
```

## Analysis overview

1. **Data loading** — load `../data/example_spike_data.mat`.
2. **Spike binning** — `calculate_spike_train`.
3. **Demeaning** — `demean_neural_data(..., axis='trials')`.
4. **Autocorrelation** — per-neuron AC via `autocorr`.
5. **Exponential fitting** — `fit_exponential_decay` fits a
   single-exponential decay to each AC curve and extracts τ.
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
