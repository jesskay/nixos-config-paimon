{
  fetchPypi,
  python3Packages,
  lib,
}:

python3Packages.buildPythonPackage rec {
  pname = "brother-ql";
  version = "0.11.1";
  format = "pyproject";

  src = fetchPypi {
    pname = "brother_ql_next";
    inherit version;
    hash = "sha256-jG8OvzDy2+2OpdVVixNguLsSwRbSIyvVEbVvorcgxfU=";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools
    future
    packbits
    pillow
    pyusb
    click
    attrs
    jsons
  ];

  # patch in version specifiers until upstream has them
  postPatch = ''
    sed -i 's/"typing"/"typing;python_version<\\"3.5\\""/' pyproject.toml
    sed -i 's/"enum34"/"enum34;python_version<\\"3.4\\""/' pyproject.toml
  '';

  meta = with lib; {
    description = "Python package for the raster language protocol of the Brother QL series label printers";
    longDescription = ''
      Python package for the raster language protocol of the Brother QL series label printers
      (QL-500, QL-550, QL-570, QL-700, QL-710W, QL-720NW, QL-800, QL-820NWB, QL-1050 and more)
    '';
    homepage = "https://github.com/LunarEclipse363/brother_ql_next";
    license = licenses.gpl3;
    maintainers = with maintainers; [ grahamc ];
    mainProgram = "brother_ql";
  };
}
