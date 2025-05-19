# Use all CPU features by default for C/C++/Fortran compilers
if ! grep -q 'CFLAGS=.*-march=native' ~/.bashrc; then
  echo '# Use all CPU features by default' >> ~/.bashrc
  echo 'export CFLAGS="$CFLAGS -march=native -O2"' >> ~/.bashrc
  echo 'export CXXFLAGS="$CXXFLAGS -march=native -O2"' >> ~/.bashrc
  echo 'export FFLAGS="$FFLAGS -march=native -O2"' >> ~/.bashrc
fi 