#!/bin/bash

# Binance API Endpoints
SPOT_URL="https://api.scraperapi.com/?api_key=d743bbf53ec96daf87a53831deddf632&url=https%3A%2F%2Fapi.binance.com%2Fapi%2Fv3%2FexchangeInfo"
FUTURES_URL="https://api.scraperapi.com/?api_key=d743bbf53ec96daf87a53831deddf632&url=https%3A%2F%2Ffapi.binance.com%2Ffapi%2Fv1%2FexchangeInfo"

# Output files (TradingView format)
SPOT_FILE="binance_usdt_coins_spot.txt"
FUTURES_FILE="binance_usdt_coins_futures.txt"

# Function to fetch SPOT trading pairs
fetch_spot() {
    echo "Fetching SPOT trading pairs..."
    response=$(curl -s "$SPOT_URL")

    if [ -z "$response" ] || [ "$(echo "$response" | jq '.symbols // empty')" == "" ]; then
        echo "⚠️ Failed to fetch SPOT trading pairs or no symbols returned."
        echo "Raw response: $response"
        return 1
    fi

    echo "$response" | jq -r '.symbols[] | select(.quoteAsset=="USDT" and .status=="TRADING") | .symbol' \
        | sort \
        | awk '{print "BINANCE:"$1}' > "$SPOT_FILE"
}

# Function to fetch FUTURES trading pairs
fetch_futures() {
    echo "Fetching FUTURES trading pairs..."
    response=$(curl -s "$FUTURES_URL")

    if [ -z "$response" ] || [ "$(echo "$response" | jq '.symbols // empty')" == "" ]; then
        echo "⚠️ Failed to fetch FUTURES trading pairs or no symbols returned."
        echo "Raw response: $response"
        return 1
    fi

    echo "$response" | jq -r '.symbols[] | select(.quoteAsset=="USDT" and .contractType=="PERPETUAL") | .symbol' \
        | sed 's/USDT$/USDT.P/' \
        | sort \
        | awk '{print "BINANCE:"$1}' > "$FUTURES_FILE"
}

# Execute functions
fetch_spot
fetch_futures

# Output summary
[ -f "$SPOT_FILE" ] && echo "✅ Spot trading pairs saved to: $SPOT_FILE"
[ -f "$FUTURES_FILE" ] && echo "✅ Futures trading pairs saved to: $FUTURES_FILE"
