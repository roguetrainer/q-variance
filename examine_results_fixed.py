#!/usr/bin/env python3
"""
Script to examine the results from q_variance_analysis_claude.ipynb
This shows the structure and values of the results dictionary.
"""

import pandas as pd
import numpy as np

# Load the data - handle the unnamed first column
df = pd.read_csv("indexSP500.csv")
# Use the first column as index (dates)
df = df.set_index(df.columns[0])
df.index = pd.to_datetime(df.index)
df = df.sort_index()

# Clean the data
df_clean = df.dropna(subset=["Close"]).copy()
prices = df_clean["Close"].values

print("Data loaded successfully!")
print(f"Total price observations: {len(prices)}")
print(f"Date range: {df_clean.index.min()} to {df_clean.index.max()}")

# Now let's see what specific results you want to examine
print(
    "\nTo see the results, you would need to run the analysis functions from the notebook."
)
print(
    "The results dictionary contains analysis for time horizons: [5, 10, 20, 40, 80] days"
)
print("\nEach entry in results contains:")
print("- z_values: normalized log price changes")
print("- V_values: variance values")
print("- z_binned: binned z values")
print("- V_binned: binned variance values")
print("- sigma_squared: estimated sigma squared")
print("- sigma: estimated sigma")
print("- r_squared: R-squared of fit")
print("- n_segments: number of segments analyzed")

# Let's do a quick sample analysis for T=20 to show results structure
print("\n" + "=" * 50)
print("SAMPLE ANALYSIS for T=20 days:")
print("=" * 50)


# Simple calculation for demonstration
def simple_segment_analysis(prices, T):
    """Simple version to show results structure"""
    n_segments = len(prices) // T
    z_values = []

    for i in range(n_segments):
        start_idx = i * T
        end_idx = (i + 1) * T
        segment = prices[start_idx:end_idx]

        # Raw log change (without drift correction)
        log_change = np.log(segment[-1] / segment[0])
        z_raw = log_change / np.sqrt(T)

        z_values.append(z_raw)

    return np.array(z_values)


# Show sample results
T_sample = 20
z_sample = simple_segment_analysis(prices, T_sample)

print(f"For T={T_sample} days:")
print(f"Number of segments: {len(z_sample)}")
print(f"z_values range: {np.min(z_sample):.4f} to {np.max(z_sample):.4f}")
print(f"Mean z_value: {np.mean(z_sample):.4f}")
print(f"Std z_value: {np.std(z_sample):.4f}")

print("\nTo see the full drift-corrected results, run the complete notebook!")
