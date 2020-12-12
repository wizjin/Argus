//
//  NSData+AGExt.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "NSData+AGExt.h"
#import <CommonCrypto/CommonDigest.h>
#import <zlib.h>
#import <strings.h>

#define kCompressChunkSize  4096
#define kCompressLevel      Z_BEST_COMPRESSION

static const char *tbl = "0123456789ABCDEF";

@implementation NSData (AGExt)

+ (nullable instancetype)dataWithBase32EncodedString:(NSString *)base32String {
    size_t len = base32String.length;
    if (len > 0) {
        NSMutableData *data = [NSMutableData dataWithLength:(len*5 + 7)/8];
        size_t cnt = base32_decode((const uint8_t *)base32String.UTF8String, len, data.mutableBytes, data.length);
        if (cnt > 0) {
            data.length = cnt;
            return data;
        }
    }
    return nil;
}

- (NSString *)base32EncodedString {
    NSMutableData *data = [NSMutableData dataWithLength:((self.length + 4)/5)*8 + 1];
    int len = base32_encode(self.bytes, self.length, data.mutableBytes, data.length);
    data.length = (len <= 0 ? 0 : len);
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (NSData *)sha1 {
    NSMutableData *data = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(self.bytes, (CC_LONG)self.length, data.mutableBytes);
    return data;
}

- (NSString *)hex {
    NSString *res = @"";
    size_t len = self.length;
    if (len > 0) {
        const uint8_t *ptr = self.bytes;
        NSMutableData *data = [NSMutableData dataWithLength:sizeof(uint16_t)*len];
        uint16_t *pout = data.mutableBytes;
        if (pout != NULL) {
            for (int i = 0; i < len; i++) {
                uint8_t c = ptr[i];
#if BYTE_ORDER == BIG_ENDIAN
                pout[i] = (uint16_t)(tbl[c&0x0f]) | ((uint16_t)(tbl[(c>>4)&0x0f]) << 8);
#else
                pout[i] = ((uint16_t)(tbl[c&0x0f]) << 8) | (uint16_t)(tbl[(c>>4)&0x0f]);
#endif
            }
            res = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];;
        }
    }
    return res;
}

- (NSData *)compress {
    z_stream zStream;
    bzero(&zStream, sizeof(zStream));
    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;
    zStream.opaque = Z_NULL;
    zStream.next_in = (Bytef *)self.bytes;
    zStream.avail_in = (uint)self.length;
    zStream.total_out = 0;
    int status = deflateInit2(&zStream, kCompressLevel, Z_DEFLATED, -15, 8, Z_DEFAULT_STRATEGY);
    NSMutableData *outData = [NSMutableData dataWithLength:kCompressChunkSize];
    do {
        if ((status == Z_BUF_ERROR) || (zStream.total_out == outData.length)) {
            outData.length += kCompressChunkSize;
        }
        zStream.next_out = (Bytef *)outData.mutableBytes + zStream.total_out;
        zStream.avail_out = (uInt)(outData.length - zStream.total_out);
        status = deflate(&zStream, Z_FINISH);
    } while ((status == Z_BUF_ERROR) || (status == Z_OK));
    status = deflateEnd(&zStream);
    if ((status == Z_OK) || (status == Z_STREAM_END)) {
        outData.length = zStream.total_out;
    } else {
        outData.length = 0;
    }
    return outData;
}

- (NSData *)decompress {
    z_stream zStream;
    bzero(&zStream, sizeof(zStream));
    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;
    zStream.opaque = Z_NULL;
    zStream.next_in = (Bytef *)self.bytes;
    zStream.avail_in = (uInt)self.length;
    zStream.total_out = 0;
    int status = inflateInit2(&zStream, -15);
    NSMutableData *outData = [NSMutableData dataWithLength:kCompressChunkSize];
    do {
        if ((status == Z_BUF_ERROR) || (zStream.total_out == outData.length)) {
            outData.length += kCompressChunkSize;
        }
        zStream.next_out = (Bytef *)outData.mutableBytes + zStream.total_out;
        zStream.avail_out = (uInt)(outData.length - zStream.total_out);
        status = inflate(&zStream, Z_FINISH);
    } while ((status == Z_BUF_ERROR) || (status == Z_OK));
    status = inflateEnd(&zStream);
    if ((status != Z_OK) && (status != Z_STREAM_END)) {
        zStream.total_out = 0;
    }
    outData.length = zStream.total_out;
    return outData;
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

static inline int base32_encode(const uint8_t *ptr, size_t len, uint8_t *outbuf, size_t outsize) {
    int count = -1;
    if (len >= 0 && len <= (1 << 28)) {
        count = 0;
        if (len > 0) {
            int buffer = ptr[0];
            int next = 1;
            int bitsLeft = 8;
            while (count < outsize && (bitsLeft > 0 || next < len)) {
                if (bitsLeft < 5) {
                    if (next < len) {
                        buffer <<= 8;
                        buffer |= ptr[next++] & 0xFF;
                        bitsLeft += 8;
                    } else {
                        int pad = 5 - bitsLeft;
                        buffer <<= pad;
                        bitsLeft += pad;
                    }
                }
                int index = 0x1F & (buffer >> (bitsLeft - 5));
                bitsLeft -= 5;
                outbuf[count++] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"[index];
            }
        }
        if (count < outsize) {
            outbuf[count] = '\0';
        }
    }
    return count;
}


@end
