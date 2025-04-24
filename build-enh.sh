#!/bin/bash

# Function to clean the build artifacts for a given platform and package directory
clean_package() {
  local package_dir=$1
  local platform=$2

  case "$platform" in
    "macos" | "linux" | "windows" | "android")
      swift package clean
      ;;
    "ios")
      xcodebuild clean -scheme "MyScheme" -archivePath "MyArchive"
      ;;
    *)
      echo "Can't clean directory for: $platform"
      return 1
      ;;
  esac
}


# Function to build a specific package for a given platform and configuration
build_package() {
  local package_name=$1
  local platform=$2
  local configuration=$3

  echo "Building ${BOLD}$configuration${RESET_FORMATTING} for ${BOLD}$package_name${RESET_FORMATTING} on ${BOLD}$platform${RESET_FORMATTING}"

  # Determine output directory and extension based on platform
  output_dir="bin/$platform"
  case "$platform" in
    "macos")
      extension=".dylib"
      ;;
    "linux")
      extension=".so"
      ;;
    "windows")
      extension=".dll"
      ;;
    "ios")
      extension=".framework"
      ;;
    "android")
      extension=".so"
      ;;
    *)
      echo "Can't derive the extension for: $platform"
      return 1
      ;;
  esac

  suffix=""
  if [[ $configuration == "debug" ]]; then
    suffix="-debug"
  fi

  # Create output directory if it doesn't exist
  mkdir -p "$output_dir"
  case "$platform" in
    "macos")
      swift build --configuration $configuration
      if [[ $(uname -m) == "x86_64" ]]; then
        library_path=".build/x86_64-apple-macosx/$configuration"
      else
        library_path=".build/arm64-apple-macosx/$configuration"
      fi
      # Move the built dylib to the output directory (using package_name)
      cp ".build/$configuration/lib$package_name.dylib" "$output_dir/lib$package_name$suffix$extension"
      cp "$library_path/libSwiftGodot$extension" "$output_dir/libSwiftGodot$suffix$extension"
      ;;
    "linux")
      # it requires docker
      # brew install --cask docker 
      docker run \
          --name swift-linux-container \
          -v "$PWD:/src" \
          -w /src \
          swift:6.0.3 \
          swift build --configuration $configuration
      # Move the built so to the output directory (using package_name)
      cp ".build/aarch64-unknown-linux-gnu/$configuration/lib$package_name.so"  "$output_dir/$package_name$suffix$extension"
      cp ".build/aarch64-unknown-linux-gnu/$configuration/libSwiftGodot.so"  "$output_dir/libSwiftGodot$suffix$extension"
      docker rm swift-linux-container 
      ;;
    "windows")
      # it requires docker
      # brew install --cask docker 
      docker run \
          --name swift-linux-container \
          -v "$PWD:/src" \
          -w /src \
          swift:6.0.3-windows \
          swift build --configuration $configuration
      # Move the built dll to the output directory (using package_name)
      # cp ".build/$configuration/$package_name.dll" "$output_dir/$package_name$suffix$extension"
      ;;
    "ios")
      # Use xcodebuild to build the framework for iOS
      # -derivedDataPath ".build/arm64-apple-ios" \
		  # -clonedSourcePackagesDirPath ".build" \
      #
      # -archivePath ".build/$package_name" archive \

      xcodebuild \
          -scheme "$package_name" \
          -destination "generic/platform=iOS" \
          -derivedDataPath ".build/arm64-apple-ios" \
		      -clonedSourcePackagesDirPath ".build" \
          -configuration "$configuration"	\
          -skipPackagePluginValidation \
		      -quiet

      if [[ $? -gt 0 ]]; then
        echo "${BOLD}${RED}Failed to build $target iOS library${RESET_FORMATTING}"
        return 1
      fi

      archive_path=".build/arm64-apple-ios/Build/Products/$configuration-iphoneos/PackageFrameworks"
      #archive_path=".build/$package_name.xcarchive/Products/usr/local/lib"
      cp -af "$archive_path/$package_name.framework" "$output_dir/$package_name$suffix$extension"
      cp -af "$archive_path/SwiftGodot.framework" "$output_dir/SwiftGodot$suffix$extension"
      ;;
    "android")
      export PATH="/path/to/your/android/toolchain/bin:$PATH" 
      swift build --configuration $configuration --destination "generic/platform=android"
      # You'll need to add code here to:
      # 1. Locate the built .so file
      # 2. Move the .so file to the output directory
      ;;
    *)
      echo "Unsupported platform: $platform"
      return 1
      ;;
  esac
  echo "${BOLD}${GREEN}Finished building $configuration libraries for $platform platform${RESET_FORMATTING}"

}

# MARK: Formatting
BOLD="$(tput bold)"
GREEN="$(tput setaf 2)"
CYAN="$(tput setaf 6)"
RED="$(tput setaf 1)"
RESET_FORMATTING="$(tput sgr0)"

# Get the package name from the command line argument
package_name=$1
shift # Shift arguments to remove the package name

# Set default values for optional parameters
platforms=("macos" "linux" "windows" "ios" "android") # Default to all platforms
configurations=("release") # Default to release configuration

# Parse the platform and configuration options
while [[ $# -gt 0 ]]; do
  case "$1" in
    --os=*)
      IFS='=' read -r _ os <<< "$1"
      if [[ "$os" == "all" ]]; then
        platforms=("macos" "linux" "windows" "ios" "android")
      else
        platforms=("$os") # Override the default with the specified platform(s)
      fi
      ;;
    --config=*)
      IFS='=' read -r _ config <<< "$1"
      if [[ "$config" == "all" ]]; then
        configurations=("release" "debug")
      else
        configurations=("$config") # Override the default with the specified configuration(s)
      fi
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

pushd "$package_name/Swift" > /dev/null

# Build the specified package for the selected platforms and configurations
for configuration in "${configurations[@]}"; do
  for platform in "${platforms[@]}"; do
    # Clean up any existing build artifacts before building
    # clean_package "$package_name" "$platform"

    build_package "$package_name" "$platform" "$configuration"

    # Clean up any remaining build artifacts after all builds are complete
    # clean_package "$package_name" "$platform"
  done
done



popd > /dev/null