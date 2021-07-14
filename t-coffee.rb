class TCoffee < Formula
  homepage "http://www.tcoffee.org/"
  version '9.03.r1318'
  url "https://github.com/cbcrg/tcoffee/archive/27c894eee70b44e4ea13130bdead2b299e13daa9.tar.gz"
  sha256 "c289ef0fe5a4fb534faba9ed980303f36d027799ad1d0bde8a0822a549784a75"
  # doi "10.1006/jmbi.2000.4042"
  # tag origin homebrew-science
  # tag derived

  depends_on 'ensembl/external/poa'
  depends_on 'ensembl/ensembl/dialign-tx'
  depends_on 'ensembl/ensembl/dialign-t'
  depends_on 'ensembl/ensembl/pcma'
  depends_on 'ensembl/ensembl/probcons'
  depends_on 'ensembl/external/clustal-w'
  depends_on 'ensembl/external/mafft@7.427'
  depends_on 'ensembl/external/muscle'
  depends_on 'ensembl/external/kalign'

  def install
    # Fix this error: MAX_N_PID exceded -- Recompile changing the value of MAX_N_PID (current: 260000 Requested: 263956)
    inreplace "lib/data_headers/coffee_defines.h", "define MAX_N_PID       260000", "define MAX_N_PID       520000"
    mkdir "lib/compilation"
    cd "t_coffee/src" do
      p = buildpath + "_build"
      # The makefile copies the executable there
      ENV["USER_BIN"] = p
      # The makefile copies the preprocessed source files there
      mkdir p + "distributions/T-COFFEE_distribution_Version_9.03/t_coffee_source"
      ENV["HOME2"] = p
      # Uncomment to see which paths it is using
      #system "make", "env"
      system "make", "c_code"
      bin.install 't_coffee'
    end
    (prefix+'plugins').install 'lib/mcoffee'
    File.open((etc+'tcoffee.bash'), 'w') { |file| file.write("export MCOFFEE_4_TCOFFEE=#{prefix}/plugins/mcoffee
") }
  end

  test do
    system "#{bin}/t_coffee -version"
  end
end
