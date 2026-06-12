#!/bin/zsh

# MARK: Formatting
BOLD="$(tput bold 2>/dev/null || echo '')"
GREEN="$(tput setaf 2 2>/dev/null || echo '')"
CYAN="$(tput setaf 6 2>/dev/null || echo '')"
RED="$(tput setaf 1 2>/dev/null || echo '')"
RESET_FORMATTING="$(tput sgr0 2>/dev/null || echo '')"

# MARK: Default Inputs
PACKAGE=""
CONFIG="release"
PLATFORM="ios"

PACKAGE_SET=false
CONFIG_SET=false
PLATFORM_SET=false

# MARK: Flag Parsing Loop
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--package)
      PACKAGE="$2"
      PACKAGE_SET=true
      shift 2
      ;;
    -c|--config)
      CONFIG="$2"
      CONFIG_SET=true
      shift 2
      ;;
    -l|--platform)
      PLATFORM="$2"
      PLATFORM_SET=true
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./build.sh <package_name> [options]"
      echo "Options:"
      echo "  -p, --package <name>    Package/plugin directory to build"
      echo "  -c, --config <type>     Build configuration: debug, release (Default: release)"
      echo "  -l, --platform <name>   Platform: macos, ios, simulator, all (Default: all)"
      exit 0
      ;;
    *)
      # Fallback to positional arguments if not a flag
      if [[ "$PACKAGE_SET" == false ]]; then
        PACKAGE="$1"
        PACKAGE_SET=true
      elif [[ "$CONFIG_SET" == false ]]; then
        CONFIG="$1"
        CONFIG_SET=true
      elif [[ "$PLATFORM_SET" == false ]]; then
        PLATFORM="$1"
        PLATFORM_SET=true
      fi
      shift
      ;;
  esac
done

if [[ -z "$PACKAGE" ]]; then
    echo "${BOLD}${RED}Error: Package name is required.${RESET_FORMATTING}"
    echo "Usage: ./build.sh <package_name> [options]"
    exit 1
fi

if [[ ! -d "$PACKAGE" ]]; then
    echo "${BOLD}${RED}Error: Package directory '$PACKAGE' does not exist.${RESET_FORMATTING}"
    exit 1
fi

PACKAGE_PATH="$PACKAGE/Swift"

# MARK: Settings
BINARY_PATH_IOS="Bin/ios"
BUILD_PATH_IOS=".build/arm64-apple-ios"

BINARY_PATH_MACOS="Bin/macos"
BUILD_PATH_MACOS=".build"

COPY_COMMANDS=()

# MARK: Build iOS
build_ios() {
	destination="generic/platform=iOS"
	device="iphoneos"
	if [[ $3 == "simulator" ]]; then
		destination="generic/platform=iOS Simulator"
		device="iphonesimulator"
	fi

	xcodebuild \
		-scheme "$1"  \
		-destination "$destination" \
		-derivedDataPath "$BUILD_PATH_IOS" \
		-clonedSourcePackagesDirPath ".build" \
		-configuration "$2" \
		-skipPackagePluginValidation \
		-skipMacroValidation \
		-quiet

	if [[ $? -gt 0 ]]; then
		echo "${BOLD}${RED}Failed to build $target iOS library${RESET_FORMATTING}"
		return 1
	fi

	echo "${BOLD}${GREEN}iOS build succeeded${RESET_FORMATTING}"

	product_path="$BUILD_PATH_IOS/Build/Products/$2-$device/PackageFrameworks"
	source_path="Sources"
	for source in $source_path/*; do
		COPY_COMMANDS+=("cp -af ""$product_path/$source:t:r.framework ""$BINARY_PATH_IOS")
	done
	
	COPY_COMMANDS+=("cp -af ""$product_path/SwiftGodot.framework ""$BINARY_PATH_IOS")

	return 0
}

# MARK: Build macOS
build_macos() {
	swift build \
		--configuration "$1" \
		--scratch-path "$BUILD_PATH_MACOS" \
		--quiet

	if [[ $? -gt 0 ]]; then
		echo "${BOLD}${RED}Failed to build macOS library${RESET_FORMATTING}"
		return 1
	fi

	echo "${BOLD}${GREEN}macOS build succeeded${RESET_FORMATTING}"

	if [[ $(uname -m) == "x86_64" ]]; then
		product_path="$BUILD_PATH_MACOS/x86_64-apple-macosx/$1"
	else
		product_path="$BUILD_PATH_MACOS/arm64-apple-macosx/$1"
	fi
 
	source_path="Sources"
	for folder in $source_path/*
	do
		COPY_COMMANDS+=("cp -af $product_path/lib$folder:t:r.dylib $BINARY_PATH_MACOS")
	done

	COPY_COMMANDS+=("cp -af $product_path/libSwiftGodot.dylib $BINARY_PATH_MACOS")
	
	return 0
}

# MARK: Pre & Post process
build_libs() {
	echo "Building libraries..."
	
	# Move to the package Swift directory safely
	cd "$PACKAGE_PATH" || {
		echo "${BOLD}${RED}Error: Failed to enter directory $PACKAGE_PATH${RESET_FORMATTING}"
		return 1
	}

	if [[ "$3" == "all" || "$3" == "macos" ]]; then
		echo "${BOLD}${CYAN}Building macOS library ($2)...${RESET_FORMATTING}"
		build_macos "$2"
	fi

	if [[ "$3" == "all" || "$3" == "ios" || "$3" == "simulator" ]]; then
		echo "${BOLD}${CYAN}Building iOS libraries ($2)...${RESET_FORMATTING}"
		build_ios "$1" "$2" "$3"
	fi

	# Set up framework copy targets to Godot demo addons directory if they exist
	if [[ -d "Bin/ios" ]]; then
		COPY_COMMANDS+=("cp -R Bin/ios ../Godot/addons/iosplugins")
	fi
	if [[ -d "Bin/macos" ]]; then
		COPY_COMMANDS+=("cp -R Bin/macos ../Godot/addons/iosplugins")
	fi

	if [[ ${#COPY_COMMANDS[@]} -gt 0 ]]; then
		echo "${BOLD}${CYAN}Copying binaries...${RESET_FORMATTING}"
		for instruction in "${COPY_COMMANDS[@]}"
		do
			target=${instruction##* }
			if ! [[ -e "$target" ]]; then
				mkdir -p "$target"
			fi
			eval $instruction
		done
	fi

	# Clean up temporary build artifacts to save disk space
	echo "${BOLD}${CYAN}Cleaning up temporary build files...${RESET_FORMATTING}"
	rm -rf .build Bin Package.resolved

	# Return to the original directory
	cd - > /dev/null

	echo "${BOLD}${GREEN}Finished building $2 libraries for $3 platforms${RESET_FORMATTING}"
}

# MARK: Run
build_libs "$PACKAGE" "$CONFIG" "$PLATFORM"
