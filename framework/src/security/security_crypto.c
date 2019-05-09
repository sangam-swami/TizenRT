/****************************************************************************
 *
 * Copyright 2019 Samsung Electronics All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific
 * language governing permissions and limitations under the License.
 *
 ****************************************************************************/
#include <tinyara/config.h>
#include <sys/types.h>
#include <security/security_crypto.h>
#include "security_internal.h"

/**
 * Crypto
 */
int crypto_aes_encryption(security_handle hnd,
						  security_aes_param param,
						  const char *key_name,
						  security_data *input,
						  security_data *output)
{
	SECAPI_ENTER;
	SECAPI_ISHANDLE_VALID(hnd);
	struct security_ctx *ctx = (struct security_ctx *)hnd;

	hal_aes_param hparam;
	SECAPI_CONVERT_AESPARAM(&param, &hparam);

	// convert path
	uint32_t key_idx = 0;
	SECAPI_CONVERT_PATH(key_name, &key_idx);

	int tmpbuf[SECURITY_MAX_BUF];

	hal_data dec = {input->data, input->length, tmpbuf, SECURITY_MAX_BUF};
	hal_data enc = {NULL, 0, NULL, 0};

	hal_result_e hres = HAL_SUCCESS;
	SECAPI_CALL(sl_aes_encrypt(ctx->sl_hnd, &dec, &hparam, key_idx, &enc, &hres));

	if (hres != HAL_SUCCESS) {
		SECAPI_HAL_RETURN(hres);
	}

	output->data = (unsigned char *)malloc(enc.data_len);
	if (!output->data) {
		SECAPI_RETURN(SECURITY_ALLOC_ERROR);
	}
	SECAPI_DATA_DCOPY(enc, output);

	SECAPI_RETURN(SECURITY_OK);
}

int crypto_aes_decryption(security_handle hnd,
						  security_aes_param param,
						  const char *key_name,
						  security_data *input,
						  security_data *output)
{
	SECAPI_ENTER;
	SECAPI_ISHANDLE_VALID(hnd);
	struct security_ctx *ctx = (struct security_ctx *)hnd;

	hal_aes_param hparam;
	SECAPI_CONVERT_AESPARAM(&param, &hparam);

	// convert path
	uint32_t key_idx = 0;
	SECAPI_CONVERT_PATH(key_name, &key_idx);

	hal_data enc = {input->data, input->length, NULL, 0};
	hal_data dec = {NULL, 0, NULL, 0};

	hal_result_e hres = HAL_SUCCESS;
	SECAPI_CALL(sl_aes_decrypt(ctx->sl_hnd, &enc, &hparam, key_idx, &dec, &hres));
	if (hres != HAL_SUCCESS) {
		SECAPI_HAL_RETURN(hres);
	}

	output->data = (unsigned char *)malloc(dec.data_len);
	if (!output->data) {
		SECAPI_RETURN(SECURITY_ALLOC_ERROR);
	}
	SECAPI_DATA_DCOPY(dec, output);

	SECAPI_RETURN(SECURITY_OK);
}

int crypto_rsa_encryption(security_handle hnd,
						  security_rsa_param mode,
						  const char *key_name,
						  security_data *input,
						  security_data *output)
{
	SECAPI_ENTER;
	SECAPI_ISHANDLE_VALID(hnd);
	struct security_ctx *ctx = (struct security_ctx *)hnd;

	hal_rsa_mode hmode;
	SECAPI_CONVERT_RSAPARAM(&mode, &hmode);

    /* convert path */
	uint32_t key_idx = 0;
	SECAPI_CONVERT_PATH(key_name, &key_idx);

	hal_data dec = {input->data, input->length, NULL, 0};
	hal_data enc = {NULL, 0, NULL, 0};

	hal_result_e hres = HAL_SUCCESS;
	SECAPI_CALL(sl_rsa_encrypt(ctx->sl_hnd, &dec, &hmode, key_idx, &enc, &hres));
	if (hres != HAL_SUCCESS) {
		SECAPI_HAL_RETURN(hres);
	}

	output->data = (unsigned char *)malloc(enc.data_len);
	if (!output->data) {
		SECAPI_RETURN(SECURITY_ALLOC_ERROR);
	}

	SECAPI_DATA_DCOPY(enc, output);

	SECAPI_RETURN(SECURITY_OK);
}

int crypto_rsa_decryption(security_handle hnd,
						  security_rsa_param mode,
						  const char *key_name,
						  security_data *input,
						  security_data *output)
{
	SECAPI_ENTER;
	SECAPI_ISHANDLE_VALID(hnd);
	struct security_ctx *ctx = (struct security_ctx *)hnd;

	hal_rsa_mode hmode;
	SECAPI_CONVERT_RSAPARAM(&mode, &hmode);

	/* convert path */
	uint32_t key_idx = 0;
	SECAPI_CONVERT_PATH(key_name, &key_idx);

	hal_data enc = {input->data, input->length, NULL, 0};
	hal_data dec = {NULL, 0, NULL, 0};

	hal_result_e hres = HAL_SUCCESS;
	SECAPI_CALL(sl_rsa_decrypt(ctx->sl_hnd, &enc, &hmode, key_idx, &dec, &hres));
	if (hres != HAL_SUCCESS) {
		SECAPI_HAL_RETURN(hres);
	}

	output->data = (unsigned char *)malloc(dec.data_len);
	if (!output->data) {
		SECAPI_RETURN(SECURITY_ALLOC_ERROR);
	}
	SECAPI_DATA_DCOPY(dec, output);

	SECAPI_RETURN(SECURITY_OK);
}