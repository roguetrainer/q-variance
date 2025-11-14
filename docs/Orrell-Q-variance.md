# Orrell's quantum oscillator model & q-variance

Here is a short summary of David Orrell's Q-variance discovery, based on the provided documents and further research.

Orrell's Q-variance discovery is a specific, quantitative relationship between the **variance** of an asset's price change and the **size of the price change itself**. It is named "Q-variance" for both "quadratic" and "quantum," as it was first predicted using a quantum oscillator model *before* it was tested against data.

This finding directly challenges standard financial models (like Black-Scholes), which assume that volatility is independent of the price change.

### 📈 What He Predicts

Orrell's core prediction is that the expected variance of an asset's price change over a time period $T$ is not constant. Instead, it follows a simple quadratic formula based on the scaled price change.

* **The Prediction:** $V(z) = \sigma_0^2 + z^2/2$
* **The Variables:**
    * $V(z)$ is the expected variance.
    * $\sigma_0^2$ is the "base volatility," or the minimum variance of the process (the variance when the price change is zero).
    * $z = x / \sqrt{T}$, where $x$ is the log-return (price change) and $T$ is the time horizon. This $z$ variable scales the price change by the square root of time.

In simple terms, **the model predicts that periods with larger price changes (in either direction) will also have higher variance**.

### 📊 What He Observes Empirically

Orrell's empirical discovery is that this precise quadratic relationship holds true when tested against actual market data.

* **Excellent Agreement:** Tests on major stock market data show "excellent agreement" with the predicted $V(z) = \sigma_0^2 + z^2/2$ formula.
* **Multi-Scale Consistency:** The relationship is observed to hold true across all tested time scales, "be it a few days or a year". This is a key finding that is inconsistent with standard models.
* **Associated Distribution:** He also observes that the underlying probability distribution of price changes matches the one predicted by his model: a "Poisson-weighted sum of Gaussians", which is linked to a Poisson rate of $\lambda=0.5$.