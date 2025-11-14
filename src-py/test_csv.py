import pandas as pd
import numpy as np

# Try reading with quote handling
try:
    df = pd.read_csv("indexSP500.csv", quotechar='"', header=0)
    print("Successfully read with quote handling")
    print("Columns:", list(df.columns))
    print("Shape:", df.shape)
    print("\nFirst few rows:")
    print(df.head())

    # Extract prices for analysis
    prices = df["Close"].values
    print(f"\nPrices extracted: {len(prices)} values")
    print(f"Price range: {prices.min():.2f} to {prices.max():.2f}")

except Exception as e:
    print(f"Error: {e}")

    # Try manual parsing
    try:
        with open("indexSP500.csv", "r") as f:
            lines = f.readlines()

        # Parse manually
        data = []
        for line in lines[1:]:  # Skip header
            line = line.strip().strip('"')
            parts = line.split('","')
            if len(parts) == 7:
                data.append(parts)

        # Create DataFrame
        df = pd.DataFrame(
            data[1:],
            columns=["Date", "Open", "High", "Low", "Close", "Volume", "AdjClose"],
        )
        df["Close"] = pd.to_numeric(df["Close"])
        prices = df["Close"].values

        print("Successfully parsed manually")
        print("Shape:", len(prices))
        print("Price range:", prices.min(), "to", prices.max())

    except Exception as e2:
        print("Manual parsing also failed:", e2)
