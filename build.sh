#! /usr/bin/env sh

build_artifact=./bin/godot_macos_editor_jvm_0_14_3.app
install_location=/Applications/godot_jvm.app

build_godot_kotlin() {
    (
        cd ./modules/kotlin_jvm/kt
        gradle build
    )

}

build_godot_editor() {
    scons --no-cache  platform=macos arch=arm64 generate_bundle=yes
}

build() {
    build_godot_kotlin
    build_godot_editor
}


install() {
    if [ -e $build_artifact ]; then
        echo "Build artifact located at $build_artifact"

        if [ -e $install_location ]; then
            echo "Removing existing installation"
            rm -rf $install_location
        fi

        echo "Copying artifact to $install_location"
        cp -r $build_artifact $install_location
    fi
}


function_exists() {
    declare -f "$1" > /dev/null 2>&1
}


if [ $# -eq 0 ]; then
  # If no arguments are passed, call the default function
  build
else
    for arg in "$@"; do
    # Check if 'arg' corresponds to a function name within this script
    if function_exists "$arg"; then
        # Call the function if it exists
        "$arg"
    else
        echo "Function '$arg' does not exist."
    fi
    done
fi
