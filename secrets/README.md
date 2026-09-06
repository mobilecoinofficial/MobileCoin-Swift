## Secrets Motivation

This repo needs some "secrets" for the unit & integration tests to run. In the past we've been passing them around as tribal knowledge, but thats messy and error-prone. This PR addresses those problems by using asymmetric cryptography. 

All contributors to this repo will create a public/private keypair which will be stored in the macOS Keychain (`security`). New contributors will do this by running `scripts/generate_and_save_contributor_keys`. It will add the new public key to a file: `secrets/contributor_public_keys`. Then, they will check in that change, and ask an existing contributor to "re-encrypt" the secrets file with this additional public key. The "re-encryption" process creates an encrypted file that can be decrypted by any of the contributors (with their matching private key).

> Most importantly, how do we use these secrets ? 

`tools/generate_secrets_json.sh` decrypts them into `Tests/Common/Secrets/secrets.json`, and `tools/generate_process_info_jsons.sh` decrypts them into `tools/TestSetupClient/TestSetupClientTests/process_info.json`. The integration tests and the account funding tool read those two files at runtime. Both are gitignored.

### Notes

Im using this tool [$ age](https://github.com/FiloSottile/age) to do the encryption and decryption. The scripts will attempt to install it with brew (if necc.)

### Workflows

#### New Contributor

The new contributor checks out the repo and runs:

```bash
$ scripts/generate_and_save_contributor_keys

...

$ git add secrets/contributor_public_keys

...

$ git commit -m 'new contributor public key added, please re-encrypt the secrets for me'
```

Then an existing contributor checks out this change and runs:

```bash
$ scripts/reencrypt_secrets

...

$ git add secrets/keys.encrypted

...

$ git commit -m 'keys re-encrypted for new contributor'
```

#### Initial encryption workflow

To encrypt a local secrets file with all the contributor public keys, run:

```bash
$ scripts/encrypt_secrets_file ~/Desktop/keys.decrypted

...

$ git add secrets/keys.encrypted

...

$ git commit -m 'adding completely new secrets file, encrypted with all the contributor public keys'
```

#### Decrypt the secrets

To decrypt the secrets, and print them to `STDOUT`

```bash
$ scripts/decrypt_secrets
```

#### Write the local test resources

> Assume you've gone through new contributor flow

Each of these decrypts the secrets and writes the file its tests read.

```bash
$ make run-all-tests-spm          # writes secrets.json, then runs the full suite
$ make generate-local-process-info # writes process_info.json only
```
