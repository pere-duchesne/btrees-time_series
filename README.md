# Tree-Based Models for Time Series Analysis

A guided walkthrough of **tree-based models for time-series analysis** —
from the simplest regression trees up to ensembles and gradient boosting,
and finally to how these methods are applied to forecasting problems.

## Motivation

Tree-based methods are among the most practical tools in a data scientist's
toolkit: they are interpretable, scale well, and require relatively little
feature engineering. Yet most textbook treatments stop at *"here is how to
grow a tree"* and never connect the dots to the actual problem of predicting
something **over time**.

This project is an attempt to close that gap. It follows a deliberate path:

1. **Simple regression trees** — what they are, how they split, why they work.
2. **Pruning** — controlling complexity and avoiding overfitting.
3. **Hyperparameter optimization** — finding the right tree for the job.
4. **Ensemble techniques** — bagging, random forests, boosting.
5. **XGBoost** — the modern workhorse, and why it dominates tabular problems.
6. **Time-series application** — how the same machinery is adapted when
   observations are not i.i.d., and what changes (features, validation,
   leakage, stationarity, etc.).

The idea is not to *teach* each of these topics from scratch, but to show
**how they relate to each other** and, most importantly, **how they land on
forecasting**.

## Scope and what is *not* covered

The project uses **example datasets**, some of them real and some of them
**simulated**, to illustrate each technique. Simulation, Monte Carlo,
bootstrapping, and train/test sampling are used throughout — but they are
*tools in service of the narrative*, not subjects of the narrative.

This means you will **not** find dedicated chapters on:

- How to design simulations or Monte Carlo experiments.
- Bootstrap theory or resampling methodology.
- Train/test split strategies as a standalone topic.

These techniques appear where they are needed and are assumed to be
understood; the focus is always on the **tree-based models and their
application to time series**.

## Structure

The repository is organized as a sequence of stages that build on each other:

| Stage | Topic |
|---|---|
| `01` | Simple regression trees |
| `02` | Pruning and complexity control |
| `03` | Hyperparameter optimization |
| `04` | Ensemble techniques (bagging, random forests, boosting) |
| `05` | XGBoost |
| `06` | Time-series analysis with tree-based models |

Each stage has its own folder with code, data (or data-generation scripts),
and a section-level `README.md` explaining the specifics.

> **Status:** 🚧 Work in progress. The `data/` folder currently contains the
> Argentine calendar module (see below); the modeling stages are being added
> incrementally.

## Data

Example datasets live under `data/`. They are a mix of:

- **Real datasets**, used where a realistic structure matters.
- **Simulated datasets**, used when a controlled example is clearer than a
  real one (for instance, when a known ground truth helps illustrate a
  concept).

When a dataset is simulated, the generation code is included alongside it,
but the *how* of the simulation is not the point — it's just the vehicle for
the example.

### Argentine calendar (`data/argentine_calendar.R`)

One of the data modules included so far is an **enriched calendar for
Argentina**, used to build time-based features (day of week, fraction of the
year, holidays, etc.) for regression models on time series.

It exposes four functions:

| Function | Description |
|---|---|
| `make_days(years)` | Builds a `data.frame` with one row per day and derives calendar features. |
| `retrieve_holidays(years)` | Downloads national holidays from the public API at [argentinadatos.com](https://argentinadatos.com/). |
| `wrapper(years)` | Combines calendar and holidays into a JSON payload. |
| `save_calendar(years)` | Persists the result to `calendar.json`. |

For details, see the full documentation in
[`data/README.md`](data/README.md).

#### Holiday source

Holidays are fetched from the public API at
**[argentinadatos.com](https://argentinadatos.com/)** — an open-source project
that maintains open datasets for Argentina.

- Endpoint used: `https://api.argentinadatos.com/v1/feriados/{year}/`
- Website / repo: <https://argentinadatos.com/>

> 🙏 **Special thanks** to the maintainers of **argentinadatos.com**
> for providing and maintaining this API for free — without it, this project
> could not automatically incorporate national holidays for Argentina.
> If you use this project, consider giving their repo a star
> and/or contributing to the project.

## Language and tools

- **R** is the primary language, chosen for its ecosystem (`rpart`, `randomForest`,
  `xgboost`, `forecast`, `tidymodels`, …) and for how well it reads as a
  narrative language for modeling code.
- **Other languages** may appear where they help (e.g. small helpers, scripts,
  or comparisons), but they are secondary.

## Who this is for

- Practitioners who already know what a decision tree is and want to see how
  the family of tree-based methods evolves toward forecasting.
- Readers who learn better from **connected examples** than from isolated
  chapters on each technique.
- Anyone curious about *"why B-trees, why boosting, why time series — and how
  do these fit together?"*

## Acknowledgments

- **[argentinadatos.com](https://argentinadatos.com/)** — for the holidays API
  used in the Argentine calendar module.
- The open-source R community — for the packages that make all of this
  possible (`rpart`, `randomForest`, `xgboost`, `tidymodels`, `lubridate`,
  `dplyr`, `httr`, `jsonlite`, and many others).

## License

*MIT*
