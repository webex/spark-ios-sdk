/* -----------------------------------------------------------------
 * iv_gen.h - generic IV generator to be used with protocols
 * requiring an initial vector.
 *
 * June, 2011
 *
 * Copyright (c) 2011,2012 by cisco Systems, Inc.
 * All rights reserved.
 *------------------------------------------------------------------
 */
#ifndef HEADER_IVGEN_H
# define HEADER_IVGEN_H

# include <openssl/opensslconf.h>
# ifdef OPENSSL_NO_AES
#  error AES is disabled.
# endif

#ifdef  __cplusplus
extern "C" {
#endif

# define IV_GEN_MAX_NUM_BYTES   16
# define IV_GEN_ALLOCATED       0x55
# define IV_GEN_INITIALIZED     0xAA

/*
 * These are the various return codes used by
 * the IV Generator functions.
 */
typedef enum iv_gen_rc_ {
    IV_OK = 0,
    IV_NULL_ERR = 1,
    IV_EXHAUSTED_ERR = 2,
    IV_NOT_INITIALIZED_ERR = 3,
    IV_NOT_ALLOCATED_ERR = 4,
    IV_LENGTH_ERR = 5,
} IV_GEN_RC;

/** @brief IV Generator Context Structure */
struct _iv_generator {
    unsigned char initialized;
    unsigned long iv_length;
    unsigned long iv_fixed_part_length;
    unsigned long iv_counter_length;
    unsigned long iv_implicit_part_len;
    unsigned char iv_counter[IV_GEN_MAX_NUM_BYTES];
    unsigned char current_iv[IV_GEN_MAX_NUM_BYTES];
};

typedef struct _iv_generator iv_generator_t;

iv_generator_t *iv_generator_new(void);

void iv_generator_free(iv_generator_t * iv_gen_ctx);

IV_GEN_RC iv_generator_init(iv_generator_t * iv_gen_ctx,
                            unsigned long bytes_in_iv,
                            const unsigned char *fixed_common,
                            unsigned long bytes_in_fixed_common,
                            const unsigned char *fixed_distinct,
                            unsigned long bytes_in_fixed_distinct,
                            const unsigned char *salt,
                            unsigned long bytes_in_salt);

IV_GEN_RC iv_generator_output_next_iv(iv_generator_t * iv_gen_ctx,
                                      unsigned char *location_to_write_iv,
                                      unsigned long bytes_in_iv);

int iv_generator_get_iv_length(iv_generator_t * iv_gen_ctx);

int iv_generator_get_fixed_part_length(iv_generator_t * iv_gen_ctx);

int iv_generator_get_implicit_part(iv_generator_t * iv_gen_ctx,
                                   unsigned char *location_to_write,
                                   unsigned long *implicit_part_len);


#ifdef  __cplusplus
}
#endif

#endif                          /* HEADER_IVGEN_H */
