# Keystone 3 Firmware Development Makefile

# Python environment
PYTHON := ~/.pyenv/versions/keystone/bin/python

# Ensure cargo is in PATH
SHELL := /bin/bash
export PATH := $(HOME)/.cargo/bin:$(PATH)

# Asset paths
ASSETS_DIR := ui_simulator/assets
DEVICE_SETTINGS := $(ASSETS_DIR)/device_setting.json

.PHONY: help build start stop restart clean status init-assets

help: ## Show this help message
	@echo "Keystone 3 Firmware Simulator Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

init-assets: ## Initialize simulator assets (required before first run)
	@echo "Initializing simulator assets..."
	@mkdir -p $(ASSETS_DIR)/sd
	@if [ ! -f $(DEVICE_SETTINGS) ]; then \
		echo '{"version":"1.0.0","setup_step":20,"bright":15,"auto_lock_screen":60,"auto_power_off":0,"vibration":1,"random_pin_pad":0,"permit_sign":0,"dark_mode":1,"usb_switch":1,"last_version":0,"language":0,"nftEnable":false,"nftValid":false,"enableBlindSigning":false}' > $(DEVICE_SETTINGS); \
		echo "Created $(DEVICE_SETTINGS)"; \
	else \
		echo "$(DEVICE_SETTINGS) already exists"; \
	fi
	@touch $(ASSETS_DIR)/qrcode_data.txt
	@echo "Assets initialized"

build: ## Build the simulator
	@echo "Building simulator..."
	$(PYTHON) build.py -o simulator

start: init-assets ## Start the simulator
	@echo "Starting Keystone simulator..."
	@./build/simulator

stop: ## Stop the simulator
	@echo "Stopping simulator..."
	@pkill -9 -f "./simulator" 2>/dev/null || echo "No simulator running"

restart: stop start ## Restart the simulator

status: ## Check if simulator is running
	@ps aux | grep "./simulator" | grep -v grep || echo "Simulator is not running"

clean: ## Clean build directory
	@echo "Cleaning build directory..."
	@rm -rf build
	@echo "Done"

reset-assets: ## Reset simulator assets to defaults
	@echo "Resetting simulator assets..."
	@rm -f $(ASSETS_DIR)/*.json
	@$(MAKE) init-assets

reset-wallet: ## Reset wallet data (keeps device settings, clears user data)
	@echo "Resetting wallet data..."
	@rm -f $(ASSETS_DIR)/user*.json $(ASSETS_DIR)/coin*.json 2>/dev/null || true
	@echo '{"version":"1.0.0","setup_step":0,"bright":15,"auto_lock_screen":60,"auto_power_off":0,"vibration":1,"random_pin_pad":0,"permit_sign":0,"dark_mode":1,"usb_switch":1,"last_version":0,"language":0,"nftEnable":false,"nftValid":false,"enableBlindSigning":false}' > $(DEVICE_SETTINGS)
	@echo "Wallet data reset. Run 'make start' to begin fresh setup."

rebuild: clean build ## Clean and rebuild the simulator
