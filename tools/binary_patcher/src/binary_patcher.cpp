#include <cstdint>
#include <cstring>
#include <fstream>
#include <iostream>

#define NUM_ELEM(x) sizeof(x) / sizeof(x[0])

int main(int argc, char **argv) {
  constexpr unsigned expectedOccurrences[] = {1, 2, 1};

  // Thanks to https://cweiske.de/tagebuch/android-root-adb.htm for the write up
  // This moves the value 2000 (the unprivileged UID/GID) to the register r0
  // before calling setuid/setgid
  // Hence, we want to replace this instruction as well as the following
  // syscalls with NOPs to gain root privileges
  constexpr uint8_t searchSequence[][4] = {
      // ARMv8 thumb: blx 0x17ddc aka blx setgroups
      {0x0E, 0xF0, 0xAC, 0xED},
      // ARMv8 thumb: mov.w r0, #0x7d0
      {0x4f, 0xf4, 0xfa, 0x60},
      // {0xf4, 0x4f, 0x60, 0xfa},
      // ARMv8 thumb: blx	0x17dfc aka blx prctl
      {0x0e, 0xf0, 0xde, 0xed},
      // {0xf0, 0x0e, 0xed, 0xde},
  };
  constexpr uint8_t replaceSeq1[] = {
      // ARMv8 thumb: nop, nop for: blx 0x17ddc / blx syscall
      0x00, 0xbf, 0x00, 0xbf,
      // nop for return value check: cmp r0,#0x0
      0x00, 0xbf,
      // nop for failure jump: bne failure
      0x00, 0xbf};
  constexpr uint8_t replaceSeq2[] = {
      // ARMv8 thumb: nop, nop for: mov.w r0, #0x7d0
      0x00, 0xbf, 0x00, 0xbf,
      // nop, nop for: blx syscall
      0x00, 0xbf, 0x00, 0xbf,
      // nop for return value check: cmp r0,#0x0
      0x00, 0xbf,
      // nop for failure jump: bne failure
      0x00, 0xbf};
  constexpr uint8_t replaceSeq3[] = {
      // ARMv8 thumb: nop, nop for: blx	0x17dfc aka blx prctl
      0x00,
      0xbf,
      0x00,
      0xbf,
  };
  const uint8_t *const replaceSequence[] = {replaceSeq1, replaceSeq2,
                                            replaceSeq3};
  constexpr unsigned replaceSequenceSizes[] = {
      NUM_ELEM(replaceSeq1), NUM_ELEM(replaceSeq2), NUM_ELEM(replaceSeq3)};

  if (argc != 3) {
    std::cerr << "Invalid argument count!" << std::endl;
    std::cerr << "Usage: ./binary_patcher input_file output_file" << std::endl;
    return 1;
  }

  std::ifstream input(argv[1], std::ios::binary);
  if (!input.is_open()) {
    std::cerr << "ERROR: input file not found!" << std::endl;
    return 2;
  }

  std::ofstream output(argv[2], std::ios::binary);
  unsigned found[NUM_ELEM(expectedOccurrences)];
  std::memset(found, 0, sizeof(found));
  uint8_t buf[sizeof(searchSequence[0])];
  std::memset(buf, 0xFF, sizeof(buf));

  while (input) {
    // move bytes to the left!
    for (unsigned i = 2; i < sizeof(buf); ++i) {
      buf[i - 2] = buf[i];
    }
    // Only read two new bytes
    input.read(reinterpret_cast<char *>(buf + sizeof(buf) - 2), 2);
    for (unsigned i = 0; i < NUM_ELEM(expectedOccurrences); ++i) {
      if (std::memcmp(buf, searchSequence[i], sizeof(buf)) == 0) {
        ++found[i];
        output.write(reinterpret_cast<const char *>(replaceSequence[i]),
                     replaceSequenceSizes[i]);
        // We can probably use seek here but I am lazy to look this up... just
        // read n times a single byte to "skip" forward
        for (unsigned i = replaceSequenceSizes[i] - sizeof(buf); i > 0; --i) {
          input.read(reinterpret_cast<char *>(buf), 1);
        }
        goto skip_copy;
      }
    }
    output.write(reinterpret_cast<const char *>(buf), sizeof(buf));
  skip_copy:
    void(); /*dummy jump position*/
  }

  for (unsigned i = 0; i < NUM_ELEM(expectedOccurrences); ++i) {
    if (found[i] != expectedOccurrences[i]) {
      // If this message is printed, make a quick sanity check via:
      // `arm-none-eabi-objdump -M force-thumb -D mnt/ramdiskExtracted/sbin/adbd
      // > adbd.disas` and look at the occurrences of f44f 60fa of 4ff4 fa60 and
      // 0ef0 deed or f00e edde (the search sequences)
      std::cerr << "ERROR: expected binary patches: " << expectedOccurrences[i]
                << " but applied patch " << found[i] << " times!" << std::endl;
      return 3 + i;
    }
  }
  std::cout << "Successfully applied the root patch!" << std::endl;

  return 0;
}