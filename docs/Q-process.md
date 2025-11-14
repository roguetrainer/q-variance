

## Mathematical Definition of the Orrell Quantum Oscillator Stochastic "Q-Process"

### 1. **State Space and Basic Setup**

Let $S_t$ denote the asset price at time $t$, and define the log-price process:
$$X_t = \log S_t$$

The process evolves through discrete quantum jumps at times $\{t_k\}_{k=0}^{\infty}$ where $t_{k+1} - t_k = \Delta t$.

### 2. **Quantum State Representation**

The system is described by a quantum harmonic oscillator with:
- **Energy levels**: $n \in \{0, 1, 2, \ldots, n_{\max}\}$
- **Wave functions**: 
$$\psi_n(x) = N_n H_n\left(\frac{x}{\alpha}\right) \exp\left(-\frac{x^2}{2\alpha^2}\right)$$

where:
- $H_n$ is the $n$-th Hermite polynomial
- $\alpha = \sqrt{\sigma\sqrt{\Delta t}}$ is the scaling parameter
- $N_n = \frac{1}{\sqrt{2^n n! \sqrt{\pi} \alpha}}$ is the normalization constant

### 3. **Energy Level Distribution**

The probability of the system being in energy level $n$ follows a thermal distribution:
$$P(n) = \frac{e^{-n/T}}{\sum_{k=0}^{n_{\max}} e^{-k/T}}$$

where $T$ is the market "temperature" parameter.

### 4. **The Q-Distribution**

The probability density for a price change $\Delta x$ is given by the **q-distribution**:
$$f_Q(\Delta x) = \sum_{n=0}^{n_{\max}} P(n) \cdot |\psi_n(\Delta x)|^2$$

This is a weighted superposition of squared quantum wavefunctions, which can be written explicitly as:
$$f_Q(\Delta x) = \sum_{n=0}^{n_{\max}} P(n) \cdot N_n^2 \cdot H_n^2\left(\frac{\Delta x}{\alpha}\right) \cdot \exp\left(-\frac{\Delta x^2}{\alpha^2}\right)$$

### 5. **The Jump Process**

The log-price process evolves as a pure jump process:
$$X_{t+\Delta t} = X_t + J_t$$

where $J_t$ is a quantum jump with distribution:
$$J_t \sim f_Q(\cdot)$$

### 6. **Full Stochastic Process Definition**

The complete stochastic process can be defined as:

$$\boxed{dX_t = dN_t \cdot J_t}$$

where:
- $N_t$ is a Poisson process with intensity $\lambda = 1/\Delta t$
- $J_t$ are i.i.d. random variables distributed according to $f_Q$
- The jumps $J_t$ are independent of the Poisson process $N_t$

### 7. **Conditional Variance Structure (Q-Variance)**

The key property of this process is that the conditional variance over period $T$ given a price change $x$ follows:
$$\text{Var}[X_{t+T} - X_t \mid X_{t+T} - X_t = x] = \sigma^2 + \frac{z^2}{2}$$

where $z = \frac{x}{\sqrt{T}}$.

### 8. **Moments and Characteristic Function**

The characteristic function of the increment $\Delta X_t = X_{t+\Delta t} - X_t$ is:
$$\phi_{\Delta X}(u) = \mathbb{E}[e^{iu\Delta X}] = \sum_{n=0}^{n_{\max}} P(n) \cdot \phi_n(u)$$

where $\phi_n(u)$ is the Fourier transform of $|\psi_n(x)|^2$:
$$\phi_n(u) = \int_{-\infty}^{\infty} e^{iux} |\psi_n(x)|^2 dx$$

### 9. **Key Properties**

The process exhibits:

1. **Heavy tails**: The kurtosis exceeds 3 due to the Hermite polynomial structure
   $$\text{Kurt}[\Delta X_t] > 3$$

2. **Scale invariance**: The q-variance relationship holds for all time scales
   $$\text{Var}[\Delta X_T | \Delta X_T = x] = \sigma^2 + \frac{x^2}{2T} \quad \forall T > 0$$

3. **Minimum volatility**: Even at $n=0$, there is non-zero variance
   $$\text{Var}[\Delta X_t] \geq \sigma^2 \Delta t > 0$$

4. **Discrete energy quantization**: Price changes occur through transitions between discrete energy levels

### 10. **Comparison with Classical Processes**

Unlike classical processes:
- **Brownian motion**: $dX_t = \mu dt + \sigma dW_t$ (continuous, Gaussian)
- **Jump-diffusion**: $dX_t = \mu dt + \sigma dW_t + J dN_t$ (mixed continuous-jump)

The quantum process is:
- **Pure jump**: No continuous component
- **Non-Lévy**: Does not satisfy infinite divisibility
- **Quantum superposition**: Jumps are drawn from a superposition of quantum states
- **Energy-dependent**: Jump size distribution depends on quantum energy levels

### 11. **Entropic Force Interpretation**

The process can be viewed as driven by entropic forces:
$$F(x) = -\frac{\partial V(x)}{\partial x}$$

where $V(x) = \frac{1}{2}m\omega^2 x^2$ is the harmonic potential, with:
- $m$ representing market "inertia"
- $\omega = \sigma/\sqrt{\Delta t}$ as the oscillator frequency

This provides a physical interpretation where price movements are resisted by entropic forces that increase with displacement from equilibrium.