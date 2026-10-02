# Qt Custom UI App

A Qt Quick desktop application built with CMake and Qt 6.

## Requirements

- CMake
- Qt 6.11.1 for MinGW 64-bit, installed at `C:\Qt\6.11.1\mingw_64`
- MinGW 13.1.0, installed at `C:\Qt\Tools\mingw1310_64\bin`

Make sure the MinGW and Qt `bin` directories are available in `PATH`.

## Build

Run these commands from the project root in PowerShell:

```powershell
cmake -S . -B build -G "MinGW Makefiles" `
  -DCMAKE_PREFIX_PATH="C:/Qt/6.11.1/mingw_64" `
  -DCMAKE_MAKE_PROGRAM="C:/Qt/Tools/mingw1310_64/bin/mingw32-make.exe" `
  -DCMAKE_CXX_COMPILER="C:/Qt/Tools/mingw1310_64/bin/g++.exe"

cmake --build build --parallel
```

The executable is created at `build\appQtQuickDemo.exe`.
