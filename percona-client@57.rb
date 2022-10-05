class PerconaClientAT57 < Formula
  desc "Drop-in MySQL replacement"
  homepage "https://www.percona.com"
  url "https://downloads.percona.com/downloads/Percona-Server-5.7/Percona-Server-5.7.39-42/source/tarball/percona-server-5.7.39-42.tar.gz"

  # tag origin homebrew-core
  # tag derived

  version "5.7.39-42"
  sha256 "bda853fb951eef8be1c2f24391798cf1f3377c776a376f4c55b192e42ae8d1b2"

  keg_only :versioned_formulae

  option "with-test", "Build with unit tests"

  depends_on "cmake" => :build
  depends_on "ensembl/external/openssl@1.0"
  depends_on "readline" unless OS.mac?

  conflicts_with "mysql-connector-c",
    :because => "both install `mysql_config`"

  conflicts_with "mariadb", "mysql",
    :because => "percona, mariadb, and mysql install the same binaries."
  conflicts_with "mysql-connector-c",
    :because => "both install MySQL client libraries"
  conflicts_with "mariadb-connector-c",
    :because => "both install plugins"
    conflicts_with "ensembl/external/mysql-client",
    :because => "both install the same client libraries"

  # Where the database files should be located. Existing installs have them
  # under var/percona, but going forward they will be under var/mysql to be
  # shared with the mysql and mariadb formulae.
  def datadir
    @datadir ||= (var/"percona").directory? ? var/"percona" : var/"mysql"
  end

  def install
    # Don't hard-code the libtool path. See:
    # https://github.com/Homebrew/homebrew/issues/20185
    inreplace "cmake/libutils.cmake",
      "COMMAND /usr/bin/libtool -static -o ${TARGET_LOCATION}",
      "COMMAND libtool -static -o ${TARGET_LOCATION}"

    args = std_cmake_args + %W[
      -DMYSQL_DATADIR=#{datadir}
      -DSYSCONFDIR=#{etc}
      -DINSTALL_MANDIR=#{man}
      -DINSTALL_DOCDIR=#{doc}
      -DINSTALL_INFODIR=#{info}
      -DINSTALL_INCLUDEDIR=include/mysql
      -DINSTALL_MYSQLSHAREDIR=#{share.basename}/mysql
      -DWITH_SSL=yes
      -DDEFAULT_CHARSET=utf8
      -DDEFAULT_COLLATION=utf8_general_ci
      -DCOMPILATION_COMMENT=Homebrew
      -DCMAKE_FIND_FRAMEWORK=LAST
      -DCMAKE_VERBOSE_MAKEFILE=ON
    ]
    args << "-DWITH_EDITLINE=system" if OS.mac?

    # PAM plugin is Linux-only at the moment
    args.concat %w[
      -DWITHOUT_AUTH_PAM=1
      -DWITHOUT_AUTH_PAM_COMPAT=1
      -DWITHOUT_DIALOG=1
    ]

    # TokuDB is broken on MacOsX
    # https://bugs.launchpad.net/percona-server/+bug/1531446
    args.concat %w[-DWITHOUT_TOKUDB=1]

    # To enable unit testing at build, we need to download the unit testing suite
    if build.with? "test"
      args << "-DENABLE_DOWNLOADS=ON"
    else
      args << "-DWITH_UNIT_TESTS=OFF"
    end

    # Build with local infile loading support
    args << "-DENABLED_LOCAL_INFILE=1"

    # Do not build the server
    args << "-DWITHOUT_SERVER=1"

    system "cmake", ".", *args
    system "make"
    system "make", "install"

    # Don't create databases inside of the prefix!
    # See: https://github.com/Homebrew/homebrew/issues/4975
    rm_rf prefix+"data"

    # Now create symbolic links to get around libperconaserver* being the shared library name
    lib.each_child(false) do | entry |
      if entry.to_s =~ /^libperconaserver/
        new_entry = entry.sub(/libperconaserver(.+)/, 'libmysql\\1')
        ln_sf lib+entry, lib+new_entry
      end
    end
  end
  
  test do
    system bin+'mysql', '--version'
  end
end
