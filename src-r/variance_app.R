library(shiny)
library(ggplot2)
library(gridExtra)

# Function to generate variance-dependent time series
generate_variance_dependent_series <- function(n_periods = 252, T = 1.0, sigma = 0.2, mu = 0.05, seed = 42) {
  set.seed(seed)
  
  dt <- T / n_periods
  
  # Initialize arrays
  log_prices <- numeric(n_periods + 1)
  prices <- numeric(n_periods + 1)
  prices[1] <- 100.0
  log_prices[1] <- log(prices[1])
  
  # Storage for analysis
  z_values <- numeric(n_periods)
  theoretical_vars <- numeric(n_periods)
  
  for (i in 1:n_periods) {
    # Calculate x (drift-corrected log price change)
    if (i == 1) {
      x <- 0
    } else {
      period_length <- min((i - 1) * dt, T)
      x <- log_prices[i] - log_prices[1] - mu * period_length
    }
    
    # Calculate z
    period_T <- min(i * dt, T)
    z <- if (period_T > 0) x / sqrt(period_T) else 0
    
    # Calculate variance for this step
    var_t <- sigma^2 + z^2 / 2
    std_t <- sqrt(var_t)
    
    # Generate return with this variance
    dW <- rnorm(1, mean = 0, sd = sqrt(dt))
    dlog_price <- mu * dt + std_t * dW
    
    log_prices[i + 1] <- log_prices[i] + dlog_price
    prices[i + 1] <- exp(log_prices[i + 1])
    
    # Store for analysis
    z_values[i] <- z
    theoretical_vars[i] <- var_t
  }
  
  list(
    prices = prices,
    log_prices = log_prices,
    z_values = z_values,
    theoretical_vars = theoretical_vars
  )
}

