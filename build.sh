#!/bin/zsh

# MARK: Help

# Syntax: ./build.sh [required] [all|release|debug] [all|macos|ios|simulator]"
# Valid configurations are: debug, release, all (Default: release)
# Valid platforms are: macos, ios & all (Default: all)

# examples:
# ./build.sh InAppPurchase release ios
# ./build.sh InAppPurchase debug macos 

# MARK: Settings
BINARY_PATH_IOS="Bin/ios"
BUILD_PATH_IOS=".build/arm64-apple-ios"

BINARY_PATH_MACOS="Bin/macos"
BUILD_PATH_MACOS=".build"

# MARK: Inputs

PACKAGE=$1
CONFIG=$2
PLATFORM=$3

if [[ ! $PACKAGE ]]; then
    PACKAGE="GameCenter"
fi

PACKAGE_PATH="$PACKAGE/Swift/"

if [[ ! $CONFIG ]]; then
	CONFIG="release"
fi

if [[ ! $PLATFORM ]]; then
	PLATFORM="all"
fi

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
	package_path
	if [[ "$3" == "all" || "$3" == "macos" ]]; then
		echo "${BOLD}${CYAN}Building macOS library ($2)...${RESET_FORMATTING}"
		build_macos "$2"
	fi

	if [[ "$3" == "all" || "$3" == "ios" || "$3" == "simulator" ]]; then
		echo "${BOLD}${CYAN}Building iOS libraries ($2)...${RESET_FORMATTING}"
		build_ios "$1" "$2" "$3"
	fi

	COPY_COMMANDS+=("cp -R Bin/ios ../Godot/addons/iosplugins")
	COPY_COMMANDS+=("cp -R Bin/macos ../Godot/addons/iosplugins")

	if [[ ${#COPY_COMMANDS[@]} -gt 0 ]]; then
		echo "${BOLD}${CYAN}Copying binaries...${RESET_FORMATTING}"
		for instruction in ${COPY_COMMANDS[@]}
		do
			target=${instruction##* }
			if ! [[ -e "$target" ]]; then
				mkdir -p "$target"
			fi
			eval $instruction
		done
	fi

	echo "${BOLD}${GREEN}Finished building $2 libraries for $3 platforms${RESET_FORMATTING}"
}

function package_path() {
    cd "$PACKAGE_PATH"
}

# MARK: Formatting
BOLD="$(tput bold)"
GREEN="$(tput setaf 2)"
CYAN="$(tput setaf 6)"
RED="$(tput setaf 1)"
RESET_FORMATTING="$(tput sgr0)"

# MARK: Run
build_libs "$PACKAGE" "$CONFIG" "$PLATFORM"
