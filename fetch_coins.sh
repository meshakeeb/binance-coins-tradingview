#!/bin/bash

# Binance API Endpoints
SPOT_URL="https://api.binance.com/api/v3/exchangeInfo"
FUTURES_URL="https://fapi.binance.com/fapi/v1/exchangeInfo"

# Output files (TradingView format)
SPOT_FILE="binance_usdt_coins_spot.txt"
FUTURES_FILE="binance_usdt_coins_futures.txt"

# Function to fetch SPOT trading pairs
fetch_spot() {
    echo "Fetching SPOT trading pairs..."
    curl -s "$SPOT_URL" | jq -r '.symbols[] | select(.quoteAsset=="USDT" and .status=="TRADING") | .symbol' | awk '{print "BINANCE:"$1}' > "$SPOT_FILE"
}

# Function to fetch FUTURES trading pairs
fetch_futures() {
    echo "Fetching FUTURES trading pairs..."
    curl -s "$FUTURES_URL" | jq -r '.symbols[] | select(.quoteAsset=="USDT" and .contractType=="PERPETUAL") | .symbol' | sed 's/USDT$/USDTTPERP/' | awk '{print "BINANCE:"$1}' > "$FUTURES_FILE"
}

# Execute functions
fetch_spot
fetch_futures

# Output summary
echo "✅ Spot trading pairs saved to: $SPOT_FILE"
echo "✅ Futures trading pairs saved to: $FUTURES_FILE"
