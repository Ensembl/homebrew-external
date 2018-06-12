class Libpll < Formula
  desc "PLL is a C library for doing phylogenetics"
  homepage "https://github.com/xflouris/libpll"
  url "https://github.com/xflouris/libpll/archive/0.3.2.tar.gz"
  sha256 "45107d59d87be921c522478bb3688beee60dc79154e0b4a183af01122c597132"
  head "https://git.assembla.com/phylogenetic-likelihood-library.git"
  # tag "bioinformatics"
  # doi "10.1093/sysbio/syu084"
  # tag origin homebrew-science
  # tag derived

  depends_on "libtool" => :build
  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "bison"
  depends_on "flex"

  def install
    system "autoreconf", "-fvi"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "check" if build.with? "check"
    system "make", "install"
  end

  test do
    (testpath/"alignment.phy").write <<-EOS.undent
      10 60
      Cow       ATGGCATATCCCATACAACTAGGATTCCAAGATGCAACATCACCAATCATAGAAGAACTA
      Carp      ATGGCACACCCAACGCAACTAGGTTTCAAGGACGCGGCCATACCCGTTATAGAGGAACTT
      Chicken   ATGGCCAACCACTCCCAACTAGGCTTTCAAGACGCCTCATCCCCCATCATAGAAGAGCTC
      Human     ATGGCACATGCAGCGCAAGTAGGTCTACAAGACGCTACTTCCCCTATCATAGAAGAGCTT
      Loach     ATGGCACATCCCACACAATTAGGATTCCAAGACGCGGCCTCACCCGTAATAGAAGAACTT
      Mouse     ATGGCCTACCCATTCCAACTTGGTCTACAAGACGCCACATCCCCTATTATAGAAGAGCTA
      Rat       ATGGCTTACCCATTTCAACTTGGCTTACAAGACGCTACATCACCTATCATAGAAGAACTT
      Seal      ATGGCATACCCCCTACAAATAGGCCTACAAGATGCAACCTCTCCCATTATAGAGGAGTTA
      Whale     ATGGCATATCCATTCCAACTAGGTTTCCAAGATGCAGCATCACCCATCATAGAAGAGCTC
      Frog      ATGGCACACCCATCACAATTAGGTTTTCAAGACGCAGCCTCTCCAATTATAGAAGAATTA
    EOS

    (testpath/"libpll-test.c").write <<-EOS.undent
      #include <stdio.h>
      #include <stdlib.h>
      #include <pll/pll.h>
      int main (int argc, char * argv[])
      {
          pllInstanceAttr attr;
          attr.rateHetModel = PLL_GAMMA;
          attr.fastScaling  = PLL_FALSE;
          attr.saveMemory   = PLL_FALSE;
          attr.useRecom     = PLL_FALSE;
          attr.randomNumberSeed = 0x12345;
          pllInstance * inst;
          inst = pllCreateInstance (&attr);
          pllAlignmentData * alignmentData;
          alignmentData = pllParseAlignmentFile(PLL_FORMAT_PHYLIP, "alignment.phy");
          if (!alignmentData) {
              printf("Error parsing alignment\\n");
              exit(-1);
          }
          pllQueue * partitionInfo;
          partitionList * partitions;
          partitionInfo = pllPartitionParseString("DNA, P = 1-30\\nDNA, P2 = 31-60");
          if (!pllPartitionsValidate(partitionInfo, alignmentData)) {
              printf("Error parsing partitions\\n");
              exit(-2);
          }
          partitions = pllPartitionsCommit(partitionInfo, alignmentData);
          pllAlignmentRemoveDups(alignmentData, partitions);
          pllTreeInitTopologyRandom(inst, alignmentData->sequenceCount, alignmentData->sequenceLabels);
          pllLoadAlignment(inst, alignmentData, partitions);
          pllInitModel(inst, partitions);
          pllQueuePartitionsDestroy(&partitionInfo);
          pllAlignmentDataDestroy(alignmentData);
          pllPartitionsDestroy(inst, &partitions);
          pllDestroyInstance (inst);
      }
    EOS
    libs = %w[-lpll-sse3 -lm]
    system ENV.cc, "-o", "test", "libpll-test.c",
           "-I#{include}", "-L#{lib}", *libs
    system "./test"
  end
end
