require 'timeout'

class Repeatmodeler < Formula
  desc "De-novo repeat family identification and modeling package"
  homepage "http://www.repeatmasker.org/RepeatModeler.html"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived

  version "2.0.1"
  url "http://www.repeatmasker.org/RepeatModeler/RepeatModeler-#{version}.tar.gz"
  sha256 "628e7e1556865a86ed9d6a644c0c5487454c99fbcac21b68eae302fae7abb7ac"

  option "without-configure", "Do not run configure"
  option "with-perl", "Use Linuxbrew Perl"
  option "without-ltr", "Disable LTR structural search"

  depends_on "ensembl/external/recon"
  depends_on "ensembl/external/repeatmasker"
  depends_on "ensembl/external/repeatscout"
  depends_on "ensembl/external/rmblast"
  depends_on "ensembl/external/trf"

  if build.with? "ltr"
    depends_on "ensembl/external/cd-hit"
    depends_on "genometools"
    depends_on "ensembl/ensembl/ltr_retriever"
    depends_on "ensembl/ensembl/ninja-cluster"
    # It needs mafft >= 7.407 so we avoid ensembl/external/mafft
    depends_on "mafft"
  end

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"RepeatModeler"
    bin.install_symlink libexec/"BuildDatabase"

  end

  def post_install
    if build.with? "configure"
      if build.with? "perl"
        perl = "#{HOMEBREW_PREFIX}/bin/perl"
      elsif ENV.has_key?('HOMEBREW_PLENV_ROOT')
        perl = %x{PLENV_ROOT=#{ENV['HOMEBREW_PLENV_ROOT']} #{ENV['HOMEBREW_PLENV_ROOT']}/bin/plenv which perl}.chomp
      else
        perl = %x{which perl}.chomp
      end

      open(libexec/"config.in", "w") { |f|
        f.puts("")
        f.puts(perl)
        f.puts(Formula["ensembl/external/repeatmasker"].opt_prefix/"libexec")
        f.puts("#{HOMEBREW_PREFIX}/bin")
        f.puts(Formula["ensembl/external/repeatscout"].opt_prefix)
        f.puts("#{HOMEBREW_PREFIX}/bin/trf")
        f.puts(1)
        if Gem::Version.new(Formula['ensembl/external/rmblast'].version.to_s) < Gem::Version.new('2.10.0')
          f.puts("#{HOMEBREW_PREFIX}/bin")
        else
          f.puts(Formula['ensembl/external/rmblast'].opt_bin)
        end
        f.puts(3)
        if build.with? "ltr"
          f.puts('Y')
          f.puts("#{HOMEBREW_PREFIX}/bin")
          f.puts("#{HOMEBREW_PREFIX}/bin")
          f.puts("#{HOMEBREW_PREFIX}/bin")
          f.puts("#{HOMEBREW_PREFIX}/bin")
          f.puts("#{HOMEBREW_PREFIX}/bin")
        else
          f.puts("N")
        end
      }

      begin
        # If the config.in is wrong, configure will loop/wait for ever. We set a timer to avoid this problem
        Timeout::timeout(300) {
          cd libexec do
            system "#{perl} configure < config.in"
          end
        }
      rescue
        odie("'perl configure' failed. You should try 'cd #{libexec} && #{perl} configure'")
      end
    else
      opoo("repeatmodeler has not been configured and config.in has not been created")
    end
  end

  def caveats; <<~EOS
    To reconfigure RepeatModeler, run
      brew postinstall repeatmodeler
    or
      cd #{prefix} && perl ./configure <config.in
    EOS
  end

  test do
    assert_match version.to_s, shell_output("perl #{bin}/RepeatModeler -v")
  end
end
