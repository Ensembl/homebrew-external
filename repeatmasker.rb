require 'timeout'

class Repeatmasker < Formula
  desc "Nucleic and proteic repeat masking tool"
  homepage "http://www.repeatmasker.org/"
  version "4.1.0"
  url "http://www.repeatmasker.org/RepeatMasker-#{version}.tar.gz"
  sha256 "7370014c2a7bfd704f0e487cea82a42f05de100c40ea7cbb50f54e20226fe449"
  
  # tag origin homebrew-science
  # tag derived

  option "without-configure", "Do not run configure"
  option "without-cache", "Do not change the cache directory to use REPEATMASKER_CACHE instead of HOME"
  option "with-dfam", "Use Hmmer and Dfam to mask sequences"

  depends_on "ensembl/external/hmmer" # at least version 3.1 for nhmmer
  depends_on "perl" => :optional
  depends_on "ensembl/external/rmblast"
  depends_on "ensembl/external/trf"
  depends_on "ensembl/moonshine/phrap" => :recommended
  depends_on "ensembl/moonshine/repbase" => :recommended
  depends_on "ensembl/ensembl/dupliconlib" => :optional

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"RepeatMasker"
    bin.install_symlink libexec/"DupMasker"
  end

  def post_install
    args = []
    default_is_set = false
    if build.with? "dfam"
      args << "-default_search_engine hmmer"
      default_is_set = true
    end
    if ! Formula['ensembl/moonshine/phrap'].any_installed_version.nil?
      args << "-default_search_engine crossmatch"
      if !default_is_set
        args << "-crossmatch_dir #{HOMEBREW_PREFIX}/bin"
        default_is_set = true
      end
    end
    if ! Formula['ensembl/moonshine/repbase'].any_installed_version.nil?
      Dir.foreach (Formula['ensembl/moonshine/repbase'].opt_libexec) { |f|
        if File.file?("#{Formula['ensembl/moonshine/repbase'].opt_libexec}/#{f}")
          if File.exists?("#{libexec}/Libraries/#{f}")
            if not File.exists?("#{libexec}/Libraries/#{f}.cp") and not File.exists?("#{libexec}/Libraries/#{f}.rm")
              mv("#{libexec}/Libraries/#{f}", "#{libexec}/Libraries/#{f}.cp")
            end
          else
            open("#{libexec}/Libraries/#{f}.rm", "w")
          end
          cp("#{Formula['ensembl/moonshine/repbase'].opt_libexec}/#{f}", "#{libexec}/Libraries/#{f}")
        end
      }
    else
      delete_lib_file = true
      Dir.glob ("#{libexec}/Libraries/*.cp") { |f|
        File.mv(f, f.gsub(".cp", ""))
        if f.equals("#{libexec}/Libraries/RepeatMaskerLib.embl.cp")
          delete_lib_file = false
        end
      }
      Dir.glob ("#{libexec}/Libraries/*.rm") { |f|
        File.delete(f)
        File.delete(f.gsub(".rm", ""))
      }
      if delete_lib_file and File.exists?("#{libexec}/Libraries/RepeatMaskerLib.embl")
        File.delete("#{libexec}/Libraries/RepeatMaskerLib.embl")
      end
    end
    args << "-trf_prgm #{HOMEBREW_PREFIX}/bin/trf"
    args << "-rmblast_dir #{HOMEBREW_PREFIX}/opt/rmblast/bin"
    if !default_is_set
      args << "-default_search_engine rmblast"
      default_is_set = true
    end
    args << "-hmmer_dir #{HOMEBREW_PREFIX}/bin"
    if !default_is_set
      args << "-default_search_engine hmmer"
      default_is_set = true
    end

    if build.with? "perl"
      perl = "#{HOMEBREW_PREFIX}/bin"
    elsif ENV.has_key?('HOMEBREW_PLENV_ROOT')
      perl = %x{PLENV_ROOT=#{ENV['HOMEBREW_PLENV_ROOT']} #{ENV['HOMEBREW_PLENV_ROOT']}/bin/plenv which perl}.chomp
    else
      perl = %x{which perl}.chomp
    end

    # maskFile.pl does not exist in the archive so I replace it with a different file
    inreplace libexec/"configure", "maskFile", "buildSummary"

    if build.with? "configure"
      cd libexec do
        system "#{perl} configure #{args.join(' ')}"
      end
    end

    if File.exists?("#{libexec}/Libraries/dupliconlib.fa")
      File.delete("#{libexec}/Libraries/dupliconlib.fa")
    end
    if ! Formula['ensembl/ensembl/dupliconlib'].any_installed_version.nil?
      Pathname("#{libexec}/Libraries").install_symlink "#{Formula['ensembl/ensembl/dupliconlib'].libexec}/dupliconlib.fa"
    end
  end

  def caveats; <<~EOS
    Congratulations!  RepeatMasker is now ready to use.
    If something went wrong you can reconfigure RepeatMasker
    with:
      brew postinstall ensembl/external/repeatmasker
      or
      cd #{libexec} && perl ./configure
    EOS
  end

  test do
    (testpath/"hmmer_dna.fa").write(">dna\nATCGAGCTACGAGCGATCATGCGATCATCATAAAAAAAAAAAATATATATATATATATA\n")
    system "RepeatMasker -engine hmmer #{testpath}/hmmer_dna.fa"
    assert File.exist?(testpath/"hmmer_dna.fa.masked")
    assert File.exist?(testpath/"hmmer_dna.fa.out")
    assert File.exist?(testpath/"hmmer_dna.fa.tbl")
    (testpath/"blast_dna.fa").write(">dna\nATCGAGCTACGAGCGATCATGCGATCATCATAAAAAAAAAAAATATATATATATATATA\n")
    (testpath/"blast_dna.lib").write(">TEST1#SIMPLE @test [S:10]\natatatatatatata\n")
    system "RepeatMasker -engine ncbi -lib #{testpath}/blast_dna.lib #{testpath}/blast_dna.fa"
    assert File.exist?(testpath/"blast_dna.fa.masked")
    assert File.exist?(testpath/"blast_dna.fa.out")
    assert File.exist?(testpath/"blast_dna.fa.tbl")
  end
end
