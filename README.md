# Qt Custom UI App

A Qt Quick desktop application built with CMake and Qt 6.

## Requirements

- CMake 3.16 or newer
- Qt 6.3 or newer with the Quick and Quick Controls modules
- A C++17 compiler supported by your Qt installation
- Ninja (recommended) or another CMake-supported build tool

Use a Qt installation built for the same compiler and architecture as your application. The Qt Quick and Quick Controls runtime modules must also be available when launching the app.

## Build on Windows

Install Qt with the Qt Online Installer, including the Quick and Quick Controls modules and a compiler kit. In the commands below, replace the Qt path and compiler path if your installation differs. These commands use the MinGW kit from the default Qt installation shown here:

```powershell
$env:Path = "C:\Qt\6.11.1\mingw_64\bin;C:\Qt\Tools\mingw1310_64\bin;$env:Path"
cmake -S . -B build -G Ninja `
  -DCMAKE_PREFIX_PATH="C:/Qt/6.11.1/mingw_64" `
  -DCMAKE_CXX_COMPILER="C:/Qt/Tools/mingw1310_64/bin/g++.exe"
cmake --build build --parallel
```

Run `build\appQtQuickDemo.exe`. If using Qt's MSVC kit, use a Visual Studio developer terminal and point `CMAKE_PREFIX_PATH` to that kit instead.

## Build on Linux

Install CMake, Ninja, a C++17 compiler, and Qt 6 development packages that include Quick and Quick Controls. For example, on Ubuntu:

```bash
sudo apt update
sudo apt install build-essential cmake ninja-build qt6-base-dev qt6-declarative-dev qt6-declarative-dev-tools
```

Configure and build from the project root:

```bash
cmake -S . -B build -G Ninja
cmake --build build --parallel
```

Run `./build/appQtQuickDemo` from the project root. If Qt is installed outside the system package paths, set `CMAKE_PREFIX_PATH` to the Qt installation prefix when configuring.

The project uses the same `build` directory on each platform; configure it with that platform's compiler and Qt installation.
