class TCoffee < Formula
  homepage "http://www.tcoffee.org/"
  version '9.03.r1318'
  url "http://www.tcoffee.org/Packages/Stable/Version_9.03.r1318/T-COFFEE_distribution_Version_9.03.r1318.tar.gz"
  sha256 "5bb9a531a4036b741a8ff0fe19f3591a3f33bf7ac4f484e5329b1b5dd1fff43c"
  # doi "10.1006/jmbi.2000.4042"
  # tag origin homebrew-science
  # tag derived

  depends_on 'ensembl/external/poa'
  depends_on 'ensembl/ensembl/dialign-tx'
  depends_on 'ensembl/ensembl/dialign-t'
  depends_on 'ensembl/ensembl/pcma'
  depends_on 'ensembl/ensembl/probcons'
  depends_on 'ensembl/external/clustal-w'
  depends_on 'ensembl/external/mafft'
  depends_on 'ensembl/external/muscle'
  depends_on 'ensembl/external/kalign'

  def install
    cd 't_coffee_source' do
      # Fix this error: MAX_N_PID exceded -- Recompile changing the value of MAX_N_PID (current: 260000 Requested: 263956)
      inreplace "io_lib_header.h", "define MAX_N_PID       260000", "define MAX_N_PID       520000"
      inreplace "define_header.h", "define MAX_N_PID       260000", "define MAX_N_PID       520000"
      system *%w[make t_coffee]
      bin.install 't_coffee'
      #prefix.install "lib" => "libexec"
      #prefix.install Dir["*"]
      #bin.install_symlink "../compile/t_coffee"
    end
    (prefix+'plugins').install 'mcoffee'
    File.open((etc+'tcoffee.bash'), 'w') { |file| file.write("export MCOFFEE_4_TCOFFEE=#{prefix}/plugins/mcoffee
") }
  end

  test do
    system "#{bin}/t_coffee -version"
  end
end
