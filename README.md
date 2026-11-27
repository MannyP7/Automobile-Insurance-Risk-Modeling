
# Automobile Insurance Risk Modeling

## Project Overview

This independent academic project investigates the relationship
between driver age, vehicle age, and automobile insurance claim
counts while accounting for policy exposure.

The objective is to determine whether vehicle age modifies the
association between driver age and expected claim counts, with
applications to insurance risk assessment and segmentation.

## Dataset

The analysis uses the Australian automobile insurance dataset
(2004–2005), containing 67,856 insurance policies.

Variables include:

- Claim count
- Policy exposure
- Driver age
- Vehicle age

Source: [CASdatasets](https://dutangc.github.io/CASdatasets/reference/ausprivauto.html)

## Methodology

- Data cleaning and validation
- Exploratory data analysis
- Exposure-adjusted descriptive claim frequencies
- Poisson generalized linear models (GLMs)
- Interaction effect analysis
- Likelihood ratio testing
- Model selection using AIC and BIC
- Deviance residual diagnostics
- Quasi-Poisson regression and overdispersion assessment

## Model Specifications

Three nested Poisson regression models were compared:

| Model | Predictors |
|-------|------------|
| M1 | Exposure |
| M2 | Exposure, Driver Age, Vehicle Age |
| M3 | Exposure, Driver Age, Vehicle Age, Driver Age × Vehicle Age |

Exposure was included as an explanatory variable in each model.

## Results

| Model | AIC | BIC |
|-------|-----|-----|
| M1 | 34908.34 | 34926.60 |
| M2 | 34808.61 | 34899.87 |
| M3 | 34823.12 | 35051.25 |

### Key Findings

- Younger drivers generally exhibited higher automobile
  insurance claim frequencies.

- Adding driver age and vehicle age significantly improved
  model fit compared with the baseline model.

- The interaction between driver age and vehicle age was
  not statistically significant (p = 0.4163).

- The additive Poisson model (M2) was preferred based on
  AIC, BIC, and likelihood ratio testing.

- Quasi-Poisson analysis produced an estimated dispersion
  parameter of approximately 1.017, indicating very mild
  overdispersion.

## Business Applications

This analysis demonstrates statistical techniques relevant to:

- Insurance risk assessment
- Actuarial modeling
- Underwriting analytics
- Risk segmentation
- Claim frequency modeling

## Limitations and Future Work

- The dataset is limited to Australian insurance policies
  from 2004–2005.
- Additional risk factors, such as driving experience and
  geographic location, were not included.
- Future work could incorporate log-exposure offsets and
  compare alternative count regression models.
- Findings should not be generalized to current insurance
  populations without further validation.

## Technologies

- R
- Generalized Linear Models
- Statistical Hypothesis Testing
- Data Visualization
- Statistical Model Selection

## Reproducing the Analysis

Run `SoloProj.R` in R or RStudio.

The script retrieves the dataset directly from an online
source and uses base R functions for statistical analysis
and visualization.

## Author

Emmanuel Pacheco Hernandez

BSc Mathematics | University of Calgary

[LinkedIn](https://www.linkedin.com/in/emmanuel-pacheco-0b6598355)

## Acknowledgments

