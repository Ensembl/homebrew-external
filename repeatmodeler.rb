class Repeatmodeler < Formula
  desc "De-novo repeat family identification and modeling package"
  homepage "http://www.repeatmasker.org/RepeatModeler.html"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived

  url "http://www.repeatmasker.org/RepeatModeler-open-1-0-8.tar.gz"
  version "1.0.8"
  sha256 "3ac87af3fd3da0c9a2ca8e7b8885496abdf3383e413575548c1d234c15f27ecc"
  revision 1

  option "without-configure", "Do not run configure"

  depends_on "ensembl/external/recon"
  depends_on "ensembl/external/repeatmasker"
  depends_on "ensembl/external/repeatscout"
  depends_on "ensembl/external/rmblast"
  depends_on "ensembl/external/trf"

  # Configure RepeatModeler. The prompts are:
  # PRESS ENTER TO CONTINUE
  # PERL INSTALLATION PATH
  # REPEATMODELER INSTALLATION PATH
  # REPEATMASKER INSTALLATION PATH
  # RECON INSTALLATION PATH
  # RepeatScout INSTALLATION PATH
  # 1. RMBlast - NCBI Blast with RepeatMasker extensionst
  # RMBlast (rmblastn) INSTALLATION PATH
  # Do you want RMBlast to be your default search engine for Repeatmasker?
  # 3. Done
  def install
    prefix.install Dir["*"]
    bin.install_symlink %w[../BuildDatabase ../RepeatModeler]

    perl = if ENV.has_key?('HOMEBREW_PLENV_ROOT')
      %x{#{ENV['HOMEBREW_PLENV_ROOT']}/bin/plenv which perl}.chomp
    else
      "/usr/bin/perl"
    end
    (prefix/"config.txt").write <<-EOS.undent

      #{perl}
      #{prefix}
      #{Formula["ensembl/external/repeatmasker"].opt_prefix/"libexec"}
      #{Formula["ensembl/external/recon"].opt_prefix/"bin"}
      #{Formula["ensembl/external/repeatscout"].opt_prefix}
      #{Formula["ensembl/external/trf"].opt_prefix/"bin"}
      1
      #{HOMEBREW_PREFIX}/bin
      Y
      3
      EOS
  end

  def post_install
    cd prefix do
      system "perl ./configure <config.txt"
    end if build.with? "configure"
  end

  def caveats; <<-EOS.undent
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
