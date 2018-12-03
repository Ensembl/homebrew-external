class Repeatmodeler < Formula
  desc "De-novo repeat family identification and modeling package"
  homepage "http://www.repeatmasker.org/RepeatModeler.html"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived

  version "1.0.11"
  url "http://www.repeatmasker.org/RepeatModeler/RepeatModeler-open-#{version}.tar.gz"
  sha256 "7ff0d588b40f9ad5ce78876f3ab8d2332a20f5128f6357413f741bb7fa172193"
  revision 3

  option "without-configure", "Do not run configure"

  depends_on "ensembl/external/recon"
  depends_on "ensembl/external/repeatmasker"
  depends_on "ensembl/external/repeatscout"
  depends_on "ensembl/external/rmblast"
  depends_on "ensembl/external/trf"

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"RepeatModeler"
    bin.install_symlink libexec/"BuildDatabase"

  end

  def post_install
    if build.with? "perl"
      perl = "#{HOMEBREW_PREFIX}/bin"
    elsif ENV.has_key?('HOMEBREW_PLENV_ROOT')
      perl = %x{PLENV_ROOT=#{ENV['HOMEBREW_PLENV_ROOT']} #{ENV['HOMEBREW_PLENV_ROOT']}/bin/plenv which perl}.chomp
    else
      perl = %x{which perl}.chomp
    end

    open(libexec/"config.in", "w") { |f|
      f.puts("")
      f.puts(perl)
      f.puts(libexec)
      f.puts(Formula["ensembl/external/repeatmasker"].opt_prefix/"libexec")
      f.puts("#{HOMEBREW_PREFIX}/bin")
      f.puts(Formula["ensembl/external/repeatscout"].opt_prefix)
      f.puts("#{HOMEBREW_PREFIX}/bin")
      f.puts("#{HOMEBREW_PREFIX}/bin")
      f.puts(1)
      f.puts("#{HOMEBREW_PREFIX}/bin")
      f.puts("Y")
      f.puts(3)
    }

    begin
      Timeout::timeout(300) {
        system "cd #{libexec} && perl configure < config.in"
      }
    rescue
      odie("'perl configure' failed. You should try 'cd #{libexec} && perl configure'")
    end
  end

  def caveats; <<~EOS
    To reconfigure RepeatModeler, run
      brew postinstall repeatmodeler
    or
      cd #{prefix} && perl ./configure <config.txt
    EOS
  end

  test do
    assert_match version.to_s, shell_output("perl #{bin}/RepeatModeler -v")
  end
end
