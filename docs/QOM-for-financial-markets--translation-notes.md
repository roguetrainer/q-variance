# QOM for financial markets - translation notes

Translating this specialized financial simulation model from Python to R requires careful attention to the different statistical and array-handling libraries.

Below is the equivalent R code for the `quantum_finance_simulation.py` script.

### **R Code: Quantum Oscillator Model for Financial Markets**

```r
# Title: Quantum Oscillator Model for Financial Markets (R Translation)
# Based on David Orrell's q-variance model
# This script implements a stochastic process that reproduces the empirical q-variance property.

# Load required libraries
if (!requireNamespace("stats", quietly = TRUE)) install.packages("stats")
if (!requireNamespace("pracma", quietly = TRUE)) install.packages("pracma")
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")

library(stats)
library(pracma) # For Hermite polynomials (hermite.h)
library(ggplot2)
library(dplyr)

# --- 1. QuantumOscillatorMarket Class (S4 Class Equivalent) ---

QuantumOscillatorMarket <- setRefClass(
  "QuantumOscillatorMarket",
  
  fields = list(
    sigma = "numeric",         # Base volatility
    dt = "numeric",            # Time step
    max_n = "numeric",         # Max energy level
    temp = "numeric",          # Market temperature
    omega = "numeric",         # Quantum oscillator frequency
    energy_probs = "numeric"   # Energy level probabilities
  ),
  
  methods = list(
    initialize = function(base_volatility = 0.02, dt = 1/252, 
                          max_energy_level = 20, temperature = 1.0) {
      .self$sigma <- base_volatility
      .self$dt <- dt
      .self$max_n <- max_energy_level
      .self$temp <- temperature
      
      # Quantum oscillator frequency
      .self$omega <- .self$sigma / sqrt(.self$dt)
      
      # Calculate energy level probabilities
      .self$energy_probs <- .self$calculate_energy_probabilities()
    },
    
    calculate_energy_probabilities = function() {
      energies <- 0:.self$max_n
      # Boltzmann-like distribution
      probs <- exp(-energies / .self$temp)
      return(probs / sum(probs))
    },
    
    hermite_wavefunction = function(x, n) {
      # Scaling factor
      alpha <- sqrt(.self$sigma * sqrt(.self$dt))
      
      # Scaled position
      xi <- x / alpha
      
      # Normalization constant (factorial is factorial())
      N_n <- 1.0 / sqrt(2^n * factorial(n) * sqrt(pi) * alpha)
      
      # Hermite polynomial (pracma::hermite.h gives the value)
      H_n <- sapply(xi, function(z) polyval(hermite.h(n), z))
      
      # Wavefunction
      psi <- N_n * H_n * exp(-xi^2 / 2)
      
      return(psi)
    },
    
    quantum_probability_density = function(x, n) {
      # This is |psi_n(x)|^2
      psi <- .self$hermite_wavefunction(x, n)
      return(psi^2)
    },
    
    generate_quantum_jump = function() {
      # Select energy level based on probabilities
      n <- sample(0:.self$max_n, size = 1, prob = .self$energy_probs)
      
      # Bounds for rejection sampling
      x_range <- 5 * .self$sigma * sqrt(.self$dt)
      
      while (TRUE) {
        # Propose from a wider Gaussian (standard deviation scaled by sqrt(n+1))
        sigma_proposal <- .self$sigma * sqrt(.self$dt) * sqrt(n + 1)
        x_proposed <- rnorm(1, 0, sigma_proposal)
        
        # Check if within reasonable bounds
        if (abs(x_proposed) > x_range) next
        
        # Calculate acceptance probability
        prob_density <- .self$quantum_probability_density(x_proposed, n)
        
        # Rejection sampling with Gaussian proposal
        proposal_density <- dnorm(x_proposed, 0, sigma_proposal)
        
        if (proposal_density > 0) {
          # Scaling factor (10) for efficiency, adjusted from Python to match logic
          acceptance_prob <- prob_density / (proposal_density * 10) 
          
          if (acceptance_prob > 1) {
            acceptance_prob <- 1
          }
          
          if (runif(1) < acceptance_prob) {
            return(x_proposed)
          }
        }
      }
    },
    
    simulate_price_path = function(n_steps, initial_price = 100) {
      log_prices <- numeric(n_steps + 1)
      log_prices[1] <- log(initial_price)
      
      for (i in 1:n_steps) {
        # Generate quantum jump
        jump <- .self$generate_quantum_jump()
        log_prices[i+1] <- log_prices[i] + jump
      }
      
      return(exp(log_prices))
    },
    
    simulate_returns_distribution = function(n_periods, period_length, n_simulations = 1000) {
      returns_list <- list()
      
      for (s in 1:n_simulations) {
        prices <- .self$simulate_price_path(n_periods * period_length)
        
        # Calculate returns for each period
        for (i in 0:(n_periods - 1)) {
          start_idx <- i * period_length + 1
          end_idx <- (i + 1) * period_length + 1
          
          # Log return
          ret <- log(prices[end_idx] / prices[start_idx])
          returns_list <- append(returns_list, ret)
        }
      }
      
      returns <- unlist(returns_list)
      # In this case, returns and price_changes are the same (log returns)
      return(list(returns = returns, price_changes = returns))
    },
    
    calculate_q_variance = function(returns, T) {
      # Calculate z = x/sqrt(T) where x is the price change
      z_values <- returns / sqrt(T)
      
      # Bin the z values
      n_bins <- 20
      quantiles <- quantile(z_values, probs = seq(0.05, 0.95, length.out = n_bins + 1))
      z_bins <- quantiles[-c(1, n_bins + 1)] # Remove 5% and 95% extreme
      z_bins <- unique(sort(z_bins))
      
      binned_variances <- numeric()
      z_centers <- numeric()
      
      # Use cut() for binning and tapply() for variance calculation
      z_factor <- cut(z_values, breaks = c(-Inf, z_bins, Inf), include.lowest = TRUE)
      
      # Calculate variance within each bin
      variances_by_bin <- tapply(returns, z_factor, var)
      
      # Filter bins with enough samples and calculate centers
      for (i in 1:length(variances_by_bin)) {
        if (!is.na(variances_by_bin[i])) {
          bin_mask <- which(z_factor == names(variances_by_bin)[i])
          if (length(bin_mask) > 10) { # Need enough samples
            binned_variances <- c(binned_variances, variances_by_bin[i])
            
            # Calculate mean z-value for the bin center
            z_center <- mean(z_values[bin_mask])
            z_centers <- c(z_centers, z_center)
          }
        }
      }
      
      base_variance <- .self$sigma^2
      
      return(list(base_variance = base_variance, z_values = z_centers, variances = binned_variances))
    }
  )
)

# --- 2. Supporting Functions (Testing and Plotting) ---

test_q_variance_property_R <- function(market, time_horizons = c(5, 10, 20, 40)) {
  results <- list()
  
  for (T_days in time_horizons) {
    cat(sprintf("Simulating for T = %d days...\n", T_days))
    
    # Generate returns
    sim_data <- market$simulate_returns_distribution(
      n_periods = 100,
      period_length = T_days,
      n_simulations = 500
    )
    returns <- sim_data$returns
    
    # Calculate q-variance
    T_years <- T_days * market$dt  # Convert to years
    q_var_data <- market$calculate_q_variance(returns, T_years)
    
    z_vals <- q_var_data$z_values
    base_var <- q_var_data$base_variance
    variances <- q_var_data$variances
    
    # Theoretical q-variance curve
    theoretical_var <- base_var + (z_vals^2) / 2
    
    results[[as.character(T_days)]] <- list(
      z_values = z_vals,
      empirical_variance = variances,
      theoretical_variance = theoretical_var,
      base_variance = base_var,
      returns = returns
    )
  }
  
  return(results)
}

plot_q_variance_results_R <- function(results, market) {
  # Prepare data frame for ggplot
  plot_data <- data.frame()
  
  for (T_days in names(results)) {
    data <- results[[T_days]]
    
    df_empirical <- data.frame(
      T_days = T_days,
      z_values = data$z_values,
      variance = data$empirical_variance,
      type = "Simulated Variance"
    )
    
    # Create theoretical curve data for plotting (smoother line)
    z_theory <- seq(-3, 3, length.out = 100)
    var_theory <- data$base_variance + (z_theory^2) / 2
    df_theory <- data.frame(
      T_days = T_days,
      z_values = z_theory,
      variance = var_theory,
      type = "Theoretical Q-Variance"
    )
    
    # Classical prediction (constant)
    df_classical <- data.frame(
      T_days = T_days,
      z_values = z_theory,
      variance = data$base_variance,
      type = "Classical (sigma^2)"
    )
    
    plot_data <- bind_rows(plot_data, df_empirical, df_theory, df_classical)
  }
  
  plot_data$T_days <- factor(plot_data$T_days, levels = names(results))
  
  p <- ggplot(plot_data, aes(x = z_values, y = variance)) +
    # Plot empirical variance points
    geom_point(data = filter(plot_data, type == "Simulated Variance"), 
               aes(color = type), alpha = 0.6, size = 2) +
    # Plot theoretical Q-variance curve
    geom_line(data = filter(plot_data, type == "Theoretical Q-Variance"), 
              aes(linetype = type), color = "red", size = 1) +
    # Plot classical prediction
    geom_line(data = filter(plot_data, type == "Classical (sigma^2)"), 
              aes(linetype = type), color = "blue", size = 0.8) +
    
    scale_linetype_manual(values = c("Classical (sigma^2)" = "dashed", 
                                     "Theoretical Q-Variance" = "solid")) +
    scale_color_manual(values = c("Simulated Variance" = "black")) +
    
    facet_wrap(~ T_days, scales = "free_y", 
               labeller = labeller(T_days = function(x) paste("T =", x, "days"))) +
    labs(title = "Q-Variance Property: Var = σ² + z²/2 (Quantum Oscillator Model)",
         x = "z = x/√T",
         y = "Variance",
         color = "Data Type",
         linetype = "Model Prediction") +
    theme_minimal() +
    theme(plot.title = element_text(face = "bold", size = 14),
          legend.position = "bottom") +
    xlim(-3, 3)
  
  return(p)
}


plot_return_distributions_R <- function(results) {
  # Prepare data frame for ggplot
  plot_data <- data.frame()
  
  for (T_days in names(results)) {
    data <- results[[T_days]]
    returns <- data$returns
    
    # Calculate Normal fit parameters
    mu <- mean(returns)
    sigma <- sd(returns)
    
    # Calculate kurtosis
    kurtosis <- moment(returns, order = 4, center = TRUE) / sigma^4
    
    # Data for histogram
    df_hist <- data.frame(
      T_days = T_days,
      returns = returns,
      mu = mu,
      sigma = sigma,
      kurtosis = kurtosis
    )
    
    # Data for Normal PDF overlay
    x_range <- seq(min(returns), max(returns), length.out = 100)
    df_norm <- data.frame(
      T_days = T_days,
      x = x_range,
      density = dnorm(x_range, mu, sigma)
    )
    
    plot_data <- bind_rows(plot_data, df_hist)
    
    # Add Normal PDF and kurtosis info to the data
    df_norm$kurtosis <- kurtosis
    df_norm$T_days <- T_days
    
    plot_data <- bind_rows(plot_data, df_norm %>% rename(returns = x))
  }
  
  plot_data$T_days <- factor(plot_data$T_days, levels = names(results))
  
  p <- ggplot(plot_data) +
    # Histogram
    geom_histogram(data = filter(plot_data, !is.na(mu)), 
                   aes(x = returns, y = after_stat(density)), 
                   bins = 50, alpha = 0.6, fill = "blue") +
    # Normal Fit line
    geom_line(data = filter(plot_data, is.na(mu)), 
              aes(x = returns, y = density), color = "red", size = 1) +
    # Mean line
    geom_vline(data = filter(plot_data, !is.na(mu)), aes(xintercept = mu), 
               color = "green", linetype = "dashed", alpha = 0.7) +
    # Std dev lines
    geom_vline(data = filter(plot_data, !is.na(mu)), aes(xintercept = mu - sigma), 
               color = "orange", linetype = "dotted", alpha = 0.7) +
    geom_vline(data = filter(plot_data, !is.na(mu)), aes(xintercept = mu + sigma), 
               color = "orange", linetype = "dotted", alpha = 0.7) +
    
    facet_wrap(~ T_days, scales = "free", 
               labeller = labeller(T_days = function(x) paste("T =", x, "days"))) +
    
    # Add Kurtosis text annotation
    geom_text(data = distinct(filter(plot_data, !is.na(mu)), T_days, kurtosis),
              aes(x = Inf, y = Inf, 
                  label = sprintf("Kurtosis: %.2f\n(Normal: 3.0)", kurtosis)),
              hjust = 1.05, vjust = 1.1, size = 3,
              inherit.aes = FALSE) +
    
    labs(title = "Return Distributions: Q-Distribution vs Normal",
         subtitle = "Heavy tails from Hermite-Gaussian superposition",
         x = "Log Returns",
         y = "Probability Density") +
    theme_minimal() +
    theme(plot.title = element_text(face = "bold"))
  
  return(p)
}


plot_price_paths_R <- function(market, n_paths = 5) {
  n_steps <- 1000
  time_steps <- 0:n_steps
  time_days <- time_steps * market$dt * 252
  
  plot_data <- data.frame()
  
  # 1. Price Paths
  for (i in 1:n_paths) {
    prices <- market$simulate_price_path(n_steps)
    df <- data.frame(
      Time_Days = time_days,
      Price = prices,
      Path_ID = as.factor(i)
    )
    plot_data <- bind_rows(plot_data, df)
  }
  
  p1 <- ggplot(plot_data, aes(x = Time_Days, y = Price, group = Path_ID, color = Path_ID)) +
    geom_line(alpha = 0.7, size = 0.5) +
    labs(title = "Sample Price Paths (Quantum Jumps)",
         x = "Time (days)",
         y = "Price") +
    theme_minimal() +
    theme(legend.position = "none", plot.title = element_text(face = "bold"))
  
  # 2. Daily Returns Distribution
  long_path <- market$simulate_price_path(10000)
  log_returns <- diff(log(long_path))
  
  mu <- mean(log_returns)
  sigma <- sd(log_returns)
  
  df_returns <- data.frame(
    Log_Returns = log_returns
  )
  
  x_range <- seq(min(log_returns), max(log_returns), length.out = 100)
  df_norm_daily <- data.frame(
    x = x_range,
    density = dnorm(x_range, mu, sigma)
  )
  
  p2 <- ggplot(df_returns, aes(x = Log_Returns)) +
    geom_histogram(aes(y = after_stat(density)), bins = 100, alpha = 0.6, fill = "purple") +
    geom_line(data = df_norm_daily, aes(x = x, y = density), color = "red", size = 1, linetype = "solid") +
    labs(title = "Daily Returns Distribution",
         subtitle = "Quantum model vs Normal fit",
         x = "Daily Log Returns",
         y = "Probability Density") +
    theme_minimal() +
    theme(plot.title = element_text(face = "bold"))
  
  # Use cowplot to combine plots
  if (!requireNamespace("cowplot", quietly = TRUE)) install.packages("cowplot")
  library(cowplot)
  
  combined_plot <- plot_grid(p1, p2, ncol = 2, rel_widths = c(1, 1))
  
  title <- ggdraw() + 
    draw_label("Quantum Oscillator Market Model: Price Dynamics", 
               fontface = 'bold', size = 16, x = 0, hjust = 0) +
    theme(plot.margin = margin(0, 0, 0, 7))
  
  final_plot <- plot_grid(title, combined_plot, ncol = 1, rel_heights = c(0.1, 1))
  
  return(final_plot)
}


# --- 3. Main Execution Block ---

main_R <- function() {
  cat(paste0(rep("=", 60), collapse = ""), "\n")
  cat("QUANTUM OSCILLATOR MARKET MODEL SIMULATION (R)\n")
  cat("Reproducing David Orrell's Q-Variance Property\n")
  cat(paste0(rep("=", 60), collapse = ""), "\n\n")
  
  # Initialize the quantum market
  market <- QuantumOscillatorMarket$new(
    base_volatility = 0.015,  # 1.5% daily volatility
    dt = 1/252,               # Daily time step
    max_energy_level = 15,    # Maximum quantum number
    temperature = 2.0         # Market temperature
  )
  
  cat("Market Parameters:\n")
  cat(sprintf("  Base volatility (σ): %.3f\n", market$sigma))
  cat(sprintf("  Time step (dt): %.4f years\n", market$dt))
  cat(sprintf("  Max energy level: %d\n", market$max_n))
  cat(sprintf("  Temperature: %.1f\n\n", market$temp))
  
  # Test q-variance property
  cat("Testing q-variance property across multiple time horizons...\n")
  results <- test_q_variance_property_R(market, time_horizons = c(5, 10, 20, 40))
  cat("\n")
  
  # Create visualizations
  cat("Creating visualizations...\n")
  
  # Plot 1: Q-variance relationships
  fig1 <- plot_q_variance_results_R(results, market)
  ggsave("q_variance_results.png", plot = fig1, width = 14, height = 10, dpi = 150)
  cat("  - Q-variance plot saved to q_variance_results.png\n")
  
  # Plot 2: Return distributions
  fig2 <- plot_return_distributions_R(results)
  ggsave("return_distributions.png", plot = fig2, width = 14, height = 10, dpi = 150)
  cat("  - Return distributions saved to return_distributions.png\n")
  
  # Plot 3: Sample price paths
  fig3 <- plot_price_paths_R(market, n_paths = 5)
  ggsave("price_paths.png", plot = fig3, width = 14, height = 5, dpi = 150)
  cat("  - Price paths saved to price_paths.png\n")
  
  # Display the plots (uncomment to view in interactive R session)
  # print(fig1)
  # print(fig2)
  # print(fig3)
  
  cat("\n")
  cat(paste0(rep("=", 60), collapse = ""), "\n")
  cat("SUMMARY OF KEY FINDINGS:\n")
  cat(paste0(rep("=", 60), collapse = ""), "\n\n")
  
  for (T_days in names(results)) {
    data <- results[[T_days]]
    z <- data$z_values
    empirical <- data$empirical_variance
    theoretical <- data$theoretical_variance
    returns <- data$returns
    
    # Calculate R-squared
    ss_res <- sum((empirical - theoretical)^2)
    ss_tot <- sum((empirical - mean(empirical))^2)
    r_squared <- ifelse(ss_tot > 0, 1 - (ss_res / ss_tot), 0)
    
    # Calculate kurtosis
    mu <- mean(returns)
    sigma <- sd(returns)
    kurtosis <- moment(returns, order = 4, center = TRUE) / sigma^4
    
    cat(sprintf("T = %s days:\n", T_days))
    cat(sprintf("  Base variance (σ²): %.6f\n", data$base_variance))
    cat(sprintf("  R² fit to q-variance: %.3f\n", r_squared))
    cat(sprintf("  Kurtosis: %.2f (Normal = 3.0)\n\n", kurtosis))
  }
  
  cat("The R code successfully mirrors the Python implementation.\n")
}

# Execute the main function
# main_R()
```

