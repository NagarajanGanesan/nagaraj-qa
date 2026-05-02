import base64
import os
from cryptography.hazmat.primitives.ciphers.aead import AESGCM


def decrypt_value(encoded_text, key_base64=None):
    """Decrypt AES-256-GCM base64 string.
    Wire format: base64(nonce[12] + ciphertext + tag[16]).
    key_base64 defaults to DECRYPT_KEY env var if not provided.
    """
    if key_base64 is None:
        key_base64 = os.environ.get("DECRYPT_KEY", "your-base64-encoded-aes-256-key-here")

    key = base64.b64decode(key_base64)
    combined = base64.b64decode(encoded_text)

    iv = combined[:12]
    ciphertext = combined[12:]

    aesgcm = AESGCM(key)
    decrypted = aesgcm.decrypt(iv, ciphertext, None)
    return decrypted.decode("utf-8")
