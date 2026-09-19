# Makefile for building fastfetch for iOS jailbroken devices (arm64)
# Uses the provided ios.toolchain.cmake for cross-compilation

# Configuration
BUILD_DIR ?= build-ios
IOS_SDK_PATH ?= $(error IOS_SDK_PATH is not set. Export the path to your iPhoneOS SDK, e.g., export IOS_SDK_PATH=/path/to/iPhoneOS.sdk)
CMAKE_TOOLCHAIN_FILE := $(CURDIR)/ios.toolchain.cmake
CMAKE := cmake
CMAKE_BUILD_TYPE ?= Release
LD64_PATH ?= /usr/local/bin/ld64

# Check that IOS_SDK_PATH exists
ifneq ($(wildcard $(IOS_SDK_PATH)),)
else
$(error IOS_SDK_PATH does not exist: $(IOS_SDK_PATH))
endif

# Check for ld64
ifeq ($(wildcard $(LD64_PATH)),)
$(warning ld64 not found at $(LD64_PATH). Trying to find it in PATH...)
LD64_PATH := $(shell which ld64)
ifndef LD64_PATH
$(error ld64 not found. Please install ld64 (e.g., from cctools-port) and set LD64_PATH)
endif
endif

# Default target
.PHONY: all
all: $(BUILD_DIR)/fastfetch

# Create build directory and configure with CMake
$(BUILD_DIR)/fastfetch:
	@mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && \
	$(CMAKE) .. \
		-DCMAKE_TOOLCHAIN_FILE=$(CMAKE_TOOLCHAIN_FILE) \
		-DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE)
	$(MAKE) -C $(BUILD_DIR) all

# Clean build
.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)
	@rm -f CMakeCache.txt
	@rm -rf CMakeFiles

# Reconfigure and rebuild
.PHONY: reconfigure
reconfigure: clean all

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all        - Build fastfetch (default)"
	@echo "  clean      - Remove build directory"
	@echo "  reconfigure - Rebuild from scratch"
	@echo "  install    - Install binary to \$(DESTDIR)/usr/local/bin"
	@echo ""
	@echo "Variables:"
	@echo "  IOS_SDK_PATH   - Path to iPhoneOS SDK (required)"
	@echo "  BUILD_DIR      - Build directory (default: build-ios)"
	@echo "  CMAKE_BUILD_TYPE - Build type (default: Release)"
	@echo "  LD64_PATH      - Path to ld64 linker (default: /usr/bin/ld64)"
	@echo ""
	@echo "Example usage:"
	@echo "  export IOS_SDK_PATH=/opt/iPhoneOS16.5.sdk"
	@echo "  make"
	@echo "  make install DESTDIR=/path/to/staging"
	@echo ""
	@echo "To build for a different iOS version (e.g., iOS 9):"
	@echo "  # Modify ios.toolchain.cmake to set the target iphoneos version"
	@echo "  # Or override the CMAKE_OSX_DEPLOYMENT_TARGET if supported"
	@echo "  make"