#ifndef ED25519_h
#define ED25519_h

#include <stdlib.h>
#include <stdint.h>

int ED25519_sign(uint8_t *out_sig, const uint8_t *message, size_t message_len,
                 const uint8_t public_key[32], const uint8_t private_key[32]);
int ED25519_verify(const uint8_t *message, size_t message_len,
                   const uint8_t signature[64], const uint8_t public_key[32]);
void ED25519_public_from_private(uint8_t out_public_key[32],
                                 const uint8_t private_key[32]);

#endif
