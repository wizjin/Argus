//
//  NSData+AGExt.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "NSData+AGExt.h"

@implementation NSData (AGExt)

+ (nullable instancetype)dataWithBase32EncodedString:(NSString *)base32String {
    size_t len = base32String.length;
    if (len > 0) {
        size_t cnt = (len*5 + 7)/8;
        uint8_t *result = malloc(cnt);
        if (result != NULL) {
            cnt = base32_decode((const uint8_t *)base32String.UTF8String, len, result, cnt);
            if (cnt > 0) {
                return [[NSData alloc] initWithBytesNoCopy:result length:cnt];
            }
            free(result);
        }
    }
    return nil;
}

#pragma mark - Private Methods
static inline int base32_decode(const uint8_t *ptr, size_t len, uint8_t *outbuf, size_t outsize) {
    int cnt = 0;
    int buffer = 0;
    int bitsLeft = 0;
    for (int i = 0; i < len; i++) {
        uint8_t ch = ptr[i];
        switch (ch) {
            case ' ': case '\t': case '\r': case '\n': case '-':
                continue;
            case 'A':case 'B':case 'C':case 'D':case 'E':case 'F':case 'G':case 'H':case 'I':case 'J':case 'K':case 'L':case 'M':
            case 'N':case 'O':case 'P':case 'Q':case 'R':case 'S':case 'T':case 'U':case 'V':case 'W':case 'X':case 'Y':case 'Z':
                ch -= 'A';
                break;
            case 'a':case 'b':case 'c':case 'd':case 'e':case 'f':case 'g':case 'h':case 'i':case 'j':case 'k':case 'l':case 'm':
            case 'n':case 'o':case 'p':case 'q':case 'r':case 's':case 't':case 'u':case 'v':case 'w':case 'x':case 'y':case 'z':
                ch -= 'a';
                break;
            case '2':case '3':case '4':case '5':case '6':case '7':
                ch -= '2' - 26;
                break;
            case '0': ch = 'O' - 'A'; break;
            case '1': ch = 'L' - 'A'; break;
            case '8': ch = 'B' - 'A'; break;
            default:
                return -1;
        }
        buffer <<= 5;
        buffer |= ch;
        bitsLeft += 5;
        if (bitsLeft >= 8) {
            outbuf[cnt++] = buffer >> (bitsLeft - 8);
            bitsLeft -= 8;
            if (cnt > outsize) {
                break;
            }
        }
    }
    return cnt;
}


@end
