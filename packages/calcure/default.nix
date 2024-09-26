{
  lib,
  python3,
  fetchFromGitHub,
  fetchPypi,
  ...
}:
let

  jilaliCore = python3.pkgs.buildPythonPackage rec {
    pname = "jalali_core";
    version = "1.0.0";
    format = "setuptools";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-9Ch8cMYwMj3PCjqybfkFuk1FHiMKwfZbO7L3d5eJSis=";
    };

    pythonImportsCheck = [ "jalali_core" ];

  };

  jilali = python3.pkgs.buildPythonPackage rec {
    pname = "jdatetime";
    version = "5.0.0";
    format = "setuptools";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-LMYD2RPA2OMokoRU09KVJhywN+mVAif2fJYpq0cQ/fk=";
    };

    propagatedBuildInputs = [
      jilaliCore
      python3.pkgs.six
    ];

    pythonImportsCheck = [ "jdatetime" ];

    meta = with lib; {
      description = "Jalali datetime binding";
      homepage = "https://github.com/slashmili/python-jalali";
      license = licenses.psfl;
      maintainers = [ ];
    };
  };

in
python3.pkgs.buildPythonApplication rec {
  pname = "calcure";
  version = "3.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "anufrievroman";
    repo = "calcure";
    rev = "refs/tags/${version}";
    hash = "sha256-ufrJbc3WMY88VEsUHlWxQ1m0iupts4zNusvQL8YAqJc=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
  ];

  propagatedBuildInputs = with python3.pkgs; [
    holidays
    icalendar
    jilali
  ];

  pythonImportsCheck = [
    "calcure"
  ];

  doCheck = false;

  patches = [ ./patch.patch ];

  meta = with lib; {
    description = "Modern TUI calendar and task manager with minimal and customizable UI";
    mainProgram = "calcure";
    homepage = "https://github.com/anufrievroman/calcure";
    changelog = "https://github.com/anufrievroman/calcure/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ dit7ya ];
  };
}
