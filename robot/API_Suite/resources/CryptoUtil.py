# CryptoUtil.py
import base64
import os
from Crypto.Cipher import AES
from cryptography.hazmat.primitives.ciphers.aead import AESGCM


class CryptoUtil:

    def encrypt_payload(self, key_base64, json_string):
        """Encrypt JSON string using AES-256-GCM.
        Wire format: base64(nonce[12] + ciphertext + tag[16]).
        Matches xxxEncryption(AesMode.GCM) in the gateway."""
        key = base64.b64decode(key_base64)
        nonce = os.urandom(12)
        cipher = AES.new(key, AES.MODE_GCM, nonce=nonce)
        ciphertext, tag = cipher.encrypt_and_digest(json_string.encode('utf-8'))
        return base64.b64encode(nonce + ciphertext + tag).decode('utf-8')

    def decrypt_payload(self, key_base64, encrypted_base64):
        """Decrypt AES-256-GCM base64 string.
        Wire format: base64(nonce[12] + ciphertext + tag[16]).
        Matches xxxEncryption(AesMode.GCM) in the gateway."""
        key = base64.b64decode(key_base64)
        raw = base64.b64decode(encrypted_base64)
        nonce = raw[:12]
        tag = raw[-16:]
        ciphertext = raw[12:-16]
        cipher = AES.new(key, AES.MODE_GCM, nonce=nonce)
        return cipher.decrypt_and_verify(ciphertext, tag).decode('utf-8')

