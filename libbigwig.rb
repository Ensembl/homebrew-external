class Libbigwig < Formula
  desc "C library for processing the big UCSC fomats"
  homepage "https://github.com/dpryan79/libBigWig"
  url "https://github.com/dpryan79/libBigWig/archive/0.4.1.tar.gz"
  sha256 "0dd6f52f6c73aaad5b00265d742bdaaf12b490cd3673fac74f80bcb661d4a591"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived

  depends_on "curl"

  def install
    curl = Formula["curl"]
    system "make", "install", "prefix=#{prefix}", "INCLUDES=-I#{curl.opt_include}", "LDLIBS=-L#{curl.opt_lib}"
  end

  test do
    (testpath/"libbigwig.c").write <<-EOS.undent
    #include "bigWig.h"
    #include <stdio.h>
    #include <inttypes.h>
    #include <stdlib.h>

    int main(int argc, char *argv[]) {
      if(bwInit(1<<17) != 0) {
          return 1;
      }
      return 0;
    }
    EOS
    libs = %w[-lBigWig]
    system ENV.cc, "-o", "test", "libbigwig.c", "-I#{include}", "-L#{lib}", *libs
    system "./test"
  end
end
