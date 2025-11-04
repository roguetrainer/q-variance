#!/bin/bash
set -e

echo "--- Python Virtual Environment Setup Script ---"

# 1. Create the requirements.txt file
echo "Creating requirements.txt..."
cat << EOF > requirements.txt
numpy
matplotlib
scipy
pandas
EOF

# 2. Check for Python 3
# Comment out or modify the alias as necessary
alias python3='/usr/local/bin/python3' 

if ! command -v python3 &> /dev/null
then
    echo "Error: python3 is not installed or not in PATH."
    echo "Please install Python 3 to continue."
    exit 1
fi

echo "Found python3 installation."

# 3. Create the virtual environment
VENV_NAME="venv"
if [ -d "$VENV_NAME" ]; then
    echo "Virtual environment '$VENV_NAME' already exists. Skipping creation."
else
    echo "Creating virtual environment named '$VENV_NAME'..."
    python3 -m venv $VENV_NAME
fi

# 4. Activate the virtual environment and install packages
echo "Activating virtual environment..."
source $VENV_NAME/bin/activate

echo "Installing required packages from requirements.txt..."
pip install -r requirements.txt

echo "---"
echo "✅ Setup Complete!"
echo "---"
echo ""
echo "To activate the virtual environment in your terminal, run:"
echo "source $VENV_NAME/bin/activate"
echo ""
echo "After activation, you can run your script with:"
echo "python quantum_finance_simulation.py"
