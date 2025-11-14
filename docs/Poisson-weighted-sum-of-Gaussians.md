The distribution you're describing - a Poisson-weighted sum of Gaussians - does indeed appear in several areas of physics and has known connections in the literature. Let me explore this:

## The Distribution Structure

Based on the quantum oscillator model, the distribution can be written as:

$$f(x) = \sum_{n=0}^{\infty} P(n) \cdot G_n(x)$$

where:
- $P(n)$ follows a thermal/Boltzmann distribution: $P(n) \propto e^{-n/T}$
- $G_n(x)$ are Gaussian-like distributions modified by Hermite polynomials: $|ψ_n(x)|^2$

However, you're right that this resembles a **Poisson mixture of Gaussians** structure.

## Known Distributions in Physics

### 1. **Mandel's Q-Distribution (Quantum Optics)**

In quantum optics, there's a well-known distribution for photon counting statistics called the **Mandel Q-parameter distribution**. When dealing with thermal light sources, the photon number distribution is:

$$P(n) = \frac{\bar{n}^n}{(1+\bar{n})^{n+1}}$$

This gives rise to a super-Poissonian distribution that's a mixture of coherent states (which are Poisson-distributed) weighted by a thermal distribution.

### 2. **Thermal Coherent States**

In quantum mechanics, **thermal coherent states** produce distributions that are Poisson-weighted sums of Gaussians. The position distribution of a thermal harmonic oscillator is:

$$\rho(x) = \sum_{n=0}^{\infty} \frac{e^{-n\hbar\omega/k_BT}}{Z} |\psi_n(x)|^2$$

This is exactly the structure in Orrell's model! The thermal weights give a geometric/Boltzmann distribution rather than pure Poisson, but the mathematical structure is similar.

### 3. **Compound Poisson-Gaussian Distribution**

In probability theory, the **compound Poisson distribution** where the jumps are Gaussian-distributed gives:

$$f(x) = e^{-\lambda} \delta(x) + \sum_{n=1}^{\infty} \frac{e^{-\lambda}\lambda^n}{n!} \phi_n(x)$$

where $\phi_n$ is the n-fold convolution of a Gaussian with itself.

## Physical Systems Where This Arises

### 1. **Brownian Motion in a Harmonic Trap**

A Brownian particle in a harmonic potential well at thermal equilibrium exhibits exactly this distribution structure. The position distribution is a thermal mixture of quantum harmonic oscillator states.

### 2. **Laser Light Statistics**

The photon counting statistics of laser light near threshold shows similar behavior - a transition from thermal light (super-Poissonian) to coherent light (Poissonian) to sub-Poissonian.

### 3. **Molecular Vibrations**

The displacement distribution of molecular vibrations at finite temperature follows this pattern, with thermal population of vibrational energy levels.

## The Hermite-Gaussian Connection

The specific form with **Hermite-Gaussian functions** appears in:

### 1. **Edgeworth Expansion**
The Edgeworth series expands a distribution as:
$$f(x) = \phi(x)\left[1 + \sum_{n=3}^{\infty} \frac{\kappa_n}{n!}H_n(x)\right]$$
where $\phi(x)$ is Gaussian and $H_n$ are Hermite polynomials.

### 2. **Gram-Charlier Series**
Similar to Edgeworth, this expands distributions using Hermite polynomials as basis functions.

### 3. **Photon-Added Coherent States**
In quantum optics, photon-added coherent states have wavefunctions involving Hermite polynomials multiplied by Gaussians.

## What Makes Orrell's Application Unique

While the mathematical structure exists in physics, Orrell's innovation is:

1. **Economic Interpretation**: Quantizing entropic forces representing buyers' and sellers' intentions

2. **Q-Variance Discovery**: The specific relationship $\sigma^2 + z^2/2$ emerging from this distribution

3. **Scale Invariance**: The property holding across all time scales in financial data

## Literature Connections

The distribution type is known in:
- **Statistical Mechanics**: Thermal states of quantum oscillators (Pathria & Beale, "Statistical Mechanics")
- **Quantum Optics**: Mandel & Wolf, "Optical Coherence and Quantum Optics"
- **Probability Theory**: Compound distributions (Feller, "Introduction to Probability Theory")

## Mathematical Name

The closest formal name would be a **"Thermal Hermite-Gaussian Distribution"** or **"Quantum Harmonic Oscillator Thermal State Distribution"**. In quantum optics, similar distributions are called **"Thermal Coherent State Distributions"**.

## Conclusion

The distribution structure is **not new to physics** - it's well-known in quantum statistical mechanics and quantum optics. However, Orrell's contribution is:
1. Recognizing this distribution describes financial returns
2. Deriving the q-variance property from it
3. Providing empirical validation in market data

So while the mathematical form exists in physics literature, its application to finance and the discovery of the q-variance scaling law appears to be original to Orrell's work.