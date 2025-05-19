# ~/.cmake/flags.cmake
# Global CMake toolchain flags for all projects
# Ensures -march=native is always used for best performance

# Append march=native if not already present
if (NOT CMAKE_C_FLAGS MATCHES "march=native")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=native" CACHE STRING "" FORCE)
endif()
if (NOT CMAKE_CXX_FLAGS MATCHES "march=native")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native" CACHE STRING "" FORCE)
endif() 