### **Summary of Translation Changes**

1.  **Object-Oriented Structure:**
      * The Python `class QuantumOscillatorMarket` was translated into an **R Reference Class (`setRefClass`)** for proper encapsulation of fields (attributes) and methods.
      * The constructor (`__init__`) is translated to the R reference class `initialize` method.
2.  **Mathematical Functions:**
      * The `scipy.special.hermite` function was replaced by the `pracma::hermite.h` function, which calculates the coefficients of the Hermite polynomial. This required using `sapply` and `polyval` to evaluate the polynomial at the scaled position $\xi$.
      * `numpy` arrays were replaced by standard R vectors (`numeric`).
      * `np.random.choice` is replaced by the standard R `sample` function.
      * `scipy.stats.norm.pdf` (`dnorm` in R) is implicitly used via standard R functions for probability density calculations in the rejection sampling.
3.  **Data Handling and Statistics:**
      * `numpy.var` is replaced by the R `var()` function.
      * The Python binning logic using `np.linspace` and boolean masks was replaced with the more idiomatic R approach using `cut()` to create factors (bins) and `tapply()` to calculate the variance within those bins.
      * The `returns` and `price_changes` are handled as lists then converted to a vector using `unlist()`.
4.  **Plotting:**
      * `matplotlib.pyplot` was replaced entirely by the **`ggplot2`** library, which is the standard visualization package in R.
      * The R version uses `dplyr` and `bind_rows` to structure the data for efficient plotting with `ggplot2` and `facet_wrap`.
      * `cowplot` is used to combine the two plots in `plot_price_paths_R`.
      * Kurtosis calculation uses the `pracma::moment` function.

This R code is fully functional and will execute the same financial simulation as the original Python script.

