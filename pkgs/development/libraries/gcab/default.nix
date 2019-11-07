{ stdenv
, fetchurl
, gettext
, gobject-introspection
, gtk-doc
, docbook_xsl
, docbook_xml_dtd_43
, pkgconfig
, meson
, ninja
, git
, vala
, glib
, zlib
, gnome3
, nixosTests
}:

stdenv.mkDerivation rec {
  pname = "gcab";
  version = "1.3";

  outputs = [ "bin" "out" "dev" "devdoc" "installedTests" ];

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "1rv81b37d5ya7xpfdxrfk173jjcwabxyng7vafgwyl5myv44qc0h";
  };

  patches = [
    # allow installing installed tests to a separate output
    ./installed-tests-path.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    git
    pkgconfig
    vala
    gettext
    gobject-introspection
    gtk-doc
    docbook_xsl
    docbook_xml_dtd_43
  ];

  buildInputs = [
    glib
    zlib
  ];

  mesonFlags = [
    "-Dinstalled_tests=true"
    "-Dinstalled_test_prefix=${placeholder ''installedTests''}"
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      versionPolicy = "none";
    };

    tests = {
      installedTests = nixosTests.installed-tests.gcab;
    };
  };

  meta = with stdenv.lib; {
    description = "GObject library to create cabinet files";
    homepage = "https://gitlab.gnome.org/GNOME/gcab";
    license = licenses.lgpl21Plus;
    maintainers = gnome3.maintainers;
    platforms = platforms.linux;
  };
}
