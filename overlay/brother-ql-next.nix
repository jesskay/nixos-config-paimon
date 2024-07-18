{
  python3Packages,
  fetchPypi
}:

python3Packages.buildPythonApplication rec {
  pname = "brother-ql-next";
  version = "0.11.1";
  pyproject = true;

  src = fetchPypi {
    pname = "brother_ql_next";
    inherit version;
    hash = "sha256-jG8OvzDy2+2OpdVVixNguLsSwRbSIyvVEbVvorcgxfU=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    click
    future
    packbits
    pillow
    pyusb
    attrs
    jsons
  ];

  # both modules are replaced by stdlib in more recent python versions
  postPatch = ''
    sed -i '/"typing"/d' pyproject.toml
    sed -i '/"enum34"/d' pyproject.toml
  '';
}