# UI
ui <- fluidPage(
  titlePanel("Variance-Dependent Time Series: Var = σ² + z²/2"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Model Parameters"),
      sliderInput("sigma", 
                  "Base Volatility (σ):",
                  min = 0.05, max = 0.5, value = 0.2, step = 0.05),
      sliderInput("mu",
                  "Drift (μ):",
                  min = -0.1, max = 0.2, value = 0.05, step = 0.01),
      sliderInput("T",
                  "Time Horizon (T):",
                  min = 0.25, max = 2.0, value = 1.0, step = 0.25),
      sliderInput("n_periods",
                  "Number of Periods:",
                  min = 50, max = 500, value = 252, step = 50),
      numericInput("seed",
                   "Random Seed:",
                   value = 42, min = 1, max = 10000),
      hr(),
      actionButton("generate", "Generate New Series", class = "btn-primary"),
      hr(),
      h4("Model Explanation"),
      p("This model generates a time series where variance depends on price movements:"),
      withMathJax(),
      helpText("$$\\text{Var} = \\sigma^2 + \\frac{z^2}{2}$$"),
      helpText("$$z = \\frac{x}{\\sqrt{T}}$$"),
      p("where x is the drift-corrected log price change."),
      br(),
      downloadButton("downloadData", "Download Data (CSV)")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Time Series", 
                 plotOutput("price_plot", height = "350px"),
                 plotOutput("logprice_plot", height = "350px")
        ),
        tabPanel("Variance Analysis",
                 plotOutput("z_plot", height = "350px"),
                 plotOutput("var_plot", height = "350px")
        ),
        tabPanel("Decomposition",
                 plotOutput("scatter_plot", height = "350px"),
                 plotOutput("decomp_plot", height = "350px")
        ),
        tabPanel("Statistics",
                 h3("Summary Statistics"),
                 verbatimTextOutput("stats_output")
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Reactive values to store the current simulation
  sim_data <- reactiveVal(NULL)
  
  # Generate initial series on startup
  observe({
    sim_data(generate_variance_dependent_series(
      n_periods = 252,
      T = 1.0,
      sigma = 0.2,
      mu = 0.05,
      seed = 42
    ))
  })
  
  # Generate new series when button is clicked
  observeEvent(input$generate, {
    sim_data(generate_variance_dependent_series(
      n_periods = input$n_periods,
      T = input$T,
      sigma = input$sigma,
      mu = input$mu,
      seed = input$seed
    ))
  })
  
  # Price plot
  output$price_plot <- renderPlot({
    req(sim_data())
    data <- sim_data()
    time <- seq(0, input$T, length.out = length(data$prices))
    df <- data.frame(time = time, price = data$prices)
    
    ggplot(df, aes(x = time, y = price)) +
      geom_line(color = "darkblue", linewidth = 1) +
      labs(title = "Simulated Price Path", x = "Time", y = "Price") +
      theme_minimal(base_size = 14) +
      theme(plot.title = element_text(face = "bold"))
  })
  
  # Log price plot
  output$logprice_plot <- renderPlot({
    req(sim_data())
    data <- sim_data()
    time <- seq(0, input$T, length.out = length(data$log_prices))
    df <- data.frame(time = time, log_price = data$log_prices)
    
    ggplot(df, aes(x = time, y = log_price)) +
      geom_line(color = "darkgreen", linewidth = 1) +
      labs(title = "Log Price Path", x = "Time", y = "Log Price") +
      theme_minimal(base_size = 14) +
      theme(plot.title = element_text(face = "bold"))
  })
  
  # Z values plot
  output$z_plot <- renderPlot({
    req(sim_data())
    data <- sim_data()
    time <- seq(input$T / input$n_periods, input$T, length.out = input$n_periods)
    df <- data.frame(time = time, z = data$z_values)
    
    ggplot(df, aes(x = time, y = z)) +
      geom_line(color = "darkred", linewidth = 1) +
      geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
      labs(title = "Standardized Drift-Corrected Move (z)", 
           x = "Time", y = "z = x/√T") +
      theme_minimal(base_size = 14) +
      theme(plot.title = element_text(face = "bold"))
  })
  
  # Variance plot
  output$var_plot <- renderPlot({
    req(sim_data())
    data <- sim_data()
    time <- seq(input$T / input$n_periods, input$T, length.out = input$n_periods)
    df <- data.frame(time = time, variance = data$theoretical_vars)
    
    ggplot(df, aes(x = time, y = variance)) +
      geom_line(color = "purple", linewidth = 1.2) +
      geom_hline(aes(yintercept = input$sigma^2, color = "σ²"), 
                 linetype = "dashed", linewidth = 1.2) +
      scale_color_manual(values = c("σ²" = "orange"), name = "") +
      labs(title = "Variance: σ² + z²/2", x = "Time", y = "Variance") +
      theme_minimal(base_size = 14) +
      theme(plot.title = element_text(face = "bold"),
            legend.position = "top")
  })
  
  # Scatter plot
  output$scatter_plot <- renderPlot({
    req(sim_data())
    data <- sim_data()
    z_squared <- data$z_values^2
    var_component <- z_squared / 2
    df <- data.frame(z_squared = z_squared, var_component = var_component)
    
    ggplot(df, aes(x = z_squared, y = var_component)) +
      geom_point(alpha = 0.5, size = 2) +
      geom_abline(slope = 0.5, intercept = 0, color = "red", 
                  linetype = "dashed", linewidth = 1.2) +
      labs(title = "Variance Component vs z²", 
           x = "z²", y = "z²/2 component") +
      theme_minimal(base_size = 14) +
      theme(plot.title = element_text(face = "bold"))
  })
  
  # Decomposition plot
  output$decomp_plot <- renderPlot({
    req(sim_data())
    data <- sim_data()
    time <- seq(input$T / input$n_periods, input$T, length.out = input$n_periods)
    base_var <- rep(input$sigma^2, input$n_periods)
    
    df <- data.frame(
      time = time,
      base = base_var,
      total = data$theoretical_vars,
      additional = data$theoretical_vars - base_var
    )
    
    ggplot(df) +
      geom_ribbon(aes(x = time, ymin = 0, ymax = base, fill = "Base: σ²"), alpha = 0.5) +
      geom_ribbon(aes(x = time, ymin = base, ymax = total, fill = "Additional: z²/2"), alpha = 0.5) +
      geom_line(aes(x = time, y = total, color = "Total Var"), linewidth = 1.2) +
      scale_fill_manual(values = c("Base: σ²" = "blue", "Additional: z²/2" = "red"), name = "") +
      scale_color_manual(values = c("Total Var" = "black"), name = "") +
      labs(title = "Variance Decomposition", x = "Time", y = "Variance") +
      theme_minimal(base_size = 14) +
      theme(plot.title = element_text(face = "bold"),
            legend.position = "top")
  })
  
  # Statistics output
  output$stats_output <- renderText({
    req(sim_data())
    data <- sim_data()
    
    initial_price <- data$prices[1]
    final_price <- data$prices[length(data$prices)]
    total_return <- (final_price / initial_price - 1) * 100
    log_return <- data$log_prices[length(data$log_prices)] - data$log_prices[1]
    
    paste0(
      "Model Parameters:\n",
      "  σ = ", input$sigma, "\n",
      "  μ = ", input$mu, "\n",
      "  T = ", input$T, "\n",
      "  Number of periods = ", input$n_periods, "\n\n",
      
      "Price Statistics:\n",
      "  Initial price: ", sprintf("%.2f", initial_price), "\n",
      "  Final price: ", sprintf("%.2f", final_price), "\n",
      "  Total return: ", sprintf("%.2f%%", total_return), "\n",
      "  Log return: ", sprintf("%.4f", log_return), "\n\n",
      
      "Variance Statistics:\n",
      "  Base variance (σ²): ", sprintf("%.4f", input$sigma^2), "\n",
      "  Mean realized variance: ", sprintf("%.4f", mean(data$theoretical_vars)), "\n",
      "  Min variance: ", sprintf("%.4f", min(data$theoretical_vars)), "\n",
      "  Max variance: ", sprintf("%.4f", max(data$theoretical_vars)), "\n\n",
      
      "Z Statistics:\n",
      "  Mean z value: ", sprintf("%.4f", mean(data$z_values)), "\n",
      "  Std of z values: ", sprintf("%.4f", sd(data$z_values)), "\n",
      "  Min z: ", sprintf("%.4f", min(data$z_values)), "\n",
      "  Max z: ", sprintf("%.4f", max(data$z_values))
    )
  })
  
  # Download handler
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("variance_timeseries_", Sys.Date(), ".csv")
    },
    content = function(file) {
      req(sim_data())
      data <- sim_data()
      time <- seq(0, input$T, length.out = length(data$prices))
      
      df <- data.frame(
        time = time,
        price = data$prices,
        log_price = data$log_prices,
        z_value = c(NA, data$z_values),
        variance = c(NA, data$theoretical_vars)
      )
      
      write.csv(df, file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
